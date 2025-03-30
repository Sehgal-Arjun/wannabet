import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/new_bet.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class UserObject {
  final String uid;
  final String? email;
  final String? profile_picture;
  final String? first_name;
  final String? last_name;
  final String? full_name;
  final String? username;
  final List<String> friends;
  final List<String> pinnedBets;
  final double total_money_won;
  final int total_bets;
  final String? username_lowercase;
  final List<Map<String, dynamic>> friend_requests;

  UserObject({
    required this.uid,
    this.email,
    this.profile_picture,
    this.first_name,
    this.last_name,
    this.full_name,
    this.username,
    this.friends = const [],
    this.pinnedBets = const [],
    this.total_money_won = 0.0,
    this.total_bets = 0,
    this.username_lowercase,
    this.friend_requests = const [],
  });
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildStatCard(String title, String value, {Color? valueColor}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xff5e548e),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff5e548e).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xff5e548e),
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBetCard(Map<String, dynamic> bet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff5e548e).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_esports,
              color: Color(0xff5e548e),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bet['title'] ?? 'Untitled Bet',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'vs ${bet['opponent']}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${bet['amount']}',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5e548e),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xff5e548e).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bet['status'] ?? 'Active',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: const Color(0xff5e548e),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  UserObject _buildUserFromData(Map<String, dynamic> userData) {
    return UserObject(
      uid: user.uid,
      email: userData['email'],
      profile_picture: userData['profile_picture'],
      first_name: userData['first_name'],
      last_name: userData['last_name'],
      full_name: userData['full_name'],
      username: userData['username'],
      friends: List<String>.from(userData['friends'] ?? []),
      pinnedBets: List<String>.from(userData['pinned_bets'] ?? []),
      total_money_won: userData['totalMoneyWon']?.toDouble() ?? 0.0,
      total_bets: userData['totalBets'] ?? 0,
      username_lowercase: userData['username_lowercase'],
      friend_requests: List<Map<String, dynamic>>.from(userData['friend_requests'] ?? []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return LoadingPage(user: [], selectedIndex: _selectedIndex, title: 'Home');
        }

        var userData = snapshot.data!;
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;

        final user = _buildUserFromData(data);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'WannaBet',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5e548e),
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Summary
                    Row(
                      children: [
                        _buildStatCard('Active Bets', '5'),
                        const SizedBox(width: 12),
                        _buildStatCard('Balance', '\$420', valueColor: Colors.green),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          Icons.add_circle_outline,
                          'New Bet',
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NewBetPage(user: user)),
                          ),
                        ),
                        _buildQuickAction(
                          Icons.people_outline,
                          'Challenge',
                          () {
                            // Navigate to challenge friend
                          },
                        ),
                        _buildQuickAction(
                          Icons.history,
                          'History',
                          () {
                            // Navigate to history
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Active Bets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Bets',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all bets
                          },
                          child: Text(
                            'See All',
                            style: GoogleFonts.lato(
                              color: const Color(0xff5e548e),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Example active bets - replace with StreamBuilder for real data
                    _buildActiveBetCard({
                      'title': 'Basketball Game',
                      'opponent': 'John Doe',
                      'amount': '50',
                      'status': 'Active',
                    }),
                    _buildActiveBetCard({
                      'title': 'Running Race',
                      'opponent': 'Jane Smith',
                      'amount': '100',
                      'status': 'Pending',
                    }),
                  ],
                ),
              ),
            ),
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