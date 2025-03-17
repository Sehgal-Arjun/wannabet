import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wannabet/intro.dart';

class SettingsPage extends StatefulWidget {
  final user;
  SettingsPage({super.key, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  get user => widget.user;

  void signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => IntroPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign out: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: ListView(
          children: [

            GestureDetector(
              onTap: () {
     
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  leading: Icon(Icons.dark_mode, color: Colors.blueAccent),
                  title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Switch(
                    value: false, // Replace with your dark mode state
                    onChanged: (value) {
                    
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10), 

  
            GestureDetector(
              onTap: () {
       
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), 
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  leading: Icon(Icons.notifications, color: Colors.blueAccent),
                  title: Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Switch(
                    value: true, 
                    onChanged: (value) {
                    
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),


            GestureDetector(
              onTap: () {
    
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  leading: Icon(Icons.lock, color: Colors.blueAccent),
                  title: Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(height: 10), 


            GestureDetector(
              onTap: () {
    
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  leading: Icon(Icons.help_outline, color: Colors.blueAccent),
                  title: Text("Help", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(height: 10), // 


            GestureDetector(
              onTap: () {
            
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  leading: Icon(Icons.privacy_tip, color: Colors.blueAccent),
                  title: Text("Privacy", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}