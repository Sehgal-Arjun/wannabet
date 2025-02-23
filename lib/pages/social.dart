import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/widgets/custom_text_field.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:wannabet/widgets/profile_picture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialPage extends StatefulWidget {
  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  int _selectedIndex = 3;
  final _searchController = TextEditingController();
  final friendsController = PageController(viewportFraction: 1, keepPage: true, initialPage: 0);
  final pageCount = 2;
  List<String> searchResults = []; // To hold search results

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to search for usernames
  Future<void> searchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final results = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff') // To match the query
        .get();

    setState(() {
      searchResults = results.docs.map((doc) => doc['username'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return LoadingPage(selectedIndex: _selectedIndex, title: 'Social');
        }

        var userData = snapshot.data!;

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
                  onChanged: (value) {
                    searchUsernames(value); // Call search method on text change
                  },
                ),
              ),

              // Display search results
              if (searchResults.isNotEmpty) 
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('@${searchResults[index]}'),
                        onTap: () {
                          // Handle tap on username (e.g., navigate to profile)
                        },
                      );
                    },
                  ),
                ),

              // Friends section
              Column(
                children: [
                  Container(
                    height: 200,
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
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ProfilePicture(),
                                  SizedBox(height: 2),
                                  Flexible(
                                    child: Text(
                                      'username${index + 1}', // Example username
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis, // Prevent overflow
                                      maxLines: 1, // Limit to one line
                                    ),
                                  ),
                                ],
                              );
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
                ]
              ),
            ],
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
    );
  }
}