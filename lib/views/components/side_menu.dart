import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/authentication.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherEditUser/teacher_edit_user_page.dart';
import 'package:cce_project/views/teacherHourLogs/teacher_log_hours_page.dart';
import 'package:cce_project/views/teacherHoursSummary/teacher_hours_summary_page.dart';
import 'package:cce_project/views/teacherNotifications/teacher_notifications_page.dart';
import 'package:cce_project/views/teacherSettings/teacher_settings_page.dart';
import 'package:cce_project/views/teacherStatistics/teacher_statistics_page.dart';
import 'package:cce_project/views/teacherSubmissions/teacher_submissions_page.dart';
import 'package:cce_project/views/teacherTimetable/teacher_timetable_page.dart';
import 'package:cce_project/views/teacherUsers/teacher_users_page.dart';
import 'package:cce_project/views/teacher_dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cce_project/views/responsive_layout.dart';

class ButtonsInfo {
  String title;
  IconData icon;

  ButtonsInfo({required this.title, required this.icon});
}

class Task {
  String task;
  double taskValue;
  Color color;

  Task({required this.task, required this.taskValue, required this.color});
}

int _currentIndex = 0;

List<ButtonsInfo> _buttonNames = [
  ButtonsInfo(title: "Home", icon: Icons.home),
  ButtonsInfo(title: "Settings", icon: Icons.settings),
  ButtonsInfo(title: "Notifications", icon: Icons.notifications),
  ButtonsInfo(title: "Statistics", icon: Icons.pie_chart_sharp),
  ButtonsInfo(title: "Timetable", icon: Icons.calendar_month_sharp),
  ButtonsInfo(title: "Log Hours", icon: Icons.access_time_outlined),
  ButtonsInfo(title: "Edit User", icon: Icons.verified_user),
  ButtonsInfo(title: "Users", icon: Icons.supervised_user_circle_rounded),
  ButtonsInfo(title: "Hours summary", icon: Icons.share),
  ButtonsInfo(title: "Log Out", icon: Icons.logout_sharp),
];

class SideMenu extends StatefulWidget {
  const SideMenu({
    super.key,
  });

  @override
  State<SideMenu> createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColour,
      elevation: 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0 * 4),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  "Teacher Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                trailing: !ResponsiveLayout.isComputer(context)
                    ? IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      )
                    : null,
              ),
              ...List.generate(
                _buttonNames.length,
                (index) => Column(
                  children: [
                    Container(
                      decoration: (index) == _currentIndex
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: ListTile(
                        title: Text(
                          _buttonNames[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        leading: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            _buttonNames[index].icon,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            _currentIndex = index;
                          });
                          if (_buttonNames[index].title == "Home") {
                            User? currentUser = AuthService().currentUser;
                            Map<dynamic, dynamic> userData =
                                await FirestoreService(uid: currentUser!.uid)
                                    .getData(currentUser.uid);
                            Navigator.pushNamed(
                                context, '/teacherDashboardPage',
                                arguments: UserInfoArguments(
                                    currentUser.uid, userData["firstName"]));
                          } else if (_buttonNames[index].title == "Settings") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherSettingsPage()),
                            );
                          } else if (_buttonNames[index].title ==
                              "Notifications") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherNotificationsPage()),
                            );
                          } else if (_buttonNames[index].title == "Edit User") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherEditPage()),
                            );
                          } else if (_buttonNames[index].title == "Log Hours") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherLogHoursPage()),
                            );
                          } else if (_buttonNames[index].title == "Timetable") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherTimetablePage()),
                            );
                          } else if (_buttonNames[index].title ==
                              "Statistics") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherStatisticsPage()),
                            );
                          } else if (_buttonNames[index].title == "Users") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeacherUsersPage()),
                            );
                          } else if (_buttonNames[index].title ==
                              "Hours summary") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TeacherHoursSummaryPage()),
                            );
                          } else if (_buttonNames[index].title == "Log Out") {
                            FirebaseAuth.instance.signOut();
                            Navigator.pushNamed(context, '/loginPage');
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.white,
                      thickness: 0.1,
                    ),
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

void incrementCounter() {
  _currentIndex++;
}
