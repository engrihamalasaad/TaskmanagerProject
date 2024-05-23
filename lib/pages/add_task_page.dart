import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class AddTaskPage extends StatelessWidget {
  final TextEditingController _todoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _todoController,
              decoration: InputDecoration(labelText: 'Todo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String? todo = _todoController.text;

                if (todo != null && todo.isNotEmpty) {
                  final newTask = Task(
                    id: null, 
                    todo: todo,
                    completed: false, 
                    userId: 1,
                  );
                  try {
                    await Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add task')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Todo cannot be empty')));
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
