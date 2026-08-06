// The app's first screen, kept out of main.dart so entry point and UI stay separate.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".

import 'package:flutter/material.dart';

// The first screen. Becomes stateful once tasks can be added and completed.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the standard screen layout slots.
    return Scaffold(
      // Colours come from the theme, so no colour is set here.
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      // Center positions its single child in the middle of the screen.
      body: const Center(
        child: Text(
          'Welcome to Flutter!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
