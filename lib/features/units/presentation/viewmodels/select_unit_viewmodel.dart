import 'package:flutter/material.dart';
import 'package:reportya/features/units/data/models/worksite.dart';
import 'package:reportya/features/units/data/repositories/worksite_repository.dart';

class SelectUnitViewModel extends ChangeNotifier {
  final _repo = WorksiteRepository();

  bool loading = false;
  String? error;
  String searchQuery = '';
  String? selectedId;

  List<Worksite> _all = [];
  List<Worksite> filtered = [];

  int get total => _all.length;

  void selectUnit(String id) {
    selectedId = selectedId == id ? null : id;
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q.toLowerCase();
    filtered = _all
        .where((w) =>
            w.name.toLowerCase().contains(searchQuery) ||
            w.location.toLowerCase().contains(searchQuery))
        .toList();
    notifyListeners();
  }

  /// Devuelve lista plana con String (header) y Worksite (item)
  List<dynamic> get groupedList {
    final lima   = filtered.where((w) => w.location.toLowerCase().contains('lima')).toList();
    final others = filtered.where((w) => !w.location.toLowerCase().contains('lima')).toList();

    final result = <dynamic>[];
    if (lima.isNotEmpty) {
      result.add('LIMA');
      result.addAll(lima);
    }
    if (others.isNotEmpty) {
      result.add('OTRAS REGIONES');
      result.addAll(others);
    }
    return result;
  }

  Future<void> load() async {
    loading = true;
    error   = null;
    notifyListeners();

    try {
      _all     = await _repo.fetchActive();
      filtered = List.from(_all);

      debugPrint('[SelectUnitVM] ${_all.length} worksites cargados');
    } catch (e) {
      error = e.toString();
      debugPrint('[SelectUnitVM] error: $e');
    }

    loading = false;
    notifyListeners();
  }
}
