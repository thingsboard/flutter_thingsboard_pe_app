import 'package:flutter_test/flutter_test.dart';
import 'package:thingsboard_app/core/auth/login/models/login_state.dart';
import 'package:thingsboard_app/modules/main/providers/navigation_helper.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/layouts/pages_layout.dart';

import 'navigation_test_utils.dart';

const builtInPages = [
  Pages.home,
  Pages.alarms,
  Pages.devices,
  Pages.customers,
  Pages.assets,
  Pages.audit_logs,
  Pages.notifications,
  Pages.device_list,
  Pages.dashboards,
  Pages.live_location_tracking,
];

const sysAdminPages = {Pages.home, Pages.notifications, Pages.audit_logs};

Set<Pages> visibleBuiltInPages(LoginState login) => {
  for (final id in builtInPages)
    if (NavigationHelper.isPageVisible(PageLayout(id: id), login)) id,
};

void expectCustomPagesVisible(LoginState login) {
  for (final page in customPages) {
    expect(
      NavigationHelper.isPageVisible(page, login),
      isTrue,
      reason: page.label,
    );
  }
}

void main() {
  group('NavigationHelper.isPageVisible', () {
    group('sysadmin', () {
      // What the server grants SYS_ADMIN generically, ALARM and DASHBOARD
      // read included, although the tenant list endpoints reject sysadmins.
      final sysAdmin = loginAs(
        Authority.SYS_ADMIN,
        permissions({
          Resource.ALARM: {Operation.READ},
          Resource.DASHBOARD: {Operation.READ},
          Resource.AUDIT_LOG: {Operation.READ},
          Resource.ALL: {Operation.ALL},
        }),
      );

      test('shows only the allowlisted built-in pages', () {
        expect(visibleBuiltInPages(sysAdmin), sysAdminPages);
      });

      test('shows custom pages', () {
        expectCustomPagesVisible(sysAdmin);
      });

      test('applies the allowlist before permissions are loaded', () {
        expect(
          visibleBuiltInPages(loginAs(Authority.SYS_ADMIN)),
          sysAdminPages,
        );
      });
    });

    test('tenant admin with full permissions sees every page', () {
      expect(visibleBuiltInPages(fullAccessTenantAdmin), builtInPages.toSet());
      expectCustomPagesVisible(fullAccessTenantAdmin);
    });

    test('customer user sees pages backed by their permissions', () {
      final customerUser = loginAs(
        Authority.CUSTOMER_USER,
        permissions(
          {
            Resource.ALARM: {Operation.READ},
          },
          sharedGroups: {EntityType.DEVICE, EntityType.DASHBOARD},
        ),
      );

      expect(visibleBuiltInPages(customerUser), {
        Pages.home,
        Pages.alarms,
        Pages.notifications,
        Pages.device_list,
        Pages.dashboards,
        Pages.live_location_tracking,
      });
      expectCustomPagesVisible(customerUser);
    });

    test('non-sysadmin pages fail open before permissions are loaded', () {
      expect(
        visibleBuiltInPages(loginAs(Authority.CUSTOMER_USER)),
        builtInPages.toSet(),
      );
    });
  });
}
