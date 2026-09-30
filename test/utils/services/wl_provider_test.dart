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

void main() {
  late MockTbClientService clientService;
  late MockThingsboardClient liveClient;
  late MockWhiteLabelingControllerApi staleApi;
  late MockWhiteLabelingControllerApi liveApi;

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
    when(() => liveApi.getWhiteLabelParams()).thenAnswer(
      (_) async => Response(
        data: WhiteLabelingParams((b) => b..logoImageUrl = defaultLogoUrl),
        requestOptions: RequestOptions(),
      ),
    );

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

  testWidgets('updateWhiteLabeling uses the client current at call time, '
      'not the one captured when the provider was built', (tester) async {
    final container = ProviderContainer(
      overrides: [loginProvider.overrideWith(FakeLogin.new)],
    );
    addTearDown(container.dispose);
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
    final wl = container.read(wlProvider.notifier);

    // A QR-code login re-creates the client (TbClientService.reInit).
    when(() => clientService.client).thenReturn(liveClient);

    await wl.updateWhiteLabeling();

    verify(() => liveApi.getWhiteLabelParams()).called(1);
    verifyNever(() => staleApi.getWhiteLabelParams());
    expect(container.read(wlProvider).isUserWlMode, isTrue);
  });
}
