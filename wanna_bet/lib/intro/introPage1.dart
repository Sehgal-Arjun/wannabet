import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15), // Adjust top padding
            Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
            child: Text(
              'Think you can beat me in a race?',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 36,
                // fontWeight: FontWeight.bold,
              )
            ),
            ),
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: Lottie.asset(
                'assets/animation1.json',
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
