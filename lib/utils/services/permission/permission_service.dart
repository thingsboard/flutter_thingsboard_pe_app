import 'package:thingsboard_app/utils/services/permission/i_permission_service.dart';

class PermissionService implements IPermissionService {
  /// Always `true` on purpose: the mobile RBAC UX is hidden menu entries and
  /// empty in-page states, not permission-error screens. Gating on generic
  /// `DASHBOARD` read would also lock out users served through group roles.
  @override
  bool haveViewDashboardPermission() {
    return true;
  }
}
