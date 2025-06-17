import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String title;
  final double w;
  final TextEditingController controller;
  MyTextField({super.key,required this.title,required this.w,required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
  decoration: InputDecoration(
    hintText: title,
    filled: true,
    fillColor: Colors.grey[200], // Light grey background
    contentPadding: EdgeInsets.symmetric(vertical: w, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none, // No border
    ),
  ),
  controller: controller,
);

  }
}