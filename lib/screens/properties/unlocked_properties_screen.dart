import 'package:flutter/material.dart';

class UnlockedPropertiesScreen extends StatelessWidget {
  const UnlockedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unlocked Properties"),
      ),
      body: const Center(
        child: Text("Unlocked properties here"),
      ),
    );
  }
}