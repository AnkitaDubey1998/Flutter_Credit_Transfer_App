import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForTransaction.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:material_dialog/material_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class ApproveMaterialDialog extends StatefulWidget {

  String requestId;
  String requestCredit;
  String receiverUid;

  ApproveMaterialDialog({ this.requestId, this.requestCredit, this.receiverUid  });

  @override
  _ApproveMaterialDialogState createState() => _ApproveMaterialDialogState();
}

class _ApproveMaterialDialogState extends State<ApproveMaterialDialog> {

  ProgressDialog approveProgressDialog;
  ProgressDialog declineProgressDialog;

  String requestId;
  String requestCredit;
  String senderUid;
  String senderName;
  String senderCredit;
  String receiverUid;
  String receiverName;
  String receiverCredit;
  String transactionId;
  String transactionDateTime;

  @override
  Widget build(BuildContext context) {

    final senderUser = Provider.of<DocumentSnapshot>(context);
    print(senderUser.runtimeType);

    if(senderUser == null) {
      return Center(child: CircularProgressIndicator());
    }

    senderUid = senderUser.data['uid'];
    senderName = senderUser.data['name'];
    senderCredit = senderUser.data['credit'];
    receiverUid = widget.receiverUid;
    requestId = widget.requestId;
    requestCredit = widget.requestCredit;

    approveProgressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Download,
        isDismissible: true
    );
    approveProgressDialog.style(
      message: 'Transferring credit...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
    );

    declineProgressDialog = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: true
    );
    declineProgressDialog.style(
      message: 'Declining...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
    );

    return MaterialDialog(
      borderRadius: 8.0,
      children: <Widget>[
        Center(
          child: Text(
            'You have $senderCredit credits',
            style: TextStyle(
              fontSize: 15.0,
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        getMaterialDialog(),
      ],
    );
  }


  Widget getMaterialDialog() {
    if(int.parse(senderCredit) < int.parse(requestCredit)) {
      return Column(
        children: <Widget>[
          Text(
            "You don't have enough credits",
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text(
              'Decline',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.deepPurple[900],
            onPressed: () async {
              await declineRequest();
              Navigator.pop(context);
            },
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Text(
            "On clicking Approve $requestCredit credits will be transferred automatically",
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: Text(
                  'Decline',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.deepPurple[900],
                onPressed: () async {
                  await declineRequest();
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text(
                  'Approve',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.deepPurple[900],
                onPressed: () async {
                  await approveRequest();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      );
    }
  }



  // method for declining request
  declineRequest() async {
    await declineProgressDialog.show();

    // updating status of request sent by receiver to the sender
    await DatabaseService(uid: receiverUid).updateRequestStatus(requestId, 'to', 'Declined').then((value) async {
      // updating status of request received by sender from the receiver
      await DatabaseService(uid: senderUid).updateRequestStatus(requestId, 'from', 'Declined').then((value) async {
        await declineProgressDialog.hide();
        Fluttertoast.showToast(msg: "Request declined", toastLength: Toast.LENGTH_LONG);
      }).catchError((error) {
        Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
      });
    }).catchError((error) {
      Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
    });
  }



  // method for approving request
  approveRequest() async {
    await approveProgressDialog.show();

    // getting name and credit of receiver from database
    List<String> receiverUser = await DatabaseService(uid: receiverUid).getUserNameCredit();
    receiverName = receiverUser[0];
    receiverCredit = receiverUser[1];

    // computing credits of sender and receiver
    senderCredit = (int.parse(senderCredit) - int.parse(requestCredit)).toString();
    receiverCredit = (int.parse(receiverCredit) + int.parse(requestCredit)).toString();

    // date and time of transaction
    transactionDateTime = DateFormat.yMd().add_jm().format(DateTime.now()).toString();

    // generating transaction ID
    transactionId = await DatabaseService().transactionCollection.document(senderUid).collection(senderUid).document().documentID.toString();

    // creating two transaction objects
    ModelForTransaction toReceiver = ModelForTransaction(transactionId: transactionId, uid: receiverUid, type: 'to', name: receiverName,
        credit: requestCredit, dateTime: transactionDateTime);

    ModelForTransaction fromSender = ModelForTransaction(transactionId: transactionId, uid: senderUid, type: 'from', name: senderName,
        credit: requestCredit, dateTime: transactionDateTime);

    // updating status of request sent by receiver to the sender
    await DatabaseService(uid: receiverUid).updateRequestStatus(requestId, 'to', 'Approved').then((value) async {
      // updating status of request received by sender from the receiver
      await DatabaseService(uid: senderUid).updateRequestStatus(requestId, 'from', 'Approved').then((value) async {
        // updating sender details in database
        await  DatabaseService().updateCreditDetails(senderUid, senderCredit).then((value) async {
          // updating receiver details in database
          await DatabaseService().updateCreditDetails(receiverUid, receiverCredit).then((value) async {
            // adding transaction detail of sender in database
            await DatabaseService(uid: senderUid).insertTransactionDetails(toReceiver).then((value) async {
              // adding transaction detail of receiver in database
              await DatabaseService(uid: receiverUid).insertTransactionDetails(fromSender).then((value) async {
                await approveProgressDialog.hide();
                Fluttertoast.showToast(msg: "Credit transferred successfully", toastLength: Toast.LENGTH_LONG);
              }).catchError((error) {
                Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
              });
            }).catchError((error) {
              Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
            });
          }).catchError((error) {
            Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
          });
        }).catchError((error) {
          Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
      });
    }).catchError((error) {
      Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
    });
  }

}
