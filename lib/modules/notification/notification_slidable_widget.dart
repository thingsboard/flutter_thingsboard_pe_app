import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/modules/notification/notification_model.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

class NotificationSlidableWidget extends StatefulWidget {
  const NotificationSlidableWidget({
    required this.child,
    required this.notification,
    required this.thingsboardClient,
    required this.onClearNotification,
    required this.onReadNotification,
    required this.tbContext,
  });

  final Widget child;
  final NotificationModel notification;
  final ThingsboardClient thingsboardClient;
  final ValueChanged<String> onClearNotification;
  final ValueChanged<String> onReadNotification;
  final TbContext tbContext;

  @override
  State<StatefulWidget> createState() => _NotificationSlidableWidget();
}

class _NotificationSlidableWidget extends State<NotificationSlidableWidget> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 134,
        alignment: Alignment.center,
        child: RefreshProgressIndicator(),
      );
    }

    return Slidable(
      key: ValueKey(widget.notification.message.messageId),
      child: widget.child,
      startActionPane: widget.notification.read
          ? null
          : ActionPane(
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => widget.onReadNotification(
                    widget.notification.message.messageId!,
                  ),
                  backgroundColor: Color(0xFF198038),
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  label: 'Mark as read',
                  borderRadius: BorderRadius.circular(8),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
      endActionPane: ActionPane(
        extentRatio: _endExtentRatio(widget.notification),
        motion: const ScrollMotion(),
        children: [
          ..._buildAlarmRelatedButtons(widget.notification),
          SlidableAction(
            onPressed: (context) {
              widget.onClearNotification(
                widget.notification.message.messageId!,
              );
            },
            backgroundColor: Color(0xFFD12730).withOpacity(0.94),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: _buildAlarmRelatedButtons(widget.notification).isEmpty
                ? BorderRadius.circular(8)
                : BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlarmRelatedButtons(NotificationModel notification) {
    final items = <Widget>[];

    final type = notification.message.data['notificationType'];
    if (type?.toUpperCase().contains('ALARM') == true) {
      final status = AlarmStatus.values.byName(
        notification.message.data['info.alarmStatus'],
      );
      final id = notification.message.data['info.alarmId'];

      if ([AlarmStatus.CLEARED_UNACK, AlarmStatus.ACTIVE_UNACK]
          .contains(status)) {
        items.add(
          SlidableAction(
            onPressed: (context) => _ackAlarm(id, context),
            backgroundColor: Color(0xFF198038),
            foregroundColor: Colors.white,
            icon: Icons.done,
            label: 'Acknowledge',
            padding: const EdgeInsets.symmetric(horizontal: 4),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
        );
      }

      if ([AlarmStatus.ACTIVE_UNACK, AlarmStatus.ACTIVE_ACK].contains(status)) {
        items.add(
          SlidableAction(
            onPressed: (context) => _clearAlarm(id, context),
            backgroundColor: Color(0xFF757575),
            foregroundColor: Colors.white,
            icon: Icons.clear,
            label: 'Clear',
            borderRadius: items.isEmpty
                ? BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  )
                : BorderRadius.zero,
          ),
        );
      }
    }

    return items;
  }

  _ackAlarm(String alarmId, BuildContext context) async {
    final res = await widget.tbContext.confirm(
        title: '${S.of(context).alarmAcknowledgeTitle}',
        message: '${S.of(context).alarmAcknowledgeText}',
        cancel: '${S.of(context).No}',
        ok: '${S.of(context).Yes}');

    if (res != null && res) {
      setState(() {
        loading = true;
      });
      try {
        await widget.thingsboardClient.getAlarmService().ackAlarm(alarmId);
        final newAlarm = await widget.thingsboardClient
            .getAlarmService()
            .getAlarmInfo(alarmId);

        widget.notification.message.data['info.alarmStatus'] =
            newAlarm!.status!.name;
      } catch (_) {}

      setState(() {
        loading = false;
        widget.onReadNotification(widget.notification.message.messageId!);
      });
    }
  }

  _clearAlarm(String alarmId, BuildContext context) async {
    final res = await widget.tbContext.confirm(
        title: '${S.of(context).alarmClearTitle}',
        message: '${S.of(context).alarmClearText}',
        cancel: '${S.of(context).No}',
        ok: '${S.of(context).Yes}');
    if (res != null && res) {
      setState(() {
        loading = true;
      });

      try {
        await widget.thingsboardClient.getAlarmService().clearAlarm(alarmId);
        final newAlarm = await widget.thingsboardClient
            .getAlarmService()
            .getAlarmInfo(alarmId);

        widget.notification.message.data['info.alarmStatus'] =
            newAlarm!.status!.name;
      } catch (_) {}

      setState(() {
        loading = false;
        widget.onReadNotification(widget.notification.message.messageId!);
      });
    }
  }

  double _endExtentRatio(NotificationModel notification) {
    final items = _buildAlarmRelatedButtons(notification);
    if (items.isEmpty) {
      return 0.27;
    } else if (items.length == 1) {
      return 0.53;
    }

    return 0.8;
  }
}
