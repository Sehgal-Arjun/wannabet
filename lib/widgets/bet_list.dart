import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                          CircleAvatar(
                            backgroundImage: NetworkImage("https://www.shutterstock.com/image-vector/man-character-face-avatar-glasses-600nw-542759665.jpg"),
                            radius: 20,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width * 0.18),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundImage: NetworkImage("https://static.vecteezy.com/system/resources/previews/020/389/525/non_2x/hand-drawing-cartoon-girl-cute-girl-drawing-for-profile-picture-vector.jpg"),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "\$${bet['side_two_value']}",
                            style: GoogleFonts.lato(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.18),
                        ],
                      ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
            );
          },
        ),
      ],
    );
  }
}
