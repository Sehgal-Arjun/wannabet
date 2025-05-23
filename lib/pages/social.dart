import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wannabet/pages/notifications.dart';
import 'package:wannabet/pages/sent_friend_requests.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/view_profile.dart';
import 'package:wannabet/widgets/custom_text_field.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:wannabet/widgets/profile_picture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final box = Hive.box<UserObject>('userBox');

  late UserObject user;
  bool userLoading = true;

  List<Map<String, String>> friendInfoList = [];
  bool weHaveFriendIds = false;
  int numberOfFriends = 0;
  int numberOfSentFriendRequests = 0;

  @override
  void initState() {
    super.initState();
    initUserWithState(
      state: this,
      onLoadingStart: () => userLoading = true,
      onUserLoaded: (loadedUser) async {
        user = loadedUser;
        userLoading = false;
        weHaveFriendIds = user.friends.isNotEmpty;
        numberOfFriends = user.friends.length;
        numberOfSentFriendRequests = user.sent_friend_requests.length;

        // Fetch friend info once user is loaded
        friendInfoList = await Future.wait(
          user.friends.map((id) async {
            final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
            return {
              'username': doc['username'],
              'profile_picture': doc['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
              'id': doc.id,
            };
          }),
        );

        setState(() {});
      },
    );
  }


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
        .where('username_lowercase', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
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

  Future<List<Map<String, String>>> fetchFriendInfo(List<String> friendIds) async {
    return await Future.wait(friendIds.map((id) async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      return {
        'username': doc['username'],
        'profile_picture': doc['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
        'id': doc.id,
      };
    }));
  }


  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: _selectedIndex, title: 'Profile');
    }
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
                    builder: (context) => NotificationsPage(),
                  ),
                );
              },
            ),
            if (user.friend_requests.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsPage(),
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
                      String userUid = searchResults[index]['id']!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewProfile(uid:userUid),
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
                    repeat: false,
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
          if (searchResults.isEmpty && _searchController.text.isEmpty) ...[
            if (!weHaveFriendIds) ...[
              Column(
                children: [
                    if (numberOfSentFriendRequests != 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewSentFriendRequests(),
                                ),
                              );
                            },
                            child: Text(
                              "Sent Requests",
                              style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        Lottie.asset(
                          'assets/noFriendsAnimation2.json',
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: MediaQuery.of(context).size.width / 1.5,
                          repeat: false,
                        ),
                        SizedBox(height: 30),
                        Text(
                          'No friends found.\nSearch for them to get started!',
                          style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Friends",
                      style: GoogleFonts.lato(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (numberOfSentFriendRequests != 0)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewSentFriendRequests(),
                            ),
                          );
                        },
                        child: Text(
                          "Sent Requests",
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: friendsController,
                  itemCount: (friendInfoList.length / 8).ceil(),
                  itemBuilder: (_, pageIndex) {
                    final start = pageIndex * 8;
                    final end = (start + 8).clamp(0, friendInfoList.length);
                    final pageFriends = friendInfoList.sublist(start, end);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              ProfilePicture(
                                profilePicture: friend['profile_picture']!,
                                accountId: friend['id']!,
                                searched: false,
                              ),
                              SizedBox(height: 2),
                              Flexible(
                                child: Text(
                                  friend['username']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        },
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: friendsController,
                count: (numberOfFriends / 8).ceil(),
                effect: ExpandingDotsEffect(
                  dotWidth: 8,
                  dotHeight: 8,
                  activeDotColor: const Color(0xff5e548e),
                  dotColor: const Color.fromARGB(255, 206, 206, 206),
                ),
              ),
            ]
          ]
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
}