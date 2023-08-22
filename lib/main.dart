import 'package:flutter/material.dart';
import 'views/login_page.dart';
import 'views/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(),
      // Named routes in the app
      routes: {
        '/loginPage': (context) => const LoginPage(),
       },
    );
  }
}
