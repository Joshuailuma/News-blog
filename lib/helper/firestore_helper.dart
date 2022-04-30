import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_blog/constants/constants.dart';
import 'package:news_blog/model/post_model.dart';

class FirestoreDb extends ChangeNotifier {
  // final GoogleSignIn googleSignIn = GoogleSignIn(); //Instantiate googleSignIn

  // streamUser() async {
  //   final GoogleSignInAccount? googleAccount = googleSignIn.currentUser;

  //   DocumentSnapshot userId = await firebaseFirestore
  //       .collection('posts').doc(googleAccount?.email).get();

  //   _userDetail = PostModel.fromFireStore(userId);
  //   //Call this whenever there is some change in any field of change notifier.
  //   // notifyListeners();
  // }

  Stream<PostModel> politicsStream() {
    return firebaseFirestore
        .collection('posts')
        .doc('news')
        .collection('Politics')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => PostModel.fromFireStore(snapshot as DocumentSnapshot<Object?>));
  }
}

// return firebaseFirestore
//         .collection('posts')
//         .doc('news').collection('Politics').orderBy('timestamp', descending: true).snapshots().map((anyNameILike) => anyNameILike.docs
//         .map((userId) => PostModel.fromFireStore(userId))
//         .toList());