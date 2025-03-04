import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/intro.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void signOut() async{
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IntroPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out: ${e.toString()}")),
      );
    }
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

        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $e")),
        );
      }
    }
  }

  void _navigateToSettings() {
   
  }

  void _navigateToPrivacy() {
   
  }

  void _navigateToHelp() {
   
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return LoadingPage(selectedIndex: _selectedIndex, title: 'Profile');
        }

        var userData = snapshot.data!;
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        
        String username = data['username'] ?? 'unknown';
        String firstName = data['first_name'] ?? 'User';
        String lastName = data['last_name'] ?? '';
        String email = data['email'] ?? user.email ?? '';
        String profilePicture = data['profile_picture'] ?? "http://www.gravatar.com/avatar/?d=mp";
        double totalMoneyWon = (data['total_money_won'] ?? 0).toDouble();
        int totalBets = data['total_bets'] ?? 0;
        int wonBets = data['won_bets'] ?? 0;
        List<dynamic> friends = data['friends'] ?? [];

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Profile", style: TextStyle(color: Colors.black)),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: signOut,
                color: Colors.black,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
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
                              profilePicture: profilePicture,
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
                          "@$username",
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$firstName $lastName",
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
                        _buildStatColumn('Friends', friends.length.toString()),
                        _buildStatColumn('Win Rate', 
                          "${totalBets > 0 ? ((wonBets / totalBets) * 100).toStringAsFixed(1) : '0'}%"
                        ),
                        _buildStatColumn('Total Bets', totalBets.toString()),
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
                                  totalMoneyWon >= 0 ? Icons.trending_up : Icons.trending_down,
                                  color: totalMoneyWon >= 0 ? Colors.green : Colors.red,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                "${totalMoneyWon >= 0 ? '+' : '-'}\$${totalMoneyWon.abs().toStringAsFixed(2)}",
                                style: GoogleFonts.lato(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: totalMoneyWon >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  
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

                  // Settings & Help Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text("Settings"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                             
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text("Privacy"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              
                            },
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.help_outline),
                            title: const Text("Help & Support"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                             
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            pages: [
              HomePage(),
              NewBetPage(),
              SocialPage(),
              ProfilePage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
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
    );
  }
}
