import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reportya/features/units/data/models/worksite.dart';

class WorksiteRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Worksite>> fetchActive() async {
    final data = await _supabase
        .from('worksites')
        .select('id, name, location, website')
        .eq('is_active', true)
        .order('name');
    return List<Map<String, dynamic>>.from(data as List)
        .map(Worksite.fromRow)
        .toList();
  }
}
