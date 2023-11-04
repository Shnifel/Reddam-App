import 'package:cce_project/styles.dart';
import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  final String hours_type;
  final String activty;
  final double amount;
  final String? receipt_no;
  final String? note;

  final TextStyle labelStyle = TextStyle(color: secondaryColour);
  final TextStyle valueStyle =
      TextStyle(color: primaryColour, fontWeight: FontWeight.bold);

  Success({
    required this.hours_type,
    required this.activty,
    required this.amount,
    required this.receipt_no,
    this.note = "",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 75, 20, 10),
      child: Container(
          alignment: Alignment.topCenter,
          width: 500,
          height: 600,
          decoration: BoxDecoration(
              color: secondaryColour.withOpacity(0.1),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(90, 54, 155, 54),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.done_rounded,
                    size: 50,
                    color: Color.fromARGB(255, 4, 109, 4),
                  ),
                ),
              ),
              const Text("Successfully logged new hours:"),
              const SizedBox(
                height: 20,
              ),
              DataTable(
                headingRowHeight: 0,
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('Receipt No.', style: labelStyle)),
                    DataCell(Text(
                        receipt_no == "" || receipt_no == null
                            ? "-"
                            : receipt_no!,
                        style: valueStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Type', style: labelStyle)),
                    DataCell(Text(hours_type, style: valueStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Activity', style: labelStyle)),
                    DataCell(Text(activty, style: valueStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Hours', style: labelStyle)),
                    DataCell(Text('$amount', style: valueStyle)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Status', style: labelStyle)),
                    const DataCell(Text('Pending approval',
                        style: TextStyle(
                            color: Color.fromARGB(255, 202, 190, 18),
                            fontWeight: FontWeight.bold))),
                  ]),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (note != null && note != "")
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    alignment: Alignment.topLeft,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(50, 255, 200, 0),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.warning,
                            color: Color.fromARGB(255, 255, 150, 0),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Text(
                              "Note:" + note!,
                              overflow: TextOverflow.visible,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              const Text("Keep up the good work !")
            ],
          )),
    ))));
  }
}
