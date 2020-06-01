import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForRequest.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class RequestMaterialDialog extends StatefulWidget {

  String receiverUid;

  RequestMaterialDialog({ this.receiverUid });

  @override
  _RequestMaterialDialogState createState() => _RequestMaterialDialogState();
}

class _RequestMaterialDialogState extends State<RequestMaterialDialog> {

  final _formKey = GlobalKey<FormState>();
  ProgressDialog progressDialog;

  String senderUid;
  String senderName;
  String receiverUid;
  String receiverName;
  String requestId;
  String requestCredit = '';
  String requestDateTime;

  @override
  Widget build(BuildContext context) {

    final currentUser = Provider.of<FirebaseUser>(context);

    progressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true
    );
    progressDialog.style(
      message: 'Requesting...',
    );

    return MaterialDialog(
      borderRadius: 8.0,
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() => requestCredit = value);
                },
                validator: (value) {
                  if(value.isEmpty) {
                    return 'Enter credit value';
                  } else if (int.parse(value) == 0) {
                    return "You cannot request 0 credit";
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: '150',
                  labelText: 'Credit',
                  labelStyle: TextStyle(
                    color: Colors.deepPurple[900],
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
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
              RaisedButton(
                onPressed: () async {
                  if(_formKey.currentState.validate()) {
                    await progressDialog.show();

                    senderUid = currentUser.uid;
                    receiverUid = widget.receiverUid;

                    List<String> receiverUser = await DatabaseService(uid: widget.receiverUid).getUserNameCredit();
                    List<String> senderUser = await DatabaseService(uid: senderUid).getUserNameCredit();
                    receiverName = receiverUser[0];
                    senderName = senderUser[0];

                    // date and time of request
                    requestDateTime = DateFormat.yMd().add_jm().format(DateTime.now()).toString();

                    // generating request ID
                    requestId = await DatabaseService().requestCollection.document(senderUid).collection('to').document().documentID.toString();

                    // creating two request objects
                    ModelForRequest toReceiver = ModelForRequest(requestId: requestId, uid: receiverUid, name: receiverName,
                                                                  credit: requestCredit, dateTime: requestDateTime, status: 'Pending');
                    ModelForRequest fromSender = ModelForRequest(requestId: requestId, uid: senderUid, name: senderName,
                                                                  credit: requestCredit, dateTime: requestDateTime, status: 'Pending');

                    // adding request details in sender node
                    await DatabaseService(uid: senderUid).insertRequestDetails(toReceiver, 'to').then((value) async {
                      // adding request details in receiver node
                      await DatabaseService(uid: receiverUid).insertRequestDetails(fromSender, 'from').then((value) async {
                        await progressDialog.hide();
                        Fluttertoast.showToast(msg: "Requested successfully", toastLength: Toast.LENGTH_LONG);
                      }).catchError((error) {
                        Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
                      });
                    }).catchError((error) {
                      Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
                    });

                    Navigator.pop(context);
                  }
                },
                color: Colors.deepPurple[900],
                child: Text(
                  'Request Credit',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
