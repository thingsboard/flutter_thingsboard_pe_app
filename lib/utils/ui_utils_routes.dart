import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/tb_routes.dart';
import 'package:thingsboard_app/utils/ui/qr_code_scanner.dart';
import 'package:thingsboard_app/utils/ui/tb_recaptcha.dart';

class UiUtilsRoutes extends TbRoutes {
  UiUtilsRoutes(super.tbContext);
  late final qrCodeScannerHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      final bool isProvisioning =
          bool.tryParse(params['isProvisioning'].toString()) ?? false;
      return QrCodeScannerPage(
        isProvisioning: isProvisioning,
      );
    },
  );
late final tbRecaptchaHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      final siteKey = params['siteKey']!.first;
      final version = params['version']!.first;
      final logActionName = params['logActionName']?.first;

      return TbRecaptcha(
        tbContext,
        siteKey: siteKey,
        version: version,
        logActionName: logActionName,
      );
    },
  );
  @override
  void doRegisterRoutes(FluroRouter router) {
    router.define('/qrCodeScan', handler: qrCodeScannerHandler);
    router.define('/tbRecaptcha', handler: tbRecaptchaHandler);
  }
}
