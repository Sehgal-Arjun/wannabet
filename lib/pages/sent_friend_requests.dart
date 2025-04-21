import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/notifications/notification_group.dart';

class ViewSentFriendRequests extends StatefulWidget {
  final user;

  const ViewSentFriendRequests({
    super.key,
    required this.user
  });

  @override
  State<ViewSentFriendRequests> createState() => _ViewSentFriendRequestsState();
}

class _ViewSentFriendRequestsState extends State<ViewSentFriendRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sent Friend Requests',
          style: GoogleFonts.lato(),
        ),
        centerTitle: true,
      ),
      body: NotificationGroup(
        title: "", 
        items: [
          for (var friendRequest in widget.user.sent_friend_requests){
            'action': 'sent_friend_request',
            'profilePicture': friendRequest['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
            'username': friendRequest['username'] ?? 'unknown',
            'full_name': friendRequest['full_name'] ?? 'Unknown User',
            'id': friendRequest['uid'],
          },
        ],
        user: widget.user,
        collapsable: false,
        startCollapsed: false,
      )
    );
  }
}