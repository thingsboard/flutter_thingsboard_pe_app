import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart' show MobileInfoQuery;
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/widgets/tb_progress_indicator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TermsOfUse extends TbPageWidget {
  TermsOfUse(TbContext tbContext, {super.key}) : super(tbContext);

  @override
  State<StatefulWidget> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends TbPageState<TermsOfUse> {
  late Future<String?> termsOfUseFuture;

  @override
  void initState() {
    super.initState();
    termsOfUseFuture =
        tbContext.tbClient.getSelfRegistrationService().getTermsOfUse(
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
        title: Text(S.of(context).termsOfUse),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: FutureBuilder<String?>(
                    future: termsOfUseFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.data == null ||
                            snapshot.data?.isEmpty == true) {
                          return const SizedBox.shrink();
                        }
                        return HtmlWidget(
                         snapshot.data?? '',
                          onTapUrl: (link) async {
                        launchUrlString(
                          link,
                          mode: LaunchMode.externalApplication,
                        );
                      return true;
                    },
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
                    onPressed: () => getIt<ThingsboardAppRouter>().pop(false, context),
                    child: Text(S.of(context).cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => getIt<ThingsboardAppRouter>().pop(true, context),
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
