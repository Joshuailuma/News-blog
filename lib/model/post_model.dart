import 'package:cloud_firestore/cloud_firestore.dart';

PostModel? postModel;

// Making data accesible throuout our app regardless wether user is signed in or not

class PostModel {
  // final GoogleSignIn googleSignIn = GoogleSignIn(); //Instantiate googleSignIn

  String? body;
  String? mediaUrl;
  String? title;
  String? imageId;
  String? id;

  PostModel({
    required this.body,
    required this.mediaUrl,
    required this.title,
    required this.imageId,
    required this.id,
  });
// To fetch user details from firestore
  factory PostModel.fromFireStore(DocumentSnapshot thePost) {

    return PostModel(
      id: thePost.id,
      body: thePost['body'] ?? '',
      mediaUrl: thePost['mediaUrl'] ?? '',
      title: thePost['title'] ?? '',
      imageId: thePost['imageId'] ?? '',
    );
  }
}
