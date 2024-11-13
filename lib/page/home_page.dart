import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/S.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/category_model.dart';
import '../widgets/drawer_menu.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  HomePage({required this.onLocaleChange});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedPeriod = 'week';
  String _selectedType = 'all';
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final expenseModel = Provider.of<ExpenseModel>(context);
    final incomeModel = Provider.of<IncomeModel>(context);
    final categories = Provider.of<CategoryModel>(context).categories;

    List<dynamic> filteredItems = [];
    double totalAmount = 0;

    if (_selectedType == 'income') {
      filteredItems = incomeModel.incomes.where((income) {
        return _selectedCategory == 'all' || income.category == _selectedCategory;
      }).toList();
      totalAmount = incomeModel.totalIncome;
    } else if (_selectedType == 'expense') {
      filteredItems = expenseModel.expenses.where((expense) {
        return _selectedCategory == 'all' || expense.category == _selectedCategory;
      }).toList();
      totalAmount = expenseModel.totalExpense;
    } else {
      filteredItems = [
        ...incomeModel.incomes.where((income) =>
        _selectedCategory == 'all' || income.category == _selectedCategory),
        ...expenseModel.expenses.where((expense) =>
        _selectedCategory == 'all' || expense.category == _selectedCategory),
      ];
      totalAmount = incomeModel.totalIncome - expenseModel.totalExpense;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)?.appTitle ?? "Home"),
      ),
      drawer: DrawerMenu(onLocaleChange: widget.onLocaleChange),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(totalAmount, context),
            SizedBox(height: 20),
            _buildFilterOptions(categories),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isIncome = item is Income;
                  return _buildTransactionCard(item, isIncome, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double totalAmount, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.balanceLabel ?? "Баланс",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 10),
            Text(
              '${totalAmount.toStringAsFixed(2)} \$',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(List<String> categories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _selectedType,
          items: [
            DropdownMenuItem(value: 'all', child: Text(S.of(context)?.typeAll ?? "Все")),
            DropdownMenuItem(value: 'income', child: Text(S.of(context)?.typeIncome ?? "Доход")),
            DropdownMenuItem(value: 'expense', child: Text(S.of(context)?.typeExpense ?? "Расход" )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        ),
        DropdownButton<String>(
          value: _selectedCategory,
          items: [
            DropdownMenuItem(value: 'all', child: Text(S.of(context)?.categoryAll ?? "Все категории")),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        DropdownButton<String>(
          value: _selectedPeriod,
          items: [
            DropdownMenuItem(value: 'week', child: Text(S.of(context)?.periodWeek ?? "Неделя")),
            DropdownMenuItem(value: 'month', child: Text(S.of(context)?.periodMonth ?? "Месяц")),
            DropdownMenuItem(value: 'year', child: Text(S.of(context)?.periodYear ?? "Год")),
          ],
          onChanged: (value) {
            setState(() {
              _selectedPeriod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic item, bool isIncome, BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(item.date);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green : Colors.red,
          child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
        ),
        title: Text(
          '${item.amount.toStringAsFixed(2)} \$',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.category} - ${item.description}'),
            Text(formattedDate, style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: Text(
          isIncome ? S.of(context)?.transactionIncome ?? "Доход" : S.of(context)?.transactionExpense ?? "Расход",
          style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
