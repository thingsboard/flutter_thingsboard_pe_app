import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/config/themes/wl_theme_widget.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/layouts/i_layout_service.dart';
import 'package:toastification/toastification.dart';

class ThingsboardApp extends StatefulWidget {
  const ThingsboardApp({super.key});

  @override
  State<StatefulWidget> createState() => _ThingsBoardAppState();
}

class _ThingsBoardAppState extends State<ThingsboardApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<ILayoutService>().setDeviceScreenSize(
        MediaQuery.of(context).size,
        orientation: MediaQuery.of(context).orientation,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: WlThemeWidget(
        getIt<ThingsboardAppRouter>().tbContext,
        wlThemedWidgetBuilder: (context, data, wlParams) => MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
          title: wlParams.appTitle!,
          themeMode: ThemeMode.light,
          theme: data,
          darkTheme: tbDarkTheme,
          navigatorKey: getIt<ThingsboardAppRouter>().navigatorKey,
          onGenerateRoute: getIt<ThingsboardAppRouter>().router.generator,
          navigatorObservers: [
            getIt<ThingsboardAppRouter>().tbContext.routeObserver,
          ],
        ),
      ),
    );
  }
}
