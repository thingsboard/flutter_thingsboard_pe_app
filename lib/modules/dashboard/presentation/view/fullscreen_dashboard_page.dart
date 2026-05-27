import 'package:flutter/material.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/dashboard/di/dashboards_di.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/view/dashboard_permission_error_view.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/widgets/dashboard_back_handler.dart';
import 'package:thingsboard_app/modules/dashboard/presentation/widgets/dashboard_widget.dart';
import 'package:thingsboard_app/utils/services/custom_translation/i_custom_translation_service.dart';
import 'package:thingsboard_app/utils/services/endpoint/i_endpoint_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';
import 'package:thingsboard_app/utils/services/permission/i_permission_service.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';

class FullscreenDashboardPage extends StatefulWidget {
  const FullscreenDashboardPage(
    this.fullscreenDashboardId, {
    super.key,
    String? dashboardTitle,
  }) : _dashboardTitle = dashboardTitle;
  final String fullscreenDashboardId;
  final String? _dashboardTitle;

  @override
  State<StatefulWidget> createState() => _FullscreenDashboardPageState();
}

class _FullscreenDashboardPageState extends State<FullscreenDashboardPage> {
  late ValueNotifier<String> dashboardTitleValue;
  final showBackValue = ValueNotifier<bool>(false);
  late final String diKey;
  DashboardController? _dashboardController;
  late final bool havePermission;

  @override
  Widget build(BuildContext context) {
    if (!havePermission) {
      return DashboardPermissionErrorView( fullScreen: true);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: showBackValue,
          builder: (context, canGoBack, widget) {
            return TbAppBar(
              leading: IconButton(
            icon: const Icon(Icons.arrow_back),
                onPressed: _handleBack,
              ),
              elevation: 1,
              shadowColor: Colors.transparent,
              title: ValueListenableBuilder<String>(
                valueListenable: dashboardTitleValue,
                builder: (context, title, widget) {
                  return FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.centerLeft,
                    child: Text(title),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  // translate-me-ignore-next-line
                  onPressed:
                      () => getIt<ThingsboardAppRouter>().navigateTo(
                        '/profile?fullscreen=true',
                      ),
                ),
              ],
              canGoBack: canGoBack,
            );
          },
        ),
      ),
      body: DashboardBackHandler(
        onBack: _handleBack,
        child: ValueListenableBuilder<String?>(
          valueListenable: getIt<IEndpointService>().listenEndpointChanges,
          builder:
            (context, _, _) => DashboardWidget(
              titleCallback: (title) {
                dashboardTitleValue.value = title;
              },
              controllerCallback: (controller, _) {
                _dashboardController = controller;

                controller.canGoBack.addListener(() {
                  _onCanGoBack(controller.canGoBack.value);
                });
                controller.openDashboard(
                  widget.fullscreenDashboardId,
                  fullscreen: true,
                );
              },
            ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    diKey = UniqueKey().toString();
    DashboardsDi.init(diKey, tbClient: getIt<ITbClientService>().client);
    havePermission = getIt<IPermissionService>()
        .haveViewDashboardPermission();
    dashboardTitleValue = ValueNotifier(
      getIt<ICustomTranslationService>()
          .translate(widget._dashboardTitle ?? 'Dashboard'),
    );
  }

  @override
  void dispose() {
    DashboardsDi.dispose(diKey);
    dashboardTitleValue.dispose();
    showBackValue.dispose();
    super.dispose();
  }

  void _onCanGoBack(bool canGoBack) {
    showBackValue.value = canGoBack;
  }

  Future<void> _handleBack() async {
    await DashboardBackHandler.tryNavigateBack(_dashboardController);
  }
}
