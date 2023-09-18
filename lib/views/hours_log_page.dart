import 'dart:io';

import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/views/image_upload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../styles.dart';

class LogHoursPage extends StatelessWidget {
  const LogHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    //Extract the arguments passed to this page

    return const Scaffold(
      backgroundColor: Colors.white,
      //The body is filled with the SignUpForm class below
      body: LogHoursForm(), //use f
    );
  }
}

class LogHoursForm extends StatefulWidget {
  const LogHoursForm({super.key});

  @override
  State<LogHoursForm> createState() => _LogHoursFormState();
}

class _LogHoursFormState extends State<LogHoursForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _receiptController = TextEditingController();
  List<File?> evidence = [];
  List<File?> optional = [];
  String? _typeSelected;
  String? _typeActive;
  String? _activeChoice;
  bool _isLoading = false;

  // New image added
  void handleImageChange(File? photo) {
    if (photo != null) {
      setState(() {
        evidence.add(photo);
      });
    }
  }

  // Optional image added
  void handleOptionalImageChange(File? photo) {
    if (photo != null) {
      setState(() {
        optional.add(photo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 25),
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                // Form heading
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Log hours',
                        style: loginPageText.copyWith(
                            fontSize: 35, fontWeight: FontWeight.bold))),
                const SizedBox(height: 50),

                // Dropdown menus for submitting hours - heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Text('Step 1 : Type of hours submitting',
                            style: loginPageText.copyWith(
                                fontSize: 14, color: primaryColour))),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: LinearProgressIndicator(
                            value: 1 / 5,
                            backgroundColor: primaryColour,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondaryColour,
                            ))),
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
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
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
                          items: DropdownListHelper.hoursChoices[_typeSelected],
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
                          items: DropdownListHelper.hoursChoices[_typeActive],
                          onChanged: (value) => setState(() {
                            _activeChoice = value;
                            _formKey.currentState?.validate();
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
                        child: Text('Step 2 : Enter the number of hours',
                            style: loginPageText.copyWith(
                                fontSize: 14, color: primaryColour))),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                        child: LinearProgressIndicator(
                            value: 2 / 5,
                            backgroundColor: primaryColour,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondaryColour,
                            ))),
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
                            return "Please enter the number hours";
                          }
                          return null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Enter the number of hours completed",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Enter the receipt number, a string - heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Text('Step 3 : Enter the receipt number',
                            style: loginPageText.copyWith(
                                fontSize: 14, color: primaryColour))),
                    const SizedBox(
                      width: 60,
                    ),
                    Expanded(
                        child: LinearProgressIndicator(
                            value: 3 / 5,
                            backgroundColor: primaryColour,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondaryColour,
                            ))),
                  ],
                ),

                // Receipt number input box
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
                        controller: _receiptController,
                        validator: (value) {
                          if (value == "") {
                            return "Please enter the receipt number matching the evidence";
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText:
                                "Enter the receipt number you're logging",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Upload evidence - compulsory field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Text('Step 4 : Upload photos of your evidence',
                            style: loginPageText.copyWith(
                                fontSize: 14, color: primaryColour))),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: LinearProgressIndicator(
                            value: 4 / 5,
                            backgroundColor: primaryColour,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondaryColour,
                            ))),
                  ],
                ),

                // Uploading image
                Container(
                    margin: const EdgeInsets.only(top: 5),
                    alignment: Alignment.centerLeft,
                    height: 150,
                    child: ImageUploads(
                      onChange: handleImageChange,
                    )),

                // Display all uploaded images
                for (int i = 0; i < evidence.length; i++)
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: evidence[i] != null
                        ? ClipRRect(
                            child: Image.file(
                              evidence[i]!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            width: 150,
                            height: 150,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),

                // Upload any additional photos field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Text('Step 5 : Upload any additional photos',
                            style: loginPageText.copyWith(
                                fontSize: 14, color: primaryColour))),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: LinearProgressIndicator(
                            value: 1,
                            backgroundColor: primaryColour,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              secondaryColour,
                            ))),
                  ],
                ),

                // Uploading image
                Container(
                    margin: const EdgeInsets.only(top: 5),
                    alignment: Alignment.centerLeft,
                    height: 150,
                    child: ImageUploads(
                      onChange: handleOptionalImageChange,
                    )),

                // Display all uploaded images
                for (int i = 0; i < optional.length; i++)
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: optional[i] != null
                        ? ClipRRect(
                            child: Image.file(
                              optional[i]!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            width: 150,
                            height: 150,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                            ),
                          ),
                  ),

                // Submit button for logging hours
                Container(
                  height: 100,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: primaryColour,
                          width: 1.5,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate() &&
                              evidence.length >= 1) {
                            // User id
                            String uid = FirebaseAuth.instance.currentUser!.uid;

                            //FirestoreService ref
                            FirestoreService firestore =
                                FirestoreService(uid: uid);

                            List<String> evidenceUrls = [];
                            List<String> optionalUrls = [];

                            // Upload all images to cloud storage
                            for (int i = 0; i < evidence.length; i++) {
                              String? url =
                                  await firestore.uploadFile(evidence[i]);
                              if (url != null) {
                                evidenceUrls.add(url);
                              }
                            }

                            //Upload all additional images to cloud storage
                            for (int i = 0; i < optional.length; i++) {
                              String? url =
                                  await firestore.uploadFile(optional[i]);
                              if (url != null) {
                                optionalUrls.add(url);
                              }
                            }

                            // Record hours and send notification of new hours logged
                            await firestore.logHours(
                                uid,
                                _typeSelected,
                                _typeActive,
                                double.parse(_hoursController.text),
                                _receiptController.text,
                                evidenceUrls,
                                activeType: _activeChoice,
                                optionalUrls: optionalUrls);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Color.fromARGB(255, 26, 231, 43),
                              content: Text(
                                "Successfully logged ! Keep up the good work",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(0, 0, 0, 0)),
                              ),
                            ));

                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color.fromARGB(255, 123, 11, 24),
                                content: Text("One or more fields are invalid",
                                    textAlign: TextAlign.center),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color.fromARGB(255, 123, 11, 24),
                              content: Text(
                                  "An error has occurred. Please try again",
                                  textAlign: TextAlign.center),
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit hours',
                                style: loginPageText.copyWith(
                                  fontSize: 20,
                                  color: primaryColour,
                                )),
                            SizedBox(
                              width: 10,
                            ),
                            if (_isLoading) CircularProgressIndicator()
                          ])),
                ),
              ],
            )));
  }
}
