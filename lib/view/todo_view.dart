// view/todo_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../view_model/todo_view_model.dart';

class TodoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: viewModel.todos.length,
            itemBuilder: (context, index) {
              final todo = viewModel.todos[index];
              return ListTile(
                title: Text(todo.title),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(BuildContext context, TodoViewModel viewModel, int index,
      Animation<double> animation, Todo todo) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            viewModel.toggleTodo(index);
          },
        ),
        title: Text(todo.title),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    String newTodo = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Todo'),
          content: TextField(
            onChanged: (value) {
              newTodo = value;
            },
            decoration: InputDecoration(hintText: 'Enter your todo'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newTodo.isNotEmpty) {
                  Provider.of<TodoViewModel>(context, listen: false)
                      .addTodo(newTodo);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
