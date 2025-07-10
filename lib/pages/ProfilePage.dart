import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/widget/Buttonprofile.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    Future<void> settings() async {
      // Navigate to the settings page
    }
    Future<void> edit() async {
      // Navigate to the edit profile page
    }
    Future<void> logout() async {
      await authService.logout();
      context.go("/login");
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonProfile(
            onTap: edit,
            icon: Icon(Icons.edit),
            title: "Chỉnh sửa thông tin cá nhân",
          ),
          SizedBox(height: 70),
          ButtonProfile(
            onTap: settings,
            icon: Icon(Icons.settings),
            title: "Cài đặt",
          ),
        ],
      ),
    );
  }
}
