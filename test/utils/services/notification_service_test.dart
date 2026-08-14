import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/notification_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

class MockTbStorage extends Mock implements TbStorage {}

class MockTbClientService extends Mock implements ITbClientService {}

class MockThingsboardClient extends Mock implements ThingsboardClient {}

class TestableNotificationService extends NotificationService {
  int logoutCalls = 0;

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

void main() {
  late MockTbStorage storage;

  setUp(() {
    storage = MockTbStorage();
    final clientService = MockTbClientService();
    when(() => clientService.client).thenReturn(MockThingsboardClient());

    getIt
      ..registerLazySingleton(() => TbLogger())
      ..registerLazySingleton<TbStorage>(() => storage)
      ..registerLazySingleton<ITbClientService>(() => clientService);
  });

  tearDown(() => getIt.reset());

  group('NotificationService.handleSessionExpired', () {
    test(
      'does nothing when push notifications were never registered',
      () async {
        when(() => storage.getItem(any())).thenAnswer((_) async => null);
        final service = TestableNotificationService();

        await service.handleSessionExpired();

        expect(service.logoutCalls, 0);
      },
    );

    test(
      'cleans up the registration when the session expired after a login',
      () async {
        when(() => storage.getItem(any())).thenAnswer((_) async => 'true');
        final service = TestableNotificationService();

        await service.handleSessionExpired();

        expect(service.logoutCalls, 1);
      },
    );
  });
}
