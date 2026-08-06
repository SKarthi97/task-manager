// Task Manager — application entry point.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".

import 'package:flutter/material.dart';
import 'package:task_manager/screens/home_screen.dart';

// main is the first function that runs. runApp puts the app on screen.
void main() {
  runApp(const TaskManagerApp());
}

// The outermost widget. Stateless because nothing here changes as the app runs.
class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp wraps the app and provides screen switching and theming.
    return MaterialApp(
      title: 'Task Manager', // Shown by the OS / browser tab, not on screen.
      debugShowCheckedModeBanner: false, // Hides the "DEBUG" ribbon.
      theme: ThemeData(
        // Give it one colour and Flutter works out the rest of the palette.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
      ),
      // home is the screen shown when the app opens.
      home: const HomeScreen(),
    );
  }
}
