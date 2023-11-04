import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/authentication.dart';
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
                  onPressed: () {
                    //go to login page
                    User? currentUser = AuthService().currentUser;
                    if (currentUser == null) {
                      Navigator.pushNamed(context, '/loginPage');
                    } else {
                      print("Here uid is $currentUser.uid");
                      Navigator.pushNamed(context, '/studentDashboardPage',
                          arguments:
                              UserInfoArguments(currentUser.uid, "Test"));
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
