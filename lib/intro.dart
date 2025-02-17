import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wannabet/intro/introPage1.dart';
import 'package:wannabet/intro/introPage2.dart';
import 'package:wannabet/intro/introPage3.dart';
import 'package:wannabet/signup/signup.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (value) => setState(() => onLastPage = (value == 2)),
            controller: _controller,
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3()
            ],
          ),
          Align(
            alignment: Alignment(0, 0.7),
            child: SmoothPageIndicator(
              controller: _controller, 
              count: 3,
              effect: ExpandingDotsEffect(
                dotWidth: 10,
                dotHeight: 10,
                activeDotColor: Color(0xff5e548e),
                dotColor: const Color.fromARGB(255, 206, 206, 206)
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                child: Text(
                  onLastPage ? 'Get Started' : 'Next',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                onTap:() => 
                  onLastPage?
                    Navigator.push(context, MaterialPageRoute(builder: (context) { return SignUpPage(); })) : 
                    _controller.nextPage(duration: Duration(milliseconds: 150), curve: Curves.easeIn),
              ),
            ),
          )
        ]
      )
    );
  }
}