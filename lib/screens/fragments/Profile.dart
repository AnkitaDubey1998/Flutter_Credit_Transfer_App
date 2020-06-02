import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForUser.dart';
import 'package:fluttercredittransferapp/services/Auth.dart';
import 'package:fluttercredittransferapp/services/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final AuthServices _auth = AuthServices();
  ProgressDialog progressDialog;
  ProgressDialog signOutProgressDialog;
  ModelForUser currentUser;
  File imageFile;

  @override
  Widget build(BuildContext context) {

    final currentUserData = Provider.of<DocumentSnapshot>(context);
    if(currentUserData == null) {
      return Center(child: CircularProgressIndicator());
    }

    currentUser = ModelForUser(uid: currentUserData.data['uid'], name: currentUserData.data['name'], email: currentUserData.data['email'],
                                    gender: currentUserData.data['gender'], credit: currentUserData.data['credit'], image: currentUserData.data['image']);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage: NetworkImage(currentUser.image),
                    radius: 60.0,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 12,
                    child: Container(
                      height: 35,
                      width: 35,
                      child: FittedBox(
                        child: FloatingActionButton(
                          child: Icon(
                            Icons.add,
                          ),
                          backgroundColor: Colors.deepPurple[900],
                          onPressed: () async {
                            await _showChoiceDialog(context);
                          },
                        ),
                      ),
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
                          Icons.person,
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          'Name',
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30.0,0,0,0),
                      child: Text(
                        currentUser.name,
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
                        currentUser.email,
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
                        currentUser.credit,
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
            Center(
              child: RaisedButton(
                color: Colors.deepPurple[900],
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  signOutProgressDialog = ProgressDialog(
                      context,
                      type: ProgressDialogType.Normal,
                      isDismissible: true
                  );
                  signOutProgressDialog.style(
                    message: 'Signing out...',
                  );
                  await signOutProgressDialog.show();

                  // getting all devices tokens of current user from database
                  List<dynamic> tokens = await DatabaseServices(uid: currentUser.uid).getUserDeviceTokens();
                  String deviceToken;
                  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
                  // getting token of current device of the user
                  await firebaseMessaging.getToken().then((token) {
                    deviceToken = token;
                  });
                  if(tokens.contains(deviceToken)) {
                    tokens.remove(deviceToken);           // removing current device token from tokens list
                    // updating tokens list in database
                    await DatabaseServices(uid: currentUser.uid).insertDeviceToken(tokens).then((value) {

                    }).catchError((error) {
                      Fluttertoast.showToast(msg: "error: "+error, toastLength: Toast.LENGTH_LONG);
                    });
                  }

                  // signing out
                  await _auth.signOut();
                  await signOutProgressDialog.hide();
                  Fluttertoast.showToast(msg: "Logged out successful", toastLength: Toast.LENGTH_LONG);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Dialog which shows Camera and Gallery as options
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Make a choice'),
          content: SingleChildScrollView(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await _openGallery(context);
                      await _showImageDialog(context, imageFile);
                    },
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: Icon(
                              Icons.photo,
                              color: Colors.deepPurple[900],
                              size: 35.0,
                            ),
                            radius: 30.0,
                          ),
                          radius: 32.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Gallery',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await _openCamera(context);
                      await _showImageDialog(context, imageFile);
                    },
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.deepPurple[900],
                              size: 35.0,
                            ),
                            radius: 30.0,
                          ),
                          radius: 32.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Camera',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await progressDialog.show();
                      FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutter-credit-transfer.appspot.com');
                      String newImageUrl = await _storage.ref().child('Default profile image.png').getDownloadURL();
                      await DatabaseServices(uid: currentUser.uid).updateUserProfileImage(newImageUrl).then((value) async {
                        await progressDialog.hide();
                        Fluttertoast.showToast(msg: "Profile image removed successfully", toastLength: Toast.LENGTH_LONG);
                      }).catchError((error) {
                        Fluttertoast.showToast(msg: "error"+error.toString(), toastLength: Toast.LENGTH_LONG);
                      });

                      Navigator.of(context).pop();
                    },
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.black,
                          child: CircleAvatar(
                            backgroundColor: Colors.yellow,
                            child: Icon(
                              Icons.delete,
                              color: Colors.deepPurple[900],
                              size: 35.0,
                            ),
                            radius: 30.0,
                          ),
                          radius: 32.0,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          'Remove',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }


  // Function which opens gallery
  _openGallery(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = image;
    });
    Navigator.of(context).pop();
  }


  // Function which opens camera
  _openCamera(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imageFile = image;
    });
    Navigator.of(context).pop();
  }


  // Dialog which shows the selected image
  Future<void> _showImageDialog(BuildContext context, File imageFile) {

    if(imageFile != null) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: Image.file(imageFile)
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: RaisedButton(
                        color: Colors.deepPurple[900],
                        child: Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          await _uploadImage(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      );
    }

  }


  // uploading image to firebase storage
  Future _uploadImage(BuildContext context) async {
    Navigator.pop(context);
    try {
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutter-credit-transfer.appspot.com');
        StorageReference _imageStorageReference = _storage.ref().child('Profile Images/${currentUser.uid}/');

        StorageUploadTask _uploadTask = await _imageStorageReference.child('${currentUser.uid}.png').putFile(imageFile);

        progressDialog = ProgressDialog(
            context,
            type: ProgressDialogType.Download,
            isDismissible: true
        );
        progressDialog.style(
          message: 'Changing Profile Image...',
          progress: 0.0,
          maxProgress: 100.0,
        );

        if(!progressDialog.isShowing()){
          await progressDialog.show();
        }
        await _uploadTask.events.listen((event) async{
          double progressPercent= event!=null ? event.snapshot.bytesTransferred.toDouble()/event.snapshot.totalByteCount.toDouble() : 0;
          if(_uploadTask.isInProgress){
            print(progressPercent*100);
            progressDialog.update(progress: double.parse((progressPercent*100).toStringAsFixed(2)));
          }

          if(_uploadTask.isComplete){
            var downloadUrl = await (await _uploadTask.onComplete).ref.getDownloadURL();
            String imageUrl = downloadUrl.toString();
            print('hi');
            print(imageUrl);
            DatabaseServices(uid: currentUser.uid).updateUserProfileImage(imageUrl.toString());
            if(progressDialog.isShowing()){
              progressDialog.hide();
            }
            Navigator.pop(context);
            Fluttertoast.showToast(msg: "Upload Successful",toastLength: Toast.LENGTH_LONG);
          }
        });
      }
    } on SocketException catch(e) {
      Fluttertoast.showToast(msg: "No Internet Connection",toastLength: Toast.LENGTH_LONG);
    }
  }

}
