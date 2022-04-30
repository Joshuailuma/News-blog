import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ProfileCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color iconColor;
  final Color containerColor;
  final void Function() press;
  const ProfileCard(
      {required this.text,
      required this.icon,
      required this.iconColor,
      required this.containerColor,
      required this.press});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.w, top: 10.h, bottom: 10.h, right: 20.w),
          child: Row(
            children: [
              Container(
                height: 58.h,
                width: 55.w,
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(width: 23.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.6.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).cardColor,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 15.96.sp,
                color:  Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
