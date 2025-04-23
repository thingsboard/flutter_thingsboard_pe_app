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
        title: SizedBox(
          height: kToolbarHeight - 8,
          child: Image.asset('assets/images/logo.png'),
        ),
        actions: [
          if (tbContext.tbClient.isSystemAdmin())
            IconButton(
              icon: Image.asset('assets/images/search.png'),
              onPressed: () {
                tbContext.navigateTo('/tenants?search=true');
              },
            ),
          IconButton(
            icon: Image.asset('assets/images/notifications.png',color: Colors.black,),
            onPressed: () {
              tbContext.navigateTo('/notifications');
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
