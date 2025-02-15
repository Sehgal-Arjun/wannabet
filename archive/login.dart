import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final double chipSize = 175;
  final double chipSpeed = 5;
  bool isCombining = false;
  bool isCovered = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  final Random _random = Random();
  bool isCircleMoved = false;

  double pokerChip1Left = Random().nextDouble() * 300;
  double pokerChip1Top = Random().nextDouble() * 600;
  double pokerChip2Left = Random().nextDouble() * 300;
  double pokerChip2Top = Random().nextDouble() * 600;
  late double pokerChip1VelocityX;
  late double pokerChip1VelocityY;
  late double pokerChip2VelocityX;
  late double pokerChip2VelocityY;

  void _startBouncingAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (!isCombining && !isCircleMoved) 
      {  // Check if the circle hasn't moved
        setState(() {
          pokerChip1Left += pokerChip1VelocityX;
          pokerChip1Top += pokerChip1VelocityY;
          pokerChip2Left += pokerChip2VelocityX;
          pokerChip2Top += pokerChip2VelocityY;

          if (pokerChip1Left < 0 || pokerChip1Left > MediaQuery.of(context).size.width - chipSize) {
            pokerChip1VelocityX = -pokerChip1VelocityX;
          }
          if (pokerChip1Top < 0 || pokerChip1Top > MediaQuery.of(context).size.height - chipSize) {
            pokerChip1VelocityY = -pokerChip1VelocityY;
          }
          if (pokerChip2Left < 0 || pokerChip2Left > MediaQuery.of(context).size.width - chipSize) {
            pokerChip2VelocityX = -pokerChip2VelocityX;
          }
          if (pokerChip2Top < 0 || pokerChip2Top > MediaQuery.of(context).size.height - chipSize) {
            pokerChip2VelocityY = -pokerChip2VelocityY;
          }
        });
      }
    });
  }


  @override
  void initState() {
    super.initState();
    pokerChip1VelocityX = (_random.nextBool() ? 1 : -1) * (2 + _random.nextDouble() * chipSpeed);
    pokerChip1VelocityY = (_random.nextBool() ? 1 : -1) * (2 + _random.nextDouble() * chipSpeed);
    pokerChip2VelocityX = (_random.nextBool() ? 1 : -1) * (2 + _random.nextDouble() * chipSpeed);
    pokerChip2VelocityY = (_random.nextBool() ? 1 : -1) * (2 + _random.nextDouble() * chipSpeed);
    _startBouncingAnimation();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _combineChips() {
  setState(() {
    isCombining = true;
  });

  _controller.forward().then((_) {
    // Delay before showing the circle and removing the chips
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        isCovered = true;
      });

      // Start the transition of the circle to the left after the chips are covered
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          pokerChip1Left = -25; // Move circle to left of the screen
        });

        // Wait for the circle to finish moving, then wait 1 more second before showing input
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            isCircleMoved = true; // Now show the text input
          });
        });
      });
    });
  });

  setState(() {
    pokerChip1Left = MediaQuery.of(context).size.width / 2 - chipSize / 2;
    pokerChip1Top = MediaQuery.of(context).size.height / 2 - chipSize / 2;
    pokerChip2Left = pokerChip1Left;
    pokerChip2Top = pokerChip1Top;
  });
}



  Widget _buildPokerChip(double left, double top, String imageAsset) {
    return AnimatedPositioned(
      duration: isCombining ? Duration(seconds: 1) : Duration(milliseconds: 30),
      curve: Curves.easeInOut,
      left: left,
      top: top,
      child: isCovered
        ? SizedBox.shrink()
        : SizedBox(
            width: chipSize,
            height: chipSize,
            child: ScaleTransition(
              scale: isCombining ? _animation : AlwaysStoppedAnimation(1),
              child: Image.asset(imageAsset, width: chipSize, height: chipSize, fit: BoxFit.contain),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0E9E2),
      body: SafeArea(
        child: Stack(
          children: [
            _buildPokerChip(pokerChip1Left, pokerChip1Top, 'assets/pokerChip1.png'),
            _buildPokerChip(pokerChip2Left, pokerChip2Top, 'assets/pokerChip2.png'),

            // Fading Circle Effect
            if (isCovered)
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: pokerChip1Left + chipSize * 0.5 - (chipSize * 0.1) / 2, // Centering the circle
                top: pokerChip1Top + chipSize * 0.5 - (chipSize * 0.1) / 2, // Centering the circle
                child: Container(
                  width: chipSize * 0.1,
                  height: chipSize * 0.1,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(94, 115, 137, 1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
            // Add TextField next to the circle
            if (isCovered && isCircleMoved)
              Positioned(
                left: pokerChip1Left + chipSize * 0.5 + 10, // Adjust position to the right of the circle
                top: pokerChip1Top + chipSize * 0.5 - 20, // Center vertically with the circle
                child: Container(
                  width: 150, // Set a width for the TextField
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

            Center(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Text("WannaBet?", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 610),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color(0xFF62637D),
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: _combineChips,
                    child: Text('Get Started', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
