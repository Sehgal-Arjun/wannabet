import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/loading_page.dart';
import '../widgets/notifications/notification_group.dart';

class NotificationsPage extends StatefulWidget {
  final user;
  const NotificationsPage({super.key, required this.user});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  Future fetchUser() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
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
    return FutureBuilder(
      future: fetchUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return LoadingPage(user:[], selectedIndex: 3, title: 'Notifications');
        }

        final friendRequests = snapshot.data['friend_requests'] ?? [];
        
        if (friendRequests.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/noNotificationsAnimation.json',
                    width: MediaQuery.of(context).size.width / 1.15,
                    height: MediaQuery.of(context).size.width / 1.15,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'No notifications',
                    style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (friendRequests.isNotEmpty) NotificationGroup(
                  title: 'Friend requests',
                  startCollapsed: false,
                  collapsable: true,
                  items: [
                    for (var friendRequest in friendRequests){
                      'action': 'friend_request',
                      'profilePicture': friendRequest['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
                      'username': friendRequest['username'] ?? 'unknown',
                      'full_name': friendRequest['full_name'] ?? 'Unknown User',
                      'id': friendRequest['uid'],
                    },
                  ],
                  user: widget.user,
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}