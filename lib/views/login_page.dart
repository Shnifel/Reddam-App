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

Widget buildEmail(TextEditingController emailController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      //the text box
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

Widget buildPassword(TextEditingController passwordController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const SizedBox(height: 10),

      //password box
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

Widget buildLoginButton(
    TextEditingController emailController,
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
    BuildContext context) {

  return Column(
    children: <Widget>[
      const SizedBox(height: 50),
      OutlinedButton(
        onPressed: () {
          // TODO
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
                      'log in',
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
                // TODO
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
