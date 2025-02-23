import 'package:flutter/material.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/widgets/navbar.dart';

class LoadingPage extends StatefulWidget {
  int selectedIndex;
  final String title;

  LoadingPage({
    super.key,
    required this.selectedIndex,
    required this.title,
    });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  void _onItemTapped(int index) {
      setState(() {
        widget.selectedIndex = index;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: NavBar(
        selectedIndex: widget.selectedIndex,
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