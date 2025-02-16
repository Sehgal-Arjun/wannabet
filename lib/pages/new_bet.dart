import 'package:flutter/material.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/profile.dart';

class NewBetPage extends StatefulWidget {
  @override
  _NewBetPageState createState() => _NewBetPageState();
}

class _NewBetPageState extends State<NewBetPage> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Bet'),
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