import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository taskRepository;

  TaskProvider({required this.taskRepository});

  List<Task> _tasks = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks(int page) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newTasks = await taskRepository.fetchTasks(_pageSize, page * _pageSize);
      _tasks.addAll(newTasks);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      throw e;
    }
  }

  Future<void> loadMoreTasks() async {
    _currentPage++;
    await fetchTasks(_currentPage);
  }

  Future<void> addTask(Task task) async {
    try {
      await taskRepository.addTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await taskRepository.updateTask(task);
      int index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.completed = !(task.completed ?? false);
    await updateTask(task);
  }

  Future<void> deleteTask(Task task) async {
    try {
      await taskRepository.deleteTask(task.id!);
      _tasks.remove(task);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> loadTasksFromLocal() async {
    final localTasks = await taskRepository.loadTasksFromLocal();
    if (localTasks != null) {
      _tasks = localTasks;
      notifyListeners();
    }
  }
}
