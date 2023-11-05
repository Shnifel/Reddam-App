import 'package:cce_project/panel_left/panel_left_page.dart';
import 'package:cce_project/panel_right/panel_right_page.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/components/side_menu.dart';
import 'package:cce_project/views/responsive_layout.dart';
import 'package:cce_project/views/teacherEditUser/teacher_edit_user_panel.dart';
import 'package:cce_project/widgets/student_widget.dart';
import 'package:flutter/material.dart';

class TeacherLogHoursPage extends StatefulWidget {
  const TeacherLogHoursPage({super.key});

  @override
  State<TeacherLogHoursPage> createState() => _TeacherLogHoursPageState();
}

class _TeacherLogHoursPageState extends State<TeacherLogHoursPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        tiny: Container(),
        phone: TeacherEditUsersPanelPage(),
        tablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(
              child: TeacherEditUsersPanelPage(),
            ),
          ],
        ),
        largeTablet: Row(
          children: [
            Expanded(
              child: PanelLeftPage(),
            ),
            Expanded(
              child: TeacherEditUsersPanelPage(),
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
              child: TeacherEditUsersPanelPage(),
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
