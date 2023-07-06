import 'dart:convert';

import 'package:http/http.dart' as http;
class SendNotification{

  static void sendPushMessage(String token, String title, String body) async{
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type':'application/json',
        'Authorization': 'key=AAAAlSOrbXc:APA91bExZr1YFiYibLGeEv-guuHEmHnZQfzQhWzvyDt49_NC-WICDDGfL3EjO14zF-x1mYUdU3v813u64UI5cFGW9mMNA4Idbb4liHkrzMqriKk4BTHnvniAr9N_ovs25nE3P_stBakW'
      },
      body:  jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },

          'notification': <String, dynamic>{
            'body': body,
            'title': title,
            'android_channel_id': 'flutter_chat',
          },
          'to': token,
        }
      )
    );
  }
}