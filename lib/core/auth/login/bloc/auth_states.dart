import 'package:equatable/equatable.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';
import 'package:thingsboard_app/thingsboard_client.dart'
    show OAuth2ClientInfo, MobileSelfRegistrationParams;

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

final class AuthDataState extends AuthState {
  const AuthDataState({
    required this.oAuthClients,
    required this.selfRegistrationParams,
    required this.recaptchaClient,
  });

  final List<OAuth2ClientInfo> oAuthClients;
  final MobileSelfRegistrationParams? selfRegistrationParams;
  final RecaptchaClient? recaptchaClient;

  @override
  List<Object?> get props =>
      [oAuthClients, selfRegistrationParams, recaptchaClient];
}
