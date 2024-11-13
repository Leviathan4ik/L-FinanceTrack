import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryModel with ChangeNotifier {
  List<String> _categories = ['Products', 'Medicines', 'Rent', 'Transport', 'Entertainment', 'Salaries'];

  List<String> get categories => _categories;

  CategoryModel() {
    _loadCategories();
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
      _saveCategories();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    notifyListeners();
    _saveCategories();
  }

  void _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('categories', jsonEncode(_categories));
  }

  void _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString('categories');

    if (categoriesString != null) {
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      _categories = categoriesJson.cast<String>().toList();
      notifyListeners();
    }
  }
}
