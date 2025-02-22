import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wannabet/intro.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;

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

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Profile")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        var userData = snapshot.data!;
        String username = userData['username'] ?? 'unknown';
        String firstName = userData['first_name'] ?? 'User';
        String profilePicture = userData['profile_picture'] ?? "http://www.gravatar.com/avatar/?d=mp";
        double totalMoneyWon = (userData['total_money_won'] ?? 0).toDouble();

        Color moneyColor = totalMoneyWon > 0
            ? Colors.green
            : totalMoneyWon < 0
                ? Colors.red
                : Colors.grey;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Profile", style: TextStyle(color: Colors.black)),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: signOut
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(profilePicture),
                          child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                            color: Color(0xff231942),
                            width: 1.0,
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "@$username",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hi, $firstName!",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${totalMoneyWon >= 0 ? "+\$" : "-\$"}${totalMoneyWon.abs().toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: moneyColor),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ),
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
      },
    );
  }
}
