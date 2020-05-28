import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/transactions/RequestMaterialDialog.dart';
import 'package:fluttercredittransferapp/screens/transactions/TranferMaterialDialog.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:provider/provider.dart';

class TransferCredit extends StatefulWidget {
  @override
  _TransferCreditState createState() => _TransferCreditState();
}

class _TransferCreditState extends State<TransferCredit> {

  @override
  Widget build(BuildContext context) {

    final currentUser = Provider.of<FirebaseUser>(context);
    final userData = Provider.of<DocumentSnapshot>(context);

    if(userData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text('Credit Transfer App'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(userData.data['image']),
                      radius: 60.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      userData.data['name'],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40.0,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.email,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Email',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                        child: Text(
                          userData.data['email'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.person,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Gender',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                        child: Text(
                          userData.data['gender'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.attach_money,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Credits',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                        child: Text(
                          userData.data['credit'],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.deepPurple[900],
                      child: Text(
                        'Transfer Credit',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return StreamProvider<DocumentSnapshot>.value(
                                value: DatabaseService(uid: currentUser.uid).userData,
                                child: TransferMaterialDialog(
                                    receiverUid: userData.data['uid']
                                ),
                              );
                            }
                        );
                      },
                    ),
                    RaisedButton(
                      color: Colors.deepPurple[900],
                      child: Text(
                        'Request Credit',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return RequestMaterialDialog(
                                receiverUid: userData.data['uid'],
                              );
                            }
                        );
                      },
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
