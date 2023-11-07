import 'package:cce_project/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HoursLogInfo extends StatefulWidget {
  final Map<String, dynamic> hoursInfo;

  const HoursLogInfo({required this.hoursInfo, super.key});

  @override
  State<HoursLogInfo> createState() => _HoursLogInfoState();
}

class _HoursLogInfoState extends State<HoursLogInfo> {
  final TextStyle labelStyle = TextStyle(color: secondaryColour, fontSize: 12);
  final TextStyle valueStyle = TextStyle(
      color: primaryColour, fontWeight: FontWeight.bold, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.hoursInfo;

    String hoursType = data['hours_type'];
    String activity = data['activity'];
    String? active_type = data['active_type'];
    DateTime date = (data['date'] as Timestamp).toDate();
    double amount = data['amount'];
    List<String> evidence = data['evidenceUrls'].cast<String>();
    List<String> optional = data['optionalUrls'].cast<String>();
    String? receiptNo = data['receipt_no'];
    bool validated = data['validated'];
    bool? accepted = data['accepted'];
    String? rejection_message = data['rejection_message'];

    return Container(
      alignment: Alignment.topLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              DataCell(Text(DateFormat('yyyy-MM-dd hh:mm a').format(date),
                  style: valueStyle)),
            ]),
            DataRow(cells: [
              DataCell(Text('Receipt No.', style: labelStyle)),
              DataCell(Text(
                  receiptNo == "" || receiptNo == null ? "-" : receiptNo,
                  style: valueStyle)),
            ]),
            DataRow(cells: [
              DataCell(Text('Type', style: labelStyle)),
              DataCell(Text(hoursType, style: valueStyle)),
            ]),
            DataRow(cells: [
              DataCell(Text('Activity', style: labelStyle)),
              DataCell(Text(activity, style: valueStyle)),
            ]),
            DataRow(cells: [
              DataCell(Text('Hours', style: labelStyle)),
              DataCell(Text('$amount', style: valueStyle)),
            ]),
            DataRow(cells: [
              DataCell(Text('Status', style: labelStyle)),
              DataCell(Text(
                  validated
                      ? (accepted! ? 'Approved' : 'Rejected')
                      : 'Pending approval',
                  style: TextStyle(
                      color: validated
                          ? (accepted! ? Colors.green : Colors.red)
                          : Colors.yellow,
                      fontWeight: FontWeight.bold))),
            ]),
            if (validated && !accepted!)
              DataRow(cells: [
                DataCell(Text('Rejection message', style: labelStyle)),
                DataCell(Text(rejection_message!,
                    style: valueStyle.copyWith(color: Colors.red))),
              ]),
          ],
        ),
        if (evidence.isNotEmpty)
          DataTable(
              headingRowHeight: 0,
              dataRowMaxHeight: 120.0 * evidence.length,
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
                      children: evidence
                          .map(
                            (image) => ClipRRect(
                              child: Image.network(
                                image,
                                loadingBuilder: (context, child,
                                        loadingProgress) =>
                                    (loadingProgress == null)
                                        ? child
                                        : CircularProgressIndicator(color: primaryColour),
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(child: Text("Image not found")),
                                width: 100,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          )
                          .toList())),
                ]),
              ])
      ]),
    );
  }
}
