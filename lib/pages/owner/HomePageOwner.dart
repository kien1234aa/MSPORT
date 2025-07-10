import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/model/user.dart';
import 'package:msport/pages/NewsPage.dart';
import 'package:msport/pages/ProfilePage.dart';

import 'package:msport/pages/owner/FieldBooked.dart';
import 'package:msport/pages/owner/YourField.dart';

class HomePageOwner extends StatefulWidget {
  final User1? user;
  const HomePageOwner({super.key, required this.user});

  @override
  State<HomePageOwner> createState() => _HomePageOwnerState();
}

class _HomePageOwnerState extends State<HomePageOwner> {
  int _selectedBottomIndex = 2;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.user?.name ?? 'User',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await authService.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.logout, color: Colors.black, size: 30),
                  ),
                ),
              ],
            ),

            // Body (middle content)
            Expanded(
              child: IndexedStack(
                index: _selectedBottomIndex,
                children: [
                  NewsPage(), // index 0
                  YourFieldsPage(), // index 1
                  Center(child: Text("Trang chủ")), // index 2
                  FieldBooked(), // index 3
                  ProfilePage(), //index 4
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem("assets/icons/news.png", 0),
            _buildBottomNavItem("assets/icons/football-field.png", 1),
            _buildBottomNavItem("assets/icons/home.png", 2),
            _buildBottomNavItem("assets/icons/checklist.png", 3),
            _buildBottomNavItem("assets/icons/user.png", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String imgIcon, int index) {
    bool isSelected = index == _selectedBottomIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4CAF50) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          imgIcon,
          color: isSelected ? Colors.white : Colors.black54,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}
