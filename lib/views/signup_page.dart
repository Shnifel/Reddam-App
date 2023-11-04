import 'package:cce_project/helpers/dropdown_helpers.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../styles.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    //When you push a new screen after a MaterialApp, a back button is automatically added
    return const Scaffold(
      backgroundColor: Colors.white,
      //The body is filled with the SignUpForm class below
      body: SignUpForm(), //use form inside page so text thingies work
    );
  }
}

//This is our form widget
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

//This class holds data related to the form
class _SignUpFormState extends State<SignUpForm> {
  //These variables store the information entered by the user
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController houseController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //Create a global key that uniquely identifies the Form widget
  //and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  String? _houseValue;
  String? _gradeValue;
  String? _classValue;

  @override
  // Everything below determines how the page is displayed
  Widget build(BuildContext context) {
    //we are using a form to allow for input validation
    return Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 25),
        child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Create Account',
                        style: loginPageText.copyWith(
                            fontSize: 35, fontWeight: FontWeight.bold))),

                const SizedBox(height: 50),

                // First name textbox
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
                      child: TextFormField(
                        obscureText: false,
                        controller: firstNameController,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "First name",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Last name textbox
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
                      child: TextFormField(
                        obscureText: false,
                        controller: lastNameController,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Last name",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Grade drop down
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
                        value: _gradeValue,
                        items: DropdownListHelper.grades,
                        onChanged: (value) => setState(() {
                          _gradeValue = value;
                          _formKey.currentState?.validate();
                        }),
                        validator: (value) {
                          if (value == null) {
                            return "Please select your grade";
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Grade",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Class drop down
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
                        value: _classValue,
                        items: DropdownListHelper.classes,
                        onChanged: (value) => setState(() {
                          _classValue = value;
                          _formKey.currentState?.validate();
                        }),
                        validator: (value) {
                          if (value == null) {
                            return "Please select your class";
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Class",
                            labelStyle: loginPageText),
                      ),
                    )),

                // House drop down
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
                          value: _houseValue,
                          items: DropdownListHelper.houses,
                          onChanged: (value) => setState(() {
                            _houseValue = value;
                            _formKey.currentState?.validate();
                          }),
                          validator: (value) {
                            if (value == null) {
                              return "Please select a house";
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              labelText: "House",
                              labelStyle: loginPageText),
                        ))),

                // Email address textbox
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
                      child: TextFormField(
                        obscureText: false,
                        controller: emailController,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        validator: (value) {
                          if (value == null ||
                              !value.contains("@reddam.house")) {
                            return "Please enter a valid Reddam Email";
                          }

                          return null;
                        },
                        onChanged: (value) {
                          _formKey.currentState?.validate();
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Email",
                            labelStyle: loginPageText),
                      ),
                    )),

                // Password textbox
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
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: "Password",
                            labelStyle: loginPageText),
                      ),
                    )),

                Container(
                    height: 90,
                    padding: const EdgeInsets.only(top: 40),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primaryColour,
                            width: 1.5,
                          ),
                        ),
                        onPressed: () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            //If the form is valid
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text);

                              String userID = userCredential.user!.uid;
                              FirestoreService(uid: userID).setUserData({
                                "firstName": firstNameController.text,
                                "lastName": lastNameController.text,
                                "grade": _gradeValue,
                                "class": _classValue,
                                "house": _houseValue,
                                "email": emailController.text,
                                "teacher": false,
                              });

                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //     backgroundColor:
                              //         Color.fromARGB(255, 123, 11, 24),
                              //     content: Text("Success",
                              //         textAlign: TextAlign.center),
                              //   ),
                              // );
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 123, 11, 24),
                                    content: Text(
                                        "The password provided is too weak",
                                        textAlign: TextAlign.center),
                                  ),
                                );
                              } else if (e.code == 'email-already-in-use') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 123, 11, 24),
                                    content: Text(
                                        "An account already exists for that email",
                                        textAlign: TextAlign.center),
                                  ),
                                );
                              } else if (e.code == 'invalid-email') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 123, 11, 24),
                                    content: Text("The email domain is invalid",
                                        textAlign: TextAlign.center),
                                  ),
                                );
                              }
                            } catch (e) {
                              print(e);
                            }
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
                        },
                        child: Text('sign up',
                            style: loginPageText.copyWith(
                              fontSize: 30,
                              color: primaryColour,
                            )))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Already have an account?',
                        style: loginPageText.copyWith(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black)),
                    TextButton(
                        onPressed: () {
                          //go to login page
                          Navigator.pushNamed(context, '/loginPage');
                        },
                        child: Text(
                          'Log in',
                          style: loginPageText.copyWith(
                            fontSize: 14,
                            color: secondaryColour,
                          ),
                          textAlign: TextAlign.right,
                        ))
                  ],
                ),
              ],
            )));
  }
}
