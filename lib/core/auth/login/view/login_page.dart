import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thingsboard_app/core/auth/login/di/login_di.dart';
import 'package:thingsboard_app/core/auth/login/login_theme.dart';
import 'package:thingsboard_app/core/auth/login/models/login_state.dart';
import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';
import 'package:thingsboard_app/core/auth/login/widgets/full_screen_loader.dart';
import 'package:thingsboard_app/core/auth/login/widgets/login_widget.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';
import 'package:thingsboard_app/utils/services/wl_provider.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key, required this.riderectUrl});
  final String? riderectUrl;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final darkForeground =
        ref.watch(wlProvider).loginWhiteLabelingParams.darkForeground ?? false;
    final isUserLoading = useState(false);
    useEffect(() {
      LoginDi.init();
      handleUserLoading(loginState, isUserLoading);
      return () => LoginDi.dispose();
    }, []);
    useEffect(() {
      handleUserLoading(loginState, isUserLoading);
    }, [loginState]);
    return Theme(
      data: loginTheme(Theme.of(context), darkForeground: darkForeground),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            darkForeground
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Stack(
            children: [
              const LoginWidget(),
              if (isUserLoading.value) const FullScreenLoader(),
            ],
          ),
        ),
      ),
    );
  }

  void handleUserLoading(
    LoginState loginState,
    ValueNotifier<bool> isUserLoading,
  ) {
    final client = getIt<ITbClientService>().client;
    final user = client.getAuthUser();

    if (user != null &&
        (!user.isMfaConfigurationToken() || !user.isPreVerificationToken())) {
      isUserLoading.value = true;
    }
    if (user != null &&
        (user.isMfaConfigurationToken() || user.isPreVerificationToken())) {
      isUserLoading.value = false;
    }
  }
}
