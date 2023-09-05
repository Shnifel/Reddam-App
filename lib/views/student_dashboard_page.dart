import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Extract the arguments passed to this page
    UserInfoArguments arguments = ModalRoute.of(context)!.settings.arguments as UserInfoArguments;
    String userID = arguments.userID;
    String name = arguments.name;

    return Scaffold(
      //The body is filled with the StudentDashboard class below
      body: StudentDashboard(userID, name),
    );
  }
}

class StudentDashboard extends StatefulWidget {

  //We have to initialise the variables
  String userID = '';
  String name = '';

  //Constructor
  StudentDashboard(String passedUserID, String passedName, {super.key}) {
    userID = passedUserID;
    name = passedName;
  }

  @override
  State<StudentDashboard> createState() => _StudentDashboardState(userID, name);
}

class _StudentDashboardState extends State<StudentDashboard> {

  //We have to initialise the variable before getting it from the constructor
  String userID = '';
  String name = '';

  //Constructor
  _StudentDashboardState(String passedUserID, String passedName) {
    userID = passedUserID;
    name = passedName;
  }

  List<Segment> segments = [
    Segment(value: 30, color: primaryColour, label: const Text("Passive Hours")),
    Segment(value: 54, color: secondaryColour, label: const Text("Active Hours")),
  ];

  // String name = '';
  // @override
  // void initState() {
  //   super.initState();
  //   getData();
  // }

  // void getData() async {
  //   //Retrieve the users full name
  //   name = (await FirestoreService(uid: userID).getUserData())!;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {

    // Hours progress bar
    PrimerProgressBar progressBar = PrimerProgressBar(
      segments: segments,
      // Set the maximum number of hours for the bar
      maxTotalValue: 150,
      // Spacing between legend items
      legendStyle: const SegmentedBarLegendStyle(spacing: 80),
    );
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 10),
          child: Column(
            // Add spacing between column elements
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget> [

              // Students name
              FittedBox(
                // This ensures that the student's name is resized to fit the screen
                fit: BoxFit.cover, 
                child: Text(name, style: loginPageText.copyWith(fontSize: 200))
              ),

              // Reddam Crest
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("assets/images/ReddamHouseCrest.svg.png"),
              ),

              Text("You are currently working towards", style: loginPageText),

              // Current objective
              Text("Full Colours", style: loginPageText,),

              // Progress bar
              Container(
                child: progressBar,
              ),
              
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
                child: Text("80% \n Active", style: loginPageText, textAlign: TextAlign.center),
              ),

              // Log hours button
              OutlinedButton(
                onPressed: (){},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: primaryColour,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              'log hours',
                              style: loginPageText.copyWith(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
