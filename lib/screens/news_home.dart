import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_blog/constants/home_news_card.dart';
import 'package:news_blog/model/category_model.dart';
import 'package:news_blog/screens/news_detail.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class NewsHome extends StatefulWidget {
  final bool isLoggedin;
 final  bool isAdmin;

   const NewsHome({
    Key? key,
    required this.isLoggedin,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _NewsHomeState createState() => _NewsHomeState();
}

class _NewsHomeState extends State<NewsHome>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  int currentIndex = 0;
  Stream<QuerySnapshot<Object?>>? popularStream;
  Stream<QuerySnapshot<Object?>>? politicsStream;
  Stream<QuerySnapshot<Object?>>? sportsStream;
  Stream<QuerySnapshot<Object?>>? techStream;
  Stream<QuerySnapshot<Object?>>? entertainmentStream;

  final storageRef = FirebaseStorage.instance.ref();

  final postRef = FirebaseFirestore.instance.collection('posts').doc('news');

  _smoothScrollToTop() {
    //For smooth scrolling of listview widgets to index 0(top)
    _scrollController.animateTo(0,
        duration: const Duration(microseconds: 500), curve: Curves.ease);
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(() {
      _smoothScrollToTop();
    });
    getMessageStream();
    super.initState();
  }

//TO change page index | We have 4 indexes(popular, tech, entertainment etc)
  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  //To get our stream of messages from our firestore database. We should call it on initState too
  getMessageStream() {
    popularStream = politicsStream = postRef
        .collection('Popular')
        .orderBy('timestamp', descending: true)
        .snapshots();

    politicsStream = postRef
        .collection('Politics')
        .orderBy('timestamp', descending: true)
        .snapshots();

    sportsStream = postRef
        .collection('Sports')
        .orderBy('timestamp', descending: true)
        .snapshots();

    techStream = postRef
        .collection('Tech')
        .orderBy('timestamp', descending: true)
        .snapshots();

    entertainmentStream = postRef
        .collection('Entertainment')
        .orderBy('timestamp', descending: true)
        .snapshots();
    setState(() {});
  }

  

//Alert dialog on deleting post
  showAlertDialog(
    BuildContext context,
    String section,
    String? imageId,
    String postId,
  ) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Post will be deleted'),
          content: const Text('Do you want to delete this Post?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  //Delete uploaded image from storage
                  storageRef.child("tempDirPath/$imageId.jpg").delete();

                  // Delete from fiestore
                  postRef.collection(section).doc(postId).get().then((value) {
                    if (value.exists) {
                      value.reference.delete();
                      Navigator.pop(context);
                      Get.snackbar("Post deleted", "",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  }).onError((error, stackTrace) {
                    Get.snackbar("Deleting failed", "Please try again",
                        snackPosition: SnackPosition.BOTTOM);
                  });
                },
                child: const Text('Accept')),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
           SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text('Latest News',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25.2.sp,
                  )),
            ),
          ),

          //For just the tab bar
          SliverToBoxAdapter(
            child: Container(
              margin:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: TabBar(
                labelPadding: EdgeInsets.only(right: 15.w),
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                isScrollable: true,
                indicator: const UnderlineTabIndicator(),
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelColor: Colors.black45,
                unselectedLabelStyle: TextStyle(
                    fontSize: 12.6.sp,
                    fontWeight: FontWeight.normal),
                tabs: List.generate(
                  categories.length,
                  (index) => Text(
                    categories[index].name,
                      style: TextStyle(
                        color: Theme.of(context).cardColor)),
                ),
              ),
            ),
          ),
        ];
      },

      //The Display at the bottom of tab ba
      body: TabBarView(
        controller: _tabController,
        children: [
          // Popular
          StreamBuilder(
            stream: popularStream,
            builder:
                (BuildContext context, AsyncSnapshot<dynamic> popularSnapshot) {
              if (popularSnapshot.hasData &&
                  popularSnapshot.data.docs.length == 0) {
                return SizedBox(
                  child: Center(
                    child: Text(
                      'No Posts yet',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                );
              } else if (popularSnapshot.hasData &&
                  popularSnapshot.data.docs.length != 0) {
                return ListView.builder(
                  itemCount: popularSnapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot ds = popularSnapshot.data.docs[index];

                    //Declaring local variables here and not globally
                    //so that they can change according to number of index on this Popular tab

                    String section = 'Popular';
                    int? popularCommentLength;
                    String? commentLengthFromDetailsScreen;
                    bool availablePopularComment = false;

                    String? title = ds['title'];
                    String? body = ds['body'];
                    String? mediaUrl = ds['mediaUrl'];
                    String? imageId = ds['imageId'];
                    Timestamp messageTimestamp = ds['timestamp'];

                    DateTime dateTime = messageTimestamp
                        .toDate(); //Coverting timestamp to DateTime object

                    String lastTimeFromJiffy =
                        Jiffy(dateTime).startOf(Units.MINUTE).fromNow();

                    String postId = ds.reference.id.toString();

                    getPopularComment() async {
                      await FirebaseFirestore.instance
                          .collection('comments')
                          .doc(postId)
                          .collection('comments')
                          .get()
                          .then((popular) {
                        popularCommentLength = popular.docs.length;
                      });
                    }

                    //We will pass popularCommentLegth to the next screen
                    //Sice we can't make this screen to wait a while to get it
                    //Then pass it back to this screen to display it here

                    getPopularComment();

                    return InkWell(
                      onLongPress: () {
                        widget.isAdmin
                            ? showAlertDialog(
                                context, section, imageId!, postId)
                            : ('');
                      },
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsDetail(
                                      title: title,
                                      body: body,
                                      mediaUrl: mediaUrl,
                                      postId: postId,
                                      lastTimeFromJiffy: lastTimeFromJiffy,
                                      isLoggedIn: widget.isLoggedin,
                                      commentLength: popularCommentLength,
                                    )));

                        setState(() {
                          commentLengthFromDetailsScreen = result;
                          availablePopularComment =
                              commentLengthFromDetailsScreen != null;
                        });
                      },
                      child: HomeNewsCard(
                          imageUrl: mediaUrl!,
                          body: body!,
                          time: lastTimeFromJiffy,
                          title: title!,
                          commentNumber: availablePopularComment
                              ? '$commentLengthFromDetailsScreen comments'
                              : ''),
                    );
                  },
                );
              } else if (!popularSnapshot.hasData) {
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
            },
          ),

          //Politics News
          StreamBuilder(
            stream: politicsStream,
            builder: (BuildContext context,
                AsyncSnapshot<dynamic> politicsSnapshot) {
              if (politicsSnapshot.hasData &&
                  politicsSnapshot.data.docs.length == 0) {
                return SizedBox(
                  child: Center(
                    child: Text(
                      'No Posts yet',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                );
              } else if (politicsSnapshot.hasData &&
                  politicsSnapshot.data.docs.length != 0) {
                return ListView.builder(
                  itemCount: politicsSnapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot ds = politicsSnapshot.data!.docs[index];

                    String section = 'Politics';
                    String? title = ds['title'];
                    String? body = ds['body'];
                    String? mediaUrl = ds['mediaUrl'];
                    String? imageId = ds['imageId'];
                    Timestamp messageTimestamp = ds['timestamp'];

                    DateTime dateTime = messageTimestamp.toDate();
                    String lastTimeFromJiffy =
                        Jiffy(dateTime).startOf(Units.MINUTE).fromNow();

                    String postId = ds.reference.id.toString();

                    int? politicsCommentLength;
                    //To get comment length
                    getPoliticsComment() async {
                      FirebaseFirestore.instance
                          .collection('comments')
                          .doc(postId)
                          .collection('comments')
                          .get()
                          .then((politics) {
                        politicsCommentLength = politics.docs.length;
                      });
                    }

                    getPoliticsComment();

                    bool availableComment = politicsCommentLength != null;

                    return InkWell(
                      onLongPress: () {
                        widget.isAdmin
                            ? showAlertDialog(
                                context, section, imageId!, postId)
                            : ('');
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetail(
                              title: title,
                              body: body,
                              mediaUrl: mediaUrl,
                              postId: postId,
                              lastTimeFromJiffy: lastTimeFromJiffy,
                              isLoggedIn: widget.isLoggedin,
                              commentLength: politicsCommentLength,
                            ),
                          ),
                        );
                      },
                      child: HomeNewsCard(
                          imageUrl: mediaUrl!,
                          body: body!,
                          time: lastTimeFromJiffy,
                          title: title!,
                          commentNumber: availableComment
                              ? '$politicsCommentLength comments'
                              : ''),
                    );
                  },
                );
              } else if (!politicsSnapshot.hasData) {
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
            },
          ),

          //Sports

          StreamBuilder(
            stream: sportsStream,
            builder:
                (BuildContext context, AsyncSnapshot<dynamic> sportsSnapshot) {
              if (sportsSnapshot.hasData &&
                  sportsSnapshot.data.docs.length == 0) {
                return SizedBox(
                  child: Center(
                    child: Text(
                      'No Posts yet',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                );
              } else if (sportsSnapshot.hasData &&
                  sportsSnapshot.data.docs.length != 0) {
                return ListView.builder(
                  itemCount: sportsSnapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot ds = sportsSnapshot.data!.docs[index];

                    String section = 'Sports';
                    String? title = ds['title'];
                    String? body = ds['body'];
                    String? mediaUrl = ds['mediaUrl'];
                    String postId = ds.reference.id.toString();
                    String? imageId = ds['imageId'];
                    Timestamp messageTimestamp = ds['timestamp'];

                    DateTime dateTime = messageTimestamp.toDate();
                    String lastTimeFromJiffy =
                        Jiffy(dateTime).startOf(Units.MINUTE).fromNow();

                    //Get comment length
                    int? sportsCommentLength;
                    getsportComment() {
                      FirebaseFirestore.instance
                          .collection('comments')
                          .doc(postId)
                          .collection('comments')
                          .get()
                          .then((sports) {
                        sportsCommentLength = sports.docs.length;
                      });
                    }

                    getsportComment();

                    bool availableComment = sportsCommentLength != null;

                    return InkWell(
                      onLongPress: () {
                        widget.isAdmin
                            ? showAlertDialog(
                                context, section, imageId!, postId)
                            : ('');
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsDetail(
                                      title: title,
                                      body: body,
                                      mediaUrl: mediaUrl,
                                      postId: postId,
                                      lastTimeFromJiffy: lastTimeFromJiffy,
                                      isLoggedIn: widget.isLoggedin,
                                      commentLength: sportsCommentLength,
                                    )));
                      },
                      child: HomeNewsCard(
                        imageUrl: mediaUrl!,
                        body: body!,
                        time: lastTimeFromJiffy,
                        title: title!,
                        commentNumber: availableComment
                            ? '$sportsCommentLength comments'
                            : '',
                      ),
                    );
                  },
                );
              } else if (!sportsSnapshot.hasData) {
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
            },
          ),

          //Tech

          StreamBuilder(
            stream: techStream,
            builder:
                (BuildContext context, AsyncSnapshot<dynamic> techSnapshot) {
              if (techSnapshot.hasData && techSnapshot.data.docs.length == 0) {
                return SizedBox(
                  child: Center(
                    child: Text(
                      'No Posts yet',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                );
              } else if (techSnapshot.hasData &&
                  techSnapshot.data.docs.length != 0) {
                return ListView.builder(
                  itemCount: techSnapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot ds = techSnapshot.data!.docs[index];

                    String section = 'Tech';
                    String? title = ds['title'];
                    String? body = ds['body'];
                    String? mediaUrl = ds['mediaUrl'];
                    String postId = ds.reference.id.toString();
                    String? imageId = ds['imageId'];
                    Timestamp messageTimestamp = ds['timestamp'];

                    DateTime dateTime = messageTimestamp.toDate();
                    String lastTimeFromJiffy =
                        Jiffy(dateTime).startOf(Units.MINUTE).fromNow();

                    //Get comment length
                    int? techCommentLength;
                    FirebaseFirestore.instance
                        .collection('comments')
                        .doc(postId)
                        .collection('comments')
                        .get()
                        .then((tech) {
                      techCommentLength = tech.docs.length;
                    });

                    bool availableComment = techCommentLength != null;

                    return InkWell(
                      onLongPress: () {
                        widget.isAdmin
                            ? showAlertDialog(
                                context, section, imageId!, postId)
                            : ('');
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsDetail(
                                      title: title,
                                      body: body,
                                      mediaUrl: mediaUrl,
                                      postId: postId,
                                      lastTimeFromJiffy: lastTimeFromJiffy,
                                      isLoggedIn: widget.isLoggedin,
                                      commentLength: techCommentLength,
                                    )));
                      },
                      child: HomeNewsCard(
                        imageUrl: mediaUrl!,
                        body: body!,
                        time: lastTimeFromJiffy,
                        title: title!,
                        commentNumber: availableComment
                            ? '$techCommentLength comments'
                            : '',
                      ),
                    );
                  },
                );
              } else if (!techSnapshot.hasData) {
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
            },
          ),

          //Entertainment
          StreamBuilder(
            stream: entertainmentStream,
            builder: (BuildContext context,
                AsyncSnapshot<dynamic> entertainmentSnapshot) {
              if (entertainmentSnapshot.hasData &&
                  entertainmentSnapshot.data.docs.length == 0) {
                return SizedBox(
                  child: Center(
                    child: Text(
                      'No Posts yet',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                );
              } else if (entertainmentSnapshot.hasData &&
                  entertainmentSnapshot.data.docs.length != 0) {
                return ListView.builder(
                  itemCount: entertainmentSnapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot ds =
                        entertainmentSnapshot.data!.docs[index];

                    String section = 'Entertainment';
                    String? title = ds['title'];
                    String? body = ds['body'];
                    String? mediaUrl = ds['mediaUrl'];
                    String postId = ds.reference.id.toString();
                    String? imageId = ds['imageId'];
                    Timestamp messageTimestamp = ds['timestamp'];

                    DateTime dateTime = messageTimestamp.toDate();
                    String lastTimeFromJiffy =
                        Jiffy(dateTime).startOf(Units.MINUTE).fromNow();

                    //Get comment length
                    int? entertainmentCommentLength;
                    FirebaseFirestore.instance
                        .collection('comments')
                        .doc(postId)
                        .collection('comments')
                        .get()
                        .then((entertainment) {
                      entertainmentCommentLength = entertainment.docs.length;
                    });

                    bool availableComment = entertainmentCommentLength != null;

                    return InkWell(
                      onLongPress: () {
                        widget.isAdmin
                            ? showAlertDialog(
                                context, section, imageId!, postId)
                            : ('');
                      },
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsDetail(
                                      title: title,
                                      body: body,
                                      mediaUrl: mediaUrl,
                                      postId: postId,
                                      lastTimeFromJiffy: lastTimeFromJiffy,
                                      isLoggedIn: widget.isLoggedin,
                                      commentLength: entertainmentCommentLength,
                                    )));
                      },
                      child: HomeNewsCard(
                        imageUrl: mediaUrl!,
                        body: body!,
                        time: lastTimeFromJiffy,
                        title: title!,
                        commentNumber: availableComment
                            ? '$entertainmentCommentLength comments'
                            : '',
                      ),
                    );
                  },
                );
              } else if (!entertainmentSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return Center(
                  child: Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}