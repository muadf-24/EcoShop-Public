import '../entities/product.dart';
import '../entities/category.dart';

/// Product repository contract
abstract class ProductRepository {
  Future<List<Product>> getProducts({int page = 1, int limit = 20});
  Future<Product> getProductDetails(String id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> filterProducts({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? ecoFriendlyOnly,
  });
  Future<List<Product>> getFeaturedProducts();
  Future<List<Category>> getCategories();
  Future<List<Product>> getProductsByIds(List<String> ids);
}
