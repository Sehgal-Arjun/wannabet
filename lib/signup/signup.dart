import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/pages/home.dart';
import 'package:wannabet/login.dart';
import 'package:wannabet/signup/name_and_username.dart';
import 'package:wannabet/widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  void signUp() async {
    if (_password.text.trim() == _confirmPassword.text.trim()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        String userID = userCredential.user!.uid;
        String userEmail = userCredential.user!.email!;

        await FirebaseFirestore.instance.collection('users').doc(userID).set({
          "first_name": null,
          "last_name": null,
          "full_name": null,
          "username": null,
          "email": userEmail,
          "profile_picture": null,
          "friends": [],
          "friend_requests": [],
          "pinned_bets": [],
          "total_money_won": 0.0,
          "total_bets": 0,
          "id": userID,
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NameAndUsernamePage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign up: ${e.toString()}")),
        );
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Sign Up",
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
                Lottie.asset(
                  'assets/signUpAnimation.json',
                  width: MediaQuery.of(context).size.width / 1.25,
                  height: MediaQuery.of(context).size.width / 1.25,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField(Icons.mail_outline, "Email", _email),
                      const SizedBox(height: 16),
                      buildTextField(Icons.lock_outline, "Password", _password, isPassword: true),
                      const SizedBox(height: 16),
                      buildTextField(Icons.lock_outline, "Confirm Password", _confirmPassword, isPassword: true),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5e548e),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: signUp,
                  child: Text("Create Account", style: GoogleFonts.lato(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    child: Text("Already have an account?",
                        style: GoogleFonts.lato(color: Color(0xFF5e548e))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
