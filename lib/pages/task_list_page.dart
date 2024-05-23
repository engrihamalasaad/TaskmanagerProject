import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_task_page.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.loadTasksFromLocal();
    taskProvider.fetchTasks(0);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent &&
        !Provider.of<TaskProvider>(context, listen: false).isLoading) {
      Provider.of<TaskProvider>(context, listen: false).loadMoreTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: taskProvider.tasks.length + (taskProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == taskProvider.tasks.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final task = taskProvider.tasks[index];
                    return ListTile(
                      title: Text(task.todo ?? ''),
                      subtitle: Text('Completed: ${task.completed}'),
                      trailing: Checkbox(
                        value: task.completed,
                        onChanged: (bool? value) {
                          taskProvider.toggleTaskCompletion(task);
                        },
                      ),
                    );
                  },
                ),
              ),
              if (taskProvider.isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
