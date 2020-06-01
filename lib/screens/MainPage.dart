import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/fragments/Approve.dart';
import 'package:fluttercredittransferapp/screens/fragments/History.dart';
import 'package:fluttercredittransferapp/screens/fragments/Home.dart';
import 'package:fluttercredittransferapp/screens/fragments/Profile.dart';
import 'package:fluttercredittransferapp/screens/fragments/Requests.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:provider/provider.dart';

import 'models/ModelForUser.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _currentIndex = 0;
  FirebaseUser currentUser;

  Widget callPage(int currentIndex) {

    switch(currentIndex) {
      case 0:
        return StreamProvider<QuerySnapshot>.value(
            value: DatabaseServices().users,
            child: Home()
        );

      case 1:
        return StreamProvider<QuerySnapshot>.value(
            value: DatabaseServices(uid: currentUser.uid).transactionHistory,
            child: History()
        );

      case 2:
        return StreamProvider<QuerySnapshot>.value(
            value: DatabaseServices(uid: currentUser.uid).sentRequests,
            child: Requests()
        );

      case 3:
        return StreamProvider<QuerySnapshot>.value(
            value: DatabaseServices(uid: currentUser.uid).receivedRequests,
            child: Approve()
        );

      case 4:
        return StreamProvider<DocumentSnapshot>.value(
            value: DatabaseServices(uid: currentUser.uid).userData,
            child: Profile()
        );

      default:
        return StreamProvider<QuerySnapshot>.value(
            value: DatabaseServices().users,
            child: Home()
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    currentUser = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Transfer App'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
      ),
      body: callPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple[900],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('History'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            title: Text('Requests'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            title: Text('Approve'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }

}
