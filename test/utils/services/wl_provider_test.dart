import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thingsboard_app/config/routes/v2/router_2.dart';
import 'package:thingsboard_app/core/auth/login/models/login_state.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';
import 'package:thingsboard_app/core/select_region/model/region.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/utils/services/overlay_service/i_overlay_service.dart';
import 'package:thingsboard_app/utils/services/wl_provider.dart';

import '../../helpers/test_dependencies.dart';

class MockWhiteLabelingControllerApi extends Mock
    implements WhiteLabelingControllerApi {}

class MockOverlayService extends Mock implements IOverlayService {}

class MockDeviceInfoService extends Mock implements IDeviceInfoService {}

/// The white-labeling provider only asks the login state whether the user is
/// fully authenticated; the real notifier would start loading the user.
class FakeLogin extends Login {
  @override
  LoginState build() =>
      const LoginState(isUserLoaded: true, userScope: Authority.TENANT_ADMIN);
}

const systemInfoPath = '/api/system/info';

Response<WhiteLabelingParams> wlResponse(WhiteLabelingParams? params) =>
    Response(data: params, requestOptions: RequestOptions());

Response<Map<String, dynamic>> systemInfoResponse(String? version) => Response(
  data: {if (version != null) 'version': version, 'type': 'PE'},
  requestOptions: RequestOptions(),
);

void main() {
  late MockTbClientService clientService;
  late MockThingsboardClient liveClient;
  late MockWhiteLabelingControllerApi staleApi;
  late MockWhiteLabelingControllerApi liveApi;

  setUpAll(() => registerFallbackValue(Options()));

  Future<Response<Map<String, dynamic>>> systemInfoCall() =>
      liveClient.get<Map<String, dynamic>>(
        systemInfoPath,
        options: any(named: 'options'),
      );

  void stubSystemInfo(String? version) =>
      when(systemInfoCall).thenAnswer((_) async => systemInfoResponse(version));

  void stubSystemInfoFailure() =>
      when(systemInfoCall).thenThrow(ThingsboardError(message: 'Forbidden'));

  setUp(() {
    final staleClient = MockThingsboardClient();
    liveClient = MockThingsboardClient();
    staleApi = MockWhiteLabelingControllerApi();
    liveApi = MockWhiteLabelingControllerApi();
    when(
      () => staleClient.getWhiteLabelingControllerApi(),
    ).thenReturn(staleApi);
    when(() => liveClient.getWhiteLabelingControllerApi()).thenReturn(liveApi);
    // What HttpInterceptor.onRequest does on a client whose in-memory JWT is
    // null: the request is rejected before it leaves the device (PROD-8879).
    when(
      () => staleApi.getWhiteLabelParams(),
    ).thenThrow(ThingsboardError(message: 'Unauthorized!'));
    // What the server answers when no admin typed a platform version into the
    // white-labeling settings: the field is simply null.
    when(() => liveApi.getWhiteLabelParams()).thenAnswer(
      (_) async => wlResponse(
        WhiteLabelingParams((b) => b..logoImageUrl = defaultLogoUrl),
      ),
    );
    stubSystemInfo('4.4.0PE');

    final localDatabase = MockLocalDatabaseService();
    when(
      () => localDatabase.getSelectedRegion(),
    ).thenAnswer((_) async => Region.europe);
    clientService = registerTestDependencies(
      tbClient: staleClient,
      localDatabase: localDatabase,
      firebaseService: MockFirebaseService(),
    );
    // Resolved by Login's field initializers when FakeLogin is constructed.
    getIt
      ..registerLazySingleton<IOverlayService>(() => MockOverlayService())
      ..registerLazySingleton<IDeviceInfoService>(
        () => MockDeviceInfoService(),
      );
  });

  /// Mounts an app around the provider and returns the notifier, with the
  /// client service already handing out [liveClient].
  Future<Wl> pumpWlProvider(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    // _updateImages() resolves the global navigator context, so the
    // provider needs a mounted app around it.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalNavigatorKey,
          home: const SizedBox(),
        ),
      ),
    );
    // The provider is autoDispose; the app root keeps it alive with a watch,
    // which is what lets it outlive a client re-creation.
    container.listen(wlProvider, (_, _) {});
    when(() => clientService.client).thenReturn(liveClient);
    return container.read(wlProvider.notifier);
  }

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [loginProvider.overrideWith(FakeLogin.new)],
    );
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('updateWhiteLabeling uses the client current at call time, '
      'not the one captured when the provider was built', (tester) async {
    final container = makeContainer();
    final wl = await pumpWlProvider(tester, container);

    // A QR-code login re-creates the client (TbClientService.reInit).
    await wl.updateWhiteLabeling();

    verify(() => liveApi.getWhiteLabelParams()).called(1);
    verifyNever(() => staleApi.getWhiteLabelParams());
    expect(container.read(wlProvider).isUserWlMode, isTrue);
  });

  group('platform version', () {
    testWidgets('is taken from the running server when the white-label '
        'response leaves it null', (tester) async {
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).platformVersion, '4.4.0PE');
    });

    testWidgets('drops the -SNAPSHOT suffix of a development server build', (
      tester,
    ) async {
      stubSystemInfo('4.4.0PE-SNAPSHOT');
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).platformVersion, '4.4.0PE');
    });

    testWidgets('set by an admin is kept and the server is not asked', (
      tester,
    ) async {
      when(() => liveApi.getWhiteLabelParams()).thenAnswer(
        (_) async => wlResponse(
          WhiteLabelingParams(
            (b) =>
                b
                  ..logoImageUrl = defaultLogoUrl
                  ..platformVersion = 'Custom 1.0',
          ),
        ),
      );
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).platformVersion, 'Custom 1.0');
      verifyNever(
        () => liveClient.get<Map<String, dynamic>>(
          any(),
          options: any(named: 'options'),
        ),
      );
    });

    testWidgets('lookup failure does not break white-labeling loading', (
      tester,
    ) async {
      stubSystemInfoFailure();
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).isUserWlMode, isTrue);
      expect(container.read(wlProvider).platformNameAndVersion, 'ThingsBoard');
    });

    testWidgets('shows only the name when the server reports no version', (
      tester,
    ) async {
      stubSystemInfo(null);
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).platformNameAndVersion, 'ThingsBoard');
    });

    testWidgets('is taken from the running server when the white-label '
        'response has no body', (tester) async {
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) async => wlResponse(null));
      final container = makeContainer();
      final wl = await pumpWlProvider(tester, container);

      await wl.updateWhiteLabeling();

      expect(container.read(wlProvider).isUserWlMode, isTrue);
      expect(container.read(wlProvider).platformVersion, '4.4.0PE');
    });
  });
}
