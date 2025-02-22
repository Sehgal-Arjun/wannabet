import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wannabet/widgets/custom_text_field.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:wannabet/widgets/profile_picture.dart';

class SocialPage extends StatefulWidget {
  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _selectedIndex = 3;
  final _searchController = TextEditingController();
  final friendsController = PageController(viewportFraction: 1, keepPage: true, initialPage: 0);
  final pageCount = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Social'),
        automaticallyImplyLeading: false,
      ),

      body: Column(
        children: [

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildTextField(
              Icons.search,
              "Search",
              _searchController,
            ),
          ),

          // Friends section
          Container(
            height: 200.0,
            child: PageView.builder(
              controller: friendsController,
              itemCount: pageCount,
              itemBuilder: (_, pageIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return ProfilePicture();
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  ),
                );
              },
            ),
          ),
          SmoothPageIndicator(
            controller: friendsController, 
            count: pageCount,
            effect: ExpandingDotsEffect(
              dotWidth: 10,
              dotHeight: 10,
              activeDotColor: Color(0xff5e548e),
              dotColor: const Color.fromARGB(255, 206, 206, 206)
            ),
          ),
        ],
      ),
      
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        pages: [
          HomePage(),
          SocialPage(),
          NewBetPage(),
          SocialPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}