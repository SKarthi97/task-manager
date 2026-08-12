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

  // A second callback, for the same reason: the tile cannot remove a task from
  // a list it does not own, so it just reports the tap.
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

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

      // trailing is the slot at the end of the row.
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        // Passed straight through: onDelete already takes no arguments and
        // returns nothing, which is exactly what onPressed wants.
        onPressed: onDelete,
        // tooltip shows on hover or long-press, and is what screen readers
        // announce — an icon on its own has no words to read out.
        tooltip: 'Delete task',
      ),
    );
  }
}
