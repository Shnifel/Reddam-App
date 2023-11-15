import 'dart:io';
import 'package:cce_project/data/data.dart';
import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:cce_project/views/image_upload.dart';
import 'package:cce_project/widgets/success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../styles.dart';

class LogHoursPage extends StatelessWidget {
  final bool isSuccess;
  final VoidCallback onSuccess;

  const LogHoursPage(
      {required this.isSuccess, required this.onSuccess, super.key});

  @override
  Widget build(BuildContext context) {
    //Extract the arguments passed to this page

    return Scaffold(
      backgroundColor: Colors.white,
      //The body is filled with the SignUpForm class below
      body: LogHoursForm(isSuccess: isSuccess, onSuccess: onSuccess), //use f
    );
  }
}

class LogHoursForm extends StatefulWidget {
  final bool isSuccess;
  final VoidCallback onSuccess;

  const LogHoursForm(
      {required this.isSuccess, required this.onSuccess, super.key});

  @override
  State<LogHoursForm> createState() => _LogHoursFormState();
}

class _LogHoursFormState extends State<LogHoursForm> {
  final _formKey = GlobalKey<FormState>(); // Form handler
  final TextEditingController _hoursController =
      TextEditingController(); // Hours entered
  final TextEditingController _receiptController =
      TextEditingController(); // Receipt number entered
  List<File?> evidence = []; // Files uploaded with images of evidence
  List<File?> optional = []; // Optional photos for gallery
  String? _typeSelected; // Active or Passive
  String? _typeActive; // Specific active
  String? _activeChoice;
  String? _passiveNote;
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

  // Delete an image
  void _showPicker(context, int i, bool isEvidence) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete image'),
                    onTap: () {
                      setState(() {
                        if (isEvidence) {
                          evidence.removeAt(i);
                        } else {
                          optional.removeAt(i);
                        }
                      });
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          );
        });
  }

  // Submit handler
  void handleSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate returns true if the form is valid, or false otherwise.
      if (_formKey.currentState!.validate() && evidence.isNotEmpty) {
        // User id
        String uid = FirebaseAuth.instance.currentUser!.uid;

        //FirestoreService ref
        FirestoreService firestore = FirestoreService(uid: uid);

        List<String> evidenceUrls = [];
        List<String> optionalUrls = [];

        // Upload all images to cloud storage
        for (int i = 0; i < evidence.length; i++) {
          String? url = await firestore.uploadFile(evidence[i]);
          if (url != null) {
            evidenceUrls.add(url);
          }
        }

        //Upload all additional images to cloud storage
        for (int i = 0; i < optional.length; i++) {
          String? url =
              await firestore.uploadFile(optional[i], isGallery: true);
          if (url != null) {
            optionalUrls.add(url);
          }
        }

        double amount = double.parse(_hoursController.text);
        double excess = 0;

        if (Data.LOG_BOUNDS[_activeChoice] != null) {
          double bounds = Data.LOG_BOUNDS[_activeChoice]!.toDouble();
          Map<String, double> totalAggregate = await firestore.aggregateHours(
              filters: {'active_type': _activeChoice}) as Map<String, double>;
          double total = totalAggregate[_typeSelected!]!;

          if (total >= bounds) {
            excess = amount;
            amount = 0;
          } else if (amount > bounds || total + amount > bounds) {
            double original = amount;
            amount = bounds - total;
            excess = original - amount;
          }

          if (excess != 0) {
            setState(() {
              _passiveNote =
                  "Your total hours for this activity exceed the maximum ($bounds) and ($excess) of the hours will be recorded as Passive";
            });
          }
        }

        if (amount != 0) {
          // Record hours and send notification of new hours logged
          await firestore.logHours(uid, _typeSelected, _typeActive, amount,
              _receiptController.text, evidenceUrls,
              activeType: _activeChoice, optionalUrls: optionalUrls);
        }

        if (excess != 0) {
          // Remove excess amount and allocate as passive hours
          await firestore.logHours(uid, 'Passive', _activeChoice, excess,
              _receiptController.text, evidenceUrls);
        }

        widget.onSuccess();
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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSuccess
        ? Success(
            hours_type: _typeSelected! +
                (_activeChoice != null ? " " + _typeActive! : ""),
            activty: _typeSelected == 'Passive' ? _typeActive! : _activeChoice!,
            amount: double.parse(_hoursController.text),
            receipt_no: _receiptController.text,
            note: _passiveNote,
          )
        : Padding(
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
                        Container(
                          child: Icon(
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
                            child: Text('Step 2 : Enter the number of hours',
                                style: loginPageText.copyWith(
                                    fontSize: 14, color: primaryColour))),
                        const SizedBox(
                          width: 50,
                        ),
                        Container(
                          child: Icon(
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
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                labelText:
                                    'Enter the number of hours completed',
                                labelStyle: loginPageText),
                          ),
                        )),

                    // Enter the receipt number, a string - heading
                    if (_typeActive != "External" &&
                        _activeChoice != "External")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 0,
                              child: Text('Step 3 : Enter the receipt number',
                                  style: loginPageText.copyWith(
                                      fontSize: 14, color: primaryColour))),
                          Container(
                            child: Icon(
                              Icons.receipt,
                              color: secondaryColour,
                            ),
                          )
                        ],
                      ),

                    // Receipt number input box
                    if (_typeActive != "External" &&
                        _activeChoice != "External")
                      Container(
                          margin:
                              const EdgeInsets.only(bottom: 10.5, top: 10.5),
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
                              onChanged: (value) => setState(() {
                                _formKey.currentState?.validate();
                              }),
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
                            child: Text(
                                'Step 4 : Upload photos of your evidence',
                                style: loginPageText.copyWith(
                                    fontSize: 14, color: primaryColour))),
                        Container(
                          child: Icon(
                            Icons.image,
                            color: secondaryColour,
                          ),
                        )
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
                      GestureDetector(
                        onTap: () => {_showPicker(context, i, true)},
                        child: Container(
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
                      ),

                    SizedBox(
                      height: 10,
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
                      ],
                    ),

                    // Uploading image
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        alignment: Alignment.centerLeft,
                        height: 150,
                        child: ImageUploads(
                          size: 150,
                          onChange: handleOptionalImageChange,
                        )),

                    // Display all uploaded images
                    for (int i = 0; i < optional.length; i++)
                      GestureDetector(
                        onTap: () => {_showPicker(context, i, true)},
                        child: Container(
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
                      ),

                    // Submit button for logging hours
                    Container(
                      height: 75,
                      padding: const EdgeInsets.only(bottom: 20, top: 20),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
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
                                if (_isLoading)
                                  const CircularProgressIndicator(
                                      color: primaryColour)
                              ])),
                    ),
                  ],
                )));
  }
}
