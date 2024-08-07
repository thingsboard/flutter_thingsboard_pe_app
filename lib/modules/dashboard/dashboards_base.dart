import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/entity/entities_base.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/widgets/dashboard_grid_card.dart';
import 'package:thingsboard_app/thingsboard_client.dart';

mixin DashboardsBase on EntitiesBase<DashboardInfo, PageLink> {
  @override
  String get title => 'Dashboards';

  @override
  String get noItemsFoundText => 'No dashboards found';

  @override
  Future<PageData<DashboardInfo>> fetchEntities(PageLink pageLink) {
    return tbClient
        .getDashboardService()
        .getUserDashboards(pageLink, mobile: true);
  }

  @override
  void onEntityTap(DashboardInfo dashboard) {
    if (hasGenericPermission(Resource.WIDGETS_BUNDLE, Operation.READ) &&
        hasGenericPermission(Resource.WIDGET_TYPE, Operation.READ)) {
      navigateToDashboard(dashboard.id!.id!, dashboardTitle: dashboard.title);
    } else {
      showErrorNotification(
        'You don\'t have permissions to perform this operation!',
      );
    }
  }

  @override
  Widget buildEntityListCard(BuildContext context, DashboardInfo dashboard) {
    return _buildEntityListCard(context, dashboard, false);
  }

  @override
  Widget buildEntityListWidgetCard(
    BuildContext context,
    DashboardInfo dashboard,
  ) {
    return _buildEntityListCard(context, dashboard, true);
  }

  @override
  EntityCardSettings entityGridCardSettings(DashboardInfo dashboard) =>
      EntityCardSettings(dropShadow: true); //dashboard.image != null);

  @override
  Widget buildEntityGridCard(BuildContext context, DashboardInfo dashboard) {
    return DashboardGridCard(tbContext, dashboard: dashboard);
  }

  Widget _buildEntityListCard(
    BuildContext context,
    DashboardInfo dashboard,
    bool listWidgetCard,
  ) {
    return Row(
      mainAxisSize: listWidgetCard ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Flexible(
          fit: listWidgetCard ? FlexFit.loose : FlexFit.tight,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: listWidgetCard ? 9 : 10,
              horizontal: 16,
            ),
            child: Row(
              mainAxisSize:
                  listWidgetCard ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Flexible(
                  fit: listWidgetCard ? FlexFit.loose : FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dashboard.title,
                          style: const TextStyle(
                            color: Color(0xFF282828),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.7,
                          ),
                        ),
                      ),
                      Text(
                        _dashboardDetailsText(dashboard),
                        style: const TextStyle(
                          color: Color(0xFFAFAFAF),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
                (!listWidgetCard
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            entityDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                dashboard.createdTime!,
                              ),
                            ),
                            style: const TextStyle(
                              color: Color(0xFFAFAFAF),
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              height: 1.33,
                            ),
                          ),
                        ],
                      )
                    : Container()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dashboardDetailsText(DashboardInfo dashboard) {
    if (tbClient.isTenantAdmin()) {
      if (_isPublicDashboard(dashboard)) {
        return 'Public';
      } else {
        return dashboard.assignedCustomers.map((e) => e.title).join(', ');
      }
    }
    return '';
  }

  bool _isPublicDashboard(DashboardInfo dashboard) {
    return dashboard.assignedCustomers.any((element) => element.isPublic);
  }
}
