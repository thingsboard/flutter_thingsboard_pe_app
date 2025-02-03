import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/notification/service/i_notifications_local_service.dart';
import 'package:thingsboard_app/modules/notification/service/notifications_local_service.dart';
import 'package:thingsboard_app/utils/utils.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart'; 


class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late NotificationDetails _notificationDetails;
  late TbLogger _log;
  late ThingsboardClient _tbClient;
  late TbContext _tbContext;
  final INotificationsLocalService _localService = NotificationsLocalService();
  StreamSubscription? _foregroundMessageSubscription;
  StreamSubscription? _onMessageOpenedAppSubscription;
  StreamSubscription? _onTokenRefreshSubscription;

  String? _fcmToken;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  factory NotificationService() => _instance;

  String getCusID() {
    final longCusID = _tbContext.userDetails!.customerId.toString();
    final customerIDonly = longCusID.substring(longCusID.indexOf('{') + 5, longCusID.indexOf('}'));
    return customerIDonly;
  }

  Future<void> init(
    ThingsboardClient tbClient,
    TbLogger log,
    TbContext context,
  ) async {
    _log = log;
    _tbClient = tbClient;
    _tbContext = context;

    _log.debug('NotificationService::init()');

    String customerIDonly = getCusID();

    await FirebaseMessaging.instance.subscribeToTopic(
      customerIDonly,
      // 'ttt'
    );

    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      NotificationService.handleClickOnNotification(
        message.data,
        _tbContext,
      );
    }

    _onMessageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        NotificationService.handleClickOnNotification(
          message.data,
          _tbContext,
        );
      },
    );

    final settings = await _requestPermission();
    _log.debug(
        'Notification authorizationStatus: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _getAndSaveToken(context.userDetails!.email, customerIDonly);

      _onTokenRefreshSubscription =
          FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (_fcmToken != null) {
          _tbClient.getUserService().removeMobileSession(_fcmToken!).then((_) {
            _fcmToken = token;
            if (_fcmToken != null) {
              _saveToken(_fcmToken!, context.userDetails!.email, customerIDonly);
            }
          });
        }
      });

      await _initFlutterLocalNotificationsPlugin();
      await _configFirebaseMessaging();
      _subscribeOnForegroundMessage();
      await updateNotificationsCount();
    }
  }

  Future<void> updateNotificationsCount() async {
    final localService = NotificationsLocalService();

    await localService.updateNotificationsCount(
      await _getNotificationsCountRemote(),
    );
  }

  Future<String?> getToken() async {
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  Future<RemoteMessage?> initialMessage() async {
    return _messaging.getInitialMessage();
  }

  Future<void> logout() async {
    getIt<TbLogger>().debug('NotificationService::logout()');
    if (_fcmToken != null) {
      getIt<TbLogger>().debug(
        'NotificationService::logout() removeMobileSession',
      );
      _tbClient.getUserService().removeMobileSession(_fcmToken!);
    }

    await _foregroundMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();
    await _onTokenRefreshSubscription?.cancel();
    await _messaging.deleteToken();
    await _messaging.setAutoInitEnabled(false);
    await flutterLocalNotificationsPlugin.cancelAll();
    await _localService.clearNotificationBadgeCount();

    FirebaseFirestore db = FirebaseFirestore.instance;


    String CustomerID = getCusID();

    db.collection(CustomerID).where('token', isEqualTo: _fcmToken).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    await FirebaseMessaging.instance.unsubscribeFromTopic(CustomerID);
  }

  Future<void> _configFirebaseMessaging() async {
    await _messaging.setAutoInitEnabled(true);
  }

  Future<void> _initFlutterLocalNotificationsPlugin() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/thingsboard');

    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
          final data = json.decode(response.payload ?? '');
          handleClickOnNotification(data, _tbContext);
        }
      },
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'general',
      'General notifications',
      importance: Importance.max,
      priority: Priority.high,
      channelDescription: 'This channel is used for general notifications',
      showWhen: false,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    _notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  Future<NotificationSettings> _requestPermission() async {
    _messaging = FirebaseMessaging.instance;
    final result = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (result.authorizationStatus == AuthorizationStatus.denied) {
      return result;
    }

    return result;
  }

  Future<String?> _resetToken(String? token, String CustomerID) async {
    if (token != null) {
      _tbClient.getUserService().removeMobileSession(token);
    }

    FirebaseFirestore db = FirebaseFirestore.instance;

    db.collection(CustomerID).where('token', isEqualTo: token).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    await _messaging.deleteToken();
    return await getToken();
  }

  Future<void> _getAndSaveToken(String email, String CustomerID) async {
    String? fcmToken = await getToken();
    _log.debug('FCM token: $fcmToken');

    if (fcmToken != null) {
      MobileSessionInfo? mobileInfo =
          await _tbClient.getUserService().getMobileSession(fcmToken);
      if (mobileInfo != null) {
        int timeAfterCreatedToken = DateTime.now().millisecondsSinceEpoch -
            mobileInfo.fcmTokenTimestamp;
        if (
          // timeAfterCreatedToken > Duration(days: 30).inMilliseconds
          true
        ) {
          fcmToken = await _resetToken(fcmToken, CustomerID);
          if (fcmToken != null) {
            await _saveToken(fcmToken, email, CustomerID);
          }
        }
      } else {
        await _saveToken(fcmToken, email, CustomerID);
      }
    }
  }

  Future<void> _saveToken(String token, String email, String CustomerID) async {
    await _tbClient.getUserService().saveMobileSession(
        token, MobileSessionInfo(DateTime.now().millisecondsSinceEpoch));

    final user = <String, dynamic>{
      "email": email,
      "token": token,
    };

    FirebaseFirestore db = FirebaseFirestore.instance;

    db.collection(CustomerID).add(user).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));
  }

  void showNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        _notificationDetails,
        payload: json.encode(message.data),
      );

      _localService.increaseNotificationBadgeCount();
    }
  }

  void _subscribeOnForegroundMessage() {
    _foregroundMessageSubscription =
        FirebaseMessaging.onMessage.listen((message) {
      _log.debug('Message:' + message.toString());
      if (message.sentTime == null) {
        final map = message.toMap();
        map['sentTime'] = DateTime.now().millisecondsSinceEpoch;
        showNotification(RemoteMessage.fromMap(map));
      } else {
        showNotification(message);
      }
    });
  }

  static void handleClickOnNotification(
    Map<String, dynamic> data,
    TbContext tbContext,
  ) {
    if (data['enabled'] == true || data['onClick.enabled'] == 'true') {
      switch (data['linkType'] ?? data['onClick.linkType']) {
        case 'DASHBOARD':
          final dashboardId =
              data['dashboardId'] ?? data['onClick.dashboardId'];
          var entityId;
          if ((data['stateEntityId'] ?? data['onClick.stateEntityId']) !=
                  null &&
              (data['stateEntityType'] ?? data['onClick.stateEntityType']) !=
                  null) {
            entityId = EntityId.fromTypeAndUuid(
              entityTypeFromString(
                  data['stateEntityType'] ?? data['onClick.stateEntityType']),
              data['stateEntityId'] ?? data['onClick.stateEntityId'],
            );
          }

          final state = Utils.createDashboardEntityState(
            entityId,
            stateId: data['dashboardState'] ?? data['onClick.dashboardState'],
          );

          if (dashboardId != null) {
            tbContext.navigateToDashboard(dashboardId, state: state);
          }

          break;
        case 'LINK':
          final link = data['link'] ?? data['onClick.link'];
          if (link != null) {
            if (Uri.parse(link).isAbsolute) {
              tbContext.navigateTo('/url/${Uri.encodeComponent(link)}');
            } else {
              tbContext.navigateTo(link);
            }
          }

          break;
      }
    } else {
      tbContext.navigateTo('/notifications', replace: true);
    }
  }

  Future<int> _getNotificationsCountRemote() async {
    try {
      return _tbClient
          .getNotificationService()
          .getUnreadNotificationsCount('MOBILE_APP');
    } catch (_) {
      return 0;
    }
  }
}
