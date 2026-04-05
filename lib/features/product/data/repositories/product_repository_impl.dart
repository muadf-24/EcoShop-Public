import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Product>> getProducts({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final products = localDataSource.getProducts();
    final start = (page - 1) * limit;
    if (start >= products.length) return [];
    final end = (start + limit).clamp(0, products.length);
    return products.sublist(start, end);
  }

  @override
  Future<Product> getProductDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return localDataSource.getProducts().firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return localDataSource.getProducts().where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q)) ||
          p.categoryName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<Product>> filterProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? ecoFriendlyOnly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    var products = localDataSource.getProducts().toList();

    if (categoryId != null) {
      products = products.where((p) => p.categoryId == categoryId).toList();
    }
    if (minPrice != null) {
      products = products.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      products = products.where((p) => p.price <= maxPrice).toList();
    }
    if (minRating != null) {
      products = products.where((p) => p.rating >= minRating).toList();
    }
    if (ecoFriendlyOnly == true) {
      products = products.where((p) => p.isEcoFriendly).toList();
    }

    switch (sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popular':
        products.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return products;
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return localDataSource.getProducts().where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return localDataSource.getCategories();
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return localDataSource.getProducts().where((p) => ids.contains(p.id)).toList();
  }
}
