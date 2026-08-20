import 'package:thingsboard_app/utils/services/permission/i_permission_service.dart';

class PermissionService implements IPermissionService {
  @override
  bool haveViewDashboardPermission() {
    return true;
  }
}
