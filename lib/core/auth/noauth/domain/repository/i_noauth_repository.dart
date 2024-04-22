import 'package:thingsboard_pe_client/thingsboard_client.dart';

abstract interface class INoAuthRepository {
  Future<LoginResponse> getJwtToken({
    required String host,
    required String key,
  });

  Future<void> setUserFromJwtToken(LoginResponse loginData);
}
