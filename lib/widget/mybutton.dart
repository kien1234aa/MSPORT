import 'package:flutter/material.dart';
import 'package:msport/untils/colors.dart';

class MyButton extends StatelessWidget {
  final double? w;
  final double? h;
  final String? content;
  final VoidCallback? onTap;
  MyButton({super.key,required this.h,required this.w,required this.content,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:AppColors.buttonColor,
        ),
        child: Center(
          child: Text(content!,style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
}