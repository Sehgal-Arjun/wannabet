import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/notifications/notification_group.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class ViewSentFriendRequests extends StatefulWidget {

  const ViewSentFriendRequests({super.key,});

  @override
  State<ViewSentFriendRequests> createState() => _ViewSentFriendRequestsState();
}

class _ViewSentFriendRequestsState extends State<ViewSentFriendRequests> {

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

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: 3, title: 'Profile', showNavBar: false);
    }
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
          for (var friendRequest in user.sent_friend_requests){
            'action': 'sent_friend_request',
            'profilePicture': friendRequest['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
            'username': friendRequest['username'] ?? 'unknown',
            'full_name': friendRequest['full_name'] ?? 'Unknown User',
            'id': friendRequest['uid'],
          },
        ],
        user: user,
        collapsable: false,
        startCollapsed: false,
      )
    );
  }
}