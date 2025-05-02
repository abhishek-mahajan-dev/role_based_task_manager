import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendFcmNotification({
  required String token,
  required String title,
  required String body,
}) async {
  const String serverKey = 'YOUR_FCM_SERVER_KEY'; // Replace with your key

  final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode({
      'to': token,
      'notification': {'title': title, 'body': body},
    }),
  );
}
