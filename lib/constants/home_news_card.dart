import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class HomeNewsCard extends StatelessWidget {
  final String imageUrl, title, body, time, commentNumber;

  const HomeNewsCard(
      {Key? key,
      required this.imageUrl,
      required this.title,
      required this.time,
      required this.body,
      required this.commentNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      height: 180,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ]),

      //Inside container
      child: Row(
        children: [
          Container(
            height: 150.h,
            width: 100.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(imageUrl),
              ),
            ),
          ),

          //Right part
          Expanded(
            child: Container(
              padding:  EdgeInsets.only(top: 5.h, bottom: 10.h, left: 14.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 13.4.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),

                  Text(
                    body,
                    style:  TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 12.6.sp,
                    ),
                    softWrap: true,
                  ),

                  //For date
                  SizedBox(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, size: 16.9.sp),
                         SizedBox(width: 8.w),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12.08.sp,
                          ),
                        ),
                       const Spacer(),
                        Text(
                          commentNumber,
                          style: TextStyle(
                            fontSize: 10.08.sp,
                          ),
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
    );
  }
}
