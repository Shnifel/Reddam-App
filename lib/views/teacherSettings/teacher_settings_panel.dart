import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/user_database.dart';
import 'package:cce_project/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherSettingsPanelPage extends StatefulWidget {
  @override
  _TeacherPanelPageState createState() => _TeacherPanelPageState();
}

class _TeacherPanelPageState extends State<TeacherSettingsPanelPage> {
  String? _typeSelected; // Active or Passive
  String? _typeActive; // Specific active
  String? _activeChoice;

  bool editMode = false;
  bool loading = true;

  Map<String, dynamic> userData = {};

  final TextStyle labelStyle =
      const TextStyle(color: secondaryColour, fontSize: 15);
  final TextStyle valueStyle = const TextStyle(
      color: primaryColour, fontWeight: FontWeight.bold, fontSize: 15);

  Future<void> getUserData() async {
    setState(() {
      loading = true;
    });
    await UserLocalCache()
        .getUser(FirebaseAuth.instance.currentUser!.uid)
        .then((value) => {
              if (value.isNotEmpty)
                {
                  setState(
                    () {
                      userData = value[0];
                      loading = false;
                    },
                  )
                }
            });
  }

  Future<void> updateDetails() async {
    setState(() {
      loading = true;
    });

    await UserLocalCache()
        .updatePerson(FirebaseAuth.instance.currentUser!.uid, _typeSelected!,
            _typeSelected == "Active" ? _activeChoice! : _typeActive!)
        .then((value) => {
              setState(
                () {
                  editMode = false;
                  getUserData();
                },
              )
            });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColour));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editMode)
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        editMode = false;
                      });
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: secondaryColour,
                    ),
                    label: const Text("Cancel",
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(Colors.white)),
                  ))
            else
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        editMode = true;
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: secondaryColour,
                    ),
                    label: const Text("Edit",
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color?>(Colors.white)),
                  )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    flex: 0,
                    child: Text(
                        'User profile of ${userData["firstName"]} ${userData["lastName"]}',
                        style: loginPageText.copyWith(
                            fontSize: 20, color: primaryColour))),
              ],
            ),
            if (!editMode)
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataTable(
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.black, width: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          bottom: BorderSide(color: Colors.black, width: 0.7),
                          top: BorderSide(color: Colors.black, width: 0.7),
                          left: BorderSide(color: Colors.black, width: 0.7),
                          right: BorderSide(color: Colors.black, width: 0.7),
                        ),
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
                            DataCell(Text('Type of activity overseeing',
                                style: labelStyle)),
                            DataCell(Text(
                                userData["hoursType"] == null
                                    ? "All"
                                    : userData["hoursType"] +
                                        " - " +
                                        userData["hoursActivity"],
                                style: valueStyle)),
                          ]),
                        ],
                      ),
                    ]),
              ),

            if (editMode)
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          flex: 0,
                          child: Text(
                              'Select the activity you would like to oversee',
                              style: loginPageText.copyWith(
                                  fontSize: 15, color: primaryColour))),
                    ],
                  )),
            // Select type of hours being submitted
            if (editMode)
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
            if (_typeSelected != null && editMode)
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
                      items: DropdownListHelper.hoursChoices[_typeSelected],
                      onChanged: (value) => setState(() {
                        _typeActive = value;
                        _activeChoice = null;
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
            if (_typeSelected == 'Active' && _typeActive != null && editMode)
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
                      items: DropdownListHelper.hoursChoices[_typeActive],
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

            if (editMode &&
                ((_typeSelected == "Active" && _activeChoice != null) ||
                    (_typeSelected == "Passive" && _typeActive != null)))
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
                    onPressed: updateDetails,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Update selection',
                              style: loginPageText.copyWith(
                                fontSize: 20,
                                color: primaryColour,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ])),
              ),
          ],
        ),
      ),
    );
  }
}
