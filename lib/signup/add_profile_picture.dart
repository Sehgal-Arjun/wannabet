import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wannabet/pages/home.dart';

class AddProfilePicturePage extends StatefulWidget {
  const AddProfilePicturePage({super.key});

  @override
  State<AddProfilePicturePage> createState() => _AddProfilePicturePageState();
}

class _AddProfilePicturePageState extends State<AddProfilePicturePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  User user = FirebaseAuth.instance.currentUser!;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      _pickImage(); // If no image is selected, open image picker
      return;
    }

    setState(() => _isUploading = true);

    try {
      String userId = user.uid;
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putFile(_image!);
      String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profile_picture': downloadURL,
      });

      _navigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: ${e.toString()}")),
      );
    }

    setState(() => _isUploading = false);
  }

  Future<void> _skipForNow() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String defaultAvatarURL = "http://www.gravatar.com/avatar/?d=mp"; // Replace with a better default avatar URL

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profile_picture': defaultAvatarURL,
    });

    _navigateToHome();
  }

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "Last step!", // maybe change this to be "Hi, {name}!"?
          style: TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? Icon(Icons.person, size: 60, color: Colors.white) : null,
              ),
              const SizedBox(height: 24),
              
              if (_image != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _pickImage,
                      child: Text("Change Picture", style: TextStyle(color: Color(0xFF5e548e))),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _removeImage,
                      child: Text("Remove Picture", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5e548e),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _uploadImage,
                      child: Text(
                        _image == null ? "Upload a Picture" : "Looks Good!",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              if (_image == null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _skipForNow,
                  child: Text("Skip for now", style: TextStyle(color: Color(0xFF5e548e))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
