import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  static FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flutter-credit-transfer.appspot.com');
  final StorageReference _imageStorageReference = _storage.ref().child('Profile Images');

  Future<String> uploadImage(File imageFile, String imagePath) async {
    String imageUrl;
    try{
      StorageUploadTask uploadTask = _imageStorageReference.child(imagePath).putFile(imageFile);

      if(uploadTask.isSuccessful || uploadTask.isComplete) {
        imageUrl = await _imageStorageReference.getDownloadURL();
        print(imageUrl);
      } else if (uploadTask.isInProgress) {
        uploadTask.events.listen((event) {
          double percentage = 100 *(event.snapshot.bytesTransferred.toDouble()
              / event.snapshot.totalByteCount.toDouble());
          print(percentage);
        });
        StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
        imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
        print(imageUrl);
      }
      return imageUrl;
    } catch(e) {
      return e;
    }

  }

}