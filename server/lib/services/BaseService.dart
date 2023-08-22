import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:dotenv/dotenv.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

class BaseService {
  var _env = DotEnv(includePlatformEnvironment: true)
    ..load(["/app/bin/config/env", "./config/env"]);
  late AutoRefreshingAuthClient client;

  BaseService() {
    getClient().then((value) => client = value);
  }

  Future<AutoRefreshingAuthClient> getClient() async {

    AutoRefreshingAuthClient client;

    if (Platform.isMacOS) {
      client = await clientViaApplicationDefaultCredentials(
          scopes: ["https://www.googleapis.com/auth/cloud-platform"]);
    } else {
      client = await clientViaMetadataServer();
    }

    return client;
  }

  bool isEnvVarSet(String varName) {
    return _env.isDefined(varName);
  }

  String? getEnvVar(String varName) {
    return _env[varName];
  }


  gapis.AccessCredentials getCredentials(String accessToken) {
    final gapis.AccessCredentials credentials = gapis.AccessCredentials(
      gapis.AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().toUtc().add(const Duration(days: 365)),
      ),
      null, // We don't have a refreshToken
      ["https://www.googleapis.com/auth/cloud-platform"],
    );

    return credentials;
  }

  AuthClient getAuthenticatedClient(String accessToken) {
    var authenticatedClient = gapis.authenticatedClient(
        http.Client(), getCredentials(accessToken));

    return authenticatedClient;
  }

  // AuthClient getClientFromContext(Object context, String authType) {
  // return client that is initialized based on the context
  // }

}
