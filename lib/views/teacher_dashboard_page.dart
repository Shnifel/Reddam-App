// ignore_for_file: prefer_const_constructors

import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/panel_center/panel_center_page.dart';
import 'package:cce_project/panel_left/panel_left_page.dart';
import 'package:cce_project/panel_right/panel_right_page.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/components/side_menu.dart';
import 'package:cce_project/widgets/app_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Extract the arguments passed to this page
    UserInfoArguments arguments =
        ModalRoute.of(context)!.settings.arguments as UserInfoArguments;
    String userID = arguments.userID;
    String name = arguments.name;

    return Scaffold(
      //The body is filled with the StudentDashboard class below
      body: TeacherDashboard(userID, name),
    );
  }
}

class TeacherDashboard extends StatefulWidget {
  //We have to initialise the variables
  String userID = '';
  String name = '';

  //Constructor
  TeacherDashboard(String passedUserID, String passedName, {super.key}) {
    userID = passedUserID;
    name = passedName;
  }

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState(userID, name);
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  //We have to initialise the variable before getting it from the constructor
  String userID = '';
  String name = '';

  //Constructor
  _TeacherDashboardState(String passedUserID, String passedName) {
    userID = passedUserID;
    name = passedName;
  }

  List<Segment> segments = [
    Segment(
        value: 30, color: primaryColour, label: const Text("Teacher stuff")),
    Segment(
        value: 54,
        color: secondaryColour,
        label: const Text("Tecaher stuff 2")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: (ResponsiveLayout.isTinyLimit(context) ||
                  ResponsiveLayout.isTinyHeightLimit(context))
              ? Container()
              : AppBarWidget()),
      body: ResponsiveLayout(
        tiny: Container(),
        phone: PanelCenterPage(),
        tablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(child: PanelCenterPage()),
          ],
        ),
        largeTablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(child: PanelCenterPage()),
            Expanded(child: PanelRightPage()),
          ],
        ),
        computer: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(child: PanelCenterPage()),
            Expanded(child: PanelRightPage()),
          ],
        ),
      ),
      drawer: SideMenu(),
      backgroundColor: primaryColour.withOpacity(0.9),
    );
  }
}
