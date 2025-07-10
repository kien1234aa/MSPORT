import 'package:flutter/material.dart';

class ButtonProfile extends StatelessWidget {
  String title;
  Icon icon;
  VoidCallback? onTap;
  ButtonProfile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 323,
        decoration: BoxDecoration(
          color: Colors.white, // màu nền xanh nhạt
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextButton.icon(
          onPressed: () {},
          icon: icon,
          label: Text(title, style: TextStyle(color: Colors.black87)),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
