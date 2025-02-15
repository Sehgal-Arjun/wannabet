import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wanna_bet/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Log in",
          style: GoogleFonts.lato(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Lottie.asset(
                'assets/logInAnimation.json',
                width: MediaQuery.of(context).size.width / 1.25,
                height: MediaQuery.of(context).size.width / 1.25,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(Icons.mail_outline, "Email"),
                    const SizedBox(height: 16),
                    _buildTextField(Icons.lock_outline, "Password", isPassword: true),
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
                onPressed: () {},
                child: Text("Sign in", style: GoogleFonts.lato(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  child: Text("Don't have an account yet?",
                      style: GoogleFonts.lato(color: Color(0xFF5e548e))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
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
