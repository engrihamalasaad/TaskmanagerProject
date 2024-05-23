import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/task_repository.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/task_list_page.dart';

void main() {
  final AuthService authService = AuthService();
  final AuthRepository authRepository = AuthRepository(authService: authService);

  final ApiService apiService = ApiService();
  final TaskRepository taskRepository = TaskRepository(apiService: apiService, authRepository: authRepository);

  runApp(MyApp(authRepository: authRepository, taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TaskRepository taskRepository;

  MyApp({required this.authRepository, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(taskRepository: taskRepository)..loadTasksFromLocal(),
        ),
      ],
      child: MaterialApp(
        home: AuthCheck(authRepository: authRepository),
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  final AuthRepository authRepository;

  AuthCheck({required this.authRepository});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late Future<void> _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = Provider.of<AuthProvider>(context, listen: false).checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return authProvider.isAuthenticated ? TaskListPage() : LoginPage();
            },
          );
        }
      },
    );
  }
}
