import 'package:cce_project/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DataSummaryTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const DataSummaryTable(this.data, {super.key});

  @override
  State<DataSummaryTable> createState() => _DataSummaryTableState();
}

class _DataSummaryTableState extends State<DataSummaryTable> {
  final TextStyle labelStyle = const TextStyle(
      color: secondaryColour, fontSize: 15, fontWeight: FontWeight.bold);
  final TextStyle valueStyle = const TextStyle(
      color: primaryColour, fontWeight: FontWeight.bold, fontSize: 12);
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Text("No data found");
    } else {
      List<String> fields = widget.data[0].keys.toList();

      return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DataTable(
                            sortColumnIndex: _sortColumnIndex,
                            sortAscending: _sortAscending,
                            border: TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.black, width: 0.7),
                              borderRadius: BorderRadius.circular(10),
                              bottom:
                                  BorderSide(color: Colors.black, width: 0.7),
                              top: BorderSide(color: Colors.black, width: 0.7),
                              left: BorderSide(color: Colors.black, width: 0.7),
                              right:
                                  BorderSide(color: Colors.black, width: 0.7),
                            ),
                            columns: fields
                                .map(
                                  (field) => DataColumn(
                                    label: Text(
                                      field,
                                      style: labelStyle,
                                    ),
                                    onSort: (columnIndex, ascending) {
                                      setState(() {
                                        _sortColumnIndex = columnIndex;
                                        _sortAscending = ascending;

                                        widget.data.sort(((a, b) {
                                          if (ascending) {
                                            return a[fields[_sortColumnIndex]]
                                                .compareTo(b[
                                                    fields[_sortColumnIndex]]);
                                          } else {
                                            return b[fields[_sortColumnIndex]]
                                                .compareTo(a[
                                                    fields[_sortColumnIndex]]);
                                          }
                                        }));
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                            rows: widget.data
                                .map(
                                  (row) => DataRow(
                                      cells: fields
                                          .map(
                                            (field) => DataCell(Text(row[field],
                                                style: valueStyle)),
                                          )
                                          .toList()),
                                )
                                .toList()),
                      ]))));
    }
  }
}
