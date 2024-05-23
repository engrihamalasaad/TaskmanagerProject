// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kk/main.dart';
import 'package:kk/repositories/auth_repository.dart';
import 'package:kk/repositories/task_repository.dart';

import 'package:kk/services/api_service.dart';
import 'package:kk/services/auth_service.dart';

void main() {
   final AuthService authService = AuthService();
  final AuthRepository authRepository = AuthRepository(authService: authService);

  final ApiService apiService = ApiService();
  final TaskRepository taskRepository = TaskRepository(apiService: apiService, authRepository: authRepository);

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget( MyApp(authRepository: authRepository,taskRepository: taskRepository,));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
