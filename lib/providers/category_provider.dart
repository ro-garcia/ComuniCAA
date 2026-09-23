import 'package:flutter/foundation.dart';

import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required List<CaaCategory> initialCategories})
      : _categories = List<CaaCategory>.from(initialCategories)..sort(_compare);

  final List<CaaCategory> _categories;

  List<CaaCategory> get categories => List.unmodifiable(_categories);

  List<CaaCategory> get editableCategories =>
      categories.where((category) => !category.isFilter).toList();

  CaaCategory byId(String id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => _categories.first,
    );
  }

  void updateCategory(CaaCategory updated) {
    final index =
        _categories.indexWhere((category) => category.id == updated.id);
    if (index == -1) return;

    _categories[index] = updated;
    _categories.sort(_compare);
    notifyListeners();
  }

  void reorderCategory(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _categories.length) return;
    if (newIndex < 0 || newIndex >= _categories.length) return;

    final moved = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, moved);
    for (var index = 0; index < _categories.length; index += 1) {
      final category = _categories[index];
      _categories[index] = category.copyWith(position: index + 1);
    }
    notifyListeners();
  }

  static int _compare(CaaCategory a, CaaCategory b) {
    return a.position.compareTo(b.position);
  }
}
