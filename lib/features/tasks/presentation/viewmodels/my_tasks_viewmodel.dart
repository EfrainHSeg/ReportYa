import 'package:flutter/material.dart';
import 'package:reportya/features/tasks/data/models/task.dart';
import 'package:reportya/features/tasks/data/repositories/tasks_repository.dart';

class MyTasksViewModel extends ChangeNotifier {
  final _repo = TasksRepository();

  bool loading = false;
  String? error;
  List<Task> tasks = [];

  Future<void> load(String uid) async {
    loading = true;
    error   = null;
    notifyListeners();
    try {
      tasks = await _repo.fetchForUser(uid);
    } catch (e) {
      error = e.toString();
      debugPrint('[MyTasksVM] error: $e');
    }
    loading = false;
    notifyListeners();
  }
}
