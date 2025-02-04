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
        "type": "service_account",
        "project_id": "hotdiamond-dc51c",
        "private_key_id": "265b67b85c4ea7990350e72acb6386709f554c19",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCq4I+ZyM7XSD2g\nl998C8Jhu58dj4JFWVb/8tgXksc/6qH2nBV9Yzs6o8VYMhdlOlir4TznOXXUibLz\nYkSSF1N06f7KDFAddOpRL3zS6Nnv/dYtRF2eNpXkQivEmBJdhEFtt0RFESMZrqu0\nWs4A7NIj0wQnrdFvwIAx/z2sL3uGrjp+OaVMJYPrusJZ6ECSjgWG0f0y3FANB305\ndK0fZZMXj+EUgxjBmyLeTTsVWLm2ZNpOWvfSSS4YitnmhUopLcnxyVhiuDF7tboR\nuDnpbrl0x9gz+LG541j5jwfipxVeZ/cWpgAwJO8++jhcbZwvLgquVRmF53/+PN7S\nJXSgE/QdAgMBAAECggEACJGrUdxylvQt9vw2vls+m7UTdSGJuF2TEdHFSWVYbZmg\nFqRcJYYQ5c9pqZMVfkOPR8tLSRMmGArxuOfQJX1a9412c/5rFBcVWw3lFhSMPU8+\n6tU3VqRJHwG8fSbdIOhteYmLuGT0HCkYvjohg4VcwmQmHLFIQ/Dk3Nz+ZECbUrUb\n/KrAfyEOaF9X6DvPjKdYAtFmHBJVoodMSSk/XYq6CjlHFQIkj4zzbAHuzBlZrWXa\n1Cb4MkKKdZ+xencnMSan49dD5DSI09+lrraQHNmMuNCXpZm5UHs4lxV8wHpAu4Bs\n0meZgy06PokSLEBWFtyq2pfnx4w2IWaKNZlz7XJLBwKBgQDg0MKQkKL+BPeAmxmJ\n+3IKKKpqVF0xhOHN2+ozfwDTFikvWjFGtvGCIC/Qr8UNgv6XNY9dCz9BbI3l8yTp\neS+7gu3lhWKZcx9du0S2YlsCGDUorWdSJ3dgUJfIu/Rcxl9RB0lKg5w47d7lZWIC\n6Ni3rTeSNeHXgfFoTmPPz99mHwKBgQDClHFD3iszVsFdlism4LpUE7HNkJtDEzGo\nAe86vkJGfnmPUK1hRkA9KGnEcLRJ9OL+CvwbDT361fYXG49L+5nNlhCh6kVFvsjK\n/2KV1vHxhTWa1GT66phxh0U7VkqPVDbki2pFDlnJdVePJv0VdkHfbXw4GP2LElhY\njaziAdiGQwKBgD7CKD5hEg8lZc5R/dwmBFzPo1sRd/6V4M8t4ABGKP3ERvUAEZdz\nBJJV1+NC3hh6hAXEHuRTenISEr6plJlUij2nPDABf1fk6lGpMHJVnKBGD7juR1SI\nzetmNCkGRx4LBprBFPWnLdo6lSmmlqjHRZBo24WGYyhdDv4WPAjMN8nzAoGBAIfr\nDy98OqsS9+F6q0vuANoII9RXJc110+Lq7wQWsM7zO9CbZ3EilG7kEvWwUI+0qvcQ\nD0iKOHhGCy/bBX7rEmWkZJvlvFvayAHc4S2PxtOR3H75zEvloXT0K60mOtDh37JH\nnIT+YEO0XuRVNMZQI/WBUhsRgdIqj2HUHSaGaYxnAoGAPTyvsJAWW5AvO3YZbi9C\nAIOTzSBa2yAvsi2ThL5UhnRF11vdoYp1o7usBDqhXsizP/n2Kn6NDZZQovK7gBTz\nIjPK2Jbs2gRYIOORBaxAgv3JZNfvo+Xbw+bAQGQmDHolD9wShRysZRmHiKiNgb1s\nBUWaTXODuIRFSkGsSJeY2AA=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-mslw1@hotdiamond-dc51c.iam.gserviceaccount.com",
        "client_id": "102416494611269207504",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-mslw1%40hotdiamond-dc51c.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
