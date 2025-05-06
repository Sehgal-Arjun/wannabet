// user_loader.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wannabet/models/user_model.dart';


Future<void> initUserWithState({
  required State state,
  required void Function(UserObject) onUserLoaded,
  void Function()? onLoadingStart,
}) async {
  final box = Hive.box<UserObject>('userBox');
  final cachedUser = box.get('user');

  if (cachedUser != null) {
    if (onLoadingStart != null) onLoadingStart();
    state.setState(() {
      onUserLoaded(cachedUser);
    });
  } else {
    if (onLoadingStart != null) onLoadingStart();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (snapshot.exists) {
        final userData = snapshot.data()!;
        final userObj = UserObject.fromMap(user.uid, userData);
        await box.put('user', userObj);
        state.setState(() {
          onUserLoaded(userObj);
        });
      }
    }
  }
}
