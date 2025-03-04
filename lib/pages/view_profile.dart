import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:wannabet/widgets/loading_page.dart';

class ViewProfile extends StatefulWidget {
  final String username;
  final String uid;

  const ViewProfile({
    super.key,
    required this.username,
    required this.uid,
  });

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  var user;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> fetchUserEmail() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            user = userDoc.docs.first;
          });
        }
        return user['id'];
      }
    } catch (e) {
      print("Error fetching user email: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchUserEmail(),
       builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return LoadingPage(user: [], selectedIndex: 0, title: 'Social');
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile", style: TextStyle(color: Colors.black)),
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: NetworkImage(user['profile_picture']),
                          child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                            color: Color(0xff231942),
                            width: 1.0,
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "@${user['username']}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Hi, ${user['first_name']}!",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ),
            ),
          ),
        );
       }
    );
  }
}