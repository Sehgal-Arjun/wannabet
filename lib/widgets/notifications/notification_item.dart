import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/pages/view_profile.dart';

class NotificationItem extends StatefulWidget {
  final String action;
  final String profilePicture;
  final String commentText;
  final String username;
  final String fullName;
  final String friendId;
  final String betTitle;
  final String betId;
  final String betAmount;
  final String betDescription;
  final String notificationId;
  var user;
  NotificationItem({super.key, required this.action, required this.profilePicture, this.commentText = "", required this.username, required this.fullName, required this.friendId, required this.user, this.betId="", this.betTitle="", this.betAmount="", this.betDescription="No description given.", required this.notificationId});
  

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {

  Future acceptFriendRequest(friendId) async {
    try {
      // Add friend to current user's friend list
      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
          'friends': FieldValue.arrayUnion([friendId])
        });

      // Add current user to friend's friend list
      await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .update({
          'friends': FieldValue.arrayUnion([widget.user.uid])
        });

      // Remove current user from friend's sent friend requests
      var sentFriendRequests = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .get()
        .then((doc) => List<Map<String, dynamic>>.from(doc.data()?['sent_friend_requests'] ?? []));

      var updatedSentFriendRequests = sentFriendRequests.where((request) => request['uid'] != widget.user.uid).toList();

      await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .update({
          'sent_friend_requests': updatedSentFriendRequests
        });

      // Remove friend request from current user's friend requests
      removeFriendRequest(friendId, false);
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  Future removeFriendRequest(friendId, declined) async {
    try {
      // Remove friend request from current user's friend requests
      var friendRequests = widget.user.friend_requests ?? [];
      var updatedFriendRequests = friendRequests.where((request) => request['uid'] != friendId).toList();

      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
          'friend_requests': updatedFriendRequests
        });

    } catch (e) {
      print("Error removing friend request: $e");
    }
  }

  Future cancelFriendRequest(friendId, declined) async {
    try {
      // Remove friend request from current user's sent friend requests
      var sentFriendRequests = widget.user.sent_friend_requests ?? [];
      var updatedSentFriendRequests = sentFriendRequests.where((request) => request['uid'] != friendId).toList();

      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
          'sent_friend_requests': updatedSentFriendRequests
        });
      
      // Remove friend request from friend's friend requests
      var friendRequests = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .get()
        .then((doc) => List<Map<String, dynamic>>.from(doc.data()?['friend_requests'] ?? []));
      var updatedFriendRequests = friendRequests.where((request) => request['uid'] != widget.user.uid).toList();

      await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .update({
          'friend_requests': updatedFriendRequests
        });

    } catch (e) {
      print("Error canceling friend request: $e");
    }
  }

  void checkAndUpdateBetStatus() async {

    // check if all users in user_statuses have responded to the bet
    var bet = await FirebaseFirestore.instance
      .collection('bets')
      .doc(widget.betId)
      .get();

    var userStatuses = bet.data()?['user_statuses'] ?? {};
    var sideTwoMembers = bet.data()?['side_two_members'] ?? [];

    var allResponded = true;  
    for (var userId in userStatuses.keys) {
      if (userStatuses[userId] == 'pending') {
        allResponded = false;
        break;
      }
    }

    var allDenied = true;
    for (var userId in sideTwoMembers) {
      if (userStatuses[userId] != 'denied') {
        allDenied = false;
        break;
      }
    }

    if (allDenied) {
      // update the bet's status to 'rejected' if everybody on the other team denied the bet
      await FirebaseFirestore.instance
        .collection('bets')
        .doc(widget.betId)
        .update({
          'status': 'rejected'
        });
    } else if (allResponded) {
      // update the bet's status to 'in_progress' if at least one person accepted the bet
      await FirebaseFirestore.instance
        .collection('bets')
        .doc(widget.betId)
        .update({
          'status': 'in_progress'
        });
    }
  }

  void acceptBetInvite() async {
    // Add bet to current user's bets
    await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .update({
        'bets.${widget.betId}': 'accepted'
      });

    // Remove bet invite from current user's bet invites
    await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('notifications')
      .doc(widget.notificationId)
      .delete();

    // update the bet's user_statuses list
    await FirebaseFirestore.instance
      .collection('bets')
      .doc(widget.betId)
      .update({
        'user_statuses.${widget.user.uid}': 'accepted'
      });
    
    checkAndUpdateBetStatus();
  }

  void denyBetInvite() async {
    // Remove bet invite from current user's bet invites
    await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .update({
        'bet_invites': FieldValue.arrayRemove([widget.betId])
      });

    // Remove bet invite from current user's bet invites
    await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .collection('notifications')
      .doc(widget.notificationId)
      .delete();

    // update the bet's user_statuses list
    await FirebaseFirestore.instance
      .collection('bets')
      .doc(widget.betId)
      .update({
        'user_statuses.${widget.user.uid}': 'denied'
      });

    checkAndUpdateBetStatus();
  }

  bool isAccepted = false;
  bool isDenied = false;

  void _showBetDetailsDialog() async {
    // get the bet from firebase:
    var bet = await FirebaseFirestore.instance
      .collection('bets')
      .doc(widget.betId)
      .get();

    if (!bet.exists) {
      // Handle the case where the bet does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bet created successfully!')),
      );
      return;
    }

    // get the ids of the participants of the bet
    List<String> sideOneMemberIds = List<String>.from(bet.data()?['side_one_members'] ?? []);
    List<String> sideTwoMemberIds = List<String>.from(bet.data()?['side_two_members'] ?? []);

    // get the info for each of the members
    List<Map<String, dynamic>> sideOneMembers = [];
    for (var memberId in sideOneMemberIds) {
      var member = await FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .get();
      if (member.exists) {
        sideOneMembers.add({
          'username': member.data()?['username'] ?? 'Unknown',
          'profile_picture': member.data()?['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
          'full_name': member.data()?['full_name'] ?? 'Unknown',
          'uid': member.data()?['uid'] ?? 'Unknown',
        });
      }
    }

    List<Map<String, dynamic>> sideTwoMembers = [];
    for (var memberId in sideTwoMemberIds) {
      var member = await FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .get();
      if (member.exists) {
        sideTwoMembers.add({
          'username': member.data()?['username'] ?? 'Unknown',
          'profile_picture': member.data()?['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
          'full_name': member.data()?['full_name'] ?? 'Unknown',
          'uid': member.data()?['uid'] ?? 'Unknown',
        });
      }
    }
    
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
                      "@${widget.username}'s invite",
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
                          if (sideTwoMembers.length > 1)
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
                                children: sideTwoMembers
                                .map((better) => Chip(
                                  avatar: CircleAvatar(
                                  backgroundImage: NetworkImage(better['profile_picture']),
                                  ),
                                  label: Text(better['username']),
                                ))
                                .toList(),
                                ),
                              ],
                              ),
                            ),
                          if (sideTwoMembers.length > 1) const SizedBox(height: 20),
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
                                  'Betting against:',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: sideOneMembers
                                  .map((better) => Chip(
                                    avatar: CircleAvatar(
                                      backgroundImage: NetworkImage(better['profile_picture']),
                                    ),
                                    label: Text(better['username']),
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
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: widget.betTitle,
                              hintStyle: const TextStyle(color: Colors.black),
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
                            'Description',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: widget.betDescription,
                              hintStyle: const TextStyle(color: Colors.black),
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
                            'Each side puts in',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              enabled: false,
                              hintText: "\$ ${widget.betAmount}",
                              hintStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Text(
                            'Each team will bet \$${widget.betAmount}, split evenly among team members.',
                            style: GoogleFonts.lato(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          acceptBetInvite();
                          // play accepted bet invite animation
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
                            useSafeArea: true,
                            builder: (BuildContext context) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.width * 0.8,
                                  child: Lottie.asset(
                                    'assets/acceptBetInviteAnimation.json',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff5e548e),
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          denyBetInvite();
                        // play denied bet invite animation
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            barrierColor: Colors.black.withAlpha((0.5 * 255).toInt()),
                            useSafeArea: true,
                            builder: (BuildContext context) {
                              return Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: MediaQuery.of(context).size.width * 0.6,
                                  child: Lottie.asset(
                                    'assets/denyBetInviteAnimation.json',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Deny',
                          style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.action == "bet_invite") {
              _showBetDetailsDialog();
            }
            else if (widget.action == "friend_request" || widget.action == "sent_friend_request") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProfile(uid: widget.friendId, user: widget.user),
                ),
              );
            }
          },
          child: ListTile(
            leading: switch (widget.action) {
              "bet_invite" => null,
              _ => CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.profilePicture),
                backgroundColor: Colors.grey[300],
              ),
            },
            title: switch (widget.action) {
              "friend_request" => Text(
                "${widget.fullName} ",
                style: GoogleFonts.lato(fontSize:18, color: Colors.black),
              ),
              "sent_friend_request" => Text(
                "${widget.fullName} ",
                style: GoogleFonts.lato(fontSize:18, color: Colors.black),
              ),
              "bet_invite" => Text(
                "${widget.betTitle} ",
                style: GoogleFonts.lato(fontSize:18, color: Colors.black),
              ),
              "like" => Text("${widget.username} liked your post"),
              "comment" => Text("${widget.username} commented: ${widget.commentText}"),
              _ => Text(widget.action),
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                switch (widget.action) {
                  "friend_request" => Text(
                    "@${widget.username}",
                    style: GoogleFonts.lato(fontSize:14, color: Colors.black),
                  ),
                  "sent_friend_request" => Text(
                    "@${widget.username}",
                    style: GoogleFonts.lato(fontSize:14, color: Colors.black),
                  ),
                  "bet_invite" => Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(widget.profilePicture),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Text(
                            widget.fullName,
                            style: GoogleFonts.lato(fontSize:14),
                          ),
                          Text(
                            "@${widget.username}",
                            style: GoogleFonts.lato(fontSize: 14),
                          ),
                        ]
                      ),
                    ]
                  ),
                  "like" => Text("${widget.username} liked your post"),
                  "comment" => Text("${widget.username} commented: ${widget.commentText}"),
                  _ => Text(widget.action),
                },
              ],
            ),
            trailing: widget.action == "friend_request" ? 
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return isAccepted
                      ? SizedBox(
                        width: 50,
                        child: Lottie.asset(
                          'assets/acceptFriendRequestHeartAnimation.json',
                          repeat: false,
                          onLoaded: (composition) {
                            Future.delayed(composition.duration, () async {
                              await acceptFriendRequest(widget.friendId);
                            });
                            setState(() {});
                          },
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            isAccepted = true;
                          });
                        },
                      );
                    },
                  ),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return isDenied
                      ? SizedBox(
                        width: 30,
                        child: Lottie.asset(
                          'assets/denyFriendRequestXAnimation.json',
                          repeat: false,
                          onLoaded: (composition) {
                            Future.delayed(composition.duration, () async {
                              await removeFriendRequest(widget.friendId, true);
                            });
                            setState(() {});
                          },
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.black),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Decline Friend Request"),
                                content: const Text("Are you sure you want to decline this friend request?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        isDenied = true;
                                      });
                                    },
                                    child: const Text("Remove"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            : widget.action == "bet_invite" ? 
            Text(
              "\$${widget.betAmount}",
              style: GoogleFonts.lato(fontSize: 18),
            )
            : widget.action == "sent_friend_request" ?
            Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                      return isDenied
                      ? SizedBox(
                        width: 30,
                        child: Lottie.asset(
                          'assets/denyFriendRequestXAnimation.json',
                          repeat: false,
                          onLoaded: (composition) {
                            Future.delayed(composition.duration, () async {
                              await cancelFriendRequest(widget.friendId, true);
                            });
                            setState(() {});
                          },
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.black),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Cancel friend request"),
                                content: const Text("Are you sure you want to cancel this friend request?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text("Go back"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        isDenied = true;
                                      });
                                    },
                                    child: const Text("Cancel friend request"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            : null,
          ),
        ),
      ],
    );
  }
}