import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/auth/login/bloc/bloc.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/version/route/version_route.dart';
import 'package:thingsboard_app/modules/version/route/version_route_arguments.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.tbClient,
    required this.deviceService,
  }) : super(const AuthLoadingState()) {
    on(_onEvent);
  }
  final IDeviceInfoService deviceService;
  final ThingsboardClient tbClient;
  RecaptchaClient? _client;
  final ThingsboardAppRouter router = getIt();
  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    switch (event) {
      case AuthFetchEvent():
        try {
          final loginInfo =
              await tbClient.getMobileService().getLoginMobileInfo(
                    MobileInfoQuery(
                      packageName: event.packageName,
                      platformType: event.platformType,
                    ),
                  );

          if (loginInfo != null) {
            final versionInfo = loginInfo.versionInfo;
            if (versionInfo != null) {
              if (deviceService.getAppVersion().versionInt() <
                  (versionInfo.minVersion?.versionInt() ?? 0)) {
                router.navigateTo(
                  VersionRoutes.updateRequiredRoutePath,
                  clearStack: true,
                  replace: true,
                  routeSettings: RouteSettings(
                    arguments: VersionRouteArguments(
                      versionInfo: versionInfo,
                      storeInfo: loginInfo.storeInfo,
                    ),
                  ),
                );
                return;
              }
            }

            if (loginInfo.selfRegistrationParams?.recaptcha.version ==
                'enterprise') {
              if (event.platformType == PlatformType.IOS) {
                _client = await Recaptcha.fetchClient(
                  loginInfo.selfRegistrationParams!.recaptcha.iosSiteKey!,
                );
              } else if (event.platformType == PlatformType.ANDROID) {
                _client = await Recaptcha.fetchClient(
                  loginInfo.selfRegistrationParams!.recaptcha.androidSiteKey!,
                );
              }
            }

            emit(
              AuthDataState(
                oAuthClients: loginInfo.oAuth2Clients,
                selfRegistrationParams: loginInfo.selfRegistrationParams,
                recaptchaClient: _client,
              ),
            );
          } else {
            emit(
              const AuthDataState(
                oAuthClients: [],
                selfRegistrationParams: null,
                recaptchaClient: null,
              ),
            );
          }
        } catch (_) {
          emit(
            const AuthDataState(
              oAuthClients: [],
              selfRegistrationParams: null,
              recaptchaClient: null,
            ),
          );
        }

        break;
    }
  }
}
