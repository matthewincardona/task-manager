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
    return Scaffold(
      body: Column(
        children: [
          const TodoList(),
          CountdownView(
              viewModel: _viewModel), // Pass the view model to the widget
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
  const TodoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          margin: const EdgeInsets.fromLTRB(20, 80, 20, 20),
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.blueAccent),
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
                    return Dismissible(
                      key: Key(todo.title), // Use unique key for each todo
                      onDismissed: (direction) {
                        viewModel
                            .removeTodo(index); // Remove todo from the list
                      },
                      background: Container(
                        color: Colors
                            .red, // Background color when swiping to delete
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: CheckboxListTile(
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
                      ),
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
  final TodoViewModel viewModel; // Define the viewModel parameter

  const CountdownView({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Completed tasks: ${viewModel.completedTasksCount}/${viewModel.todos.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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
