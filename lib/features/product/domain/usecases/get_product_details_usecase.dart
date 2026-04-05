import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository repository;
  GetProductDetailsUseCase(this.repository);
  Future<Product> call(String id) => repository.getProductDetails(id);
}
