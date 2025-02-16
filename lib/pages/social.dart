import 'package:flutter/material.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/profile.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social'),
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
        ],
      ),
    );
  }
}