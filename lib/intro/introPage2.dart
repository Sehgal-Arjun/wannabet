import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Adjust top padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
            child: Text(
              'Obviously.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 36,
                // fontWeight: FontWeight.bold,
              )
            ),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.center, // Ensures the animation is centered
              child: Lottie.asset(
                'assets/animation2.json',
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.width / 1.25,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.20), // Bottom spacing for balance
        ],
      ),
    );
  }
}
