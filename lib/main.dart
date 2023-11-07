import 'package:cce_project/services/badge_notifier.dart';
import 'package:cce_project/services/database.dart';
import 'package:cce_project/views/hours_log_page.dart';
import 'package:cce_project/views/teacherSettings/teacher_settings_page.dart';
import 'package:cce_project/views/teacherSettings/teacher_settings_panel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/login_page.dart';
import 'views/welcome_page.dart';
import 'views/image_upload.dart';
import 'views/signup_page.dart';
import 'views/student_dashboard_page.dart';
import 'views/teacher_dashboard_page.dart';
import "package:device_preview/device_preview.dart";

Future<void> backgroundHandler(RemoteMessage message) async {
  await LocalDatabaseProvider().insertNotification({
    'id': message.data['id'],
    'type': message.data['notificationType'],
    'message': message.data['body'],
    'read': 0,
    'date': DateTime.now().toIso8601String()
  });
  String? title = message.notification!.title;
  String? body = message.notification!.body;
  FlutterLocalNotificationsPlugin().show(0, title, body, null);
}

Future<void> main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BadgeNotifier(), // Initialize your notifier here
      child: const MyApp(),
    ),
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddam CCE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Kollektif',
        dividerColor:
            Colors.transparent, // Set the divider color to transparent
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomePage(),
      // Named routes in the app
      routes: {
        '/loginPage': (context) => const LoginPage(),
        '/signupPage': (context) => const SignUpPage(),
        '/studentDashboardPage': (context) => const StudentDashboardPage(),
        '/teacherDashboardPage': (context) => const TeacherDashboardPage(),
        '/teacherSettingsPage': (context) => const TeacherSettingsPage(),
      },
    );
  }
}
