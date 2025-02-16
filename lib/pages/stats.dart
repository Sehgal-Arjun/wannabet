import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats Screen'),
      ),
      body: const Center(
        child: Text('Stats Screen Content'),
      ),
    );
  }
}
