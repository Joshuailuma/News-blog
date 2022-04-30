import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

enum AppState {
  free,
  picked,
}

class _CreatePostState extends State<CreatePost>
    with SingleTickerProviderStateMixin {
  final TextEditingController bodyTextController = TextEditingController();
  final TextEditingController titleTextController = TextEditingController();

  DateTime now = DateTime.now(); //To get the current date and time

  List<String> items = [
    'Popular',
    'Politics',
    'Sports',
    'Tech',
    'Entertainment',
  ];

  String dropDownValue = 'Popular';

  XFile? _file;
  String imageId = const Uuid().v4();
  bool isUploading = false;
  // File? file;
  final storageRef = FirebaseStorage.instance.ref();
  final postsRef = FirebaseFirestore.instance.collection('posts');
  String? selectedItem;

  late AppState state;
  late TransformationController transformationController;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    transformationController = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => transformationController.value = animation!.value);
  }

  void resetAnimation() {
    animation = Matrix4Tween(
      begin: transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.ease));
    animationController.forward(from: 0);
  }

  void handleSubmit(File file) async {
    DateTime messageTimestamp = now;

    setState(() {
      isUploading = true;
    });

    final tempDir =
        await getTemporaryDirectory(); //get temporary directory as you can see
    final tempDirPath = tempDir.path; //The temporary directory path
    Im.Image? decodedImage = Im.decodeImage(
        file.readAsBytesSync()); //To ecode the image using image.dart package
    final compressedImageFile = File('$tempDirPath/image1$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(decodedImage!,
          quality: 70)); //To decodedImagecompress the immage
    setState(() {
      file =
          compressedImageFile; //Make our file in state to be the compressed file
    });
    Reference ref = storageRef.child("tempDirPath/$imageId.jpg");
    UploadTask uploadTask = ref.putFile(file);

    // To upload a file to firebase storage
    uploadTask.whenComplete(() async{
      var mediaUrl = await ref.getDownloadURL();
      print(mediaUrl.toString());

      //Upload in firestore

      postsRef.doc('news').collection(selectedItem!).doc().set({
        "mediaUrl": mediaUrl,
        "title": titleTextController.text,
        "body": bodyTextController.text,
        "timestamp": messageTimestamp,
        "imageId": imageId,
      }).whenComplete(() {
        setState(() {
          isUploading = false;
        });

        Get.snackbar("Post Successful", "",
        snackPosition: SnackPosition.TOP);

        Navigator.pop(context);
      }).onError((error, stackTrace) {
       
        setState(() {
          isUploading = false;
        });

        Get.snackbar("Error Posting ", "Please try again",
            snackPosition: SnackPosition.TOP);
        Navigator.pop(context);
      });
    });

    // Get.snackbar("Posting failed", "Try again",
    //     snackPosition: SnackPosition.TOP);
  }

  @override
  void dispose() {
    transformationController.dispose();
    animationController.dispose();
    bodyTextController.dispose();
    titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_file == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create a post'),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
                maxLength: 107,
                maxLines: 2,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title must not be empty';
                  } else if (value.length > 107) {
                    return 'Title too long';
                  }
                  return null;
                },
                controller: titleTextController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueAccent,
                    ),
                  ),
                  hintText: "Write a title",
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                controller: bodyTextController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.purpleAccent,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.purpleAccent,
                    ),
                  ),
                  hintText: "Body of the post",
                )),
          ),
          DropdownButton<String>(
            hint: Text("Category",
             style: TextStyle(color: Theme.of(context).cardColor),
            ),
            value: selectedItem,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style:  TextStyle(color: Theme.of(context).cardColor),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedItem = value;
              });
            },
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.blue),
            child:  Text(
              'Choose an image',
              style: TextStyle(color: Colors.white, fontSize: 12.6.sp),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    children: [
                      SimpleDialogOption(
                        child: Text(
                          'Image from Gallery',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.overline,
                            fontSize: 11.8.sp,
                            backgroundColor: Color.fromARGB(106, 159, 164, 238),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          XFile? _file = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              maxHeight: 3000,
                              maxWidth: 4000,
                              imageQuality: 100);

                          setState(() {
                            this._file = _file;
                            state = AppState.picked;
                          });
                          // cropImage();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ]),
      );
    } else if (_file != null && state == AppState.picked) {
      File file = File(_file!.path); //Saving the file to our phone Dir.

      return Scaffold(
        appBar: AppBar(
          title: const Text('Create a post'),
        ),
        body: isUploading
            ? const CircularProgress()
            : SingleChildScrollView(
                child: Column(children: [
                  InteractiveViewer(
                    transformationController: transformationController,
                    clipBehavior: Clip.none,
                    onInteractionEnd: (details) {
                      resetAnimation();
                    },
                    child: Container(
                      color: Colors.black,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(file),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                   SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                        maxLength: 108,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title must not be empty';
                          } else if (value.length > 108) {
                            return 'Title too long';
                          }
                          return null;
                        },
                        controller: titleTextController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                            ),
                          ),
                          hintText: "Write a title",
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: bodyTextController,
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
                          hintText: "Body of the post",
                        )),
                  ),
                  DropdownButton<String>(
                    hint:  Text("Category", 
                     style: TextStyle(color: Theme.of(context).cardColor),
                    ),
                    value: selectedItem,
                    items: items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style:  TextStyle(color: Theme.of(context).cardColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(
                      'Choose an image',
                      style: TextStyle(color: Colors.white, fontSize: 12.6.sp),
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            children: [
                              SimpleDialogOption(
                                child:  Text(
                                  'Image from Gallery',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    decoration: TextDecoration.overline,
                                    fontSize: 11.8.sp,
                                    backgroundColor:
                                       const Color.fromARGB(106, 159, 164, 238),
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  XFile? _file = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                      maxHeight: 3000,
                                      maxWidth: 4000,
                                      imageQuality: 80);

                                  setState(() {
                                    this._file = _file;
                                    state = AppState.picked;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        fixedSize: const Size(70, 50),
                        backgroundColor: const Color.fromARGB(255, 40, 158, 11),
                        shadowColor: Colors.red),
                    child: Text(
                      'Post',
                      style: TextStyle(color: Colors.white, fontSize: 12.6.sp),
                    ),
                    onPressed: () async {
                      if (titleTextController.text.isNotEmpty &&
                          bodyTextController.text.isNotEmpty &&
                          selectedItem != null) {
                        handleSubmit(
                          file,
                        );
                      } else {
                        Get.snackbar('Error', 'Please write something and choose a Category',
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                ]),
              ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 2),
            child:  Text(
              ' Please go back and try again',
              style: TextStyle(
                fontSize: 16.8.sp,
              ),
            ),
          ),
        ),
      );
    }
  }
}

class CircularProgress extends StatelessWidget {
  const CircularProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
        const SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            //if isLoading is true return circulaProgressIndicator..
            //else (i.e if false) return container
            backgroundColor: Color(0xFFE3319D),
            valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: 130,
          height: 130,
          child:  Text(
            'Please wait...',
            style: TextStyle(
              decoration: TextDecoration.overline,
              decorationThickness: 0.4,
              fontSize: 15.sp,
              fontFamily: 'Castoro',
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    ));
  }
}
