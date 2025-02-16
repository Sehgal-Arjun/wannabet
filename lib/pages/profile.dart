import 'package:flutter/material.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: Text('Selected Index: $_selectedIndex')
      ),
      
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        pages: [
          HomePage(),
          StatsPage(),
          NewBetPage(),
          SocialPage(),
          ProfilePage(),
        ], // Pass the list of pages
      ),
    );
  }
}