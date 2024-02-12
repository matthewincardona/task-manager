import 'dart:async';
import 'package:flutter/material.dart';
import '../model/todo.dart';

class TodoViewModel extends ChangeNotifier {
  final List<Todo> _todos = [];
  late Timer _timer;
  late Duration _timeUntilMidnight;

  List<Todo> get todos => _todos;

  // Method to add a todo
  void addTodo(String title) {
    _todos.add(Todo(title: title));
    notifyListeners();
  }

  // Method to toggle a todo
  void toggleTodo(int index) {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    notifyListeners();
  }

  // Method to clear all todos
  void clearTodos() {
    _todos.clear();
    notifyListeners();
  }

  // Method to calculate the time remaining until midnight EST
  String calculateTimeUntilMidnight() {
    Duration timeUntilMidnight = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day + 1,
      0,
      0,
    ).difference(DateTime.now());

    int hours = timeUntilMidnight.inHours;
    int minutes = timeUntilMidnight.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Method to start the countdown timer
  void startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilMidnight.inSeconds > 0) {
        _timeUntilMidnight -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        _timer.cancel();
      }
    });
  }

  // Constructor to set up the countdown timer when the view model is created
  TodoViewModel() {
    calculateTimeUntilMidnight();
    startCountdownTimer();
  }

  // Dispose method to cancel the timer when the view model is no longer needed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
