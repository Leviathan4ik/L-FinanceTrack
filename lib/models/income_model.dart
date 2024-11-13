import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Income {
  final double amount;
  final String? description;
  final String category; // Новое поле для категории
  final DateTime date;

  Income({
    required this.amount,
    required this.description,
    required this.category, // Категория как обязательный параметр
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'description': description,
    'category': category, // Сохранение категории
    'date': date.toIso8601String(),
  };

  static Income fromJson(Map<String, dynamic> json) => Income(
    amount: json['amount'],
    description: json['description'],
    category: json['category'],
    date: DateTime.parse(json['date']),
  );
}

class IncomeModel with ChangeNotifier {
  List<Income> _incomes = [];

  List<Income> get incomes => _incomes;
  double get totalIncome => _incomes.fold(0, (sum, item) => sum + item.amount);
  double get weeklyTotal => weeklyIncomes.fold(0, (sum, item) => sum + item.amount);
  double get monthlyTotal => monthlyIncomes.fold(0, (sum, item) => sum + item.amount);
  double get yearlyTotal => yearlyIncomes.fold(0, (sum, item) => sum + item.amount);

  List<Income> get weeklyIncomes => _incomes.where((income) => _isInCurrentWeek(income.date)).toList();
  List<Income> get monthlyIncomes => _incomes.where((income) => _isInCurrentMonth(income.date)).toList();
  List<Income> get yearlyIncomes => _incomes.where((income) => _isInCurrentYear(income.date)).toList();

  void addIncome(double amount, String description, String category) {
    final newIncome = Income(
      amount: amount,
      description: description,
      category: category,
    );
    _incomes.add(newIncome);
    notifyListeners();
    _saveIncomes();
  }

  void _saveIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = _incomes.map((income) => income.toJson()).toList();
    await prefs.setString('incomes', jsonEncode(incomesJson));
  }

  void _loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesString = prefs.getString('incomes');

    if (incomesString != null) {
      final List<dynamic> incomesJson = jsonDecode(incomesString);
      _incomes = incomesJson.map((json) => Income.fromJson(json)).toList();
      notifyListeners();
    }
  }

  bool _isInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  bool _isInCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  bool _isInCurrentYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }
}
