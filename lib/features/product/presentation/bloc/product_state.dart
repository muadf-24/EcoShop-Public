import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/filter_criteria.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {
  final bool isLoadingMore;
  const ProductLoading({this.isLoadingMore = false});
  @override
  List<Object?> get props => [isLoadingMore];
}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final bool hasMore;
  final String? currentFilter;
  final String? currentSort;
  final FilterCriteria? currentFilters;

  const ProductsLoaded({
    this.products = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.hasMore = false,
    this.currentFilter,
    this.currentSort,
    this.currentFilters,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Product>? featuredProducts,
    List<Category>? categories,
    bool? hasMore,
    String? currentFilter,
    String? currentSort,
    FilterCriteria? currentFilters,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      hasMore: hasMore ?? this.hasMore,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      currentFilters: currentFilters ?? (currentFilters == null ? this.currentFilters : null),
    );
  }

  @override
  List<Object?> get props => [
        products,
        featuredProducts,
        categories,
        hasMore,
        currentFilter,
        currentSort,
        currentFilters,
      ];
}

class ProductDetailsLoaded extends ProductState {
  final Product product;

  const ProductDetailsLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductSearchResults extends ProductState {
  final List<Product> results;
  final String query;

  const ProductSearchResults({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
