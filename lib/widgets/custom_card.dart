import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final double radius;
  final Color color;

  const CustomCard({
    required this.child,
    this.elevation = 0.5,
    this.radius = 12.0,
    this.color = const Color(0xFFFFFFFF),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xff231942)),
          color: color,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow effect
              offset: Offset(0, 2),
              blurRadius: elevation,
            ),
          ],
        ),
        child: child, // Your child widgets will go here
      ),
    );
  }
}
