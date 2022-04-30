import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_blog/screens/create_post.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/profile_cards.dart';

class ProfileScreen extends StatefulWidget {
  final String myName;
  final String myPhotoUrl;
  final bool isAdmin;
  final bool isLoggedIn;
  const ProfileScreen(
      {Key? key,
      required this.myName,
      required this.myPhotoUrl,
      required this.isAdmin,
      required this.isLoggedIn})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  showAlertDialog(
    BuildContext context,
  ) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to delete a post'),
          content: const Text('Tap and hold down on any post to delete it'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Okay')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: widget.isLoggedIn
                          ? Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      widget.myPhotoUrl),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('images/blank.png'),
                                ),
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.85),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child:  Icon(
                                  Icons.arrow_back,
                                  size: 25.2.sp,
                                ),
                              ),
                            ),
                            Container(
                              margin:  EdgeInsets.only(
                                left: 8.w, right: 8.w, top: 15.h,
                              ),
                              alignment: Alignment.topLeft,
                              child:  Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    height: 230.h,
                                    width: 160.w,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                                height: 200.h,
                                                width: 150.w,
                                                child: widget.isLoggedIn
                                                    ? CircleAvatar(
                                                        radius: 10.08.sp,
                                                        backgroundImage:
                                                            CachedNetworkImageProvider(
                                                                widget
                                                                    .myPhotoUrl),
                                                      )
                                                    : const CircleAvatar(
                                                        backgroundImage: AssetImage(
                                                            'images/blank.png'),
                                                      )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    widget.isLoggedIn
                                        ? widget.myName
                                        : 'You are not Signed in',
                                    style: TextStyle(
                                      fontSize: 15.4.sp,
                                    ),
                                  ),
                                  Card(
                                    shadowColor: Colors.red,
                                    color: Colors.green,
                                    child: widget.isAdmin
                                        ? Text('Admin')
                                        : Text(''),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Body
              Expanded(
                flex: 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // SizedBox(height: 2.0.),
                      // widget.isLoggedIn
                      //     ? ProfileCard(
                      //         containerColor:
                      //             const Color(0xFFD70040).withOpacity(0.3),
                      //         text: 'Edit Profile',
                      //         icon: Icons.person,
                      //         iconColor: const Color(0xFFD70040),
                      //         press: () {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) =>
                      //                        EditProfile( myPhotoUrl: widget.myPhotoUrl!, isAdmin: widget.isAdmin,)));
                      //         })
                      //     : Text(''),

                      widget.isAdmin
                          ? ProfileCard(
                              containerColor:
                                  const Color(0xFF5D3FD3).withOpacity(0.3),
                              text: 'Create Post',
                              icon: Icons.add_to_photos,
                              iconColor: const Color(0xFF5D3FD3),
                              press: () {
                                Get.to(
                                  CreatePost(),
                                );
                              },
                            )
                          : Text(''),
                      widget.isAdmin ? Divider() : Text(''),

                      // widget.isAdmin ?  ProfileCard(
                      //     containerColor: Colors.black.withOpacity(0.3),
                      //     text: 'Edit Post',
                      //     icon: Icons.edit_note,
                      //     iconColor: Colors.black,
                      //     press: () {
                      //     },
                      //   ) : Text(''),

                      widget.isAdmin
                          ? ProfileCard(
                              containerColor: Colors.black.withOpacity(0.3),
                              text: 'Delete Post',
                              icon: Icons.delete,
                              iconColor: Colors.black,
                              press: () {
                                showAlertDialog(context);
                              })
                          : Text('')
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
