// The app's first screen, kept out of main.dart so entry point and UI stay separate.
// Explained in docs/concepts/state.md

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
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
  // Starts empty now: the real tasks are read from the device in initState, so
  // hard-coded samples would either be overwritten or appear alongside them.
  final List<Task> tasks = [];

  final TaskStorage _taskStorage = TaskStorage();

  // True until the first load finishes. Without it the empty state would flash
  // up for a moment on every launch, before the saved tasks arrive.
  bool _isLoading = true;

  // A controller is the handle on a text field: it holds what has been typed,
  // and lets this code read or clear it.
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // A key is a handle on a widget's state from outside that widget. This one is
  // how the Add Task button reaches the Form below to ask it to validate.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // initState runs once, before the first build. It is where loading starts —
  // build must stay fast and side-effect free, so it cannot go there.
  @override
  void initState() {
    super.initState();

    // Not awaited: initState cannot be async. The load finishes later and calls
    // setState when it does.
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),
      // Three states now, not two: loading, empty, and a list.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // An empty list and a full one are different screens, so the body
          // picks between them. Deleting the last task swaps one for the other.
          : tasks.isEmpty
          ? const Center(
              child: Column(
                // Only as tall as its children, so the group stays centred.
                mainAxisSize: MainAxisSize.min,
                children: [
                  // An empty state says what is missing and what to do next.
                  Icon(Icons.task_alt, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Add a task using the + button.'),
                ],
              ),
            )
          // Builds only the rows on screen, however long the list gets.
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskTile(
                  task: task,
                  // The tile reports the tap; this screen decides what it means.
                  // The data lives here, so the change has to happen here too.
                  //
                  // Redraw first, then save: setState is instant, saving is not,
                  // and the user should not wait on the disk to see a tick.
                  onToggle: () async {
                    setState(() {
                      task.isCompleted = !task.isCompleted;
                    });

                    await _saveTasks();
                  },
                  onDelete: () async {
                    setState(() {
                      // remove() matches by ==, which Task does not define, so
                      // it falls back to identity — it removes this exact
                      // object, even if another task has the same title.
                      tasks.remove(task);
                    });

                    await _saveTasks();
                  },
                );
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
    _descriptionController.dispose();
    super.dispose();
  }

  // Asks the user for a title, then adds the task.
  void _showAddTaskDialog() {
    // Clear first, so whatever was typed last time is not still sitting there.
    _taskController.clear();
    _descriptionController.clear();

    // showDialog puts a small screen on top of this one. The dark, tappable
    // background and the closing behaviour come for free.
    showDialog(
      context: context,
      builder: (context) {
        // AlertDialog is the standard dialog shape: a title, some content, and
        // a row of buttons.
        return AlertDialog(
          title: const Text('Add New Task'),
          // Form groups fields so they can be checked together. With one field
          // it looks like overhead; with several, one validate() call does all.
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  // A plain Key is a label a test can search for. With two
                  // fields on screen, "find the text field" is now ambiguous.
                  key: const Key('titleField'),
                  // Wiring the field to the controller is what lets the buttons
                  // below read what was typed.
                  controller: _taskController,
                  // hintText is the grey placeholder shown while the field is empty.
                  decoration: const InputDecoration(
                    hintText: 'Enter task title',
                  ),
                  // Put the cursor in the field straight away, so the user can type
                  // without tapping first.
                  autofocus: true,
                  // A validator returns the message to show when input is bad, or
                  // null when it is fine. Returning null means "no complaint".
                  validator: (value) {
                    // trim() drops surrounding spaces, so "   " counts as empty.
                    if (value == null || value.trim().isEmpty) {
                      return 'Task title is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  key: const Key('descriptionField'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Enter description (optional)',
                  ),
                  // Grows to three lines before it starts scrolling.
                  maxLines: 3,
                  // No validator: the description is optional, so there is
                  // nothing to complain about.
                ),
              ],
            ),
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
              onPressed: () async {
                // validate() runs every validator in the Form and shows their
                // messages. It returns false if any of them complained, and
                // returning early then leaves the dialog open with the error on
                // screen — so the user now sees *why* nothing happened.
                //
                // The ! says "this is definitely not null". Safe here because
                // the Form is on screen whenever this button can be pressed.
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                // Only the data change goes inside setState.
                setState(() {
                  tasks.add(
                    Task(
                      title: _taskController.text.trim(),
                      description: _descriptionController.text.trim(),
                    ),
                  );
                });

                _taskController.clear();
                _descriptionController.clear();

                Navigator.pop(context);

                await _saveTasks();
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  // Reads whatever was saved and puts it on screen. Runs once, from initState.
  Future<void> _loadTasks() async {
    // try/catch because storage can fail — a corrupted or half-written file
    // would otherwise crash the app on launch, which is the worst moment.
    try {
      final savedTasks = await _taskStorage.loadTasks();

      // mounted is false if the screen was closed while this was loading.
      // Calling setState then throws, so every await in a State needs this
      // check before touching state.
      if (!mounted) {
        return;
      }

      setState(() {
        tasks.addAll(savedTasks);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      // Failing to load is not failing to run: stop the spinner and show the
      // empty state, so the app is still usable.
      setState(() {
        _isLoading = false;
      });

      debugPrint('Failed to load tasks: $error');
    }
  }

  // Writes the whole list every time. Fine for a short list; a real app with
  // thousands of rows would save just what changed.
  Future<void> _saveTasks() async {
    await _taskStorage.saveTasks(tasks);
  }
}
