import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/layouts/RowForRequests.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForRequest.dart';
import 'package:provider/provider.dart';

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {

  List<ModelForRequest> requests = [];

  @override
  Widget build(BuildContext context) {

    final sentRequests = Provider.of<QuerySnapshot>(context);

    if(sentRequests == null) {
      return Center(child: CircularProgressIndicator());
    }

    requests.clear();

    for (var doc in sentRequests.documents) {
      requests.add(ModelForRequest(requestId: doc.data['requestId'], uid: doc.data['receiverUid'], name: doc.data['receiverName'],
                    status: doc.data['status'], credit: doc.data['credit'], dateTime: doc.data['dateTime']));
    }

    if(requests.length == 0) {
      return Center(
        child: Text(
            "You didn't made any request till now"
        ),
      );
    }

    return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return RowForRequests(request: requests[index]);
        }
    );
  }
}
