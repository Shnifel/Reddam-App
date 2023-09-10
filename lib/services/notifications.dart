import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// Handle all notification related services
class NotificationServices {
  String? token; // Keep reference to user token
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Display local notifications

  // Perform check for necessary permissions to receive notifications
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permission granted");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Permission provisional");
    } else {
      print("Declined");
    }
  }

  // Retrieve user's device token for push notifications
  void getToken() async {
    await FirebaseMessaging.instance
        .getToken()
        .then((token) => this.token = token);
    print("My token is $token");
    saveToken(token);
  }

  // Write the user token to the user's profile
  void saveToken(String? token) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'token': token});
  }

  // Configure listeners for notifications
  initInfo() {
    var androidInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettings = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(initSettings);

    FirebaseMessaging.onMessage.listen((event) async {
      AndroidNotificationDetails androidSpecs =
          const AndroidNotificationDetails('0', 'reddam-cce',
              importance: Importance.max,
              actions: [AndroidNotificationAction('1', 'ACCEPT')]);

      NotificationDetails notifDetails =
          NotificationDetails(android: androidSpecs);
      await flutterLocalNotificationsPlugin.show(
          0, event.notification?.title, event.notification?.body, notifDetails,
          payload: event.data['title']);
    });
  }

  // Send notification to user with specific token
  void sendNotification(String uid, String title, String body) async {
    try {
      // Given user, extract their token from profile
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("Users").doc(uid).get();
      String token = userDoc['token'];

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAZBShJDg:APA91bEJqWshi4L26rz195lRjrz8mhPptHY6KrbtcdpKtuiP0iMhrWkO5lxhZ4wYJjnXhz_DnjPvOcyVoWiQy5yqDFY9C6JWRhN0TT25CZe2XqPLBXLx8--9QZ_ORDMWQg-6OCEfhVfL'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "reddam-cce"
            },
            "to": token,
          }));
    } catch (e) {
      print(e.toString());
    }
  }
}
