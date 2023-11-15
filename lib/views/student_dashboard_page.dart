import 'dart:math';

import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/badge_notifier.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/services/notifications.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/event_page.dart';
import 'package:cce_project/views/hours_history_page.dart';
import 'package:cce_project/views/hours_log_page.dart';
import 'package:cce_project/views/hours_page.dart';
import 'package:cce_project/views/notifications_page.dart';
import 'package:cce_project/views/student_gallery_page.dart';
import 'package:cce_project/widgets/notification.dart' as Notification;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:cce_project/my_icons_icons.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

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
    double activeHours = 0;
    double passiveHours = 0;

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
  double passiveHours = 1;

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
  List<String> goals = ['Life Orientation', 'Half Colours', 'Full Colours'];
  List<double> goalValues = [20, 120, 150];
  int goalIndex = 0;
  int goalValue = 1;
  double percentActive = 0;
  double maxTotalValue = 1;
  DateTime today = DateTime.now();

  //variables for bottom nav bar
  int currentIndex = 0; //keeps track of current selected item
  String? focusDoc;

  void onTapItem(int index) {
    setState(() {
      focusDoc = null;
      currentIndex = index;
      if (index == 0) {
        aggregateHours();
      }
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
    aggregateHours();
    NotificationServices notif = NotificationServices(context);
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
      if (passiveHours + activeHours < 20) {
        goal = goals[0];
        goalIndex = 0;
        maxTotalValue = 20;
      } else if (passiveHours + activeHours < 120) {
        goal = goals[1];
        goalIndex = 1;
        maxTotalValue = 120;
      } else {
        goal = goals[2];
        goalIndex = 2;
        maxTotalValue = 150;
        activeHours = activeHours >= 120 ? 120 : activeHours;
        passiveHours = passiveHours >= 30 ? 30 : passiveHours;
      }
      if (passiveHours == 0 && activeHours == 0) {
        percentActive = 0;
      } else {
        percentActive =
            (100.0 * (activeHours + passiveHours)) / (maxTotalValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int badgeCount = context.watch<BadgeNotifier>().count;

    // Hours progress bar
    PrimerProgressBar progressBar = PrimerProgressBar(
      segments: segments = [
        if (goalIndex < 2)
          Segment(
              value: (passiveHours + activeHours).ceil(),
              color: primaryColour,
              label: const Text("Total Hours")),
        if (goalIndex == 2)
          Segment(
              value: passiveHours.ceil(),
              color: primaryColour,
              label: const Text("Passive Hours")),
        if (goalIndex == 2)
          Segment(
              value: activeHours.ceil(),
              color: secondaryColour,
              label: const Text("Active Hours")),
      ],
      // Set the maximum number of hours for the bar
      maxTotalValue: maxTotalValue.floor(),
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
          const BottomNavigationBarItem(
              icon: Icon(Icons.access_time_sharp),
              activeIcon: Icon(Icons.access_time_filled),
              label: "Hours"),

          //icon 2: notifications
          BottomNavigationBarItem(
              icon: badgeCount != 0
                  ? Badge(
                      label: Text('$badgeCount'),
                      child: const Icon(Icons.notifications_none_sharp))
                  : const Icon(Icons.notifications_none_sharp),
              activeIcon: const Icon(Icons.notifications_sharp),
              label: "Notifications"),

          //icon 3: gallery
          const BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_outlined),
              activeIcon: Icon(Icons.photo_library),
              label: "Gallery"),

          //icon 4: events
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: "Events"),

          //icon 5 : logs history
          const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: "My hours"),
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
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushNamed(context, '/loginPage');
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: secondaryColour,
                        ),
                        label: const Text("Log out",
                            style:
                                TextStyle(color: Colors.black, fontSize: 15)),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                                Colors.white)),
                      )),
                  // Students name
                  SingleChildScrollView(
                      // This ensures that the student's name is resized to fit the screen
                      child: Text("Hi, $name!",
                          style: loginPageText.copyWith(
                              fontSize: 35, fontWeight: FontWeight.bold))),

                  // Reddam Crest
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: SizedBox(
                      //height: MediaQuery.of(context).size.height/4,
                      width: MediaQuery.of(context).size.height/4,
                      child:
                          Image.asset("assets/images/ReddamHouseCrest.svg.png"),
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Current goal: ",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                              )),

                          // Current objective
                          Text(
                            goal,
                            style: const TextStyle(
                              color: primaryColour,
                              fontSize: 23,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                        color: secondaryColour.withOpacity(0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
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
                          child: Text("${(percentActive).round()}% \n Complete",
                              style: loginPageText,
                              textAlign: TextAlign.center),
                        ),

                        const SizedBox(height: 15),

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

      //hours
      const Center(
        child: HoursLog(),
      ),

      //notifications
      Center(
          child: NotificationsPage(
        navigateToHoursHistory: (String? focus) => {
          setState(
            () {
              currentIndex = 5;
              focusDoc = focus;
            },
          )
        },
      )),

      //gallery
      const GalleryPage(),
      //events
      EventsPage(),

      // Hours history page
      Center(child: HoursHistoryPage(focus: focusDoc)),
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
