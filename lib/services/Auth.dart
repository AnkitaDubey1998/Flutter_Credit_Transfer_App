import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttercredittransferapp/services/Database.dart';

class AuthServices {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on Firebase user
//  ModelForUser _userFromFirebaseUser(FirebaseUser user) {
//    return user != null ? ModelForUser(uid: user.uid) : null;
//  }


  // auth change user stream
  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }


  // sign in anonymous
  Future signInAnonymous() async {
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  // sign in with email and password
  Future signInWithEmailAndPassword (String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      print(user);
      return user;
    } catch(e) {
      print("register error");
      print(e.toString());
      return null;
    }
  }


  // register with email and password
  Future registerWithEmailAndPassword (String name, String email, String password,
                                        String gender, String credit, String image, List<dynamic> deviceTokens) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;

      // create new document of user
      await DatabaseServices(uid: user.uid).insertUserData(name, email, gender, credit, image, deviceTokens);
      return user;
    } catch(e) {
      print("register error");
      print(e.toString());
      return null;
    }
  }


  // Reset password
  Future resetPassword(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
    } catch(e) {
      return e;
    }

  }


  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


}