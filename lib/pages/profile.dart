import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/pages/friends_list.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/settings.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/widgets/bet_list.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  final ImagePicker _picker = ImagePicker();

  late UserObject user;
  bool userLoading = true;

  @override
  void initState() {
    super.initState();
    initUserWithState(
      state: this,
      onLoadingStart: () => userLoading = true,
      onUserLoaded: (loadedUser) {
        user = loadedUser;
        userLoading = false;
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _editProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      File imageFile = File(pickedFile.path);

      try {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$userId.jpg');
        await storageRef.putFile(imageFile);
        String downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profile_picture': downloadURL,
        });

        // Update the cached user in Hive
        final box = Hive.box<UserObject>('userBox');
        final cachedUser = box.get('user');
        if (cachedUser != null) {
          final updatedUser = cachedUser.copyWith(
            profile_picture: downloadURL,
          );
          box.put('user', updatedUser);
        }

        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $e")),
        );
      }
    }
  }

  Future<List<dynamic>> fetchPinnedBets() async {
    try {
      var fetchedBets = [];

      for (String userBetId in user.pinnedBets) {
        DocumentSnapshot userBetDoc = await FirebaseFirestore.instance.collection('userBets').doc(userBetId).get();
        if (userBetDoc.exists) {
          String betId = userBetDoc["bet"];
          DocumentSnapshot betDoc = await FirebaseFirestore.instance.collection('bets').doc(betId).get();
          if (betDoc.exists) {
            fetchedBets.add(betDoc.data() as Map<String, dynamic>);
          }
        }
      }
      return fetchedBets;
    } catch (e) {
      print("Error fetching pinned bets: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: _selectedIndex, title: 'Profile');
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SettingsPage();
              }));
            },
            color: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      ProfilePicture(
                        profilePicture: user.profile_picture,
                        profile: true,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            color: Colors.white,
                            onPressed: _editProfilePicture,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "@${user.username}",
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${user.first_name} ${user.last_name}",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                  'Friends',
                  user.friends.length.toString(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendsListPage(),
                      ),
                    );
                  }
                ),
                  _buildStatColumn(
                  'Win Rate', 
                  "95%",
                  () {} // onClick here if needed
                  ),
                  _buildStatColumn(
                  'Total Bets',
                  user.total_bets.toString(),
                  () {} // onClick here if needed)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Earnings Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earnings',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            user.total_money_won >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: user.total_money_won >= 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          "${user.total_money_won >= 0 ? '+' : '-'}\$${user.total_money_won.abs().toStringAsFixed(2)}",
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: user.total_money_won >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            BetList(
              listTitle: "Pinned Bets",
              fetchBets: fetchPinnedBets,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Biggest Wins',
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // WE NED TO GET THE ACTUAL TOP BETS FROM THE DATABASE here
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.sports_baseball, color: Colors.white),
                      ),
                      title: const Text("Yankees vs Red Sox"),
                      subtitle: const Text("Baseball • Won \$500"),
                      trailing: const Icon(Icons.emoji_events, color: Colors.amber),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.sports_basketball, color: Colors.white),
                      ),
                      title: const Text("Lakers vs Warriors"),
                      subtitle: const Text("Basketball • Won \$300"),
                    ),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.sports_football, color: Colors.white),
                      ),
                      title: const Text("Chiefs vs Eagles"),
                      subtitle: const Text("Football • Won \$250"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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

  Widget _buildStatColumn(String label, String value, GestureTapCallback onClick) {
     return GestureDetector(
      onTap: onClick,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
 }
 