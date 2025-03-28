import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/bet_list.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/profile_picture.dart';

class ViewProfile extends StatefulWidget {
  final String uid;

  const ViewProfile({super.key, required this.uid});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  Future<DocumentSnapshot?> fetchUserProfile() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (userDoc.exists) {
        return userDoc;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return LoadingPage(user: [], selectedIndex: 0, title: 'Social');
        }

        var user = snapshot.data!;

        Future<List<dynamic>> fetchPinnedBets() async {
          try {
            var fetchedBets = [];

            for (String userBetId in user["pinnedBets"]) {
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
            // print("Error fetching pinned bets: $e");
            return [];
          }
        }

        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header Section
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1, // Dynamic top padding
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ProfilePicture(
                                profilePicture: user["profile_picture"],
                                profile: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "@${user["username"]}",
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${user["first_name"]} ${user["last_name"]}",
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
                          _buildStatColumn('Friends', user["friends"].length.toString()),
                          _buildStatColumn('Win Rate', 
                            "${user["total_bets"] > 0 ? ((user["wonBets"] / user["total_bets"]) * 100).toStringAsFixed(1) : '0'}%"
                          ),
                          _buildStatColumn('Total Bets', user["total_bets"].toString()),
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
                                    user["total_money_won"] >= 0 ? Icons.trending_up : Icons.trending_down,
                                    color: user["total_money_won"] >= 0 ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "${user["total_money_won"] >= 0 ? '+' : '-'}\$${user["total_money_won"].abs().toStringAsFixed(2)}",
                                  style: GoogleFonts.lato(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: user["total_money_won"] >= 0 ? Colors.green : Colors.red,
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
                      child: BetList(
                        listTitle: "Pinned Bets",
                        fetchBets: fetchPinnedBets,
                      ),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1
                    )
                  ],
                ),
              ),
              Positioned(
                left: 16.0,
                top: MediaQuery.of(context).size.height * 0.08, // Align dynamically with content
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
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
