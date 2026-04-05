import '../../domain/entities/product.dart';

/// Product data model with JSON serialization
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.images,
    required super.categoryId,
    required super.categoryName,
    super.rating,
    super.reviewCount,
    super.isInStock,
    super.isFeatured,
    super.isEcoFriendly,
    super.tags,
    super.specifications,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      isEcoFriendly: json['is_eco_friendly'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'images': images,
      'category_id': categoryId,
      'category_name': categoryName,
      'rating': rating,
      'review_count': reviewCount,
      'is_in_stock': isInStock,
      'is_featured': isFeatured,
      'is_eco_friendly': isEcoFriendly,
      'tags': tags,
      'specifications': specifications,
    };
  }
}
