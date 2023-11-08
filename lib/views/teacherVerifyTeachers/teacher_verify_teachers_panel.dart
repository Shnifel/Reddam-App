import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherVerifyTeachers/teachers_verify.dart';
import 'package:flutter/material.dart';

class TeacherVerifyTeachersPanelPage extends StatefulWidget {
  @override
  _TeacherVerifyTeachersPanelPageState createState() =>
      _TeacherVerifyTeachersPanelPageState();
}

class _TeacherVerifyTeachersPanelPageState extends State<TeacherVerifyTeachersPanelPage> {
  List _teachers = [];
  bool _isLoading = true;

  void loadTeachers() async {
    setState(() {
      _isLoading = true;
    });
    await TeacherFirestoreService()
        .getUnverifiedTeachers().then((data) => setState(
              () {
                _teachers = data;
                _isLoading = false;
              },
            ));
  }

  void onValidateComplete() {
    loadTeachers();
  }

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColour))
            : ListView(
                children: _teachers
                    .map((log) => TeachersVerify(log, onValidateComplete))
                    .toList()));
  }
}
