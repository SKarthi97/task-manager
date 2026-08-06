// The app's first screen, kept out of main.dart so entry point and UI stay separate.
// Explained in docs/concepts/state.md

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

// StatefulWidget, because the list of tasks can now change while the app runs.
// The widget itself stays immutable — it just says which State class to use.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Flutter calls this once to create the State object that holds the data.
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// The leading _ makes this class private to this file. Nothing outside needs it.
class _HomeScreenState extends State<HomeScreen> {
  // Lives in State, not in the widget, so it survives every rebuild.
  // final means the list itself is never swapped for a different list —
  // its contents can still change with add() and remove().
  final List<Task> tasks = [
    const Task(title: "Learn Flutter widgets"),
    const Task(title: "Build Task Manager app"),
    const Task(title: "Practice Dart"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),
      // Builds only the rows on screen, however long the list gets.
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return TaskTile(task: tasks[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Now that onPressed has a function, the button is enabled.
        onPressed: () {
          // setState says "the data changed, redraw". Change the data inside
          // it — adding to the list without setState would update the list but
          // leave the screen showing the old rows.
          setState(() {
            tasks.add(Task(title: "Task ${tasks.length + 1}"));
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
