import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/loading_page.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<String> selectedFriendIds = [];
  List<Map<String, dynamic>> friends = [];
  bool userLoading = true;
  bool userHasFriends = false;
  double currentAmount = 0;

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
              'full_name': doc['full_name'] ?? 'Unknown User',
            };
          }),
        );

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: 4, title: 'Profile', showNavBar: false);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: !userHasFriends ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/noFriendsAnimation.json',
              width: MediaQuery.of(context).size.width / 1.15,
              height: MediaQuery.of(context).size.width / 1.15,
            ),
            Text(
              'No friends yet',
              style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ) :ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friend['profile_picture']),
            radius: 25,
          ),
          title: Text(friend['full_name'],
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('@${friend['username']}',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        );
      },
    )
    );
  }
} 