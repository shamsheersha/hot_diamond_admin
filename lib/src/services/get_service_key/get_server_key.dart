import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": dotenv.env['SERVICE_ACCOUNT_TYPE'],
      "project_id": dotenv.env['SERVICE_ACCOUNT_PROJECT_ID'],
      "private_key_id": dotenv.env['SERVICE_ACCOUNT_PRIVATE_KEY_ID'],
      "private_key": dotenv.env['SERVICE_ACCOUNT_PRIVATE_KEY']?.replaceAll('\\n', '\n'),
      "client_email": dotenv.env['SERVICE_ACCOUNT_CLIENT_EMAIL'],
      "client_id": dotenv.env['SERVICE_ACCOUNT_CLIENT_ID'],
      "auth_uri": dotenv.env['SERVICE_ACCOUNT_AUTH_URI'],
      "token_uri": dotenv.env['SERVICE_ACCOUNT_TOKEN_URI'],
      "auth_provider_x509_cert_url": dotenv.env['SERVICE_ACCOUNT_AUTH_PROVIDER_CERT_URL'],
      "client_x509_cert_url": dotenv.env['SERVICE_ACCOUNT_CLIENT_CERT_URL'],
      "universe_domain": dotenv.env['SERVICE_ACCOUNT_UNIVERSE_DOMAIN']
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
