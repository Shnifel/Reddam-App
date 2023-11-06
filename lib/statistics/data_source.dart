import 'package:cce_project/statistics/graph_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class StudentDataSource extends DataGridSource {
  StudentDataSource({required List<Student> students}) {
    dataGridRows = students
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'firstName', value: dataGridRow.firstName),
              DataGridCell<String>(columnName: 'lastName', value: dataGridRow.lastName),
              DataGridCell<String>(columnName: 'grade', value: dataGridRow.grade),
              DataGridCell<double>(columnName: 'total', value: dataGridRow.total),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: (dataGridCell.columnName == 'firstName' || dataGridCell.columnName == 'lastName')
              ? Alignment.centerLeft
              : Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }
}