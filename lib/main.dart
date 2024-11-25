import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:thingsboard_app/app_bloc_observer.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/config/themes/tb_theme.dart';
import 'package:thingsboard_app/config/themes/wl_theme_widget.dart';
import 'package:thingsboard_app/core/auth/login/region.dart';
import 'package:thingsboard_app/firebase_options.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/firebase/i_firebase_service.dart';
import 'package:thingsboard_app/utils/services/layouts/i_layout_service.dart';
import 'package:universal_platform/universal_platform.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(RegionAdapter());

  await setUpRootDependencies();
  if (UniversalPlatform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  try {
    getIt<IFirebaseService>().initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    log('main::FirebaseService.initializeApp() exception $e', error: e);
  }

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver(getIt());
  }

  runApp(const ThingsboardApp());
}

class ThingsboardApp extends StatefulWidget {
  const ThingsboardApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThingsboardAppState();
}

class _ThingsboardAppState extends State<ThingsboardApp> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        getIt<ILayoutService>().setDeviceScreenSize(
          MediaQuery.of(context).size,
          orientation: MediaQuery.of(context).orientation,
        );

        return WlThemeWidget(
          getIt<ThingsboardAppRouter>().tbContext,
          wlThemedWidgetBuilder: (context, data, wlParams) => MaterialApp(
            scaffoldMessengerKey:
                getIt<ThingsboardAppRouter>().tbContext.messengerKey,
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
            onGenerateRoute: getIt<ThingsboardAppRouter>().router.generator,
            navigatorObservers: [
              getIt<ThingsboardAppRouter>().tbContext.routeObserver,
            ],
          ),
        );
      },
    );
  }
}
