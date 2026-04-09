import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:thingsboard_app/modules/notification/widgets/no_notifications_found_widget.dart';
import 'package:thingsboard_app/modules/notification/widgets/notification_slidable_widget.dart';
import 'package:thingsboard_app/modules/notification/widgets/notification_widget.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    required this.pagingController,
    required this.thingsboardClient,
    required this.onClearNotification,
    required this.onReadNotification,
    this.isSelectionMode = false,
    this.selectedIds = const {},
    this.onToggleSelection,
    this.onLongPress,
    super.key,
  });

  final ThingsboardClient thingsboardClient;
  final Function(String id, bool read) onClearNotification;
  final ValueChanged<String> onReadNotification;
  final bool isSelectionMode;
  final Set<String> selectedIds;
  final ValueChanged<String>? onToggleSelection;
  final ValueChanged<String>? onLongPress;

  final PagingController<PushNotificationQuery, PushNotification>
  pagingController;

  @override
  Widget build(BuildContext context) {
    return PagedListView<PushNotificationQuery, PushNotification>.separated(
      pagingController: pagingController,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          final id = item.id!.id!;
          return NotificationSlidableWidget(
            notification: item,
            onReadNotification: onReadNotification,
            onClearNotification: onClearNotification,
            isSelectionMode: isSelectionMode,
            thingsboardClient: thingsboardClient,
            child: NotificationWidget(
              notification: item,
              thingsboardClient: thingsboardClient,
              onClearNotification: onClearNotification,
              onReadNotification: onReadNotification,
              isSelectionMode: isSelectionMode,
              isSelected: selectedIds.contains(id),
              onToggleSelection: () => onToggleSelection?.call(id),
              onLongPress: () => onLongPress?.call(id),
            ),
          );
        },
        firstPageProgressIndicatorBuilder:
            (_) => const SizedBox.expand(
              child: ColoredBox(
                color: Color(0x99FFFFFF),
                child: Center(child: TbProgressIndicator(size: 50.0)),
              ),
            ),
        noItemsFoundIndicatorBuilder: (_) => const NoNotificationsFoundWidget(),
      ),
      separatorBuilder: (_, _) => const Divider(thickness: 1),
    );
  }
}
