import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wannabet/intro.dart';
import 'package:wannabet/widgets/custom_card.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';
import 'package:wannabet/utils/user_loader.dart';
import 'package:wannabet/widgets/loading_page.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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

  void signOut() async{
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
    if (!Hive.isBoxOpen('userBox') || Hive.box<UserObject>('userBox').get('user') == null || userLoading) {
      return LoadingPage(selectedIndex: 4, title: 'Profile', showNavBar: false);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            color: Colors.black,
          ),
        ],
      ),
      body: Scaffold(
        body: Center(
          child: Column(
            children: [
              // Settings & Help Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text("Privacy"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text("Help & Support"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}