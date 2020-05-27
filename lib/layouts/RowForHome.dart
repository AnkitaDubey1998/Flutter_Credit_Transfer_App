import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForUser.dart';
import 'package:fluttercredittransferapp/screens/transactions/TransferCredit.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:provider/provider.dart';

class RowForHome extends StatelessWidget {

  final ModelForUser user;

  RowForHome({ this.user });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => StreamProvider<DocumentSnapshot>.value(
                value: DatabaseService(uid: user.uid).userData,
                child: TransferCredit(),
            )
        ));
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.image),
                  radius: 30.0,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.name,
                      style: TextStyle(
                          fontSize: 17.0
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      '${user.credit} credits',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
