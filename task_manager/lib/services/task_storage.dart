// Saves the task list to the device and reads it back.
// Explained in docs/concepts/persistence.md

// dart:convert is part of Dart itself, not Flutter — it holds jsonEncode/Decode.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

// A service class: it knows how to store things and nothing about the screen.
// Same idea as a model — keeping it separate is what lets each part be tested
// and changed on its own.
class TaskStorage {
  // The name the list is filed under. A typo in a key is a silent bug, so it
  // lives in one place rather than being retyped at each use.
  static const String _tasksKey = 'tasks';

  // Future<void> means "this finishes later, with no value to hand back".
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    // Task objects cannot be stored directly. Each becomes a Map...
    final taskMaps = tasks.map((task) => task.toMap()).toList();

    // ...and the whole list becomes one JSON string.
    final jsonString = jsonEncode(taskMaps);

    await prefs.setString(_tasksKey, jsonString);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_tasksKey);

    // Null means nothing has ever been saved — a first run, not an error.
    if (jsonString == null) {
      return [];
    }

    // jsonDecode gives back plain lists and maps, with no type information, so
    // dynamic is unavoidable here. Task.fromMap is where it turns back into
    // something typed.
    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded
        .map((item) => Task.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
