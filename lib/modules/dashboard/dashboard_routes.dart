import 'package:fluro/fluro.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/dashboard/domain/entites/dashboard_arguments.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/view/dashboard_permission_error_view.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/view/dashboards_page.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/view/fullscreen_dashboard_page.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/view/single_dashboard_view.dart';
import 'package:thingsboard_app/utils/services/permission/i_permission_service.dart';

class DashboardRoutes extends TbRoutes {
  DashboardRoutes(TbContext tbContext) : super(tbContext);

  late final dashboardsHandler = Handler(
    handlerFunc: (context, params) {
      return DashboardsPage(tbContext);
    },
  );

  late final dashboardHandler = Handler(
    handlerFunc: (context, params) {
      final args = context?.settings?.arguments as DashboardArgumentsEntity;

      final havePermission =
          getIt<IPermissionService>().haveViewDashboardPermission(tbContext);

      if (havePermission) {
        return SingleDashboardView(
          tbContext,
          id: args.id,
          title: args.title,
          state: args.state,
          hideToolbar: args.hideToolbar,
        );
      }

      return DashboardPermissionErrorView(tbContext);
    },
  );

  late final fullscreenDashboardHandler = Handler(
    handlerFunc: (context, params) {
      final havePermission =
          getIt<IPermissionService>().haveViewDashboardPermission(tbContext);

      if (havePermission) {
        return FullscreenDashboardPage(tbContext, params['id']![0]);
      }

      return DashboardPermissionErrorView(tbContext, fullScreen: true);
    },
  );

  late final singleDashboard = Handler(
    handlerFunc: (context, parameters) {
      return SingleDashboardView(tbContext, id: parameters['id']![0]);
    },
  );

  @override
  void doRegisterRoutes(router) {
    router
      ..define(
        '/dashboards',
        handler: dashboardsHandler,
      )
      ..define(
        '/dashboard',
        handler: dashboardHandler,
      )
      ..define(
        '/fullscreenDashboard/:id',
        handler: fullscreenDashboardHandler,
      )
      ..define(
        '/dashboard/:id',
        handler: singleDashboard,
      );
  }
}
