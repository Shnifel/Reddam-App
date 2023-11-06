import 'package:cce_project/helpers/date_forrmater.dart';
import 'package:cce_project/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentHoursLog extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function onComplete;

  const StudentHoursLog(this.data, this.onComplete, {super.key});

  @override
  State<StudentHoursLog> createState() => _StudentHoursLogState();
}

class _StudentHoursLogState extends State<StudentHoursLog> {
  final TextStyle labelStyle =
      const TextStyle(color: secondaryColour, fontSize: 12);
  final TextStyle valueStyle = const TextStyle(
      color: primaryColour, fontWeight: FontWeight.bold, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Container(
        decoration: BoxDecoration(
            color: secondaryColour.withAlpha(50),
            borderRadius: BorderRadius.circular(10)),
        // ignore: prefer_const_constructors
        child: ExpansionTile(
          iconColor: secondaryColour,
          textColor: primaryColour,
          title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Column(children: [
                  // Main notification row
                  Row(children: <Widget>[
                    // Header and summary line
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data['firstName'] +
                              " " +
                              widget.data['lastName'] +
                              " (Grade " +
                              widget.data['grade'] +
                              widget.data['class'] +
                              ")",
                          style: const TextStyle(
                              fontSize: 14,
                              color: primaryColour,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          // ignore: prefer_interpolation_to_compose_strings
                          "Logged new " +
                              widget.data['hours_type'] +
                              " " +
                              (widget.data['active_type'] != null
                                  ? widget.data['activity'] + " "
                                  : "") +
                              "hours",
                          style: const TextStyle(fontSize: 12),
                        )
                      ],
                    ),

                    // Date and approval status
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            DateFormatter.formatRelativeDate(
                                (widget.data['date'] as Timestamp).toDate()),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    )),
                  ]),
                ]))
              ]),
          children: [
            Container(
                alignment: Alignment.topLeft,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataTable(
                        headingRowHeight: 0,
                        columns: const [
                          DataColumn(
                              label: Text(
                            'Field',
                            style: TextStyle(fontSize: 12),
                          )),
                          DataColumn(label: Text('Value')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('Date', style: labelStyle)),
                            DataCell(Text(
                                DateFormat('yyyy-MM-dd hh:mm a').format(
                                    (widget.data['date'] as Timestamp)
                                        .toDate()),
                                style: valueStyle)),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Receipt No.', style: labelStyle)),
                            DataCell(Text(
                                widget.data['receipt_no'] == "" ||
                                        widget.data['receipt_no'] == null
                                    ? "-"
                                    : widget.data['receipt_no'],
                                style: valueStyle)),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Activity', style: labelStyle)),
                            DataCell(Text(
                                // ignore: prefer_if_null_operators
                                widget.data['active_type'] != null
                                    ? widget.data['active_type']
                                    : widget.data['activity'],
                                style: valueStyle)),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Hours', style: labelStyle)),
                            DataCell(Text('${widget.data['amount']}',
                                style: valueStyle)),
                          ]),
                        ],
                      ),
                      if (widget.data['evidenceUrls'] != null)
                        DataTable(
                            headingRowHeight: 0,
                            dataRowMaxHeight:
                                120.0 * widget.data['evidenceUrls'].length,
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'Field',
                                style: TextStyle(fontSize: 12),
                              )),
                              DataColumn(label: Text('Value')),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text(
                                  'Evidence',
                                  style: labelStyle,
                                  textAlign: TextAlign.start,
                                )),
                                DataCell(Column(
                                    children: List<Widget>.from(widget
                                        .data['evidenceUrls']
                                        .map((e) => e.toString())
                                        .toList()
                                        .map(
                                          (image) => ClipRRect(
                                            child: Image.network(
                                              image,
                                              loadingBuilder: (context, child,
                                                      loadingProgress) =>
                                                  (loadingProgress == null)
                                                      ? child
                                                      : CircularProgressIndicator(),
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Center(
                                                      child: Text(
                                                          "Image not found")),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        )))),
                              ]),
                            ]),
                    ])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 75,
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius here
                        ),
                        backgroundColor: Colors.green.withAlpha(100),
                        side: const BorderSide(
                          color: primaryColour,
                          width: 0,
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.green),
                            Text('Accept',
                                style: loginPageText.copyWith(
                                  fontSize: 15,
                                  color: Colors.black,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                          ])),
                ),
                Container(
                  height: 75,
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the radius here
                        ),
                        backgroundColor: Colors.red.withAlpha(100),
                        side: const BorderSide(
                          color: primaryColour,
                          width: 0,
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            Text('Reject',
                                style: loginPageText.copyWith(
                                  fontSize: 15,
                                  color: Colors.black,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                          ])),
                ),
              ],
            ),
            const Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  decoration: InputDecoration(
                      iconColor: secondaryColour,
                      hintText: 'Rejection message',
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primaryColour))),
                  style: TextStyle(color: Colors.black),
                ))
          ],
        ),
      ),
    );
  }
}
