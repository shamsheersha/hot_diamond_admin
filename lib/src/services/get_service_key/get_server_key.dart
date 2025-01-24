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
        "private_key_id": "e97799bdb5f55907c46486cc64a47ed98cd575ab",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC63yC3+2uiJWoP\nIOmSPVCsFwDekUCCR0H5omQSCypJXjcIj2/39d1F300X8dW0MvmqQ/vpXzEu/oMs\nB8xjj2D2YZXSU5N+WgI2sh7EFwZ7ZoqPcF4T132dXyHZCd6Ft0VOwZKOip5ty4KG\nY0EmiVEuzfHvh5IcykqRxX5fEZWMqTrd5yDjkvB4ciNZeAS/FKXKx/ivO52dmGnK\nu0ZevUfq6pOsjjzVTu6CWrN4SjjzI+hnfHQcFkfH0Tkbwl84eXYEn7MaKi4xymiw\nD9MeLDn0zc0FlIRUv2TT88eQx8w4JAJItwY1C+BLXYEiopxWL/J0VesnnmcW+qZY\nSAlHkyTfAgMBAAECggEAEPIg7m4vQYHxDzQl2iwTP7fKTWSQm//IPNH8DyLSD9sq\nVG1lcu/pw+dO/2ffwDqLJ2SI2I3YUPGlhX2jjDe5TD5nLq6Dhoa1Aq6+WXvZC6Gt\n2PoQne4Bpx60XBEoC6ol79Ff7+skGMLGsFcZ1lvHb94fHWCG4HN7taJaJlba3+ll\nC9N/Gq/1zbrE+l+yg/ery9nH+/osJ7oTvk6lLLBFWN8VaooMq65JaneLxNrFBw31\n8yp9HxhbHBGoqxRnOv1iViiXCy00GsPr/S3lvtQP11HgxkgDvNMWJA7nkIdSkpZN\nzGhONaISE0Hioj4ldJQm60Yvr4ai3x//bU8w4kL0UQKBgQDh026I+TRUVIzIxgXE\nMFs4gF5y8VNLr7hX8KfiJG6SFzWReWKcQBV6u59tYerZJ3iJZQZEoP8RWELNj1pE\nTi8zx/BRgwAP9tp2eWvhI3SL8c6rKe1q+m7LpVASmP81vjW6/9ucWw1sqWbbbYHk\ne5JgGgz0zXMailyl7MLkNnRXiQKBgQDT1zr/dkb7siagWkxvsm0bS3bXCVOdykja\nZYnqZRAIhsxM3dwvsU/N8domJqHNY2IZTq/lEEj02yB1bJIMNZpztTburJAGBd3d\nZ0cpuztggHIZBUXrRL3MF3ZzTTU4iBup8Nk7rUTksVffz7cQ51b98BkxYOsORZc3\nBulJtHiXJwKBgQCbGtJfx/JWPaBYwhHx11jALQMyJWiVooKV/BgDLgy30LMdUOcW\n9LkMDFQLF+bq8b5LeBTfDElEy39OmrhgE+c9xITeJ4DidiVEnE8pWmXRPOs7Ctgj\n0xBIVSnzLByV+CgFYXigIrXMvWmFKui9WtaFpT7i4T2+q+vIlx6hCnnMKQKBgBrO\nYHvVFrRg3bxq0MNNm7rZeMdLOdZ8s21XbfVIJpg9nnqXlHZAhK21zfoH52+bBN3Y\n9C8TOXgqhlf1jiGXYt0DcFkRYwQwF9wdZobkV2YlusppvWhBAZdi3K1IdtSZfI6r\nmIGRsmcR/eGnYi30aDCoAjgaYIQk0Da5XCnkeWH/AoGBAIFLZijlsGvj7oxetVtk\niPOXB/EAqRX+4Q1Qu/YmIrS2wpAPU/f0ivdK+799KMwVvpRmCSz82srcz8ZT3oGs\nQOPq6OFe6RKEt0LUS78zpWyLYP7XB3ir5+ROTI0apN5M/tzCFCK/TjPBL6lJBFkZ\nrXPZBAAeWkyVyaRbTsaLAlCi\n-----END PRIVATE KEY-----\n",
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
