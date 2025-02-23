import 'package:flutter/material.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/stats.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final List<Widget> pages;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        
        onItemTapped(index);
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => pages[index],
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      height: 60,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      animationDuration: const Duration(milliseconds: 500),
      indicatorShape: const CircleBorder(),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline, size: 30),
          selectedIcon: Icon(Icons.add_circle, size: 30),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: '',
        ),
      ],
    );
  }
}