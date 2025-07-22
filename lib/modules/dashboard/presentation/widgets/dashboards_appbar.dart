import 'package:flutter/material.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';

class DashboardsAppbar extends StatelessWidget {
  const DashboardsAppbar({
    required this.tbContext,
    required this.body,
    this.dashboardState = false,
    super.key,
    this.leading,
  });

  final TbContext tbContext;
  final Widget? leading;
  final Widget body;
  final bool dashboardState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TbAppBar(
       canGoBack: leading != null,
        tbContext,
        leading: leading ??
            (Navigator.of(context).canPop()
                ? BackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
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
                getIt<ThingsboardAppRouter>()
                    // translate-me-ignore-next-line
                    .navigateTo('/tenants?search=true');
              },
            ),
          if (leading != null)
            const SizedBox(
              width: 56,
            ),
        ],
      ),
      body: body,
    );
  }
}
