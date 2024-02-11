// view_model/todo_view_model.dart

import 'package:flutter/material.dart';
import '../model/todo.dart';

class TodoViewModel extends ChangeNotifier {
  final List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  void addTodo(String title) {
    _todos.add(Todo(title: title));
    notifyListeners();
  }

  void toggleTodo(int index) {
    _todos[index].isCompleted = !_todos[index].isCompleted;
    if (_todos[index].isCompleted) {
      _todos.removeAt(index);
    }
    notifyListeners();
  }
}
