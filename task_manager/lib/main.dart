// Task Manager — application entry point.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".

import 'package:flutter/material.dart';
import 'package:task_manager/screens/home_screen.dart';

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
