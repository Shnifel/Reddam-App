import 'package:cce_project/helpers/date_forrmater.dart';
import 'package:cce_project/services/teacher_firestore.dart';
import 'package:cce_project/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeachersVerify extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function onComplete;

  const TeachersVerify(this.data, this.onComplete, {super.key});

  @override
  State<TeachersVerify> createState() => _TeachersVerifyState();
}

class _TeachersVerifyState extends State<TeachersVerify> {
  final TextStyle labelStyle =
      const TextStyle(color: secondaryColour, fontSize: 12);
  final TextStyle valueStyle = const TextStyle(
      color: primaryColour, fontWeight: FontWeight.bold, fontSize: 12);
  TeacherFirestoreService firestoreService = TeacherFirestoreService();
  bool _isLoading = false;

  Future<void> handleAccept() async {
    await firestoreService.verifyTeacher(widget.data['id'], true);
  }

  Future<void> handleReject() async {
    await firestoreService.verifyTeacher(widget.data['id'], false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
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
                              " (" +
                              widget.data['email'] +
                              ")",
                          style: const TextStyle(
                              fontSize: 14,
                              color: primaryColour,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Has requested verification",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ]),
                ]))
              ]),
          children: [
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
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await handleAccept().then((value) {
                              widget.onComplete();
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          } catch (e) {
                            print(e);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
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
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            await handleReject().then((value) {
                              setState(() {
                                _isLoading = false;
                              });
                              widget.onComplete();
                            });
                          } catch (e) {
                            print(e);
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
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
          ],
        ),
      ),
    );
  }
}
