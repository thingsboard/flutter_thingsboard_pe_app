import 'package:flutter/material.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart' show MobileInfoQuery;
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/actions/url_action.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/results/launch_result.dart';
import 'package:thingsboard_app/utils/services/overlay_service/i_overlay_service.dart';
import 'package:thingsboard_app/utils/utils.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PrivacyPolicy extends TbPageWidget {
  PrivacyPolicy(super.tbContext, {super.key});

  @override
  State<StatefulWidget> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends TbPageState<PrivacyPolicy> {
  late Future<String?> privacyPolicyFuture;

  @override
  void initState() {
    super.initState();
    privacyPolicyFuture =
        tbContext.tbClient.getSelfRegistrationService().getPrivacyPolicy(
              query: MobileInfoQuery(
                packageName: getIt<IDeviceInfoService>().getApplicationId(),
                platformType: getIt<IDeviceInfoService>().getPlatformType(),
              ),
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TbAppBar(
        tbContext,
        title: Text(S.of(context).privacyPolicy),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: FutureBuilder<String?>(
                    future: privacyPolicyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null ||
                            snapshot.data?.isEmpty == true) {
                          return const SizedBox.shrink();
                        }

                        return HtmlWidget(
                          snapshot.data ?? '',
                          onTapUrl: (link) async => Utils.onWebViewLinkPressed(link)
                        );
                      } else {
                        return Center(
                          child: TbProgressIndicator(
                            tbContext,
                            size: 50.0,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () =>
                        getIt<ThingsboardAppRouter>().pop(false, context),
                    child: Text(S.of(context).cancel),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        getIt<ThingsboardAppRouter>().pop(true, context),
                    child: Text(S.of(context).accept),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
}
