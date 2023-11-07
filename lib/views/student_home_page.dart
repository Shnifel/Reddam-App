import 'dart:ffi';

import 'package:cce_project/arguments/student_home_args.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:cce_project/styles.dart';

class StudentHomePage extends StatefulWidget {
  //We have to initialise the variables
  String name = '';
  String userID = '';

  //Constructor
  StudentHomePage(String passedName, String passedUserId, {super.key}) {
    name = passedName;
    userID = passedUserId;
  }

  @override
  State<StudentHomePage> createState() => _StudentHomePageState(name, userID);
}

class _StudentHomePageState extends State<StudentHomePage> {
  //We have to initialise the variables
  String name = '';
  String userID = '';

  //Extract the arguments passed to this page
  // StudentHomeArgs arguments =
  //     ModalRoute.of(context)!.settings.arguments as StudentHomeArgs;
  // String goal = arguments.goal;
  // int goalHours = arguments.goalHours;
  // double activeHours = arguments.activeHours;
  // double passiveHours = arguments.passiveHours;
  double percentActive = 0;
  String goal = 'Full Colours';
  int goalHours = 100;
  double activeHours = 0;
  double passiveHours = 0;

  //Constructor
  _StudentHomePageState(String passedName, String passedUserId) {
    name = passedName;
    userID = passedUserId;
  }

  @override
  void initState() {
    super.initState();
    aggregateHours();
  }

  void aggregateHours() async {
    FirestoreService firestoreService = FirestoreService(uid: userID);
    Map<String, double> hours =
        await firestoreService.aggregateHours() as Map<String, double>;
    setState(() {
      passiveHours = hours['Passive']!;
      activeHours = hours['Active']!;
      if (passiveHours == 0 && activeHours == 0) {
        percentActive = 0;
      } else {
        percentActive =
            (100.0 * hours['Active']!) / (hours['Active']! + hours['Passive']!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Segment> segments = [
      Segment(
          value: passiveHours.ceil(),
          color: primaryColour,
          label: const Text("Passive Hours")),
      Segment(
          value: activeHours.ceil(),
          color: secondaryColour,
          label: const Text("Active Hours")),
    ];

    // Hours progress bar
    PrimerProgressBar progressBar = PrimerProgressBar(
      segments: segments,
      // Set the maximum number of hours for the bar
      maxTotalValue: goalHours,
      // Spacing between legend items
      legendStyle: const SegmentedBarLegendStyle(spacing: 80),
    );

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 75, 20, 10),
              child: Column(
                // Add spacing between column elements
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Students name
                  Row(
                    children: [
                      FittedBox(
                          // This ensures that the student's name is resized to fit the screen
                          fit: BoxFit.cover,
                          child: Text("Hi, $name!",
                              style: loginPageText.copyWith(
                                  fontSize: 35, fontWeight: FontWeight.bold))),
                    ],
                  ),

                  SizedBox(
                    height: 55,
                  ),

                  //goal
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      // spacing: 100,
                      runSpacing: 7,
                      children: [
                        Text("You are currently working towards: ",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                            )),

                        // Current objective
                        Text(
                          goal,
                          style: TextStyle(
                            color: primaryColour,
                            fontSize: 23,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  //progress
                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColour.withOpacity(0.1),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Column(children: <Widget>[
                        // Active hour percentage
                        Container(
                          width: 150,
                          height: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: secondaryColour,
                            ),
                          ),
                          child: Text("${percentActive.round()}% \n Active",
                              style: loginPageText,
                              textAlign: TextAlign.center),
                        ),

                        SizedBox(height: 15),

                        // Progress bar
                        Container(
                          child: progressBar,
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
