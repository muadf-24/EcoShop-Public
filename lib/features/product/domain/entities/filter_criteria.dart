/// Advanced filter criteria for product search
class FilterCriteria {
  final double? minPrice;
  final double? maxPrice;
  final List<String>? categories;
  final List<String>? brands;
  final double? minRating;
  final bool? inStock;
  final bool? onSale;
  final bool? ecoFriendly;
  final String? sortBy; // price_asc, price_desc, rating, newest, popular

  const FilterCriteria({
    this.minPrice,
    this.maxPrice,
    this.categories,
    this.brands,
    this.minRating,
    this.inStock,
    this.onSale,
    this.ecoFriendly,
    this.sortBy,
  });

  FilterCriteria copyWith({
    double? minPrice,
    double? maxPrice,
    List<String>? categories,
    List<String>? brands,
    double? minRating,
    bool? inStock,
    bool? onSale,
    bool? ecoFriendly,
    String? sortBy,
  }) {
    return FilterCriteria(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      minRating: minRating ?? this.minRating,
      inStock: inStock ?? this.inStock,
      onSale: onSale ?? this.onSale,
      ecoFriendly: ecoFriendly ?? this.ecoFriendly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        (categories?.isNotEmpty ?? false) ||
        (brands?.isNotEmpty ?? false) ||
        minRating != null ||
        inStock != null ||
        onSale != null ||
        ecoFriendly != null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (categories != null) 'categories': categories,
      if (brands != null) 'brands': brands,
      if (minRating != null) 'minRating': minRating,
      if (inStock != null) 'inStock': inStock,
      if (onSale != null) 'onSale': onSale,
      if (ecoFriendly != null) 'ecoFriendly': ecoFriendly,
      if (sortBy != null) 'sortBy': sortBy,
    };
  }
}
