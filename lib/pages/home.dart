import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/pages/bet_invites.dart';
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
  List<Map<String, dynamic>> acceptedBetsDetails = [];

  @override
  void initState() {
    super.initState();
    fetchAcceptedBets();
  }

  Future<void> fetchAcceptedBets() async {

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      final betsMap = data['bets'] as Map<String, dynamic>?;
      print('Bets map: $betsMap');
    
     
      
    
     

      if (betsMap != null) {
        for (var entry in betsMap.entries) {
          String betId = entry.key;
          String status = entry.value;
          print('Bet ID: $betId, Status: $status');
    
        

          if (status == 'accepted') {
            DocumentSnapshot betDoc = await FirebaseFirestore.instance.collection('bets').doc(betId).get();
            if (betDoc.exists) {
              Map<String, dynamic> betData = betDoc.data() as Map<String, dynamic>;

              List<String> sideOneNames = await fetchMemberNames(betData['side_one_members']);
              List<String> sideTwoNames = await fetchMemberNames(betData['side_two_members']);

              acceptedBetsDetails.add({
                'bet_name': betData['bet_name'],
                'description': betData['description'],
                'amount': betData['side_one_value'],
                'side_one_members': sideOneNames,
                'side_two_members': sideTwoNames,
                'status': betData['status'],
              });
            }
          }
        }
      }

      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  void printUserBets(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      var bets = data['bets'];

      print('Bets for user $userId: $bets');
    } else {
      print('User with uid $userId does not exist.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return LoadingPage(user: [], selectedIndex: _selectedIndex, title: 'WannaBet');
        }

        var userData = snapshot.data!;
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;

        final user = _buildUserFromData(data);
        final betInvites = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('type', isEqualTo: 'bet_invite')
          .get()
          .then((querySnapshot) {
            return querySnapshot.docs.map((doc) {
              final data = doc.data();
              return {
                ...data,
                'notification_id': doc.id,
              };
            }).toList();
          });

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
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.inbox_outlined),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
                            future: betInvites,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return LoadingPage(user: [], selectedIndex: 0, title: 'Loading...');
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return const Center(child: Text('Error loading invites'));
                              }
                              return BetInvitesPage(betInvites: snapshot.data!, user: user);
                            },
                          ),
                        ),
                      );
                      
                      if (result == true) {
                        setState(() {
                          acceptedBetsDetails.clear();
                        });
                        await fetchAcceptedBets();
                      }
                    },
                  ),
                  if (betInvites != null)
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: betInvites,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
                                      future: betInvites,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return LoadingPage(user: [], selectedIndex: 0, title: 'Loading...');
                                        }
                                        if (snapshot.hasError || !snapshot.hasData) {
                                          return const Center(child: Text('Error loading invites'));
                                        }
                                        return BetInvitesPage(betInvites: snapshot.data!, user: user);
                                      },
                                    ),
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
                                  '${snapshot.data!.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ],
          ),
          body: acceptedBetsDetails.isEmpty
              ? Center(child: Text('No accepted bets found'))
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: acceptedBetsDetails.length,
                  itemBuilder: (context, index) {
                    final bet = acceptedBetsDetails[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xff5e548e),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      bet['bet_name'] ?? 'Unnamed Bet',
                                      style: GoogleFonts.lato(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff5e548e),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (bet['status'] == 'in_progress' || bet['status'] == 'accepted')
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (bet['status'] == 'in_progress' || bet['status'] == 'accepted')
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          bet['status'] == 'in_progress'
                                              ? 'ACTIVE'
                                              : bet['status'] == 'accepted'
                                                  ? 'ACCEPTED'
                                                  : bet['status']?.toUpperCase() ?? '',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (bet['status'] == 'in_progress' || bet['status'] == 'accepted')
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.0),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                margin: EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xff5e548e),
                                      const Color(0xff5e548e).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff5e548e).withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '\$${bet['amount'] ?? 0}',
                                    style: GoogleFonts.lato(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                bet['description'] ?? 'No description',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xff5e548e).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Text(
                                            'TEAM 1',
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xff5e548e),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            bet['side_one_members'].join('\n'),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff5e548e),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'VS',
                                              style: GoogleFonts.lato(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Text(
                                            'TEAM 2',
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xff5e548e),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            bet['side_two_members'].join('\n'),
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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

  Future<List<String>> fetchMemberNames(List<dynamic> memberUids) async {
    List<String> memberNames = [];
    for (String uid in memberUids) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        memberNames.add(userData['full_name'] ?? 'Unknown User');
      }
    }
    return memberNames;
  }
}