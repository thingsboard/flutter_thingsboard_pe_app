import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thingsboard_app/utils/services/push_notification_display.dart';

void main() {
  group('notificationIdFor', () {
    // Expected values are Java's String.hashCode, which the native side uses
    // (TbFirebaseMessagingService.notificationId), so the Dart re-post
    // replaces the plain notification instead of adding a second one.
    test('matches Java String.hashCode for a typical FCM message id', () {
      const message = RemoteMessage(
        messageId: '0:1760000000000000%6ed3e9f36ed3e9f3',
      );

      expect(notificationIdFor(message), 1487038457);
    });

    test('wraps to a signed 32-bit int like Java', () {
      const message = RemoteMessage(
        messageId: '0:1760000000000002%6ed3e9f36ed3e9f3',
      );

      expect(notificationIdFor(message), -507106249);
    });

    test('is stable for the same id', () {
      const message = RemoteMessage(messageId: 'abc');

      expect(notificationIdFor(message), 96354);
      expect(notificationIdFor(message), notificationIdFor(message));
    });

    test('falls back to the notification hash without a message id', () {
      const notification = RemoteNotification(title: 't', body: 'b');
      const message = RemoteMessage(notification: notification);

      expect(notificationIdFor(message), notification.hashCode);
    });
  });
}
