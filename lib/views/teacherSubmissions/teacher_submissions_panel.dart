import 'package:cce_project/styles.dart';
import 'package:cce_project/widgets/student_widget.dart';
import 'package:flutter/material.dart';

class TeacherSubmissionsPanelPage extends StatefulWidget {
  @override
  _TeacherSubmissionsPanelPageState createState() =>
      _TeacherSubmissionsPanelPageState();
}

class _TeacherSubmissionsPanelPageState
    extends State<TeacherSubmissionsPanelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Text("Log hours"),
                    StudentDataRow({"Name": "Reveluv"}),
                    StudentDataRow({"Name": "Reveluv"}),
                    StudentDataRow({"Name": "Reveluv"}),
                  ],
                ))));
  }
}
