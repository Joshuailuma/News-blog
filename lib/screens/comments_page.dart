import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_blog/constants/shared_preferences.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CommentsPage extends StatefulWidget {
  final bool isLoggedIn;
  final String? postId;
  const CommentsPage({
    Key? key,
    this.postId,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController messageController = TextEditingController();
  String? myPhotoUrl, myName;
  Stream<QuerySnapshot<Object?>>? commentStream;
  DateTime now = DateTime.now(); //To get the current date and time
  bool? admin;
  String? noOfPost;
  // int noOfPost;

  @override
  void initState() {
    getCommentStream();
    getDataFromSharedPreference();
    super.initState();
  }

  getCommentStream() {
    commentStream = FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  getDataFromSharedPreference() async {
    myPhotoUrl = await MySharedPreferences().getPhotoUrl();
    myName = await MySharedPreferences().getDisplayName();
    admin = await MySharedPreferences().getIsAdmin();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: StreamBuilder(
                    stream: commentStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData && snapshot.data.docs.length == 0) {
                        return SizedBox(
                          child: Center(
                            child: Text(
                              'No comments yet',
                              style: TextStyle(fontSize: 18.4.sp),
                            ),
                          ),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data.docs.length != 0) {
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              DocumentSnapshot ds = snapshot.data!.docs[index];

                               noOfPost = snapshot.data!.docs.length.toString();
                              

                              String? name = ds['name'];
                              String? message = ds['message'];
                              String? profileImage = ds['profileImage'];
                              Timestamp messageTimestamp = ds['timestamp'];

                              DateTime dateTime = messageTimestamp
                                  .toDate(); //Coverting timestamp to DateTime object

                              String lastTimeFromJiffy = Jiffy(dateTime)
                                  .startOf(Units.MINUTE)
                                  .fromNow(); //Using Jiffy package

                              return   Container(
                                  margin:  EdgeInsets.only(
                                      left: 10.w, right: 10.w, top: 21.h, bottom: 15.h),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                      ),
                                                            
                                  //Inside container
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                profileImage!),
                                      ),
                                                            
                                      //Right part
                                      Expanded(
                                        child: Container(
                                          padding:  EdgeInsets.only(
                                              top: 5.h, bottom: 10.h, left: 14.w),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    name!,
                                                    style: TextStyle(
                                                      fontSize: 13.4.sp,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                   SizedBox(width: 8.w),
                                                  Text(
                                                    lastTimeFromJiffy,
                                                    style:  TextStyle(
                                                      fontSize: 9.2.sp,
                                                      fontWeight: FontWeight.w300,
                                                    ),
                                                    softWrap: true,
                                                  ),
                                                ],
                                              ),
                                                            
                                              SizedBox(
                                                height: 7.h,
                                              ),
                                                            
                                              //For date
                                              SizedBox(
                                                child: Row(
                                                  children: [
                                                    Text(message!),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              );
                            }
                            );
                      } else if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Center(
                          child: Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 15.sp,
                            ),
                          ),
                        );
                      }
                    }),
              ),
            ),
          ),

          //TextField
          Container(
            height: 40.h,
            width: MediaQuery.of(context).size.width,
            margin:  EdgeInsets.only(left: 12.w, right: 12.w, bottom: 9.h),
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Color(0xFF512E5F),
                    Colors.teal,
                  ],
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                )),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:  EdgeInsets.only(left: 8.0.w),
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 6,
                      style:  TextStyle(
                        color: Theme.of(context).cardColor,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      decoration:  InputDecoration.collapsed(
                          hintText: 'Send a message...',
                          hintStyle: TextStyle(color: Theme.of(context).cardColor)),
                      autocorrect: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  iconSize: 15.12.sp,
                  onPressed: () {
                    if (messageController.text != '' &&
                        widget.isLoggedIn == true) {
                      // DateTime messageTimestamp = now
                      DateTime messageTimestamp = now;

                      String message =
                          messageController.text; //Our message input

                      Map<String, dynamic> messageInfoMap = {
                        //This map will be uploaded in a colletion called chats which is inside  a chat room
                        "message": message, //The message text
                        "name": myName, //Person who sent the message
                        "timestamp":
                            messageTimestamp, // Time message was sent //"timestamp": messageTimestamp,  Time message was sent
                        "profileImage": myPhotoUrl,
                        // "secondUserImageUrl": widget
                        //     .secondUserImageUrl, //The image of the user u are chatting with
                      };

                      //Add message to database
                      FirebaseFirestore.instance
                          .collection("comments")
                          .doc(widget.postId)
                          .collection("comments")
                          .doc()
                          .set(messageInfoMap);

                      messageController.clear(); //Clear text in input field
                    } else if (widget.isLoggedIn == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Sorry'),
                            content: const Text(
                                "You can't comment unless you are logged in"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, noOfPost);
                                  },
                                  child: const Text('Ok')),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
