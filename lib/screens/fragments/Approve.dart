import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/layouts/RowForApprove.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForRequest.dart';
import 'package:provider/provider.dart';

class Approve extends StatefulWidget {
  @override
  _ApproveState createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {

  List<ModelForRequest> requests = [];

  @override
  Widget build(BuildContext context) {

    final receivedRequests = Provider.of<QuerySnapshot>(context);

    if(receivedRequests == null) {
      return Center(child: CircularProgressIndicator());
    }

    requests.clear();

    for (var doc in receivedRequests.documents) {
      requests.add(ModelForRequest(requestId: doc.data['requestId'], uid: doc.data['senderUid'], name: doc.data['senderName'],
                                    status: doc.data['status'], credit: doc.data['credit'], dateTime: doc.data['dateTime']));
    }

    return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return RowForApprove(request: requests[index]);
        }
    );
  }
}
