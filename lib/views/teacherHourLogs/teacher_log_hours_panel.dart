import 'package:cce_project/data/data.dart';
import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cce_project/views/student_dashboard_page.dart';
import 'package:cce_project/widgets/student_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherLogHoursPanelPage extends StatefulWidget {
  const TeacherLogHoursPanelPage({super.key});

  @override
  State<TeacherLogHoursPanelPage> createState() =>
      _TeacherLogHoursPanelPageState();
}

class _TeacherLogHoursPanelPageState extends State<TeacherLogHoursPanelPage> {
  final _formKey = GlobalKey<FormState>(); // Form handler
  final TextEditingController _hoursController =
      TextEditingController(); // Hours entered
  final TextEditingController _receiptController =
      TextEditingController(); // Receipt number entered

  String? _typeSelected; // Active or Passive
  String? _typeActive; // Specific active
  String? _activeChoice;

  String? _grade;
  String? _class;
  String? _house;
  bool _isLoading = false;
  bool _submitLoading = false;

  String? _filterQuery;
  List<Map<String, dynamic>> studentList = [];
  List<Map<String, dynamic>> filteredList = [];

  Future<void> loadStudentsData() async {
    // Set loading state for data
    setState(() {
      _isLoading = true;
    });

    // No grade selected - return
    if (_grade == null) {
      setState(() {
        _isLoading = false;
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
                studentList.forEach((element) {
                  element['isSelected'] = true;
                });
                filteredList = data.where((element) => true).toList();
                _isLoading = false;
              },
            ));
  }

  void filterSearchResults(String query) {
    setState(() {
      filteredList = studentList
          .where((item) => (item['firstName'] + item['lastName'])
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  // Submit handler
  void handleSubmit() async {
    setState(() {
      _submitLoading = true;
    });

    try {
      // Validate returns true if the form is valid, or false otherwise.
      if (_formKey.currentState!.validate()) {
        //FirestoreService
        TeacherFirestoreService firestore = TeacherFirestoreService();

        double amount = double.parse(_hoursController.text);
        double excess = 0;

        List<Map<String, dynamic>> students = filteredList
            .where((element) =>
                element['isSelected'] == true || element['isSelected'] == null)
            .toList();

        List<String> users = students.map((e) => e['id'] as String).toList();

        // Activity that has bounds on it
        if (Data.LOG_BOUNDS[_activeChoice] != null) {
          double bounds = Data.LOG_BOUNDS[_activeChoice]!.toDouble();
          Map<String, Map<String, dynamic>> aggregatedHours = await firestore
              .aggregateHours(
                  filters: {'active_type': _activeChoice}, users: users);

          for (int i = 0; i < users.length; i++) {
            String user = users[i];
            Map<String, double> totalAggregate =
                aggregatedHours[user] as Map<String, double>;

            double total = totalAggregate[_typeSelected!]!;

            if (total >= bounds) {
              excess = amount;
              amount = 0;
            } else if (amount > bounds || total + amount > bounds) {
              double original = amount;
              amount = bounds - total;
              excess = original - amount;
            }

            students[i]['amount'] = amount;
            students[i]['excess'] = excess;
          }
        }

        students.forEach((student) {
          if (student['amount'] == null) {
            student['amount'] = amount;
          }
        });

        print(users);
        print(students);

        await firestore.logHoursBatch(
            students, _typeSelected, _typeActive, amount,
            activeType: _activeChoice);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 123, 11, 24),
            content: Text("One or more fields are invalid",
                textAlign: TextAlign.center),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 123, 11, 24),
          content: Text("An error has occurred. Please try again",
              textAlign: TextAlign.center),
        ),
      );
    } finally {
      setState(() {
        _submitLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 25),
            child: Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    // Form heading
                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text('Log hours',
                            style: loginPageText.copyWith(
                                fontSize: 35, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 30),

                    // Heading for grade/house/class filters
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Text('Step 1: Select grade, class or house',
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
                            value: _grade,
                            items: DropdownListHelper.grades,
                            onChanged: (value) async {
                              setState(() {
                                _grade = value;
                                _class = null;
                              });
                              await loadStudentsData();
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
                        )),

                    if (_grade != null)
                      Container(
                          margin:
                              const EdgeInsets.only(top: 10.5, bottom: 10.5),
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
                                await loadStudentsData();
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
                          )),

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
                              await loadStudentsData();
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

                    // Dropdown menus for submitting hours - heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Text('Step 2 : Type of hours submitting',
                                style: loginPageText.copyWith(
                                    fontSize: 14, color: primaryColour))),
                        Container(
                          child: const Icon(
                            Icons.menu,
                            color: secondaryColour,
                          ),
                        )
                      ],
                    ),

