import 'dart:io';

import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/data_export.dart';
import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/teacherHoursSummary/data_summary.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TeacherHoursSummaryPanelPage extends StatefulWidget {
  @override
  _TeacherHoursSummaryPanelPageState createState() =>
      _TeacherHoursSummaryPanelPageState();
}

class _TeacherHoursSummaryPanelPageState
    extends State<TeacherHoursSummaryPanelPage> {
  TeacherFirestoreService firestoreService = TeacherFirestoreService();
  List<Map<String, dynamic>> studentList = [];
  Map<String, Map<String, dynamic>> aggregatedHours = {};
  List<Map<String, dynamic>> displayData = [];
  bool _dataLoading = false;
  bool _fileDownloading = false;
  String? _grade;
  String? _class;
  String? _house;

  Future<void> loadData() async {
    setState(() {
      _dataLoading = true;
    });

    // No grade selected - return
    if (_grade == null && _house == null) {
      setState(() {
        _dataLoading = false;
      });
      return;
    }

    // Apply all filters for retrieving data
    Map<String, Object?> filters = {};

    filters['grade'] = _grade;
    if (_class != null) {
      filters['class'] = _class;
    }
    if (_house != null) {
      filters['house'] = _house;
    }

    // Load data
    await TeacherFirestoreService()
        .getStudents(filters: filters)
        .then((data) => setState(
              () {
                studentList = data;
                List<String> users =
                    studentList.map((e) => e['id'] as String).toList();
                Map<String, Map<String, dynamic>> aggregatedHours;
                firestoreService
                    .aggregateHours(
                        users: users,
                        splitTimeCollection: true,
                        formatAsString: true)
                    .then((value) {
                  setState(() {
                    aggregatedHours = value;
                    displayData = studentList
                        .map((student) => {
                              'Last name': student['lastName'],
                              'First name': student['firstName'],
                              'Grade': student['grade'] + student['class'],
                              'House': student['house'],
                              ...aggregatedHours[student['id']]!,
                            })
                        .toList();
                    _dataLoading = false;
                  });
                });
              },
            ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 25),
            child: ListView(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      flex: 0,
                      child: Text('Select grade, class or house',
                          style: loginPageText.copyWith(
                              fontSize: 14, color: primaryColour))),
                  Container(
                    child: const Icon(
                      Icons.school,
                      color: secondaryColour,
                    ),
                  )
                ],
              ),
              Row(children: [
                Flexible(
                    child: Container(
                        margin: const EdgeInsets.only(top: 10.5, bottom: 10.5),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: secondaryColour.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 60,
                        child: Material(
                          color: Colors.transparent,
                          child: DropdownButtonFormField(
                            value: _grade,
                            items: DropdownListHelper.grades,
                            onChanged: (value) async {
                              setState(() {
                                _grade = value;
                                _class = null;
                              });
                              await loadData();
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Please enter the grade";
                              }

                              return null;
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                labelText: "Grade",
                                labelStyle: loginPageText),
                          ),
                        ))),
                if (_grade != null)
                  Flexible(
                      child: Container(
                          margin: const EdgeInsets.only(
                              top: 10.5, bottom: 10.5, left: 10.5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: secondaryColour.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 60,
                          child: Material(
                            color: Colors.transparent,
                            child: DropdownButtonFormField(
                              value: _class,
                              items: DropdownListHelper.classes,
                              onChanged: (value) async {
                                setState(() {
                                  _class = value;
                                });
                                await loadData();
                              },
                              validator: (value) {
                                return null;
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  labelText: "Class",
                                  labelStyle: loginPageText),
                            ),
                          ))),
              ]),
              Container(
                  margin: const EdgeInsets.only(top: 10.5, bottom: 10.5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: secondaryColour.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  height: 60,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField(
                      value: _house,
                      items: DropdownListHelper.houses,
                      onChanged: (value) async {
                        setState(() {
                          _house = value;
                        });
                        await loadData();
                      },
                      validator: (value) {
                        return null;
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          labelText: "House",
                          labelStyle: loginPageText),
                    ),
                  )),
              if (displayData.isNotEmpty && !_dataLoading)
                Container(
                  height: 75,
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              0.0), // Adjust the radius here
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: primaryColour,
                          width: 0,
                        ),
                      ),
                      onPressed: () async {
                        String filePath =
                            await DataExporter(displayData).writeExcel();

                        final file = File(filePath);

                        if (await file.exists()) {
                          // Provide a way to download the file
                          print(
                              '${(await getDownloadsDirectory())!.path}/data.xlsx');
                          await file.copy(
                              '${(await getDownloadsDirectory())!.path}/data.xlsx');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('File downloaded successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error generating file')),
                          );
                        }
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.download, color: Colors.black),
                            Text('Export as Excel spreadsheet',
                                style: loginPageText.copyWith(
                                  fontSize: 15,
                                  color: Colors.black,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                          ])),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      flex: 0,
                      child: Text('Preview',
                          style: loginPageText.copyWith(
                              fontSize: 14, color: primaryColour))),
                  Container(
                    child: const Icon(
                      Icons.search,
                      color: secondaryColour,
                    ),
                  )
                ],
              ),
              if (_dataLoading)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColour,
                    )
                  ],
                )
              else
                DataSummaryTable(displayData),
            ])));
  }
}
