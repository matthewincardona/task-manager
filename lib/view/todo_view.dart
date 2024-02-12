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
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Your todo list here
              Container(
                margin: const EdgeInsets.all(18.0),
                padding: const EdgeInsets.fromLTRB(
                    10.0, 15.0, 10.0, 15.0), // Adjust margin as needed
                decoration: BoxDecoration(
                  color: Colors.white, // Set background color to white
                  borderRadius: BorderRadius.circular(8.0), // Round corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                      height: 350), // Fixed height for the todo list
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: 350, // Fixed height for the todo list
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
                              setState(() {
                                viewModel.toggleTodo(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Countdown view
              Text(
                'Time until todos clear: ${viewModel.calculateTimeUntilMidnight().toString()}',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
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
}
