import 'package:cce_project/styles.dart';
import 'package:flutter/material.dart';

class StudentDataRow extends StatefulWidget {
  final Map<dynamic, dynamic> data;
  final bool? startSelected;
  final Function(bool) updateChecked;

  const StudentDataRow(this.startSelected, this.data, this.updateChecked,
      {super.key});

  @override
  State<StudentDataRow> createState() => _StudentDataRowState();
}

class _StudentDataRowState extends State<StudentDataRow> {
  String? firstName;
  String? lastName;
  String? uid;

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    firstName = widget.data['firstName'];
    lastName = widget.data['lastName'];
    uid = widget.data['id'];
    if (widget.startSelected == true) {
      _isSelected = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Checkbox(
              activeColor: secondaryColour,
              value: _isSelected,
              onChanged: (val) {
                {
                  setState(
                    () {
                      _isSelected = val!;
                    },
                  );
                  widget.updateChecked(val!);
                }
              }),
          Text(lastName! + ", " + firstName!)
        ],
      ),
    );
  }
}
