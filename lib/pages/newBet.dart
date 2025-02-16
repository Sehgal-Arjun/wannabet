import 'package:flutter/material.dart';

class NewBetScreen extends StatelessWidget {
  const NewBetScreen({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bet Screen'),
      ),
      body: const Center(
        child: Text('New Bet Screen Content'),
      ),
    );
  }
}