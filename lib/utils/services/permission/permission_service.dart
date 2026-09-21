import 'package:thingsboard_app/utils/services/permission/i_permission_service.dart';

class PermissionService implements IPermissionService {
  /// Temporary stub, not a policy. The real check (PROD-6314, generic
  /// DASHBOARD read) was lost in the client migration when
  /// `TbContext.hasGenericPermission` went away. PROD-8771 restores it with
  /// `hasReadGenericOrSharedGroupsPermission(DASHBOARD, DASHBOARD)`, the gate
  /// the Dashboards menu item uses, so group-role users are not locked out.
  /// Until then the callers' `DashboardPermissionErrorView` branches are
  /// unreachable but not dead.
  @override
  bool haveViewDashboardPermission() {
    return true;
  }
}
