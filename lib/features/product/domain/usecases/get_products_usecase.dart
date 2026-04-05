import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);
  Future<List<Product>> call({int page = 1, int limit = 20}) =>
      repository.getProducts(page: page, limit: limit);
}
