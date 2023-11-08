// ignore_for_file: use_build_context_synchronously

import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/authentication.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotVerifiedPage extends StatelessWidget {
  const NotVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: primaryColour,),
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text("You have not been verified", style: TextStyle(fontSize: 30),),
            ]),
      ),
    );
  }
}
