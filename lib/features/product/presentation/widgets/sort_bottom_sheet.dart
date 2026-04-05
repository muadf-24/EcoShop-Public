import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SortBottomSheet extends StatelessWidget {
  final String? currentSort;
  final void Function(String) onSortSelected;

  const SortBottomSheet({
    super.key,
    this.currentSort,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final options = [
      ('popular', 'Most Popular', Icons.trending_up_rounded),
      ('rating', 'Highest Rated', Icons.star_rounded),
      ('price_low', 'Price: Low to High', Icons.arrow_upward_rounded),
      ('price_high', 'Price: High to Low', Icons.arrow_downward_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort By', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTheme.spacingMd),
          ...options.map((option) {
            final isSelected = currentSort == option.$1;
            return ListTile(
              leading: Icon(option.$3),
              title: Text(option.$2),
              trailing: isSelected ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
              selected: isSelected,
              onTap: () {
                onSortSelected(option.$1);
                Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            );
          }),
        ],
      ),
    );
  }
}
