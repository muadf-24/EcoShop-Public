import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductEvent {}

class ProductDetailsRequested extends ProductEvent {
  final String productId;
  const ProductDetailsRequested(this.productId);
  @override
  List<Object?> get props => [productId];
}

class ProductSearchRequested extends ProductEvent {
  final String query;
  const ProductSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}

class ProductFilterRequested extends ProductEvent {
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final String? sortBy;
  final bool? ecoFriendlyOnly;

  const ProductFilterRequested({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.sortBy,
    this.ecoFriendlyOnly,
  });

  @override
  List<Object?> get props => [
    categoryId, minPrice, maxPrice, minRating, sortBy, ecoFriendlyOnly,
  ];
}

class FeaturedProductsRequested extends ProductEvent {}

class CategoriesLoadRequested extends ProductEvent {}
