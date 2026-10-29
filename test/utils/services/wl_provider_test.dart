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

  void logOut() => state = const LoginState(isUserLoaded: false);
}

Response<WhiteLabelingParams> wlResponse([
  void Function(WhiteLabelingParamsBuilder b)? update,
]) => Response(
  data: WhiteLabelingParams((b) {
    b.logoImageUrl = defaultLogoUrl;
    update?.call(b);
  }),
  requestOptions: RequestOptions(),
);

Response<LoginWhiteLabelingParams> loginWlResponse() => Response(
  data: LoginWhiteLabelingParams((b) => b..logoImageUrl = defaultLogoUrl),
  requestOptions: RequestOptions(),
);

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
    when(
      () => liveApi.getWhiteLabelParams(),
    ).thenAnswer((_) async => wlResponse());

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

  // A real device reports every intermediate state (the engine message path
  // fills them in); calling the binding directly does not.
  void sendToBackground(WidgetTester tester) {
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
  }

  void bringToForeground(WidgetTester tester) {
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
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

    testWidgets('re-fetches white-labeling every poll interval', (
      tester,
    ) async {
      final container = await pumpWlProvider(tester);

      await tester.pump(wlPollInterval - const Duration(seconds: 1));
      verifyNever(() => liveApi.getWhiteLabelParams());

      await tester.pump(const Duration(seconds: 1));
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      container.dispose();
    });

    testWidgets('does not poll while the app is in the background', (
      tester,
    ) async {
      final container = await pumpWlProvider(tester);

      sendToBackground(tester);
      await tester.pump(wlPollInterval * 10);
      verifyNever(() => liveApi.getWhiteLabelParams());

      bringToForeground(tester);
      // Coming back to the foreground fetches right away, then on schedule.
      await tester.pump();
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      await tester.pump(wlPollInterval);
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

      await tester.pump(wlPollInterval);
      final emissionsAfterFirstLoad = emissions;
      expect(emissionsAfterFirstLoad, 1);

      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(2);
      expect(emissions, emissionsAfterFirstLoad);
      container.dispose();
    });

    testWidgets('a changed response is applied', (tester) async {
      final container = await pumpWlProvider(tester);
      await tester.pump(wlPollInterval);

      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) async => wlResponse((b) => b.appTitle = 'Acme IoT'));
      await tester.pump(wlPollInterval);

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

      await tester.pump(wlPollInterval);
      await tester.pump(wlPollInterval);

      verify(() => liveApi.getWhiteLabelParams()).called(2);
      container.dispose();
    });

    testWidgets('coming back to the foreground does not start a second '
        'fetch while the previous one is still running', (tester) async {
      final slowResponse = Completer<Response<WhiteLabelingParams>>();
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) => slowResponse.future);
      final container = await pumpWlProvider(tester);

      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      sendToBackground(tester);
      bringToForeground(tester);
      await tester.pump();
      verifyNever(() => liveApi.getWhiteLabelParams());

      slowResponse.complete(wlResponse());
      await tester.pump();
      container.dispose();
    });

    testWidgets('a request that never completes does not stop polling', (
      tester,
    ) async {
      // What a stalled connection looks like: the client has no receive
      // timeout, so the request neither completes nor fails.
      final hungResponse = Completer<Response<WhiteLabelingParams>>();
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) => hungResponse.future);
      final container = await pumpWlProvider(tester);

      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) async => wlResponse());
      // The hung fetch is given up after wlFetchTimeout, so the next tick
      // fetches again.
      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(1);
      container.dispose();
    });

    testWidgets('a timed-out response landing after a newer one does not '
        'bring back the older white-labeling', (tester) async {
      final staleResponse = Completer<Response<WhiteLabelingParams>>();
      final responses = [
        staleResponse.future,
        Future.value(wlResponse((b) => b.appTitle = 'Fresh')),
      ];
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) => responses.removeAt(0));
      final container = await pumpWlProvider(tester);

      await tester.pump(wlPollInterval);
      await tester.pump(wlPollInterval);
      expect(container.read(wlProvider).wlParams.appTitle, 'Fresh');

      staleResponse.complete(wlResponse((b) => b.appTitle = 'Stale'));
      await tester.pump();
      await tester.pump();

      expect(container.read(wlProvider).wlParams.appTitle, 'Fresh');
      container.dispose();
    });

    testWidgets('a user response landing after a logout does not replace '
        'the login white-labeling', (tester) async {
      final slowUserResponse = Completer<Response<WhiteLabelingParams>>();
      when(
        () => liveApi.getWhiteLabelParams(),
      ).thenAnswer((_) => slowUserResponse.future);
      when(
        () => liveApi.getLoginWhiteLabelParams(),
      ).thenAnswer((_) async => loginWlResponse());
      final container = await pumpWlProvider(tester);

      await tester.pump(wlPollInterval);
      verify(() => liveApi.getWhiteLabelParams()).called(1);

      (container.read(loginProvider.notifier) as FakeLogin).logOut();
      await tester.pump();
      await tester.pump();
      verify(() => liveApi.getLoginWhiteLabelParams()).called(1);
      expect(container.read(wlProvider).isUserWlMode, isFalse);

      slowUserResponse.complete(wlResponse((b) => b.appTitle = 'Stale'));
      await tester.pump();
      await tester.pump();

      expect(container.read(wlProvider).isUserWlMode, isFalse);
      expect(container.read(wlProvider).userParams.appTitle, isNot('Stale'));
      container.dispose();
    });
  });
}
