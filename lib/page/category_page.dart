import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import 'package:flutter_gen/gen_l10n/S.dart';

class CategoryPage extends StatelessWidget {
  final _categoryController = TextEditingController();

  void _addCategory(BuildContext context) {
    final category = _categoryController.text.trim();
    if (category.isNotEmpty) {
      Provider.of<CategoryModel>(context, listen: false).addCategory(category);
      _categoryController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)?.categoryAddedMessage(category) ?? "Category added")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryModel = Provider.of<CategoryModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context)?.categoryPageTitle ?? "Categories"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: S.of(context)?.newCategoryLabel ?? "New Category"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addCategory(context),
              child: Text(S.of(context)?.addCategoryButton ?? "Add category"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categoryModel.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryModel.categories[index];
                  return ListTile(
                    title: Text(category),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        categoryModel.removeCategory(category);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context)?.categoryDeletedMessage(category) ?? "Category deleted")),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
