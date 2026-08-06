// The app's first screen, kept out of main.dart so entry point and UI stay separate.
// Explained in docs/concepts/widgets.md

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

// StatelessWidget means: this widget shows something, but does not manage
// changing data. It becomes a StatefulWidget once tasks can be added.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Sample data, hard-coded for now so there is something to display. It moves
  // into state once the "+" button can add tasks.
  static const List<Task> tasks = [
    Task(title: "Learn Flutter widgets"),
    Task(title: "Build Task Manager app"),
    Task(title: "Practice Dart"),
  ];

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
      // ListView.builder makes the rows on demand, only for what is on screen.
      body: ListView.builder(
        // How many rows there are in total.
        itemCount: tasks.length,
        // Called for each row, and told which position to build.
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(task: task);
        },
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
