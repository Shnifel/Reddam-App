import 'package:flutter/material.dart';

class StudentDataRow extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const StudentDataRow(this.data, {super.key});

  @override
  State<StudentDataRow> createState() => _StudentDataRowState();
}

class _StudentDataRowState extends State<StudentDataRow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Checkbox(value: true, onChanged: (val) => {}),
          Text("Student name")
        ],
      ),
    );
  }
}
