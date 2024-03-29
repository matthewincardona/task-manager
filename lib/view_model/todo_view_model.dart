import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/todo.dart';
import 'dart:convert';

class TodoViewModel extends ChangeNotifier {
  late final BuildContext _context;

  final List<Todo> _todos = [];
  late Timer _timer;
  // late Duration _timeUntilMidnight;

  List<Todo> get todos => _todos;

  // Method to add a todo

  void addTodo(String title) {
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Set the timestamp based on the current time
    DateTime timestamp = now;
    if (hour >= 17) {
      // If it's past 5 PM, set the timestamp to the next day at 9 AM
      timestamp = DateTime(now.year, now.month, now.day + 1, 9);
    } else if (hour < 9) {
      // If it's before 9 AM, set the timestamp to today at 9 AM
      timestamp = DateTime(now.year, now.month, now.day, 9);
    }

    // Check if the newly added todo is past the deadline
    bool isPastDeadline = timestamp.hour >= 17 || timestamp.hour < 9;

    _todos.add(Todo(
      title: title,
      timestamp: timestamp,
      isCompleted: isPastDeadline, // Mark as completed if past deadline
    ));
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(int index) {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    _saveTodos();
    notifyListeners();
  }

  // Method to remove a todo
  void removeTodo(int index) {
    _todos.removeAt(index);
    _saveTodos();
    notifyListeners();
  }

  // Method to clear all todos
  void clearTodos() {
    _todos.clear();
    _clearStoredTodos();
    notifyListeners();
  }

  // Method to calculate the time remaining until midnight EST
  String calculateTimeUntilClear() {
    DateTime now = DateTime.now();
    DateTime targetTime = DateTime(now.year, now.month, now.day, 17, 0); // 5 PM
    if (now.hour >= 17) {
      // If it's already past 5 PM today, calculate for 5 PM tomorrow
      targetTime = targetTime.add(const Duration(days: 1));
    }
    Duration timeUntilTarget = targetTime.difference(now);

    if (timeUntilTarget.inSeconds <= 0) {
      // If countdown is zero or negative, clear todos and return empty string
      clearTodos();
      return '';
    }

    int hours = timeUntilTarget.inHours;
    int minutes = timeUntilTarget.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Method to start the countdown timer
  void startCountdownTimer(BuildContext context) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      String timeRemaining = calculateTimeUntilClear();
      if (timeRemaining.isEmpty) {
        // If countdown is empty, cancel timer and show the completion popup
        _timer.cancel();
        showCompletionPopup(context);
      } else {
        notifyListeners();
      }
    });
  }

  // Method to save todos to storage
  Future<void> _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoStrings =
        _todos.map((todo) => todo.toJsonString()).toList();
    await prefs.setStringList('todos', todoStrings);
  }

  // Method to load todos from storage
  Future<void> loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoStrings = prefs.getStringList('todos');
    if (todoStrings != null) {
      _todos.clear();
      _todos.addAll(todoStrings
          .map((todoString) => Todo.fromJson(json.decode(todoString))));
    }
  }

  // Method to clear stored todos from storage
  Future<void> _clearStoredTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('todos');
  }

  // Method to handle clearance of tasks if the app was not open at midnight
  Future<void> handleMidnightClearance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastClearanceTimestamp = prefs.getInt('lastClearanceTimestamp') ?? 0;
    DateTime lastClearanceDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastClearanceTimestamp);
    DateTime now = DateTime.now();

    if (now.isAfter(DateTime(now.year, now.month, now.day, 0, 0)) &&
        lastClearanceDateTime
            .isBefore(DateTime(now.year, now.month, now.day, 0, 0))) {
      clearTodos();
    }

    await prefs.setInt('lastClearanceTimestamp', now.millisecondsSinceEpoch);
  }

  // Constructor to set up the countdown timer and handle clearance of tasks
  TodoViewModel({required BuildContext context}) : _context = context {
    loadTodos().then((_) {
      calculateTimeUntilClear();
      startCountdownTimer(_context);
      handleMidnightClearance();
    });
  }

  // Dispose method to cancel the timer when the view model is no longer needed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int get completedTasksCount =>
      _todos.where((todo) => todo.isCompleted).length;

  // Add a function to show a popup at midnight with the completed tasks count
  void showCompletionPopup(BuildContext context) {
    int completedTasksToday = completedTasksCount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tasks completed today: $completedTasksToday'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
