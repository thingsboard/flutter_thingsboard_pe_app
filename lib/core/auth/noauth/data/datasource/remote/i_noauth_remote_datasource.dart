import 'package:flutter/foundation.dart';
import 'package:thingsboard_pe_client/thingsboard_client.dart';

abstract interface class INoAuthRemoteDatasource {
  Future<LoginResponse> getJwtToken({
    required String host,
    required String key,
  });

  Future<void> setUserFromJwtToken(LoginResponse loginData);

  Future<void> logout({RequestConfig? requestConfig, bool notifyUser = true});

  Future<void> reInit({
    required String endpoint,
    required VoidCallback onDone,
    required ErrorCallback onError,
  });

  bool isAuthenticated();
}
