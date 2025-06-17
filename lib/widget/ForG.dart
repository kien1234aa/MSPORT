import 'package:flutter/material.dart';

class ForG extends StatelessWidget {
  final String img;
  ForG({super.key,required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 101,
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(0xFFE8F5E9)
      ),
      child: Center(
        child: Image.asset(img,height: 20,width: 20,),
      ),
    );
  }
}