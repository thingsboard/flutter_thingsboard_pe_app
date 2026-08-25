import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/local_database/local_database_service.dart';

import '../../helpers/test_dependencies.dart';

class MockTbStorage extends Mock implements TbStorage {}

void main() {
  late MockTbStorage storage;
  late LocalDatabaseService service;

  setUp(() {
    storage = MockTbStorage();
    service = LocalDatabaseService(storage: storage, logger: MockTbLogger());
  });

  // The literal key is asserted on purpose: it is the persisted contract, so
  // renaming the constant must fail these tests rather than drift silently.
  group('push registration flag', () {
    test('setPushRegistered stores the flag under the persisted key', () async {
      when(() => storage.setItem(any(), any())).thenAnswer((_) async {});

      await service.setPushRegistered();

      verify(
        () => storage.setItem('push_notifications_registered', true),
      ).called(1);
    });

    test('isPushRegistered checks the persisted key', () async {
      when(() => storage.containsKey(any())).thenAnswer((_) async => true);

      expect(await service.isPushRegistered(), isTrue);

      verify(
        () => storage.containsKey('push_notifications_registered'),
      ).called(1);
    });

    test('clearPushRegistered deletes the persisted key', () async {
      when(() => storage.deleteItem(any())).thenAnswer((_) async {});

      await service.clearPushRegistered();

      verify(
        () => storage.deleteItem('push_notifications_registered'),
      ).called(1);
    });
  });
}
