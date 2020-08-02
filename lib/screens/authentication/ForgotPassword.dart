import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/services/Auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final AuthServices _auth = AuthServices();
  final _formKey = GlobalKey<FormState>();
  ProgressDialog progressDialog;

  // text field state
  String inputEmail = '';

  @override
  Widget build(BuildContext context) {

    progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true
    );
    progressDialog.style(
      message: 'Sending link...',
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text('Credit Transfer App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0, 100.0, 10.0, 50.0),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Enter your registered email address. You will receive a link for resetting your password',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13.0,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
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
                      height: 30.0,
                    ),
                    RaisedButton(
                      onPressed: ()  async {
                        if(_formKey.currentState.validate()) {
                          await progressDialog.show();
                          await _auth.resetPassword(inputEmail).then((value) async {
                            await progressDialog.hide();
                            Fluttertoast.showToast(msg: "Reset password link sent successfully", toastLength: Toast.LENGTH_LONG);
                          }).catchError((error) {
                            Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
                          });
                        }
                      },
                      color: Colors.deepPurple[900],
                      child: Text(
                        'Send Link',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
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
