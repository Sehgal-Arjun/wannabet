import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/signup/add_profile_picture.dart';

class NameAndUsernamePage extends StatefulWidget {
  const NameAndUsernamePage({super.key});

  @override
  State<NameAndUsernamePage> createState() => _NameAndUsernamePageState();
}

class _NameAndUsernamePageState extends State<NameAndUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Save name & username to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        "username": _usernameController.text.trim(),
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "full_name": "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AddProfilePicturePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save data: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Let's get started!",
          style: GoogleFonts.lato(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What should we call you?",
                  style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(Icons.person, "First Name", _firstNameController),
                      const SizedBox(height: 16),
                      _buildTextField(Icons.person, "Last Name", _lastNameController),
                      const SizedBox(height: 16),
                      _buildTextField(Icons.alternate_email, "Username", _usernameController),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5e548e),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: saveUserData,
                  child: Text("Continue", style: GoogleFonts.lato(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) => value == null || value.trim().isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF9f86c0)),
        hintText: hintText,
        hintStyle: GoogleFonts.lato(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF9f86c0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF5e548e)),
        ),
      ),
    );
  }
}
