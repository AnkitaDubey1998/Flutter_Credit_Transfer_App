import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercredittransferapp/screens/authentication/ForgotPassword.dart';
import 'package:fluttercredittransferapp/screens/authentication/Register.dart';
import 'package:fluttercredittransferapp/services/Auth.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  ProgressDialog progressDialog;

  //text field state
  String inputEmail = '';
  String inputPassword = '';
  String error ='';

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true
    );
    progressDialog.style(
      message: 'Logging in...',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text('Credit Transfer App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 80.0, 10.0, 50.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      onChanged: (value) {
                        setState(() => inputEmail = value);
                      },
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Email field cannot be empty";
                        } else if (!EmailValidator.validate(value)) {
                          return "Enter valid email address";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'john@gmail.com',
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Colors.deepPurple[900],
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.deepPurple[900],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(
                            color: Colors.deepPurple[900],
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      obscureText: _obscurePassword,
                      onChanged: (value) {
                        setState(() => inputPassword = value);
                      },
                      validator: (value) {
                        if(value.length < 6) {
                          return "Password must be atleast pf 6 characters";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
//                      hintText: 'Should be at least 6 characters',
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.deepPurple[900],
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.deepPurple[900],
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: _obscurePassword ? Icon(Icons.visibility_off, color: Colors.deepPurple[900],) : Icon(Icons.visibility, color: Colors.deepPurple[900],)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:  BorderSide(
                            color: Colors.deepPurple[900],
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      onPressed: ()  async {
                        if(_formKey.currentState.validate()) {
                          await progressDialog.show();

                          FirebaseUser user = await _auth.signInWithEmailAndPassword(inputEmail, inputPassword);
                          if(user == null) {
                            await progressDialog.hide();
                            Fluttertoast.showToast(msg: "Login failed", toastLength: Toast.LENGTH_LONG);
                          } else {
                            List<dynamic> tokens = await DatabaseService(uid: user.uid).getUserDeviceTokens();
                            String deviceToken;
                            FirebaseMessaging firebaseMessaging = FirebaseMessaging();
                            await firebaseMessaging.getToken().then((token) {
                              deviceToken = token;
                            });
                            if(!tokens.contains(deviceToken)) {
                              tokens.add(deviceToken);
                              await DatabaseService(uid: user.uid).insertDeviceToken(tokens).then((value) {

                              }).catchError((error) {
                                Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
                              });
                            }
                            await progressDialog.hide();
                            Fluttertoast.showToast(msg: "Login successful", toastLength: Toast.LENGTH_LONG);
                          }
                        }
                      },
                      color: Colors.deepPurple[900],
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                              },
                              child: Text(
                                'Sign Up Here',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                              },
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
