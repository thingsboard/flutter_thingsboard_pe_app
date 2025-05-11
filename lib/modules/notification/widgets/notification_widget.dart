import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/modules/alarm/alarms_base.dart';
import 'package:thingsboard_app/modules/notification/widgets/notification_icon.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../constants/app_constants.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    required this.notification,
    required this.thingsboardClient,
    required this.onClearNotification,
    required this.onReadNotification,
    required this.tbContext,
    super.key,
  });

  final PushNotification notification;
  final ThingsboardClient thingsboardClient;
  final Function(String id, bool readed) onClearNotification;
  final ValueChanged<String> onReadNotification;
  final TbContext tbContext;

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(notification.createdTime!),
    );

    final severity = notification.info?.alarmSeverity;

    return InkWell(
      onTap: () {
        NotificationService.handleClickOnNotification(
          notification.additionalConfig?['onClick'] ?? {},
          tbContext,
          isOnNotificationsScreenAlready: true,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: notification.info?.alarmSeverity != null
              ? Border.all(
                  color: alarmSeverityColors[notification.info?.alarmSeverity]!,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: notification.status !=
                      PushNotificationStatus.READ,
                  child: const Icon(Icons.circle,size: 20,color: ThingsboardAppConstants.primaryColor,),
                ),
                Visibility(
                  visible: severity != null,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          alarmSeverityColors[severity]?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      alarmSeverityTranslations[severity] ?? '',
                      style: TextStyle(
                        color: alarmSeverityColors[AlarmSeverity.CRITICAL]!,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      notification.subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Text(
                  timeago.format(
                    DateTime.now().subtract(diff),
                    locale: 'en_short',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 5,),
            const Divider(thickness: 1,),
            Html(
              data: notification.text,
            ),
            if(notification.status != PushNotificationStatus.READ)
              const SizedBox(height: 16,),
            if(notification.status != PushNotificationStatus.READ)
              InkWell(
              onTap: () => onReadNotification(
                notification.id!.id!,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white
                ),
                child: const Text('Mark As Read',style: TextStyle(fontWeight: FontWeight.w500),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
