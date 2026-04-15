import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reportya/features/tasks/data/models/task.dart';

class TasksRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Task>> fetchForUser(String uid) async {
    final data = await _supabase
        .from('tasks')
        .select('*, profiles!assigned_to(full_name)')
        .or('assigned_to.eq.$uid,created_by.eq.$uid')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data as List)
        .map(Task.fromRow)
        .toList();
  }
}
