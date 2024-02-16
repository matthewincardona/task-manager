import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/todo_view_model.dart';

class TodoView extends StatefulWidget {
  const TodoView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TodoViewState createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Task Manager'),
      // ),
      body: const Column(
        children: [
          TodoList(), // Separate widget for todo list
          CountdownView(), // Separate widget for countdown view
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(50.0, 80.0, 50.0, 20.0),
          // padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(height: 400),
            child: SingleChildScrollView(
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: viewModel.todos.length,
                  itemBuilder: (context, index) {
                    final todo = viewModel.todos[index];
                    return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        todo.title,
                        style: todo.isCompleted
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      value: todo.isCompleted,
                      onChanged: (newValue) {
                        viewModel.toggleTodo(index);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CountdownView extends StatelessWidget {
  const CountdownView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Text(
          'Time until todos clear: ${viewModel.calculateTimeUntilMidnight()}',
        );
      },
    );
  }
}

void _showAddTodoDialog(BuildContext context) {
  String newTodo = '';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          onChanged: (value) {
            newTodo = value;
          },
          decoration: const InputDecoration(hintText: 'Enter your todo'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (newTodo.isNotEmpty) {
                Provider.of<TodoViewModel>(context, listen: false)
                    .addTodo(newTodo);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
