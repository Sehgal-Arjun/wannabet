import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/bet_list.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:wannabet/widgets/profile_picture.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class ViewProfile extends StatefulWidget {
  final String uid;
  const ViewProfile({super.key, required this.uid});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {

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
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: 3, title: 'Profile', showNavBar: false);
    }
    return FutureBuilder<DocumentSnapshot?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return LoadingPage(selectedIndex: 0, title: 'Social');
        }

        var account = snapshot.data!;

        bool alreadyFriends = account["friends"].contains(user.uid);
        bool friendRequestSent = false;
        for (var request in account["friend_requests"]) {
          if (request["uid"] == user.uid) {
            friendRequestSent = true;
            break;
          }
        }

        bool friendRequestReceived = false;
        for (var request in user.friend_requests) {
          if (request["uid"] == account["id"]) {
            friendRequestSent = true;
            break;
          }
        }

        Future<List<dynamic>> fetchPinnedBets() async {
          try {
            var fetchedBets = [];

            for (String userBetId in account["pinnedBets"]) {
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

        Future sendFriendRequest() async {
          try {
            var currentUser = user;
            var friendId = account.id;

            // Check if the user is already friends with the account
            if (currentUser.friends.contains(friendId)) {
              return;
            }

            // Check if the user has already received a friend request
            if (currentUser.friend_requests.any((request) => request["uid"] == friendId)) {
              return;
            }
            // Check if the account has already received a friend request from the current user
            for (var request in account["friend_requests"]) {
              if (request["uid"] == currentUser.uid) {
                return;
              }
            }

            // Add the friend request to the account's friend_requests
            await FirebaseFirestore.instance.collection('users').doc(friendId).update({
              "friend_requests": FieldValue.arrayUnion([
                {
                  "uid": currentUser.uid,
                  "profile_picture": currentUser.profile_picture,
                  "full_name": currentUser.full_name,
                  "username": currentUser.username,
                }
              ]),
            });

            // Add the account to the current user's sent_friend_requests
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
              "sent_friend_requests": FieldValue.arrayUnion([
                {
                  "uid": friendId,
                  "profile_picture": account["profile_picture"],
                  "full_name": account["full_name"],
                  "username": account["username"],
                }
              ]),
            });

            // Update the cached user in Hive
            final box = Hive.box<UserObject>('userBox');
            final cachedUser = box.get('user');

            if (cachedUser != null) {
              final updatedSentRequests = List<Map<String, dynamic>>.from(cachedUser.sent_friend_requests)
                ..add({
                  "uid": friendId,
                  "profile_picture": account["profile_picture"],
                  "full_name": account["full_name"],
                  "username": account["username"],
                });

              final updatedUser = cachedUser.copyWith(
                sent_friend_requests: updatedSentRequests,
              );

              await box.put('user', updatedUser);
            }

            // play sent friend request animation
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
                      'assets/friendRequestSentAnimation.json',
                      repeat: false,
                      onLoaded: (composition) {
                        Future.delayed(composition.duration, () {
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ),
                );
              },
            );

            setState(() {});
          } catch (e) {
            print("Error sending friend request: $e");
          }
        }

        Future removeFriend() async {
          print("hi");
        }

        return Scaffold(
            appBar: AppBar(
            actions: [
              if (!friendRequestReceived) ...[
                if (!alreadyFriends && !friendRequestSent) Padding( // not friends and no request sent
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.black),
                    onPressed: sendFriendRequest,
                  ),
                ),
                if (!alreadyFriends && friendRequestSent) Padding( // pending request
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.watch_later_outlined, color: Colors.black),
                    onPressed: null,
                  ),
                ),
                if (alreadyFriends) Padding( // already friends
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.add_task_outlined, color: Colors.black),
                    onPressed: removeFriend,
                  ),
                ),
              ],
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header Section
                    Column(
                      children: [
                        Stack(
                          children: [
                            ProfilePicture(
                              profilePicture: account["profile_picture"],
                              profile: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "@${account["username"]}",
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${account["first_name"]} ${account["last_name"]}",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Friends', account["friends"].length.toString()),
                          _buildStatColumn('Win Rate', 
                            "${account["total_bets"] > 0 ? ((account["wonBets"] / account["total_bets"]) * 100).toStringAsFixed(1) : '0'}%"
                          ),
                          _buildStatColumn('Total Bets', account["total_bets"].toString()),
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
                                    account["total_money_won"] >= 0 ? Icons.trending_up : Icons.trending_down,
                                    color: account["total_money_won"] >= 0 ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "${account["total_money_won"] >= 0 ? '+' : '-'}\$${account["total_money_won"].abs().toStringAsFixed(2)}",
                                  style: GoogleFonts.lato(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: account["total_money_won"] >= 0 ? Colors.green : Colors.red,
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
