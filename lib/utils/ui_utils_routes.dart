import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/config/routes/tb_routes.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/utils/ui/qr_code_scanner.dart';
import 'package:thingsboard_app/utils/ui/tb_recaptcha.dart';

class UiUtilsRoutes extends TbRoutes {
  late final qrCodeScannerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
       final bool isProvisioning = params['isProvisioning']?.first ?? false;
      return QrCodeScannerPage(isProvisioning: isProvisioning,);
    },
  );

  late final tbRecaptchaHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final siteKey = params['siteKey']?.first;
      final version = params['version']?.first;
      final logActionName = params['logActionName']?.first;

      return TbRecaptcha(
        tbContext,
        siteKey: siteKey,
        version: version,
        logActionName: logActionName,
      );
    },
  );

  UiUtilsRoutes(TbContext tbContext) : super(tbContext);

  @override
  void doRegisterRoutes(router) {
    router.define('/qrCodeScan', handler: qrCodeScannerHandler);
    router.define('/tbRecaptcha', handler: tbRecaptchaHandler);
  }
}
