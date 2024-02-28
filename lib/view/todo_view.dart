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
  late TodoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<TodoViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    int currentHour = DateTime.now().hour; // Get current hour
    return Scaffold(
      body: Column(
        children: [
          CountdownView(viewModel: _viewModel),
          TodoList(currentHour: currentHour), // Pass current hour
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
  const TodoList({Key? key, required this.currentHour}) : super(key: key);

  final int currentHour;

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: viewModel.todos.length,
                itemBuilder: (context, index) {
                  final todo = viewModel.todos[index];

                  return Dismissible(
                    key: Key(todo.title),
                    onDismissed: (direction) {
                      viewModel.removeTodo(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        todo.title,
                        style: todo.isCompleted ||
                                _isPastDeadline(todo.timestamp.hour)
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey) // Grey out past due tasks
                            : null,
                      ),
                      value: todo.isCompleted,
                      onChanged: _isPastDeadline(todo.timestamp.hour)
                          ? null // Disable checking for past due tasks
                          : (newValue) {
                              viewModel.toggleTodo(index);
                            },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isPastDeadline(int hour) {
    return hour >= 17 || hour < 9;
  }
}

class CountdownView extends StatelessWidget {
  final TodoViewModel viewModel; // Define the viewModel parameter

  const CountdownView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              margin: const EdgeInsets.fromLTRB(0, 80, 0, 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple, Colors.orange]),
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Completed tasks: ${viewModel.completedTasksCount}/${viewModel.todos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              // 'To dos clear at 5pm. Time left: ${viewModel.calculateTimeUntilClear()}',
              'Tasks clear at 5pm',
            ),
          ],
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
