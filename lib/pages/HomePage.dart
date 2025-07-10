import 'package:flutter/material.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/model/user.dart';
import 'package:msport/pages/customer/HomePageCustomer.dart';
import 'package:msport/pages/owner/HomePageOwner.dart';

class HomePage extends StatefulWidget {
  late final User1? user;
  HomePage({super.key, required this.user});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  int _selectedBottomIndex = 2;
  @override
  Widget build(BuildContext context) {
    if (widget.user!.role == 'customer') {
      return HomePageCustomer(user: widget.user);
    } else if (widget.user!.role == 'owner') {
      return HomePageOwner(user: widget.user);
    } else {
      return Scaffold(body: Center(child: Text('Role not recognized')));
    }
  }
}
