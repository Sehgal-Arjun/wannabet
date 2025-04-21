import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wannabet/pages/notifications.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/view_profile.dart';
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
  final user;
  const SocialPage({super.key, required this.user});

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  get user => widget.user;

  int _selectedIndex = 3;
  final _searchController = TextEditingController();
  final friendsController = PageController(viewportFraction: 1, keepPage: true, initialPage: 0);
  List<Map<String, String>> searchResults = []; // To hold search results

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

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final results = await FirebaseFirestore.instance
      .collection('users')
      .where('username_lowercase', isGreaterThanOrEqualTo: query.toLowerCase())
      .where('username_lowercase', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
      .get();

  setState(() {
    searchResults = results.docs
      .where((doc) => doc.id != currentUserId) // Do not show the user their own profile in search results
      .map((doc) => {
        'username': doc['username'] as String,
        'profile_picture': doc['profile_picture'] as String,
        'id': doc.id,
      })
      .toList();
  });
}


  @override
  Widget build(BuildContext context) {
    User currentUser = FirebaseAuth.instance.currentUser!;
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return LoadingPage(user:[], selectedIndex: _selectedIndex, title: 'Social');
        }

        var userData = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Social'),
            automaticallyImplyLeading: false,
            actions: [
              Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.inbox_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(user: user),
                      ),
                    );
                  },
                ),
                if (user.friend_requests != null && user.friend_requests.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationsPage(user: user),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${user.friend_requests.length}',
                          style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
                  clearable: true
                ),
              ),

              // Display search results
              if (searchResults.isNotEmpty) 
                Expanded(
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: ProfilePicture(profilePicture: searchResults[index]['profile_picture']!, searched: true,),
                        title: Text(searchResults[index]['username']!),
                        onTap: () {
                          String userUsername = searchResults[index]['username']!;
                          String userUid = searchResults[index]['id']!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewProfile(uid:userUid, user: user),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              
              if (searchResults.isEmpty && _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Lottie.asset(
                        'assets/noSearchResultsAnimation.json',
                        width: MediaQuery.of(context).size.width / 1.25,
                        height: MediaQuery.of(context).size.width / 1.25,
                      ),
                      SizedBox(height: 30),
                      Text(
                        'No users found',
                        style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),

              // Friends section
              if (searchResults.isEmpty && _searchController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Friends",
                    style: GoogleFonts.lato(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
                FutureBuilder(
                  future: Future.wait(
                    List.from(user.friends).map((friendId) async {
                      final doc = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
                      return {
                        'username': doc['username'],
                        'profile_picture': doc['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
                        'id': doc.id,
                      };
                    }),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Lottie.asset(
                              'assets/noFriendsAnimation2.json',
                              height: 175,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No friends found",
                              style: GoogleFonts.lato(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 27, 13, 13),
                              ),
                            )

                          ],
                        ),
                      );
                    }

                    final friends = snapshot.data!;


                    return Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: friendsController,
                            itemCount: friends.length ~/ 8 + (friends.length % 8 == 0 ? 0 : 1),
                            itemBuilder: (_, pageIndex) {
                              final start = pageIndex * 8;
                              final end = (start + 8).clamp(0, friends.length);
                              final pageFriends = friends.sublist(start, end);

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                  ),
                                  itemCount: pageFriends.length,
                                  itemBuilder: (context, index) {
                                    final friend = pageFriends[index];
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ProfilePicture(profilePicture: friend['profile_picture'], user: user, accountId: friend['id'], searched: false),
                                        SizedBox(height: 2),
                                        Flexible(
                                          child: Text(
                                            friend['username'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
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
                          count: friends.length ~/ 8 + (friends.length % 8 == 0 ? 0 : 1),
                          effect: ExpandingDotsEffect(
                            dotWidth: 8,
                            dotHeight: 8,
                            activeDotColor: Color(0xff5e548e),
                            dotColor: const Color.fromARGB(255, 206, 206, 206)
                          ),
                        ),
                      ],
                    );
                  },
                ),

            ],
          ),
          
          bottomNavigationBar: NavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            pages: [
              HomePage(),
              StatsPage(user: user),
              NewBetPage(user: user),
              SocialPage(user: user),
              ProfilePage(user: user),
            ],
          ),
        );
      }
    );
  }
}