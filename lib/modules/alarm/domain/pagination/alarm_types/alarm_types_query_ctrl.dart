import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

class AlarmTypesQueryCtrl extends PageKeyController<PageLink> {
  AlarmTypesQueryCtrl({int pageSize = 20, String? searchText})
      : super(
          PageLink(
            pageSize,
            0,
            searchText,
          ),
        );

  @override
  PageLink nextPageKey(PageLink pageKey) {
    return pageKey.nextPageLink();

    // return PushNotificationQuery(
    //   pageKey.pageLink.nextPageLink(),
    //   unreadOnly: value.pageKey.unreadOnly,
    // );
  }

  // void onSearchText(String searchText) {
  //   final query = value.pageKey;
  //   query.page = 0;
  //   query.textSearch = searchText;
  //
  //   notifyListeners();
  // }

  void refresh() {
    notifyListeners();
  }
}
