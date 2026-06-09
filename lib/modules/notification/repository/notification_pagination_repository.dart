import 'dart:async';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:thingsboard_app/modules/notification/controllers/notification_query_ctrl.dart';
import 'package:thingsboard_app/thingsboard_client.dart';

class NotificationPaginationRepository {
  NotificationPaginationRepository({
    required this.notificationQueryPageCtrl,
    required this.tbClient,
  });

  final NotificationQueryCtrl notificationQueryPageCtrl;
  final ThingsboardClient tbClient;
  late final PagingController<PushNotificationQuery, PushNotification>
  pagingController;

  void init() {
    pagingController =
        PagingController<PushNotificationQuery, PushNotification>(
          firstPageKey: notificationQueryPageCtrl.value.pageKey,
        );

    notificationQueryPageCtrl.addListener(_didChangePageKeyValue);
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  void dispose() {
    notificationQueryPageCtrl.removeListener(_didChangePageKeyValue);
    pagingController.dispose();
  }

  Future<void> _fetchPage(
    PushNotificationQuery pageKey, {
    bool refresh = false,
  }) async {
    try {
      final response = await tbClient
          .getNotificationControllerApi()
          .getNotifications(
            pageSize: pageKey.pageLink.pageSize,
            page: pageKey.pageLink.page,
            textSearch: pageKey.pageLink.textSearch,
            unreadOnly: pageKey.unreadOnly,
            deliveryMethod: pageKey.deliveryMethod,
          );

      final page = response.data!;
      final items = (page.data?.toList() ?? <Notification>[])
          .map((n) => _toPushNotification(n))
          .whereType<PushNotification>()
          .toList();

      final isLastPage = !(page.hasNext ?? false);
      if (refresh) {
        final state = pagingController.value;
        if (state.itemList != null) {
          state.itemList!.clear();
        }
      }
      if (isLastPage) {
        pagingController.appendLastPage(items);
      } else {
        final nextPageKey = notificationQueryPageCtrl.nextPageKey(pageKey);
        pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  PushNotification? _toPushNotification(Notification n) {
    try {
      final json = <String, dynamic>{
        'id': {'id': n.id?.id, 'entityType': 'NOTIFICATION'},
        'createdTime': n.createdTime,
        'requestId': {'id': n.requestId?.id ?? '', 'entityType': 'NOTIFICATION_REQUEST'},
        'recipientId': {'id': n.recipientId?.id ?? '', 'entityType': 'USER'},
        'subject': n.subject ?? '',
        'text': n.text ?? '',
        'type': n.type?.name ?? 'GENERAL',
        'status': n.status?.name ?? 'UNREAD',
        if (n.additionalConfig != null && n.additionalConfig!.isMap)
          'additionalConfig': n.additionalConfig!.asMap,
      };
      return PushNotification.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  void _didChangePageKeyValue() {
    _refreshPagingController();
  }

  void _refreshPagingController() {
    _fetchPage(notificationQueryPageCtrl.value.pageKey, refresh: true);
  }
}
