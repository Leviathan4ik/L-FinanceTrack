import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expense {
  final double amount;
  final String? description;
  final String category;
  final DateTime date;

  Expense({
    required this.amount,
    required this.description,
    required this.category,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'description': description,
    'category': category,
    'date': date.toIso8601String(),
  };

  static Expense fromJson(Map<String, dynamic> json) => Expense(
    amount: json['amount'],
    description: json['description'],
    category: json['category'],
    date: DateTime.parse(json['date']),
  );
}

class ExpenseModel with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;
  double get totalExpense => _expenses.fold(0, (sum, item) => sum + item.amount);
  double get weeklyTotal => weeklyExpenses.fold(0, (sum, item) => sum + item.amount);
  double get monthlyTotal => monthlyExpenses.fold(0, (sum, item) => sum + item.amount);
  double get yearlyTotal => yearlyExpenses.fold(0, (sum, item) => sum + item.amount);

  List<Expense> get weeklyExpenses =>
      _expenses.where((expense) => _isInCurrentWeek(expense.date)).toList();

  List<Expense> get monthlyExpenses =>
      _expenses.where((expense) => _isInCurrentMonth(expense.date)).toList();

  List<Expense> get yearlyExpenses =>
      _expenses.where((expense) => _isInCurrentYear(expense.date)).toList();

  void addExpense(double amount, String description, String category) {
    final newExpense = Expense(
      amount: amount,
      description: description,
      category: category,
    );
    _expenses.add(newExpense);
    notifyListeners();
    _saveExpenses();
  }

  void _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = _expenses.map((expense) => expense.toJson()).toList();
    await prefs.setString('expenses', jsonEncode(expensesJson));
  }

  void _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesString = prefs.getString('expenses');

    if (expensesString != null) {
      final List<dynamic> expensesJson = jsonDecode(expensesString);
      _expenses = expensesJson.map((json) => Expense.fromJson(json)).toList();
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
