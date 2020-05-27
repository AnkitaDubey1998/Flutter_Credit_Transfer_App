import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForRequest.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForTransaction.dart';

class DatabaseService {

  final String uid;

  DatabaseService({ this.uid });


  // user collection and transaction collection references
  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference transactionCollection = Firestore.instance.collection('transactions');
  final CollectionReference requestCollection = Firestore.instance.collection('requests');


  // inserting new user
  Future insertUserData(String name, String email, String gender, String credit, String image, List<dynamic> deviceTokens) async {
    try {
      return await userCollection.document(uid).setData({
        'uid': uid,
        'name': name,
        'email': email,
        'gender': gender,
        'credit': credit,
        'image': image,
        'deviceTokens': deviceTokens
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  // inserting device token of a user
  Future insertDeviceToken(List<dynamic> tokens) async {
    try {
      return await userCollection.document(uid).updateData({
        'deviceTokens': tokens
      });
    } catch (e) {
      return e;
    }
  }


  // get device tokens od a user
  Future<List<dynamic>> getUserDeviceTokens() async {
    try {
      return await userCollection.document(uid).get().then((value) {
//        print(value.data['deviceTokens'].runtimeType);
        return value.data['deviceTokens'];
      });
    } catch(e) {
      return e;
    }
  }


  // update user credit details
  Future updateCreditDetails(String uid, String credit) async {
    try{
      await Firestore.instance.runTransaction((transaction) async {
        await userCollection.document(uid).updateData({'credit': credit});
      });
    } catch(e) {
      return e;
    }
  }


  // update user profile image
  Future updateUserProfileImage(String imageUrl) async {
    try {
      await userCollection.document(uid).updateData({'image': imageUrl});
    } catch (e) {
      return e;
    }
  }


  // insert credit transaction details in history collection
  Future insertTransactionDetails(ModelForTransaction t) async {
    try{
      await Firestore.instance.runTransaction((transaction) async {
        await transactionCollection.document(uid).collection(uid).add({
          'uid': t.uid,
          'name': t.name,
          'type': t.type,
          'dateTime': t.dateTime,
          'credit': t.credit
        });
      });
    } catch(e) {
      return e;
    }
  }


  // insert request credit details in request collection
  Future insertRequestDetails(ModelForRequest request, String type) async {
    try {
      if(type == 'to') {
        await Firestore.instance.runTransaction((transaction) async {
          await requestCollection.document(uid).collection(type).add({
            'receiverUid': request.uid,
            'receiverName': request.name,
            'credit': request.credit,
            'dateTime': request.dateTime,
            'status': request.status
          });
        });
      } else {
        await Firestore.instance.runTransaction((transaction) async {
          await requestCollection.document(uid).collection(type).add({
            'senderUid': request.uid,
            'senderName': request.name,
            'credit': request.credit,
            'dateTime': request.dateTime,
            'status': request.status
          });
        });
      }
    } catch(e) {

    }
  }


  // get all users stream data
  Stream<QuerySnapshot> get users {
    return userCollection.snapshots();
  }


  // get single user data
  Stream<DocumentSnapshot> get userData {
    return userCollection.document(uid).snapshots();
  }


  // get credit and name of a user
  Future<List<String>> getUserNameCredit() async {
    return await userCollection.document(uid).get().then((value) {
      return [value.data['name'], value.data['credit']];
    });
  }


  // get all transactions of a user
  Stream<QuerySnapshot> get transactionHistory {
    return transactionCollection.document(uid).collection(uid).snapshots();
  }


}