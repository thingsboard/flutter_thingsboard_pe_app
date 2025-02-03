import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/modules/notification/controllers/notification_query_ctrl.dart';
import 'package:thingsboard_app/modules/notification/repository/notification_pagination_repository.dart';
import 'package:thingsboard_app/modules/notification/repository/notification_repository.dart';
import 'package:thingsboard_app/modules/notification/service/notifications_local_service.dart';
import 'package:thingsboard_app/modules/notification/widgets/filter_segmented_button.dart';
import 'package:thingsboard_app/modules/notification/widgets/notification_list.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationsFilter { all, unread }

class NotificationPage extends TbPageWidget {
  NotificationPage(TbContext tbContext) : super(tbContext);

  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends TbPageState<NotificationPage> {
  NotificationsFilter notificationsFilter = NotificationsFilter.unread;
  late final NotificationPaginationRepository paginationRepository;
  final notificationQueryCtrl = NotificationQueryCtrl();
  late final NotificationRepository notificationRepository;
  Map<String, dynamic> data = Map();

  @override
  Widget build(BuildContext context) {
    final longCusID = widget.tbContext.userDetails!.customerId.toString();
    final customerIDonly = longCusID.substring(longCusID.indexOf('{') + 5, longCusID.indexOf('}'));
//     List<String> items = List<String>.generate(10000, (i) => 'Item $i');
    final db = FirebaseFirestore.instance;
    final col = db.collection(customerIDonly);
    final docu = col.doc('ntf');


    return RefreshIndicator(
      onRefresh: () async {
        Map<String, dynamic> _data = Map();
        await docu.get().then((DocumentSnapshot doc) => _data = doc.data() as Map<String, dynamic>);
        // _refresh();
        setState(() {data = _data;});
      },
      child: Scaffold(
        appBar: TbAppBar(
          tbContext,
          leading: IconButton(
            onPressed: () {
              final navigator = Navigator.of(tbContext.currentState!.context);
              if (navigator.canPop()) {
                tbContext.pop();
              } else {
                tbContext.navigateTo(
                  '/home',
                  replace: true,
                  transition: TransitionType.fadeIn,
                  transitionDuration: Duration(milliseconds: 750),
                );
              }
            },
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
            ),
          ),
          title: const Text('Notifications'),
          actions: [
            TextButton(
              child: Text('Mark all as read'),
              onPressed: () async {
                await notificationRepository.markAllAsRead();

                if (mounted) {
                  notificationQueryCtrl.refresh();
                }
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: data.length,
          prototypeItem: ListTile(
            title: Text('prototype'),
          ),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data.toString()),
            );
          },
        )
        
        
//         StreamBuilder( // to do
//           stream: NotificationsLocalService.notificationsNumberStream.stream,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               _refresh();
//             }
// 
//             return Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 5,
//                 vertical: 10,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 10, bottom: 20),
//                     child: FilterSegmentedButton( // start here, botton independent
//                       selected: notificationsFilter, // enum NotificationsFilter { all, unread }
//                       onSelectionChanged: (newSelection) {
//                         if (notificationsFilter == newSelection) {  // newSelection: all / unread Equality means no change on press, i.e. error
//                           return;
//                         }
// 
//                         setState(() {
//                           notificationsFilter = newSelection;
// 
//                           notificationRepository.filterByReadStatus( // filterByReadStatus(bool unreadOnly)
//                             notificationsFilter == NotificationsFilter.unread,
//                           );
//                         });
//                       },
//                       segments: [
//                         FilterSegments(
//                           label: 'Unread',
//                           value: NotificationsFilter.unread,
//                         ),
//                         FilterSegments(
//                           label: 'All',
//                           value: NotificationsFilter.all,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: NotificationsList( // key
//                       pagingController: paginationRepository.pagingController,
//                       thingsboardClient: tbClient,
//                       tbContext: tbContext,
//                       onClearNotification: (id, read) async {
//                         await notificationRepository.deleteNotification(id); // to do
//                         if (!read) {
//                           await notificationRepository
//                               .decreaseNotificationBadgeCount();
//                         }
// 
//                         if (mounted) {
//                           notificationQueryCtrl.refresh();
//                         }
//                       },
//                       onReadNotification: (id) async {
//                         await notificationRepository.markNotificationAsRead(id);
//                         await notificationRepository
//                             .decreaseNotificationBadgeCount();
// 
//                         if (mounted) {
//                           notificationQueryCtrl.refresh();
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
      ),
    );
  }

  @override
  void initState() {
    paginationRepository = NotificationPaginationRepository(
      tbClient: widget.tbContext.tbClient,
      notificationQueryPageCtrl: notificationQueryCtrl,
    )..init();

    notificationRepository = NotificationRepository(
      notificationQueryCtrl: notificationQueryCtrl,
      thingsboardClient: widget.tbContext.tbClient,
    );

    super.initState();
  }

  @override
  void dispose() {
    paginationRepository.dispose();
    notificationQueryCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (mounted) {
      notificationQueryCtrl.refresh();
    }
  }
}
