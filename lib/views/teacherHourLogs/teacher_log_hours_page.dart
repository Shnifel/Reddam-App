import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/components/side_menu.dart';
import 'package:cce_project/views/teacherHourLogs/teacher_log_hours_panel.dart';
import 'package:cce_project/widgets/app_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:cce_project/panel_center/panel_center_page.dart';
import 'package:cce_project/panel_left/panel_left_page.dart';
import 'package:cce_project/panel_right/panel_right_page.dart';
import 'package:cce_project/views/teacherNotifications/teacher_notifications_panel.dart';

class TeacherLogHoursPage extends StatefulWidget {
  const TeacherLogHoursPage({super.key});

  @override
  _TeacherNotifications createState() => _TeacherNotifications();
}

class _TeacherNotifications extends State<TeacherLogHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 50),
          child: (ResponsiveLayout.isTinyLimit(context) ||
                  ResponsiveLayout.isTinyHeightLimit(context))
              ? Container()
              : AppBarWidget(5)),
      body: ResponsiveLayout(
        tiny: Container(),
        phone: TeacherLogHoursPanelPage(),
        tablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(
              child: TeacherLogHoursPanelPage(),
            ),
          ],
        ),
        largeTablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(
              child: TeacherLogHoursPanelPage(),
            ),
            Expanded(child: PanelRightPage()),
          ],
        ),
        computer: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(
              child: TeacherLogHoursPanelPage(),
            ),
            Expanded(child: PanelRightPage()),
          ],
        ),
      ),
      drawer: const SideMenu(),
      backgroundColor: primaryColour.withOpacity(0.9),
    );
  }
}
