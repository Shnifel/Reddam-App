import 'package:cce_project/arguments/user_info_arguments.dart';
import 'package:cce_project/services/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

//test for current user
String? _roleValue;

// This builds the email textbox
Widget buildEmail(TextEditingController emailController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: secondaryColour.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          height: 60, //container height

          child: Material(
            color: Colors.transparent,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 17,
              ),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  labelText: "Email",
                  labelStyle: loginPageText),
            ),
          ))
    ],
  );
}

// This builds the password textbox
Widget buildPassword(TextEditingController passwordController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SizedBox(height: 10),
      Container(
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  labelText: "Password",
                  labelStyle: loginPageText),
            ),
          ))
    ],
  );
}

// This builds the login button
Widget buildLoginButton(
    TextEditingController emailController,
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    BuildContext context) {
  return Column(
    children: <Widget>[
      const SizedBox(height: 50),
      OutlinedButton(
        onPressed: () async {
          // When the user presses the login button
          try {
            UserCredential userCredential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text);

            String userID = userCredential.user!.uid;

            String name = (await FirestoreService(uid: userID).getUserData())!;

            Map<String, dynamic> user_data =
                (await FirestoreService(uid: userID).getData(userID))!;

            bool isTeacher = user_data["teacher"];

            if (isTeacher) {
              Navigator.pushNamed(context, '/teacherDashboardPage',
                  arguments: UserInfoArguments(userID, name));
            } else {
              Navigator.pushNamed(context, '/studentDashboardPage',
                  arguments: UserInfoArguments(userID, name));
            }

            //go to test page
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 123, 11, 24),
                  content: Text("No user found for that email",
                      textAlign: TextAlign.center),
                ),
              );
            } else if (e.code == 'wrong-password') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 123, 11, 24),
                  content: Text("Wrong password provided for that user",
                      textAlign: TextAlign.center),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color.fromARGB(255, 123, 11, 24),
                  content: Text("Wrong password provided for that user",
                      textAlign: TextAlign.center),
                ),
              );
            }
          }
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: primaryColour,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'Log in',
                      style: loginPageText.copyWith(
                        fontSize: 30,
                      ),
                    ),
                  ),
                )
              ],
            ))
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
              onPressed: () {
                try {
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 40, 189, 11),
                      content: Text(
                          "Please check your emails to reset your password",
                          textAlign: TextAlign.center),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color.fromARGB(255, 123, 11, 24),
                      content: Text("Invalid email specified",
                          textAlign: TextAlign.center),
                    ),
                  );
                }
              },
              child: Text(
                'Forgot Password',
                style: loginPageText.copyWith(
                    fontSize: 14,
                    color: secondaryColour,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.right,
              )),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Don't have an account?",
              style: loginPageText.copyWith(
                fontSize: 14,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              )),
          TextButton(
              onPressed: () {
                //go to signup page
                Navigator.pushNamed(context, '/signupPage');
              },
              child: Text(
                'Sign up',
                style: loginPageText.copyWith(
                  fontSize: 14,
                  color: secondaryColour,
                ),
                textAlign: TextAlign.right,
              ))
        ],
      ),
    ],
  );
}

class _LoginPageState extends State<LoginPage> {
  //These variables store the email and password entered by the user
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //Create a global key that uniquely identifies the Form widget
  //and allows validation of the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        child: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 120),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Log in',
                        style: loginPageText.copyWith(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    buildEmail(emailController),
                    buildPassword(passwordController),
                    buildLoginButton(
                        emailController, passwordController, _formKey, context)
                  ],
                ),
              ),
            )),
      ),
    ));
  }
}
