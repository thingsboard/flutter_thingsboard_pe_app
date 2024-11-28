import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';

class DashboardsAppbar extends StatelessWidget {
  const DashboardsAppbar({
    required this.tbContext,
    required this.body,
    this.dashboardState = false,
    super.key,
  });

  final TbContext tbContext;
  final Widget body;
  final bool dashboardState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TbAppBar(
        tbContext,
        leading: Navigator.of(context).canPop()
            ? BackButton(
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        elevation: dashboardState ? 0 : 8,
        title: Center(
          child: SizedBox(
            height: kToolbarHeight - 8,
            child: tbContext.wlService.userLogoImage != null
                ? tbContext.wlService.userLogoImage!
                : const SizedBox(),
          ),
        ),
        actions: [
          if (tbContext.tbClient.isSystemAdmin())
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                tbContext.navigateTo('/tenants?search=true');
              },
            ),
        ],
      ),
      body: body,
    );
  }
}