                    // Select type of hours being submitted
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
                            value: _typeSelected,
                            items: DropdownListHelper.hoursTypes,
                            onChanged: (value) => setState(() {
                              _typeSelected = value;
                              _typeActive = null;
                              _formKey.currentState?.validate();
                            }),
                            validator: (value) {
                              if (value == null) {
                                return "Please select the type of hours you're submitting";
                              }

                              return null;
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                labelText: "Type of hours",
                                labelStyle: loginPageText),
                          ),
                        )),

                    // Select the specific variation of the activity chosen
                    if (_typeSelected != null)
                      Container(
                          margin: const EdgeInsets.only(bottom: 10.5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: secondaryColour.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 60,
                          child: Material(
                            color: Colors.transparent,
                            child: DropdownButtonFormField(
                              value: _typeActive,
                              items: DropdownListHelper
                                  .hoursChoices[_typeSelected],
                              onChanged: (value) => setState(() {
                                _typeActive = value;
                                _activeChoice = null;
                                _formKey.currentState?.validate();
                              }),
                              validator: (value) {
                                if (value == null) {
                                  return "Please select the type of $_typeSelected hours you're submitting";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  labelText: "Type of $_typeSelected hours",
                                  labelStyle: loginPageText),
                            ),
                          )),

                    // Specific kind of active hours chosen
                    if (_typeSelected == 'Active' && _typeActive != null)
                      Container(
                          margin: const EdgeInsets.only(bottom: 10.5),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: secondaryColour.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          height: 60,
                          child: Material(
                            color: Colors.transparent,
                            child: DropdownButtonFormField(
                              value: _activeChoice,
                              items:
                                  DropdownListHelper.hoursChoices[_typeActive],
                              onChanged: (value) => setState(() {
                                _activeChoice = value;
                              }),
                              validator: (value) {
                                if (value == null) {
                                  return "Please select the type of $_typeSelected $_typeActive hours you're submitting";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  labelText:
                                      "Type of $_typeSelected $_typeActive hours",
                                  labelStyle: loginPageText),
                            ),
                          )),

                    // Input the number of hours being logged
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Text('Step 3 : Enter the number of hours',
                                style: loginPageText.copyWith(
                                    fontSize: 14, color: primaryColour))),
                        const SizedBox(
                          width: 50,
                        ),
                        Container(
                          child: const Icon(
                            Icons.access_time,
                            color: secondaryColour,
                          ),
                        )
                      ],
                    ),

                    // Enter decimal input for number of hours done
                    Container(
                        margin: const EdgeInsets.only(bottom: 10.5, top: 10.5),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: secondaryColour.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 60,
                        child: Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            controller: _hoursController,
                            validator: (value) {
                              if (value == "") {
                                return "Compulsory field";
                              }
                              return null;
                            },
                            onChanged: (value) => setState(() {
                              _formKey.currentState?.validate();
                            }),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                labelText:
                                    'Enter the number of hours completed',
                                labelStyle: loginPageText),
                          ),
                        )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Text('Step 4: Review student selection',
                                style: loginPageText.copyWith(
                                    fontSize: 14, color: primaryColour))),
                        const SizedBox(
                          width: 50,
                        ),
                        Container(
                          child: const Icon(
                            Icons.edit,
                            color: secondaryColour,
                          ),
                        )
                      ],
                    ),

                    Container(
                        height: 40,
                        child: TextField(
                          onChanged: (value) {
                            filterSearchResults(value);
                          },
                          decoration: const InputDecoration(
                              icon: Icon(Icons.search),
                              iconColor: secondaryColour,
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: primaryColour))),
                          style: const TextStyle(color: Colors.black),
                        )),

                    if (_isLoading)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: primaryColour,
                          )
                        ],
                      )
                    else
                      Column(
                        children: filteredList
                            .map((student) => StudentDataRow(
                                  student['isSelected'],
                                  student,
                                  (isSelected) {
                                    setState(() {
                                      student['isSelected'] = isSelected;
                                    });
                                  },
                                  key: Key(student['id']),
                                ))
                            .toList(),
                      ),

                    // Submit button for logging hours
                    Container(
                      height: 75,
                      padding: const EdgeInsets.only(bottom: 20, top: 20),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: primaryColour,
                              width: 1.5,
                            ),
                          ),
                          onPressed: handleSubmit,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Submit hours',
                                    style: loginPageText.copyWith(
                                      fontSize: 20,
                                      color: primaryColour,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                if (_submitLoading)
                                  const CircularProgressIndicator(color: primaryColour)
                              ])),
                    ),
                  ],
                ))));
  }
}
