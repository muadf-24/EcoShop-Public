import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;
  SearchProductsUseCase(this.repository);
  Future<List<Product>> call(String query) => repository.searchProducts(query);
}
