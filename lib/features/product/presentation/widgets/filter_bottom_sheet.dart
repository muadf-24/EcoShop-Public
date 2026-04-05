import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCategoryId;

  const FilterBottomSheet({
    super.key,
    this.initialCategoryId,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  double? _minRating;
  bool _ecoFriendlyOnly = false;
  String? _categoryId;
  String? _sortBy;
  double _maxAvailablePrice = 500;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    
    // Initialize from current state if available
    final state = context.read<ProductBloc>().state;
    if (state is ProductsLoaded) {
      // Find max price in current catalog for dynamic slider
      if (state.products.isNotEmpty) {
        _maxAvailablePrice = state.products
            .map((p) => p.price)
            .reduce((a, b) => a > b ? a : b);
        // Round up to nearest 50
        _maxAvailablePrice = ((_maxAvailablePrice / 50).ceil() * 50).toDouble();
        if (_maxAvailablePrice < 100) _maxAvailablePrice = 100;
      }

      final filters = state.currentFilters;
      if (filters != null) {
        _priceRange = RangeValues(
          filters.minPrice ?? 0,
          filters.maxPrice ?? _maxAvailablePrice,
        );
        _minRating = filters.minRating;
        _ecoFriendlyOnly = filters.ecoFriendly ?? false;
        _sortBy = filters.sortBy;
      } else {
        _priceRange = RangeValues(0, _maxAvailablePrice);
      }
    } else {
      _priceRange = const RangeValues(0, 500);
    }
  }

  void _reset() {
    setState(() {
      _priceRange = RangeValues(0, _maxAvailablePrice);
      _minRating = null;
      _ecoFriendlyOnly = false;
      _categoryId = null;
      _sortBy = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        AppTheme.spacingLg,
        MediaQuery.of(context).padding.bottom + AppTheme.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: _reset,
                child: Text('Reset', style: TextStyle(color: colorScheme.error)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Sort By
          Text('Sort By', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTheme.spacingSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSortChip('popular', 'Popular', Icons.trending_up_rounded),
                _buildSortChip('newest', 'Newest', Icons.new_releases_rounded),
                _buildSortChip('price_low', 'Price: Low-High', Icons.arrow_downward_rounded),
                _buildSortChip('price_high', 'Price: High-Low', Icons.arrow_upward_rounded),
                _buildSortChip('rating', 'Top Rated', Icons.star_rounded),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price Range', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                style: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: _maxAvailablePrice,
              divisions: (_maxAvailablePrice / 10).round(),
              onChanged: (values) => setState(() => _priceRange = values),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          
          // Rating
          Text('Minimum Rating', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [4.0, 3.0, 2.0, 1.0].map((rating) {
              final isSelected = _minRating == rating;
              return ChoiceChip(
                showCheckmark: false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded, 
                      size: 16, 
                      color: isSelected ? Colors.white : Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text('${rating.toInt()}+'),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _minRating = selected ? rating : null);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          
          // Eco-Friendly Toggle
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.eco_rounded, color: colorScheme.primary, size: 24),
                const SizedBox(width: AppTheme.spacingMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eco-Friendly Only', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text('Show only certified sustainable products', style: textTheme.labelSmall),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: _ecoFriendlyOnly,
                  activeThumbColor: colorScheme.primary,
                  activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
                  onChanged: (value) => setState(() => _ecoFriendlyOnly = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                elevation: 0,
              ),
              onPressed: () {
                context.read<ProductBloc>().add(ProductFilterRequested(
                  categoryId: _categoryId,
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  minRating: _minRating,
                  ecoFriendlyOnly: _ecoFriendlyOnly,
                  sortBy: _sortBy,
                ));
                Navigator.pop(context);
              },
              child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        showCheckmark: false,
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.onSurfaceVariant),
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _sortBy = selected ? value : null);
        },
      ),
    );
  }
}
