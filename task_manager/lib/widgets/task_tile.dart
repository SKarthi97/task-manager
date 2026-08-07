// One row in the task list.
// Explained in docs/concepts/callbacks.md

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  // This widget receives one task; it does not create the task.
  final Task task;

  // A function passed in from the parent, to be called when the box is tapped.
  // VoidCallback is shorthand for "takes nothing, returns nothing".
  final VoidCallback onToggle;

  const TaskTile({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // ListTile is a ready-made row: something at the start, a title, and
    // optionally something at the end.
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        // Checkbox hands back the new value; this tile does not need it, so it
        // is ignored with _ and the parent is simply told a tap happened.
        onChanged: (_) {
          onToggle();
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          // ? : is Dart's inline if — cross out the title once it is done.
          decoration: task.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
    );
  }
}
