import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/todo.dart';
import 'dart:convert';

class TodoViewModel extends ChangeNotifier {
  late final BuildContext _context;

  final List<Todo> _todos = [];
  late Timer _timer;
  late Duration _timeUntilMidnight;

  List<Todo> get todos => _todos;

  // Method to add a todo
  void addTodo(String title) {
    _todos.add(Todo(title: title));
    _saveTodos();
    notifyListeners();
  }

  // Method to toggle a todo
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
  String calculateTimeUntilMidnight() {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day + 1, 0, 0);
    _timeUntilMidnight = midnight.difference(now);

    if (_timeUntilMidnight.inSeconds <= 0) {
      // If countdown is zero or negative, clear todos and return empty string
      clearTodos();
      return '';
    }

    int hours = _timeUntilMidnight.inHours;
    int minutes = _timeUntilMidnight.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Method to start the countdown timer
  void startCountdownTimer(BuildContext context) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      String timeRemaining = calculateTimeUntilMidnight();
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
      calculateTimeUntilMidnight();
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
