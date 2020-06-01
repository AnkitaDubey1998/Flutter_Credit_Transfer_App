import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercredittransferapp/services/Auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  ProgressDialog progressDialog;

  //text field state
  String inputName = '';
  String inputEmail = '';
  String inputPassword = '';
  String inputConfirmPassword = '';
  String gender="Male";
  String image = 'https://firebasestorage.googleapis.com/v0/b/flutter-credit-transfer.appspot.com/o/Default%20profile%20image.png?alt=media&token=b61ace64-b6ba-40e7-859c-e15e67eb8557';
  String error = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;


  @override
  Widget build(BuildContext context) {

    progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true
    );
    progressDialog.style(
      message: 'Registering...',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text('Credit Transfer App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 50.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'On successful registration, you will get 1000 credits',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13.0,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        setState(() => inputName = value);
                      },
                      validator: (value) => value.isEmpty ? "Name feild cannot be empty" : null,
                      decoration: InputDecoration(
                        hintText: 'John Stuart',
                        labelText: "Name",
                        labelStyle: TextStyle(
                          color: Colors.deepPurple[900],
                        ),
                        prefixIcon: Icon(
                          Icons.person,
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
                      onChanged: (value) {
                        setState(() => inputEmail = value);
                      },
                      validator: (value) {
                        if(value.isEmpty) {
                          return "Email feild cannot be empty";
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
                        hintText: 'Should be at least 6 characters',
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
                    TextFormField(
                      obscureText: _obscureConfirmPassword,
                      onChanged: (value) {
                        setState(() => inputConfirmPassword = value);
                      },
                      validator: (value) {
                        if(value != inputPassword) {
                          return "Password doesn't match";
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Should be at least 6 characters',
                        labelText: "Confirm Password",
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
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: _obscureConfirmPassword ? Icon(Icons.visibility_off, color: Colors.deepPurple[900],) : Icon(Icons.visibility, color: Colors.deepPurple[900],)
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
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: "Male",
                                groupValue: gender,
                                activeColor: Colors.deepPurple[900],
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                              Text(
                                'Male'
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: "Female",
                                groupValue: gender,
                                activeColor: Colors.deepPurple[900],
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                              Text(
                                  'Female'
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: <Widget>[
                              Radio(
                                value: "Other",
                                groupValue: gender,
                                activeColor: Colors.deepPurple[900],
                                onChanged: (value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },
                              ),
                              Text(
                                  'Other'
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: RaisedButton(
                        onPressed: ()  async {
                          if(_formKey.currentState.validate()) {
                            await progressDialog.show();

                            FirebaseMessaging firebaseMessaging = FirebaseMessaging();
                            List<dynamic> deviceTokens = [];
                            await firebaseMessaging.getToken().then((token) {
                              deviceTokens.add(token);
                            });

                            dynamic result = await _auth.registerWithEmailAndPassword(inputName, inputEmail, inputPassword, gender, "1000", image, deviceTokens);
                            if(result == null) {
                              setState(() => error = 'Please provide valid information');
                            } else {
                              setState(() => error = '');
                              await progressDialog.hide();
                              Fluttertoast.showToast(msg: "Successfuly registered", toastLength: Toast.LENGTH_LONG);
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                SystemNavigator.pop();
                              }
                            }
                          }
                        },
                        color: Colors.deepPurple[900],
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      )
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
