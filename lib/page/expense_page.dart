import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import 'package:flutter_gen/gen_l10n/S.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedFilterCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = Provider.of<CategoryModel>(context).categories;
    _selectedCategory ??= categories.isNotEmpty ? categories[0] : null;
    _selectedFilterCategory = 'All'; // Фильтр "Все"
  }

  void _addExpense(BuildContext context) {
    final amount = double.tryParse(_amountController.text);
    final description = _descriptionController.text;

    if (amount != null && _selectedCategory != null) {
      Provider.of<ExpenseModel>(context, listen: false).addExpense(
        amount,
        description.isNotEmpty ? description : "",
        _selectedCategory!,
      );

      _amountController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.expenseAddedMessage ?? "Expense added successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.invalidDataMessage ?? "Please enter valid data")),
      );
    }
  }

  List<dynamic> _filterExpenseHistory(List<dynamic> expenses) {
    final now = DateTime.now();
    return expenses.where((expense) {
      final expenseDate = expense.date;
      final matchesDateRange = (_startDate == null || expenseDate.isAfter(_startDate!)) &&
          (_endDate == null || expenseDate.isBefore(_endDate!));
      final matchesCategory = _selectedFilterCategory == 'All' ||
          expense.category == _selectedFilterCategory;
      return matchesDateRange && matchesCategory;
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryModel>(context).categories;
    final expenseModel = Provider.of<ExpenseModel>(context);
    final filteredExpenses = _filterExpenseHistory(expenseModel.expenses);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)?.expensePageTitle ?? "Add Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountInputCard(categories),
            SizedBox(height: 20),
            _buildAddButton(context),
            SizedBox(height: 20),
            _buildTotalExpenseCard(expenseModel.totalExpense),
            SizedBox(height: 20),
            _buildDateFilterButton(context),
            SizedBox(height: 10),
            _buildCategoryFilterDropdown(categories),
            SizedBox(height: 20),
            Expanded(child: _buildExpenseHistoryList(filteredExpenses)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputCard(List<String> categories) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.expenseAmountLabel ?? "Expense Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: S.of(context)?.expenseAmountLabel ?? "Expense Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text(
              S.of(context)?.expenseDescriptionLabel ?? "Expense Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: S.of(context)?.expenseDescriptionLabel ?? "Expense Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: S.of(context)?.expenseCategoryLabel ?? "Category",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _addExpense(context),
        icon: Icon(Icons.add),
        label: Text(S.of(context)?.addExpenseButton ?? "Add Expense"),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTotalExpenseCard(double totalExpense) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.totalExpenseLabel ?? "Total Expense",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade900),
            ),
            SizedBox(height: 10),
            Text(
              '${totalExpense.toStringAsFixed(2)} \$',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _selectDateRange(context),
        icon: Icon(Icons.date_range),
        label: Text(S.of(context)?.filterByDate ?? "Filter by Date"),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      value: _selectedFilterCategory,
      decoration: InputDecoration(
        labelText: S.of(context)?.filterByCategory ?? "Filter by Category",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedFilterCategory = newValue;
        });
      },
      items: ['All', ...categories].map<DropdownMenuItem<String>>((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
    );
  }

  Widget _buildExpenseHistoryList(List<dynamic> filteredExpenses) {
    return ListView.builder(
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.arrow_upward, color: Colors.white),
            ),
            title: Text(
              '${expense.amount.toStringAsFixed(2)} \$',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${expense.category} - ${expense.description}'),
            trailing: Text(
              S.of(context)?.transactionExpense ?? "Expense",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
