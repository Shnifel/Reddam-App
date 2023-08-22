import 'package:cce_project/styles.dart';
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
                      Navigator.pushNamed(context, '/loginPage');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColour,
                        minimumSize: const Size.fromHeight(50),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text('Get Started',
                                  style: welcomePageText.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                    ),
                  ),
                )
              ]
            ),
        ),
    );
  }
}
