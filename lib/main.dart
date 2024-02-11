import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/view/todo_view.dart';
import 'package:task_manager/view_model/todo_view_model.dart';

// main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoView(),
    );
  }
}
