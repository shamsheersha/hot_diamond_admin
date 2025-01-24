import 'dart:convert';
import 'dart:developer';
import 'package:hot_diamond_admin/src/services/get_service_key/get_server_key.dart';
import 'package:http/http.dart' as http;
class NotificationService {
  Future<bool> pushNotifications({
  required String titile,
  body,
  token,
}) async {
  try {
    final serveryKeyToken = await GetServerKey().getServerKeyToken();
    log('Server Key Token: $serveryKeyToken'); // Log the token

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/hotdiamond-dc51c/messages:send');

    Map<String,dynamic> payload = {
      'message': {
        'token': token,
        'notification': {'title': titile, 'body': body},
        'android': {
          'priority': 'high',
          'notification': {'sound': 'default'}
        }
      }
    };

    log('Payload: $payload'); // Log the payload
    log('Token: $token'); // Log the FCM token

    var response = await http.post(url,
      headers: <String,String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serveryKeyToken'
      },
      body: jsonEncode(payload));
    
    log('Response Status Code: ${response.statusCode}');
    log('Response Body: ${response.body}');

    if(response.statusCode == 200){
      log('Notification sent successfully');
      return true;
    } else {
      log('Failed to send notification: ${response.body}');
      return false;
    }
  } catch(e) {
    log('Error sending notification: $e');
    return false;
  }
}
}
