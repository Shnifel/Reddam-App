import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherNotifications/student_log.dart';
import 'package:flutter/material.dart';

class TeacherNotificationsPanelPage extends StatefulWidget {
  @override
  _TeacherNotificationsPanelPageState createState() =>
      _TeacherNotificationsPanelPageState();
}

class _TeacherNotificationsPanelPageState
    extends State<TeacherNotificationsPanelPage> {
  List<Map<String, dynamic>> _studentLogs = [];
  bool _isLoading = true;

  void loadStudentLogs() async {
    await TeacherFirestoreService()
        .getStudentLogs(filters: {'validated': false}).then((data) => setState(
              () {
                _studentLogs = data;
                _isLoading = false;
              },
            ));
  }

  @override
  void initState() {
    super.initState();
    loadStudentLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? CircularProgressIndicator()
            : ListView(
                children: _studentLogs
                    .map((log) => StudentHoursLog(log, () {}))
                    .toList()));
  }
}
