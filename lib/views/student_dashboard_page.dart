import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/student_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:cce_project/my_icons_icons.dart';
import 'upload_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
  DateTime today=DateTime.now();
 // String currentday=today.toString().split(" ")[0];

  //variables for bottom nav bar
  int currentIndex = 0; //keeps track of current selected item

  void onTapItem(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _onDaySelected(DateTime day, DateTime FocusedDay){
    setState(() {
      today=day;
    });
  }

  //Constructor
  _StudentDashboardState(String passedUserID, String passedName) {
    userID = passedUserID;
    name = passedName;
  }

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
                String.fromCharCode(
                    MyIcons.home_unfilled.codePoint),
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
          label: "Home"
        ),

        //icon 1: log hours
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time_sharp), 
          activeIcon: Icon(Icons.access_time_filled),
          label: "Hours"
        ),
        
        //icon 2: notifications
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_sharp), 
          activeIcon: Icon(Icons.notifications_sharp),
          label: "Notifications"
        ),
        
        //icon 3: gallery
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined), 
          activeIcon: Icon(Icons.photo_library), 
          label: "Gallery"
        ),

        //icon 4: events
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined), 
          activeIcon: Icon(Icons.calendar_month), 
          label: "Events"
        ),
      ]
    
    );

    List<Widget> screens = [ //moving between screens

      //home screen
      StudentHomePage(name),

      //hours
      Center(
        child: Text("Hours!!"),
      ),

      //notifications
      Center(
        child: Text("notifications!!"),
      ),

      //gallery
      ImageUploads(),

      //events
      Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: Column(
            children: <Widget>[
              TableCalendar(
                rowHeight: 75,
                headerStyle: HeaderStyle(formatButtonVisible: false,titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day)=> isSameDay(day,today),
                focusedDay:today,
                firstDay: DateTime.utc(2023,09,20),
                lastDay: DateTime.utc(2030,12,31),
                onDaySelected: _onDaySelected,
              ),
            ],
          ),
        ),
      )
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
