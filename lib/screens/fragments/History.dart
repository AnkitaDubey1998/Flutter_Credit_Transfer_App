import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/layouts/RowForHistory.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForTransaction.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  List<ModelForTransaction> transactions = [];

  @override
  Widget build(BuildContext context) {

    final transactionHistory = Provider.of<QuerySnapshot>(context);

    if(transactionHistory == null) {
      return Center(child: CircularProgressIndicator());
    }

    transactions.clear();
    for (var doc in transactionHistory.documents) {
      transactions.add(ModelForTransaction(uid: doc.data['uid'], name: doc.data['name'], type: doc.data['type'],
                                            credit: doc.data['credit'], dateTime: doc.data['dateTime']));
    }

    return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return RowForHistory(transaction: transactions[index]);
        }
    );
  }
}
