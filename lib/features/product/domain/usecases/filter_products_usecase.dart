import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FilterProductsUseCase {
  final ProductRepository repository;
  FilterProductsUseCase(this.repository);

  Future<List<Product>> call({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    bool? ecoFriendlyOnly,
  }) {
    return repository.filterProducts(
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      sortBy: sortBy,
      ecoFriendlyOnly: ecoFriendlyOnly,
    );
  }
}
