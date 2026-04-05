import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(String?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'checkroom': return Icons.checkroom_rounded;
      case 'home': return Icons.home_rounded;
      case 'spa': return Icons.spa_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'watch': return Icons.watch_rounded;
      case 'yard': return Icons.yard_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacingSm),
              child: FilterChip(
                selected: isSelected,
                label: const Text('All'),
                avatar: const Icon(Icons.apps_rounded, size: 18),
                onSelected: (_) => onCategorySelected(null),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.primary,
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingSm),
            child: FilterChip(
              selected: isSelected,
              label: Text(category.name),
              avatar: Icon(_getCategoryIcon(category.iconName), size: 18),
              onSelected: (_) => onCategorySelected(
                isSelected ? null : category.id,
              ),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}
