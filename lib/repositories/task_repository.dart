import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'auth_repository.dart';

class TaskRepository {
  final ApiService apiService;
  final AuthRepository authRepository;

  TaskRepository({required this.apiService, required this.authRepository});

  static const String tasksKey = 'tasks';

  Future<List<Task>> fetchTasks(int limit, int skip) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('No token found');
    final tasks = await apiService.fetchTasks(limit, skip, token);
    await saveTasksToLocal(tasks);
    return tasks;
  }

  Future<void> addTask(Task task) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('No token found');
    await apiService.addTask(task, token);
    await saveTaskToLocal(task);
  }

  Future<void> updateTask(Task task) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('No token found');
    await apiService.updateTask(task, token);
    await updateTaskInLocal(task);
  }

  Future<void> deleteTask(int id) async {
    final token = await authRepository.getToken();
    if (token == null) throw Exception('No token found');
    await apiService.deleteTask(id, token);
    await deleteTaskFromLocal(id);
  }

  Future<void> saveTasksToLocal(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    prefs.setString(tasksKey, tasksJson);
  }

  Future<void> saveTaskToLocal(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Task> tasks = await loadTasksFromLocal() ?? [];
    tasks.add(task);
    await saveTasksToLocal(tasks);
  }

  Future<void> updateTaskInLocal(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Task> tasks = await loadTasksFromLocal() ?? [];
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await saveTasksToLocal(tasks);
    }
  }

  Future<void> deleteTaskFromLocal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Task> tasks = await loadTasksFromLocal() ?? [];
    tasks.removeWhere((t) => t.id == id);
    await saveTasksToLocal(tasks);
  }

  Future<List<Task>?> loadTasksFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(tasksKey);
    if (tasksJson != null) {
      final List<dynamic> tasksList = jsonDecode(tasksJson);
      return tasksList.map((json) => Task.fromJson(json)).toList();
    }
    return null;
  }
}
