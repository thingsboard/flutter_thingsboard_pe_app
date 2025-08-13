import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thingsboard_app/config/routes/tb_routes.dart';
import 'package:thingsboard_app/core/auth/login/login_page.dart';
import 'package:thingsboard_app/core/auth/login/reset_password_request_page.dart';
import 'package:thingsboard_app/core/auth/login/two_factor_authentication_page.dart';
import 'package:thingsboard_app/core/auth/signup/email_verification_page.dart';
import 'package:thingsboard_app/core/auth/signup/email_verified_page.dart';
import 'package:thingsboard_app/core/auth/signup/privacy_policy.dart';
import 'package:thingsboard_app/core/auth/signup/signup_page.dart';
import 'package:thingsboard_app/core/auth/signup/terms_of_use.dart';

class AuthRoutes extends TbRoutes {
  AuthRoutes(super.tbContext);
  late final loginHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      return LoginPage(tbContext);
    },
  );

  late final resetPasswordRequestHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      return ResetPasswordRequestPage(tbContext);
    },
  );

  late final signUpHandler = Handler(
    handlerFunc: (BuildContext? context,  params) {
      return SignUpPage(tbContext);
    },
  );

  late final privacyPolicyHandler = Handler(
    handlerFunc: (BuildContext? context,  params) {
      return PrivacyPolicy(tbContext);
    },
  );

  late final termsOfUseHandler = Handler(
    handlerFunc: (BuildContext? context,  params) {
      return TermsOfUse(tbContext);
    },
  );

  late final emailVerificationHandler = Handler(
    handlerFunc: (BuildContext? context,  params) {
      final String email = params['email']!.first;
      return EmailVerificationPage(tbContext, email: email);
    },
  );

  late final emailVerifiedHandler = Handler(
    handlerFunc: (BuildContext? context,  params) {
      final emailCode = (context?.settings?.arguments as Map<String, dynamic>?)?['emailCode']?.toString() ?? '';
      return EmailVerifiedPage(tbContext, emailCode: emailCode);
    },
  );

  late Handler twoFactorAuthenticationHandler = Handler(
    handlerFunc: (BuildContext? context, params) {
      return TwoFactorAuthenticationPage(tbContext);
    },
  );

  @override
  void doRegisterRoutes(FluroRouter router) {
    router.define('/login', handler: loginHandler);
    router.define(
      '/login/resetPasswordRequest',
      handler: resetPasswordRequestHandler,
    );
    router.define('/signup', handler: signUpHandler);
    router.define('/signup/privacyPolicy', handler: privacyPolicyHandler);
    router.define('/signup/termsOfUse', handler: termsOfUseHandler);
    router.define(
      '/signup/emailVerification',
      handler: emailVerificationHandler,
    );
    router.define('/signup/emailVerified', handler: emailVerifiedHandler);
    router.define('/login/mfa', handler: twoFactorAuthenticationHandler);
  }
}
