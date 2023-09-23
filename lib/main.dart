import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'views/login_page.dart';
import 'views/welcome_page.dart';
import 'views/upload_page.dart';
import 'views/signup_page.dart';
import 'views/student_dashboard_page.dart';
import 'views/teacher_dashboard_page.dart';

Future<void> main() async {
  runApp(const MyApp());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      ),
      home: const WelcomePage(),
      // Named routes in the app
      routes: {
        '/loginPage': (context) => const LoginPage(),
        '/signupPage': (context) => const SignUpPage(),
        '/uploadPage': (context) => const ImageUploads(),
        '/studentDashboardPage': (context) => const StudentDashboardPage(),
        '/teacherDashboardPage': (context) => const TeacherDashboardPage(),
      },
    );
  }
}
