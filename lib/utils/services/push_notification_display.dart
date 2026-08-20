import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thingsboard_app/config/themes/app_colors.dart';
import 'package:thingsboard_app/modules/notification/widgets/notification_icon.dart';
import 'package:thingsboard_app/utils/services/notification_icon_renderer.dart';

/// Shows a push message as a local notification when the app is in the
/// background or terminated. The FCM SDK's default tray notification is
/// suppressed natively ([TbFirebaseMessagingService] strips the notification
/// payload from the intent), so this handler is the only place such messages
/// are rendered — with the icon configured in the notification template.
///
/// Must be a top-level function annotated with `vm:entry-point`: it runs in
/// a dedicated background isolate without the app's DI, and the plugin
/// resolves it by its callback handle.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await PushNotificationDisplay.initialize();
  await PushNotificationDisplay.show(message);
}

/// Renders push messages via flutter_local_notifications. Kept free of GetIt
/// and Hive dependencies so it can run both in the main isolate and in the
/// Firebase messaging background isolate.
abstract final class PushNotificationDisplay {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize({
    FlutterLocalNotificationsPlugin? plugin,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@drawable/ic_launcher_foreground',
      ),
      iOS: DarwinInitializationSettings(),
    );

    await (plugin ?? PushNotificationDisplay.plugin).initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static Future<void> show(
    RemoteMessage message, {
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    await (plugin ?? PushNotificationDisplay.plugin).show(
      notification.hashCode,
      notification.title,
      notification.body,
      await _detailsFor(message),
      payload: json.encode(message.data),
    );
  }

  static Future<NotificationDetails> _detailsFor(RemoteMessage message) async {
    final defaultDetails = NotificationDetails(
      android: _androidDetails(),
      iOS: const DarwinNotificationDetails(),
    );

    if (message.data['icon.enabled']?.toString() != 'true') {
      return defaultDetails;
    }

    final icon = toNotificationIconData(message.data['icon.icon']?.toString());
    if (icon == null) {
      return defaultDetails;
    }

    try {
      final color = toNotificationIconColor(
        message.data['icon.color']?.toString(),
      );
      final iconBytes = await NotificationIconRenderer.renderPng(icon, color);
      if (iconBytes == null) {
        return defaultDetails;
      }

      return NotificationDetails(
        android: _androidDetails(largeIcon: ByteArrayAndroidBitmap(iconBytes)),
        iOS:
            Platform.isIOS
                ? DarwinNotificationDetails(
                  attachments: [
                    DarwinNotificationAttachment(
                      await _saveIconFile(iconBytes),
                    ),
                  ],
                )
                : null,
      );
    } catch (e) {
      debugPrint('PushNotificationDisplay::_detailsFor $e');
      return defaultDetails;
    }
  }

  static AndroidNotificationDetails _androidDetails({
    AndroidBitmap<Object>? largeIcon,
  }) {
    return AndroidNotificationDetails(
      color: AppColors.appPrimaryColor,
      'general',
      // translate-me-ignore-next-line
      'General notifications',
      importance: Importance.max,
      priority: Priority.high,
      // translate-me-ignore-next-line
      channelDescription: 'This channel is used for general notifications',
      showWhen: false,
      largeIcon: largeIcon,
    );
  }

  static Future<String> _saveIconFile(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/notification_icon_'
      '${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
