import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/income_model.dart';
import '../models/category_model.dart';
import 'package:flutter_gen/gen_l10n/S.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = Provider.of<CategoryModel>(context).categories;
    _selectedCategory ??= categories.isNotEmpty ? categories[0] : null;
  }

  void _addIncome(BuildContext context) {
    final amount = double.tryParse(_amountController.text);
    final description = _descriptionController.text;

    if (amount != null && _selectedCategory != null) {
      Provider.of<IncomeModel>(context, listen: false).addIncome(
        amount,
        description.isNotEmpty ? description : "",
        _selectedCategory!,
      );

      _amountController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.incomeAddedMessage ?? "Income added successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.invalidDataMessage ?? "Please enter valid data")),
      );
    }
  }

  List<dynamic> _filterIncomeHistory(List<dynamic> incomes) {
    return incomes.where((income) {
      final incomeDate = income.date;
      if (_startDate != null && incomeDate.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && incomeDate.isAfter(_endDate!)) {
        return false;
      }
      return true;
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

    if (picked != null && picked.start != null && picked.end != null) {
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
    final incomeModel = Provider.of<IncomeModel>(context);
    final filteredIncomes = _filterIncomeHistory(incomeModel.incomes);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)?.incomePageTitle ?? "Add Income"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputFields(categories),
            SizedBox(height: 20),
            _buildAddButton(context),
            SizedBox(height: 20),
            _buildTotalIncomeCard(incomeModel.totalIncome),
            SizedBox(height: 20),
            _buildFilterOptions(categories),
            SizedBox(height: 10),
            _buildDateFilterButton(context),
            SizedBox(height: 10),
            Expanded(child: _buildIncomeHistoryList(filteredIncomes)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields(List<String> categories) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.incomeAmountLabel ?? "Income Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: S.of(context)?.incomeAmountLabel ?? "Income Amount",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text(
              S.of(context)?.incomeDescriptionLabel ?? "Income Description",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: S.of(context)?.incomeDescriptionLabel ?? "Income Description",
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
        onPressed: () => _addIncome(context),
        icon: Icon(Icons.add),
        label: Text(S.of(context)?.addIncomeButton ?? "Add Income"),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildTotalIncomeCard(double totalIncome) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context)?.totalIncomeLabel ?? "Total Income",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            SizedBox(height: 10),
            Text(
              '${totalIncome.toStringAsFixed(2)} \$',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
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
        Text(
          S.of(context)?.typeAll ?? "All Income",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: _selectedCategory,
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue;
            });
          },
          items: categories.isNotEmpty
              ? categories.map<DropdownMenuItem<String>>((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList()
              : [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                S.of(context)?.noCategoriesAvailable ?? "No categories available",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildIncomeHistoryList(List<dynamic> filteredIncomes) {
    return ListView.builder(
      itemCount: filteredIncomes.length,
      itemBuilder: (context, index) {
        final income = filteredIncomes[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.arrow_downward, color: Colors.white),
            ),
            title: Text(
              '${income.amount.toStringAsFixed(2)} \$',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${income.category} - ${income.description}'),
            trailing: Text(
              S.of(context)?.transactionIncome ?? "Income",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
