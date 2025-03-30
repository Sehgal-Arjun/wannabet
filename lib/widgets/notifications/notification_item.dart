import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItem extends StatefulWidget {
  final String action;
  final String profilePicture;
  final String commentText;
  final String username;
  final String fullName;
  final String currentUserId;
  final String friendId;
  const NotificationItem({super.key, required this.action, required this.profilePicture, this.commentText = "", required this.username, required this.fullName, required this.currentUserId, required this.friendId});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {

  Future acceptFriendRequest(friendId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

      var currentUser = userDoc.data() ?? {};

      // Add friend to current user's friend list
      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .update({
          'friends': FieldValue.arrayUnion([friendId])
        });

      // Add current user to friend's friend list
      await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .update({
          'friends': FieldValue.arrayUnion([widget.currentUserId])
        });

      // Remove friend request from current user's friend requests
      removeFriendRequest(friendId);


    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  Future removeFriendRequest(friendId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

      var currentUser = userDoc.data() ?? {};

      // Remove friend request from current user's friend requests
      var friendRequests = currentUser['friend_requests'] ?? [];
      var updatedFriendRequests = friendRequests.where((request) => request['uid'] != friendId).toList();

      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .update({
          'friend_requests': updatedFriendRequests
        });

    } catch (e) {
      print("Error removing friend request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(

            radius: 20,
            backgroundImage: NetworkImage(widget.profilePicture),
            backgroundColor: Colors.grey[300],
          ),
          title: switch (widget.action) {
            "friend_request" => Text(
              "${widget.fullName} ",
              style: GoogleFonts.lato(fontSize:18, color: Colors.black),
            ),
            "like" => Text("${widget.username} liked your post"),
            "comment" => Text("${widget.username} commented: ${widget.commentText}"),
            _ => Text(widget.action),
          },
          subtitle: switch (widget.action) {
            "friend_request" => Text(
              "@${widget.username}",
              style: GoogleFonts.lato(fontSize:14, color: Colors.black),
            ),
            "like" => Text("${widget.username} liked your post"),
            "comment" => Text("${widget.username} commented: ${widget.commentText}"),
            _ => Text(widget.action),
          },
          trailing: widget.action == "friend_request" ? 
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                  onPressed: () async {
                    await acceptFriendRequest(widget.friendId);
                  },
                ),
                IconButton(
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
                                removeFriendRequest(widget.friendId);
                              },
                              child: const Text("Remove"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            )
          : null,
        ),
      ],
    );
  }
}