import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/loading_page.dart';

class FriendsListPage extends StatefulWidget {
  final user;
  const FriendsListPage({super.key, required this.user});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  Future<List<Map<String, dynamic>>> fetchFriends() async {
    try {
      // Get the current user's friends list
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      
      List<String> friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);
      
      if (friendIds.isEmpty) {
        return [];
      }

      // Fetch details for each friend
      var friendDocs = await Future.wait(
        friendIds.map((friendId) => 
          FirebaseFirestore.instance
              .collection('users')
              .doc(friendId)
              .get()
        )
      );

      return friendDocs.map((doc) => {
        'id': doc.id,
        'username': doc.data()?['username'] ?? 'Unknown',
        'full_name': doc.data()?['full_name'] ?? 'Unknown User',
        'profile_picture': doc.data()?['profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
      }).toList();
    } catch (e) {
      print("Error fetching friends: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final friend = snapshot.data![index];
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
          );
        },
      ),
    );
  }
} 