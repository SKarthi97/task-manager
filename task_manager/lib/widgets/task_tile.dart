// One row in the task list.
// Explained in docs/concepts/lists.md

import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  // This widget receives one task; it does not create the task.
  final Task task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // ListTile is a ready-made row: something at the start, a title, and
    // optionally something at the end.
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: null, // Disabled for now, like the "+" button.
      ),
      title: Text(task.title),
    );
  }
}
