// The app's first screen, kept out of main.dart so entry point and UI stay separate.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".

import 'package:flutter/material.dart';

// StatelessWidget means: this widget shows something, but does not manage
// changing data. It becomes a StatefulWidget once tasks can be added.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // build describes what to show. Flutter calls it whenever the screen
  // needs drawing.
  @override
  Widget build(BuildContext context) {
    // Scaffold is the standard screen frame: it has a slot for a top bar, a
    // slot for the main content, a slot for a floating button, and so on.
    return Scaffold(
      // The bar across the top of the screen.
      appBar: AppBar(
        // const means: this never changes, so Flutter can reuse it.
        title: const Text('Task Manager'),
      ),
      // Center puts its one child in the middle of the space available.
      body: const Center(
        // The empty state — what the user sees before any task exists.
        child: Text('No tasks yet', style: TextStyle(fontSize: 24)),
      ),
      // The round "+" button in the bottom corner.
      floatingActionButton: const FloatingActionButton(
        // onPressed: null means the button is disabled — it looks greyed out
        // and taps do nothing. Give it a function to make it work.
        onPressed: null,
        child: Icon(Icons.add),
      ),
    );
  }
}
