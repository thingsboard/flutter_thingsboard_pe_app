import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thingsboard_app/constants/assets_path.dart';
import 'package:thingsboard_app/core/auth/login/region.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/endpoint/i_endpoint_service.dart';
import 'package:thingsboard_app/utils/ui/tb_text_styles.dart';

import '../../../constants/app_constants.dart';

class SelectRegionScreen extends TbContextStatelessWidget {
  SelectRegionScreen(super.tbContext, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // SvgPicture.asset(ThingsboardImage.thingsboardBigLogo),
            const SizedBox(height: 32),
            Image.asset('assets/images/splash.png'),
            const SizedBox(height: 166),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      S.of(context).selectRegion,
                      style: TbTextStyles.titleMedium.copyWith(
                        color: Colors.black.withOpacity(.76),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DefaultButton2(
                      isMobileDevice: true,
                      onPressed: () {
                        getIt<IEndpointService>()
                            .setRegion(Region.northAmerica);
                        navigateTo('/');
                      },
                      buttonTitle: S.of(context).northAmerica,
                      color: ThingsboardAppConstants.primaryColor,

                    ),
                    const SizedBox(height: 16),
                    DefaultButton2(
                      isMobileDevice: true,
                      onPressed: () {
                        getIt<IEndpointService>().setRegion(Region.europe);
                        navigateTo('/');
                      },
                      buttonTitle: S.of(context).europe,
                      color: ThingsboardAppConstants.primaryColor,

                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget DefaultButton2({
    required bool isMobileDevice,
    required void Function()? onPressed,
    required String buttonTitle,
    required Color color,
    IconData? icon,
    Color? iconColor = Colors.white,
    String? iconImage,
    Color titleColor = Colors.white,
    Color borderColor = Colors.white,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        side: BorderSide(color: borderColor),
        backgroundColor: color,
        //disabledBackgroundColor: primaryColor.withOpacity(0.5),
        padding: EdgeInsets.symmetric(
            vertical: isMobileDevice ? 14 : 16, horizontal: 35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.circular(
            20,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: iconColor,
            ),
          if (icon != null)
            const SizedBox(
              width: 24,
            ),
          if (iconImage != null) Image.asset(iconImage),
          if (iconImage != null)
            const SizedBox(
              width: 24,
            ),
          Text(
            buttonTitle,
            style: TextStyle(
              color: titleColor,
              fontSize: isMobileDevice ? 18 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
