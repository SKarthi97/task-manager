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

  // A controller is the handle on a text field: it holds what has been typed,
  // and lets this code read or clear it.
  final TextEditingController _taskController = TextEditingController();

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
        // The button no longer adds a task itself — it asks for the title first.
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // dispose runs when this screen is removed for good. The controller holds
  // resources Flutter cannot clean up on its own, so it has to be released here
  // or it leaks. Anything you create in a State and keep needs this.
  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Asks the user for a title, then adds the task.
  void _showAddTaskDialog() {
    // Clear first, so whatever was typed last time is not still sitting there.
    _taskController.clear();

    // showDialog puts a small screen on top of this one. The dark, tappable
    // background and the closing behaviour come for free.
    showDialog(
      context: context,
      builder: (context) {
        // AlertDialog is the standard dialog shape: a title, some content, and
        // a row of buttons.
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            // Wiring the field to the controller is what lets the buttons
            // below read what was typed.
            controller: _taskController,
            // hintText is the grey placeholder shown while the field is empty.
            decoration: const InputDecoration(hintText: 'Enter task title'),
            // Put the cursor in the field straight away, so the user can type
            // without tapping first.
            autofocus: true,
          ),
          // actions is the button row along the bottom.
          actions: [
            TextButton(
              onPressed: () {
                _taskController.clear();
                // Navigator.pop closes the dialog — the same call that goes
                // back a screen, because a dialog is just another route.
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // trim() drops surrounding spaces, so "   " counts as empty.
                if (_taskController.text.trim().isEmpty) {
                  // Returning early leaves the dialog open, so the user can
                  // see nothing happened and type something.
                  return;
                }

                // Only the data change goes inside setState.
                setState(() {
                  tasks.add(Task(title: _taskController.text.trim()));
                });

                _taskController.clear();
                Navigator.pop(context);
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }
}
