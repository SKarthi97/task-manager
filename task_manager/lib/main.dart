// Task Manager — application entry point.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".

import 'package:flutter/material.dart';

// Entry point: runApp mounts the root widget on screen.
void main() {
  runApp(const TaskManagerApp());
}

// The root widget. Stateless because nothing here changes at runtime.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up app-wide navigation and theming.
    return MaterialApp(
      title: 'Task Manager', // Shown by the OS / browser tab, not on screen.
      debugShowCheckedModeBanner: false, // Hides the "DEBUG" ribbon.
      theme: ThemeData(
        // One seed colour generates the whole palette.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
      ),
      home: const HomeScreen(),
    );
  }
}

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
