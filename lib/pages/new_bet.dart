import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/navbar.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/pages/stats.dart';
import 'package:wannabet/pages/social.dart';
import 'package:wannabet/pages/profile.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class NewBetPage extends StatefulWidget {
  // final user;
  const NewBetPage({super.key});

  @override
  State<NewBetPage> createState() => _NewBetPageState();
}

class _NewBetPageState extends State<NewBetPage> {
  List<String> selectedFriendIds = [];
  List<Map<String, dynamic>> friends = [];
  bool userLoading = true;
  bool userHasFriends = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  double currentAmount = 0;
  
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late UserObject user;

  @override
  void initState() {
    super.initState();
    initUserWithState(
      state: this,
      onLoadingStart: () => userLoading = true,
      onUserLoaded: (loadedUser) async {
        user = loadedUser;
        userLoading = false;
        userHasFriends = user.friends.isNotEmpty;

        // Fetch friend info once user is loaded
        friends = await Future.wait(
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

  Future<void> createBet() async {
    try {
      if (selectedFriendIds.isEmpty) {
        throw Exception('Please select at least one friend');
      }

      final betDoc = FirebaseFirestore.instance.collection('bets').doc();
      
      final betData = {
        'bet_name': titleController.text,
        'status': 'pending',
        'id': betDoc.id,
        'side_one_members': [user.uid],
        'side_one_name': "Side one Wins",
        'side_one_value': amountController.text, 
        'side_two_members': selectedFriendIds,
        'side_two_name': "Side two Wins",
        'side_two_value': amountController.text,
        'winning_side': "",
        'created_at': FieldValue.serverTimestamp(),
        'creator': user.uid,
        'creator_username': user.username,
        'description': descriptionController.text,
        'user_statuses': {
          user.uid: 'accepted',
          ...{for (var id in selectedFriendIds) id: 'pending'},
        },
      };

      await betDoc.set(betData);
     
      // add the bet to the user's list of bets as "accepted"
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'bets.${betDoc.id}': 'accepted',
      });

      // Notify each selected friend
      for (String friendId in selectedFriendIds) {
        await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('notifications')
          .add({
            'type': 'bet_invite',
            'bet_id': betDoc.id,
            'from_user_id': user.uid,
            'from_username': user.username,
            'title': titleController.text,
            'amount': double.parse(amountController.text),
            'created_at': FieldValue.serverTimestamp(),
            'read': false,
            'side': 'two',
            'from_full_name': user.full_name,
            'individual_stake': double.parse(amountController.text) / selectedFriendIds.length,
            'from_profile_picture': user.profile_picture,
          });
      }

      // Update the cached user in Hive
      final box = Hive.box<UserObject>('userBox');
      final cachedUser = box.get('user');

      if (cachedUser != null) {
        final updatedBets = Map<String, String>.from(cachedUser.bets)
          ..[betDoc.id] = "accepted";

        final updatedUser = cachedUser.copyWith(
          bets: updatedBets,
        );

        await box.put('user', updatedUser);
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
          useSafeArea: true,
          builder: (BuildContext context) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                child: Lottie.asset(
                  'assets/betSentAnimation.json',
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration, () {
                      _navigateToHome();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bet created successfully!')),
                      );
                    });
                  },
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error creating bet: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create bet: ${e.toString()}')),
      );
    }
  }

  void _showBetDetailsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Create New Bet',
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5e548e),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Betting with:',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: friends
                                    .where((friend) => selectedFriendIds.contains(friend['id']))
                                    .map((friend) => Chip(
                                          avatar: CircleAvatar(
                                            backgroundImage: NetworkImage(friend['profile_picture']),
                                          ),
                                          label: Text(friend['username']),
                                        ))
                                    .toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'What\'s the bet?',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Warriors win tonight',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Description (optional)',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Add more details about the bet...',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Amount',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setModalState(() {
                                // This will trigger a rebuild of the bottom sheet
                              });
                            },
                            decoration: InputDecoration(
                              prefixText: '\$ ',
                              hintText: '0.00',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Betting Structure',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff5e548e).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'If You Win',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xff5e548e),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'You get: \$${amountController.text.isEmpty ? "0.00" : amountController.text}',
                                              style: GoogleFonts.lato(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'If Opponents Win',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'You lose: \$${amountController.text.isEmpty ? "0.00" : amountController.text}',
                                              style: GoogleFonts.lato(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Each opponent will bet \$${amountController.text.isEmpty ? "0.00" : (double.tryParse(amountController.text) ?? 0) / selectedFriendIds.length}',
                                  style: GoogleFonts.lato(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a title')),
                          );
                          return;
                        }
                        if (amountController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter an amount')),
                          );
                          return;
                        }
                        createBet();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5e548e),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Bet',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: _selectedIndex, title: 'Profile');
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'New Bet',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5e548e),
          ),
        ),
        actions: [
          if (selectedFriendIds.isNotEmpty) TextButton(
            onPressed: _showBetDetailsDialog,
            child: Text(
              'Next',
              style: GoogleFonts.lato(
                color: const Color(0xff5e548e),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: userLoading ? const Center(child: CircularProgressIndicator())
      : !userHasFriends ? Center (
        child: Text(
          'No friends yet',
          style: GoogleFonts.lato(fontSize: 16),
        ),
      ) : ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final isSelected = selectedFriendIds.contains(friend['id']);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend['profile_picture']),
            ),
            title: Text(
              friend['username'],
              style: GoogleFonts.lato(),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xff5e548e))
                : const Icon(Icons.circle_outlined),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedFriendIds.remove(friend['id']);
                } else {
                  selectedFriendIds.add(friend['id']);
                }
              });
            },
          );
        },
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