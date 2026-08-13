import 'package:app_links/app_links.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/config/routes/v2/router_2.dart';
import 'package:thingsboard_app/config/themes/dark_theme.dart';
import 'package:thingsboard_app/config/themes/tb_ce_theme.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/local_database/i_local_database_service.dart';
import 'package:toastification/toastification.dart';

class ThingsboardApp extends HookConsumerWidget {
  const ThingsboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // App links (e.g. the login QR code scanned with the camera app) used to
    // be handled by TbContext.init, which the v2 router no longer calls.
    // Listen here and route through the same navigateByAppLink path the
    // in-app QR scanner uses. The platform may deliver the same intent more
    // than once, so consecutive duplicates are dropped.
    useEffect(() {
      String? lastLink;
      DateTime? lastLinkAt;
      final sub = AppLinks().uriLinkStream.listen((link) {
        final now = DateTime.now();
        final isDuplicate =
            link.toString() == lastLink &&
            lastLinkAt != null &&
            now.difference(lastLinkAt!) < const Duration(seconds: 2);
        lastLink = link.toString();
        lastLinkAt = now;
        if (!isDuplicate) {
          getIt<ThingsboardAppRouter>().navigateByAppLink(link.toString());
        }
      });

      // Consume the link the app was cold-started with (stored in main()).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final initialLink =
            await getIt<ILocalDatabaseService>().getInitialAppLink();
        if (initialLink != null && initialLink != lastLink) {
          getIt<ThingsboardAppRouter>().navigateByAppLink(initialLink);
        }
      });
      return sub.cancel;
    }, const []);

    return ToastificationWrapper(
      child: ColoredBox(
        color: tbCeTheme.scaffoldBackgroundColor,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          color: tbCeTheme.scaffoldBackgroundColor,
          localizationsDelegates: const [
            S.delegate,
            LocaleNamesLocalizationsDelegate(),
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          onGenerateTitle: (BuildContext context) => S.of(context).appTitle,
          themeMode: ThemeMode.light,
          theme: tbCeTheme,
          darkTheme: tbDarkTheme,
          routerConfig: router,
        ),
      ),
    );
  }
}
