import 'package:flutter/material.dart';

class UnlockedPropertiesScreen extends StatelessWidget {
  const UnlockedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Unlocked Properties"),
      ),
      body: const Center(
        child: Text("Unlocked properties here"),
      ),
    );
  }
}