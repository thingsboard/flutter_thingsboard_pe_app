import 'dart:async';

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

  /// Mounts the provider the way the app root does and returns its container.
  /// The container is disposed by the caller before the test ends, so the
  /// poll timer is cancelled before flutter_test checks for pending timers.
  Future<ProviderContainer> pumpWlProvider(
    WidgetTester tester, {
    void Function(WlState state)? onState,
  }) async {
    final container = ProviderContainer(
      overrides: [loginProvider.overrideWith(FakeLogin.new)],
    );
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
    container.listen(wlProvider, (_, next) => onState?.call(next));
    return container;
  }

  testWidgets('updateWhiteLabeling uses the client current at call time, '
      'not the one captured when the provider was built', (tester) async {
    final container = await pumpWlProvider(tester);
    final wl = container.read(wlProvider.notifier);

    // A QR-code login re-creates the client (TbClientService.reInit).
    when(() => clientService.client).thenReturn(liveClient);

    await wl.updateWhiteLabeling();

    verify(() => liveApi.getWhiteLabelParams()).called(1);
    verifyNever(() => staleApi.getWhiteLabelParams());
    expect(container.read(wlProvider).isUserWlMode, isTrue);
    container.dispose();
  });

  group('polling (PROD-8928)', () {
    setUp(() {
      when(() => clientService.client).thenReturn(liveClient);
    });

    testWidgets('re-fetches white-labeling every 30 seconds', (tester) async {
      final container = await pumpWlProvider(tester);

      await tester.pump(const Duration(seconds: 29));
      verifyNever(() => liveApi.getWhiteLabelParams());

      await tester.pump(const Duration(seconds: 1));
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      await tester.pump(const Duration(seconds: 30));
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      container.dispose();
    });

    testWidgets('does not poll while the app is in the background', (
      tester,
    ) async {
      final container = await pumpWlProvider(tester);

      // A real device reports every intermediate state (the engine message
      // path fills them in); calling the binding directly does not.
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump(const Duration(minutes: 5));
      verifyNever(() => liveApi.getWhiteLabelParams());

      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump(const Duration(seconds: 30));
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      container.dispose();
    });

    testWidgets('an unchanged response does not emit a new state', (
      tester,
    ) async {
      var emissions = 0;
      final container = await pumpWlProvider(
        tester,
        onState: (_) => emissions++,
      );

      await tester.pump(const Duration(seconds: 30));
      final emissionsAfterFirstLoad = emissions;
      expect(emissionsAfterFirstLoad, greaterThan(0));

      await tester.pump(const Duration(seconds: 30));
      verify(() => liveApi.getWhiteLabelParams()).called(2);
      expect(emissions, emissionsAfterFirstLoad);
      container.dispose();
    });

    testWidgets('a changed response is applied', (tester) async {
      final container = await pumpWlProvider(tester);
      await tester.pump(const Duration(seconds: 30));

      when(() => liveApi.getWhiteLabelParams()).thenAnswer(
        (_) async => Response(
          data: WhiteLabelingParams(
            (b) =>
                b
                  ..logoImageUrl = defaultLogoUrl
                  ..appTitle = 'Acme IoT',
          ),
          requestOptions: RequestOptions(),
        ),
      );
      await tester.pump(const Duration(seconds: 30));

      expect(container.read(wlProvider).wlParams.appTitle, 'Acme IoT');
      container.dispose();
    });

    testWidgets('a failed poll is swallowed and polling continues', (
      tester,
    ) async {
      final container = await pumpWlProvider(tester);
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenThrow(ThingsboardError(message: 'Network error'));

      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 30));

      verify(() => liveApi.getWhiteLabelParams()).called(2);
      container.dispose();
    });

    testWidgets('skips a tick while the previous fetch is still running', (
      tester,
    ) async {
      final slowResponse = Completer<Response<WhiteLabelingParams>>();
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) => slowResponse.future);
      final container = await pumpWlProvider(tester);

      await tester.pump(const Duration(seconds: 90));
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      slowResponse.complete(
        Response(
          data: WhiteLabelingParams((b) => b..logoImageUrl = defaultLogoUrl),
          requestOptions: RequestOptions(),
        ),
      );
      await tester.pump(const Duration(seconds: 30));
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      container.dispose();
    });
  });
}
