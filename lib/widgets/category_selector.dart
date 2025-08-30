import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String>? categories;
  final String selectedCategory;
  final void Function(String)? onCategoryTap;
  final void Function(String)? onCategoryChanged;

  const CategorySelector({
    super.key,
    this.categories,
    required this.selectedCategory,
    this.onCategoryTap,
    this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final defaultCategories = ['Alle', 'Swap', 'Give away', 'Sell'];
    final categoryList = categories ?? defaultCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categoryList.map((cat) {
          final selected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              onPressed: () {
                onCategoryTap?.call(cat);
                onCategoryChanged?.call(cat);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: selected ? AppColors.accent : Colors.grey[200],
                foregroundColor: selected ? Colors.white : Colors.black,
              ),
              child: Text(cat),
            ),
          );
        }).toList(),
      ),
    );
  }
}
