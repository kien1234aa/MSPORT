import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/model/user.dart';
import 'package:msport/pages/NewsPage.dart';
import 'package:msport/pages/ProfilePage.dart';
import 'package:msport/pages/customer/BookedPage.dart';
import 'package:msport/pages/customer/BookingPage.dart';

class HomePageCustomer extends StatefulWidget {
  final User1? user;
  HomePageCustomer({super.key, required this.user});

  @override
  State<HomePageCustomer> createState() => _HomePageCustomerState();
}

class _HomePageCustomerState extends State<HomePageCustomer> {
  int _selectedBottomIndex = 2;
  AuthService authService = AuthService();
  SportsField? _selectedSportField;
  Key bookedPageKey = UniqueKey();
  Key bookingPageKey = UniqueKey();
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
                  BookingPage(key: bookedPageKey, user: widget.user), // index 1
                  Center(child: Text("Trang chủ")), // index 2
                  BookedPage(key: bookedPageKey), // index 3
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
            _buildBottomNavItem(Icons.newspaper, 0),
            _buildBottomNavItem(Icons.sports_soccer, 1),
            _buildBottomNavItem(Icons.home, 2),
            _buildBottomNavItem(Icons.edit_note, 3),
            _buildBottomNavItem(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, int index) {
    bool isSelected = index == _selectedBottomIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomIndex = index;
          if (index == 3) {
            bookedPageKey = UniqueKey(); // Reset key to force rebuild
          } else if (index == 1) {
            bookingPageKey = UniqueKey(); // Reset key to force rebuild
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4CAF50) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black54,
          size: 24,
        ),
      ),
    );
  }
}
