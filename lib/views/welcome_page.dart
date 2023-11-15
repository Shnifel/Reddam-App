// ignore_for_file: use_build_context_synchronously

import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/authentication.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/services/user_database.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
            image: AssetImage("assets/images/ReddamHouseLogo.svg.png"),
            fit: BoxFit.contain),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50, left: 0, right: 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              //get started button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    //go to login page
                    User? currentUser = AuthService().currentUser;
                    if (currentUser == null) {
                      Navigator.pushNamed(context, '/loginPage');
                    } else {
                      Map<dynamic, dynamic> userData;

                      List<Map<dynamic, dynamic>> cachedUsers =
                          await UserLocalCache().getUser(currentUser.uid);

                      if (cachedUsers.isEmpty) {
                        userData = await FirestoreService(uid: currentUser.uid)
                            .getData(currentUser.uid);
                      } else {
                        Map<dynamic, dynamic> data = cachedUsers[0];
                        userData = {
                          ...data,
                          "isTeacher": data["isTeacher"] == 1 ? true : false,
                          "isVerified": data["isVerified"] == 1 ? true : false
                        };
                      }

                      if (userData["isTeacher"] == true &&
                          userData["isVerified"] == true) {
                        Navigator.pushNamed(context, '/teacherDashboardPage',
                            arguments: UserInfoArguments(
                                currentUser.uid,
                                userData["firstName"] +
                                    " " +
                                    userData["lastName"]));
                      } else {
                        Navigator.pushNamed(context, '/studentDashboardPage',
                            arguments: UserInfoArguments(
                                currentUser.uid,
                                userData["firstName"] +
                                    " " +
                                    userData["lastName"]));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColour,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Text('Get Started',
                        style: loginPageText.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        )),
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
