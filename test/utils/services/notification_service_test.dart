import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thingsboard_app/modules/notification/service/i_notifications_local_service.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/notification_service.dart';

import '../../helpers/test_dependencies.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotificationsLocalService extends Mock
    implements INotificationsLocalService {}

class MockUserControllerApi extends Mock implements UserControllerApi {}

void main() {
  late MockFirebaseMessaging messaging;
  late MockFlutterLocalNotificationsPlugin localNotificationsPlugin;
  late MockNotificationsLocalService localService;
  late MockLocalDatabaseService localDatabase;
  late MockFirebaseService firebaseService;
  late MockUserControllerApi userApi;

  NotificationService buildService() => NotificationService(
    messaging: messaging,
    localNotificationsPlugin: localNotificationsPlugin,
    localService: localService,
  );

  setUp(() {
    messaging = MockFirebaseMessaging();
    localNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    localService = MockNotificationsLocalService();
    localDatabase = MockLocalDatabaseService();
    firebaseService = MockFirebaseService();
    userApi = MockUserControllerApi();

    final tbClient = MockThingsboardClient();
    when(() => tbClient.getUserControllerApi()).thenReturn(userApi);
    when(() => firebaseService.apps).thenReturn(['[DEFAULT]']);
    when(() => messaging.deleteToken()).thenAnswer((_) async {});
    when(() => messaging.setAutoInitEnabled(any())).thenAnswer((_) async {});
    when(() => localNotificationsPlugin.cancelAll()).thenAnswer((_) async {});
    when(
      () => localService.clearNotificationBadgeCount(),
    ).thenAnswer((_) async {});
    when(() => localDatabase.clearPushRegistered()).thenAnswer((_) async {});

    registerTestDependencies(
      tbClient: tbClient,
      localDatabase: localDatabase,
      firebaseService: firebaseService,
    );
  });

  tearDown(resetTestDependencies);

  group('NotificationService.cleanUpStalePushRegistration', () {
    test('skips entirely when Firebase is not configured', () async {
      when(() => firebaseService.apps).thenReturn(const []);
      final service = buildService();

      await service.cleanUpStalePushRegistration();

      verifyNever(() => localDatabase.isPushRegistered());
      verifyNever(() => messaging.deleteToken());
    });

    test(
      'does nothing when push notifications were never registered',
      () async {
        when(
          () => localDatabase.isPushRegistered(),
        ).thenAnswer((_) async => false);
        final service = buildService();

        await service.cleanUpStalePushRegistration();

        verify(() => localDatabase.isPushRegistered()).called(1);
        verifyNever(() => messaging.deleteToken());
        verifyNever(() => localDatabase.clearPushRegistered());
      },
    );

    test('cleans up the local registration when the session expired '
        'after a login', () async {
      when(
        () => localDatabase.isPushRegistered(),
      ).thenAnswer((_) async => true);
      final service = buildService();

      await service.cleanUpStalePushRegistration();

      verify(() => messaging.deleteToken()).called(1);
      verify(() => messaging.setAutoInitEnabled(false)).called(1);
      verify(() => localNotificationsPlugin.cancelAll()).called(1);
      verify(() => localService.clearNotificationBadgeCount()).called(1);
      verify(() => localDatabase.clearPushRegistered()).called(1);
      verifyNever(
        () => userApi.removeMobileSession(
          xMobileToken: any(named: 'xMobileToken'),
        ),
      );
    });

    test('keeps the registration flag when the cleanup is interrupted, '
        'so it is retried on the next launch', () async {
      when(
        () => localDatabase.isPushRegistered(),
      ).thenAnswer((_) async => true);
      when(() => messaging.deleteToken()).thenThrow(Exception('no network'));
      final service = buildService();

      await service.cleanUpStalePushRegistration();

      verifyNever(() => localDatabase.clearPushRegistered());
    });
  });

  group('NotificationService.logout', () {
    Response<void> emptyResponse() =>
        Response<void>(requestOptions: RequestOptions());

    test('skips entirely when Firebase is not configured', () async {
      when(() => firebaseService.apps).thenReturn(const []);
      final service = buildService();

      await service.logout();

      verifyNever(() => messaging.deleteToken());
    });

    test('removes the mobile session and cleans up the local '
        'registration', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
      when(
        () => userApi.removeMobileSession(
          xMobileToken: any(named: 'xMobileToken'),
        ),
      ).thenAnswer((_) async => emptyResponse());
      final service = buildService();
      await service.getToken();

      await service.logout();

      verify(
        () => userApi.removeMobileSession(xMobileToken: 'fcm-token'),
      ).called(1);
      verify(() => messaging.deleteToken()).called(1);
      verify(() => localDatabase.clearPushRegistered()).called(1);
    });

    test('still cleans up when removeMobileSession fails '
        '(e.g. the JWT already expired)', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
      when(
        () => userApi.removeMobileSession(
          xMobileToken: any(named: 'xMobileToken'),
        ),
      ).thenThrow(Exception('401'));
      final service = buildService();
      await service.getToken();

      await service.logout();

      verify(() => messaging.deleteToken()).called(1);
      verify(() => localDatabase.clearPushRegistered()).called(1);
    });

    test('does not reuse the deleted FCM token on a repeated logout', () async {
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
      when(
        () => userApi.removeMobileSession(
          xMobileToken: any(named: 'xMobileToken'),
        ),
      ).thenAnswer((_) async => emptyResponse());
      final service = buildService();
      await service.getToken();

      await service.logout();
      await service.logout();

      verify(
        () => userApi.removeMobileSession(
          xMobileToken: any(named: 'xMobileToken'),
        ),
      ).called(1);
    });
  });
}
