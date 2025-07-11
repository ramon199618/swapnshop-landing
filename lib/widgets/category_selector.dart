import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final void Function(String) onCategoryTap;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((cat) {
          final selected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              onPressed: () => onCategoryTap(cat),
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
