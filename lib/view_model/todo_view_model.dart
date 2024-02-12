import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/todo.dart';
import 'dart:convert';

class TodoViewModel extends ChangeNotifier {
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
  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      String timeRemaining = calculateTimeUntilMidnight();
      if (timeRemaining.isEmpty) {
        // If countdown is empty, cancel timer
        _timer.cancel();
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

  // Constructor to set up the countdown timer when the view model is created
  TodoViewModel() {
    loadTodos().then((_) {
      calculateTimeUntilMidnight();
      startCountdownTimer();
    });
  }

  // Dispose method to cancel the timer when the view model is no longer needed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
