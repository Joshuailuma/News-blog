import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_blog/constants/constants.dart';
import 'package:news_blog/constants/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final String myPhotoUrl;
  final bool isAdmin;
  const EditProfile(
      {Key? key,
      required this.myPhotoUrl,
      String? photoUrl,
      required this.isAdmin})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameTextController = TextEditingController();

  final usersRef = firebaseFirestore.collection('users');

  changeName() async {
    await googleSignIn.signIn().then((googleAccount) async {
      //To get the Google account id from firestore
      DocumentSnapshot userId =
          await usersRef.doc(googleAccount!.id).get().catchError((e) {});

      usersRef.doc(googleAccount.id).update({
        "displayName": nameTextController.text,
      });

      await MySharedPreferences.setDisplayName(nameTextController.text);
      await MySharedPreferences().getDisplayName();

      Get.snackbar("Name updated successfully", "",
          snackPosition: SnackPosition.BOTTOM);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 5, right: 15, top: 40),
        child: SizedBox(
          child: Column(
            children: [
              // Back button row
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 65),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              SizedBox(height: 20),

              ClipOval(
                child: SizedBox(
                  height: 200,
                  width: 150,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage:
                        CachedNetworkImageProvider(widget.myPhotoUrl),
                  ),
                ),
              ),

              Text(
                'Joshua Iluma',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Card(
                shadowColor: Colors.red,
                color: Colors.green,
                child: widget.isAdmin ? Text('Admin') : Text(''),
              ),

              TextButton(
                onPressed: () {},
                child: Text('Change Image'),
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    onEditingComplete: () {
                      changeName();
                    },
                    textCapitalization: TextCapitalization.sentences,
                    controller: nameTextController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.purpleAccent),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purpleAccent,
                        ),
                      ),
                      hintText: "New Name",
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
