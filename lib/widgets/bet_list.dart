import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/profile_group.dart';

class BetList extends StatefulWidget {
  final String listTitle;
  final Future<List<dynamic>> Function() fetchBets; // Function to fetch bets

  BetList({super.key, required this.listTitle, required this.fetchBets});

  @override
  State<BetList> createState() => _BetListState();
}

class _BetListState extends State<BetList> {
  List<dynamic> betsList = [];
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _loadBets(); // Load bets when the widget initializes
  }

  Future<void> _loadBets() async {
    try {
      betsList = await widget.fetchBets(); // Fetch bets using the provided function
    } catch (e) {
      print("Error fetching bets: $e");
    } finally {
      setState(() {
        _isLoading = false; // Update loading state
      });
    }
  }

  Future<Object> fetchProfilePictures(bet) async{
    try {
      List<String> sideOneProfilePictures = [];
      List<String> sideTwoProfilePictures = [];
      for (var sideOneMember in bet['side_one_members']) {
        DocumentSnapshot sideOneUserBet = await FirebaseFirestore.instance.collection('userBets').doc(sideOneMember).get();
        DocumentSnapshot sideOneUser = await FirebaseFirestore.instance.collection('users').doc(sideOneUserBet['user']).get();
        sideOneProfilePictures.add(sideOneUser['profile_picture']);
      }
      for (var sideTwoMember in bet['side_two_members']) {
        DocumentSnapshot sideTwoUserBet = await FirebaseFirestore.instance.collection('userBets').doc(sideTwoMember).get();
        DocumentSnapshot sideTwoUser = await FirebaseFirestore.instance.collection('users').doc(sideTwoUserBet['user']).get();
        sideTwoProfilePictures.add(sideTwoUser['profile_picture']);
      }

       return {
        'sideOneProfilePictures': sideOneProfilePictures,
        'sideTwoProfilePictures': sideTwoProfilePictures,
      };
    } catch (e) {
      print("Error fetching pinned bets: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator()); // Show loading indicator
    }

    if (betsList.isEmpty) {
      return Column(
        children: [
          // Bet title
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 3.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.listTitle,
                style: GoogleFonts.lato(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
          ),
          Center(
            child: Text(
              'No bets available',
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 6.0),
            child: const Divider()
          )
        ]
      );
    }

    return Column(
      children: [
        // Bet title
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 3.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.listTitle,
              style: GoogleFonts.lato(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: betsList.length,
          itemBuilder: (context, index) {
            final bet = betsList[index];
            // Fetch profile pictures synchronously or handle loading state
            return FutureBuilder(
              future: fetchProfilePictures(bet),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}"); // Handle error
                } else {
                  final profilePictures = snapshot.data; // Get profile pictures
                  return Container(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                bet['bet_name'],
                                style: GoogleFonts.lato(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                                Text(
                                  "\$${bet['side_one_value']}",
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ProfileGroup(imageUrls: (profilePictures as Map<String, dynamic>)['sideOneProfilePictures']?.isNotEmpty ? (profilePictures)['sideOneProfilePictures'] : ["http://www.gravatar.com/avatar/?d=mp"]),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                                Text(
                                  "\$${bet['side_two_value']}",
                                  style: GoogleFonts.lato(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ProfileGroup(imageUrls: (profilePictures as Map<String, dynamic>)['sideTwoProfilePictures']?.isNotEmpty ? (profilePictures)['sideTwoProfilePictures'] : ["http://www.gravatar.com/avatar/?d=mp"]),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}
