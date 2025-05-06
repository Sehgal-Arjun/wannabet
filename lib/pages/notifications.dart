import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/loading_page.dart';
import '../widgets/notifications/notification_group.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  late UserObject user;
  bool userLoading = true;
  bool userHasFriendRequests = false;

  @override
  void initState() {
    super.initState();
    initUserWithState(
      state: this,
      onLoadingStart: () => userLoading = true,
      onUserLoaded: (loadedUser) {
        user = loadedUser;
        userLoading = false;
        userHasFriendRequests = user.friend_requests.isNotEmpty;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: 3, title: 'Notifications', showNavBar: false);
    }
    
    if (!userHasFriendRequests) {
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
            if (user.friend_requests.isNotEmpty) NotificationGroup(
              title: 'Friend requests',
              startCollapsed: false,
              collapsable: true,
              items: [
                for (var friendRequest in user.friend_requests){
                  'action': 'friend_request',
                  'profilePicture': friendRequest['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
                  'username': friendRequest['username'] ?? 'unknown',
                  'full_name': friendRequest['full_name'] ?? 'Unknown User',
                  'id': friendRequest['uid'],
                },
              ],
              user: user,
            ),
          ],
        ),
      ),
    );
  }
}