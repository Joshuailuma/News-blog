import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:news_blog/screens/comments_page.dart';

class NewsDetail extends StatefulWidget {
  final String? title, body, mediaUrl, postId, lastTimeFromJiffy;
  final int? commentLength;
  final bool isLoggedIn;

  const NewsDetail({
    Key? key,
    this.title,
    this.body,
    this.mediaUrl,
    this.postId,
    this.lastTimeFromJiffy,
    required this.isLoggedIn,
    this.commentLength,
  }) : super(key: key);

  @override
  State<NewsDetail> createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  String? newResult;

  @override
  Widget build(BuildContext context) {
    bool availableComment = widget.commentLength != null;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsPage(
                    postId: widget.postId!,
                    isLoggedIn: widget.isLoggedIn,
                  ),
                ),
              );
            },
            child: const Icon(Icons.chat)),
        body: WillPopScope(
          onWillPop: () async{
            Navigator.pop(context, widget.commentLength.toString());
            return false;
          },
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(widget.mediaUrl!),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, widget.commentLength.toString());
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 21.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Bottom write-up space
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 20.w),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          SizedBox(width: 8.w),
                          Text(widget.lastTimeFromJiffy!),
                          const Spacer(),
                          Text(
                            availableComment
                                ? widget.commentLength.toString() +
                                    '\u{00A0}comments'
                                : '',
                            style: TextStyle(
                              fontSize: 10.8.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 5.h, bottom: 10.h, left: 20.w, right: 20.w),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Title
                              Text(
                                widget.title!,
                                style: TextStyle(
                                  fontSize: 15.1.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5.h,
                                  backgroundColor:
                                      Colors.indigoAccent.withOpacity(0.5),
                                ),
                                softWrap: true,
                              ),

                               SizedBox(
                                height: 20.h,
                              ),

                              SizedBox(
                                //Body
                                child: Text(
                                  widget.body!,
                                  style:  TextStyle(
                                    height: 2.h,
                                    wordSpacing: 2.5,
                                    fontSize: 12.6.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
