import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final bool isFeatured;
  final bool isEcoFriendly;
  final List<String> tags;
  final Map<String, String>? specifications;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    this.rating = 0,
    this.reviewCount = 0,
    this.isInStock = true,
    this.isFeatured = false,
    this.isEcoFriendly = false,
    this.tags = const [],
    this.specifications,
  });

  double get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  String get primaryImage => images.isNotEmpty ? images.first : '';

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    double? rating,
    int? reviewCount,
    bool? isInStock,
    bool? isFeatured,
    bool? isEcoFriendly,
    List<String>? tags,
    Map<String, String>? specifications,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isInStock: isInStock ?? this.isInStock,
      isFeatured: isFeatured ?? this.isFeatured,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, price, originalPrice, images,
        categoryId, categoryName, rating, reviewCount,
        isInStock, isFeatured, isEcoFriendly, tags, specifications,
      ];
}
