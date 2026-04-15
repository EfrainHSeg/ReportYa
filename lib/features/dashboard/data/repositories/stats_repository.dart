import 'package:supabase_flutter/supabase_flutter.dart';

class StatsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchReports({
    required String uid,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _supabase
        .from('reports')
        .select('id, status, created_at')
        .eq('reported_by', uid)
        .gte('created_at', from.toUtc().toIso8601String())
        .lte('created_at', to.toUtc().toIso8601String());
    return List<Map<String, dynamic>>.from(data as List);
  }
}
