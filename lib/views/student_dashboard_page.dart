import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/services/notifications.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/hours_log_page.dart';
import 'package:cce_project/views/hours_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:cce_project/my_icons_icons.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Extract the arguments passed to this page
    UserInfoArguments arguments =
        ModalRoute.of(context)!.settings.arguments as UserInfoArguments;
    String userID = arguments.userID;
    String name = arguments.name;
    String goal = 'Full Colours';
    double activeHours = 50;
    double passiveHours = 30;

    return Scaffold(
      //The body is filled with the StudentDashboard class below
      body: StudentDashboard(userID, name, goal, activeHours, passiveHours),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  //We have to initialise the variables
  String userID = '';
  String name = '';
  String goal = '';
  double activeHours = 0;
  double passiveHours = 0;

  //Constructor
  StudentDashboard(String passedUserID, String passedName, String passedGoal,
      double passedActiveHours, double passedPassiveHours,
      {super.key}) {
    userID = passedUserID;
    name = passedName;
    goal = passedGoal;
    activeHours = passedActiveHours;
    passiveHours = passedPassiveHours;
  }

  @override
  State<StudentDashboard> createState() =>
      _StudentDashboardState(userID, name, goal, activeHours, passiveHours);
}

class _StudentDashboardState extends State<StudentDashboard> {
  //We have to initialise the variable before getting it from the constructor
  String userID = '';
  String name = '';
  String goal = '';
  double activeHours = 0;
  double passiveHours = 0;
  List<Segment> segments = [];
  double percentActive = 0;

  //variables for bottom nav bar
  int currentIndex = 0; //keeps track of current selected item

  void onTapItem(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  //Constructor
  _StudentDashboardState(String passedUserID, String passedName,
      String passedGoal, double passedActiveHours, double passedPassiveHours) {
    userID = passedUserID;
    name = passedName;
    goal = passedGoal;
    activeHours = passedActiveHours;
    passiveHours = passedPassiveHours;

    segments = [
      Segment(
          value: passiveHours.ceil(),
          color: primaryColour,
          label: const Text("Passive Hours")),
      Segment(
          value: activeHours.ceil(),
          color: secondaryColour,
          label: const Text("Active Hours")),
    ];
  }

  // String name = '';
  @override
  void initState() {
    super.initState();
    NotificationServices notif = NotificationServices();
    notif.requestPermission();
    notif.getToken();
    notif.initInfo();
  }

  // void getData() async {
  //   //Retrieve the users full name
  //   name = (await FirestoreService(uid: userID).getUserData())!;
  //   setState(() {});
  // }

  void aggregateHours() async {
    FirestoreService firestoreService = FirestoreService(uid: userID);
    Map<String, double> hours =
        await firestoreService.aggregateHours() as Map<String, double>;
    setState(() {
      passiveHours = hours['Passive']!;
      activeHours = hours['Active']!;
      percentActive =
          (100.0 * hours['Active']!) / (hours['Active']! + hours['Passive']!);
    });
  }

  @override
  Widget build(BuildContext context) {
    aggregateHours();
    // Hours progress bar
    PrimerProgressBar progressBar = PrimerProgressBar(
      segments: segments = [
        Segment(
            value: passiveHours.ceil(),
            color: primaryColour,
            label: const Text("Passive Hours")),
        Segment(
            value: activeHours.ceil(),
            color: secondaryColour,
            label: const Text("Active Hours")),
      ],
      // Set the maximum number of hours for the bar
      maxTotalValue: 500,
      // Spacing between legend items
      legendStyle: const SegmentedBarLegendStyle(spacing: 80),
    );

    //bottom nav
    BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
        selectedItemColor: primaryColour,
        unselectedItemColor: primaryColour.withOpacity(0.4),
        elevation: 0,

        //allowing for screen switching with item switching
        currentIndex: currentIndex,
        onTap: onTapItem,
        items: [
          //icon 0: home summary
          BottomNavigationBarItem(
              icon: Text(
                String.fromCharCode(MyIcons.home_unfilled.codePoint),
                style: TextStyle(
                  inherit: false,
                  fontSize: 25.0,
                  color: primaryColour.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                  fontFamily: MyIcons.home_unfilled.fontFamily,
                  package: MyIcons.home_unfilled.fontPackage,
                ),
              ),
              activeIcon: Icon(Icons.home_filled),
              label: "Home"),

          //icon 1: log hours
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time_sharp),
              activeIcon: Icon(Icons.access_time_filled),
              label: "Hours"),

          //icon 2: notifications
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_sharp),
              activeIcon: Icon(Icons.notifications_sharp),
              label: "Notifications"),

          //icon 3: gallery
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_outlined),
              activeIcon: Icon(Icons.photo_library),
              label: "Gallery"),

          //icon 4: events
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: "Events"),
        ]);

    List<Widget> screens = [
      //moving between screens, implemented at the bottom of the page

      //home screen
      SingleChildScrollView(
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

                  // Reddam Crest
                  SizedBox(
                    height: 75,
                    width: 200,
                    child:
                        Image.asset("assets/images/ReddamHouseCrest.svg.png"),
                  ),

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
                          child: Text("${(percentActive).round()}% \n Active",
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

                  SizedBox(height: 15),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("You are currently working towards:",
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
                ],
              ),
            ),
          ],
        ),
      ),

      //hours
      Center(
        child: HoursLog(),
      ),

      //notifications
      Center(
        child: Text("notifications!!"),
      ),

      //gallery
      Center(
        child: Text("gallery!!"),
      ),

      //events
      Center(
        child: Text("events!!"),
      ),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.transparent,
        ), // sets the inactive color of the `BottomNavigationBar`
        child: bottomNavigationBar,
      ),
    );
  }
}
