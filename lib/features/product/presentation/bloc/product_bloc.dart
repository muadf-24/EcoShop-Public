import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/filter_products_usecase.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/filter_criteria.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final FilterProductsUseCase filterProductsUseCase;
  final ProductRepository productRepository;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  ProductBloc({
    required this.getProductsUseCase,
    required this.getProductDetailsUseCase,
    required this.searchProductsUseCase,
    required this.filterProductsUseCase,
    required this.productRepository,
  }) : super(ProductInitial()) {
    on<ProductsLoadRequested>(_onLoadProducts);
    on<ProductDetailsRequested>(_onLoadDetails);
    on<ProductSearchRequested>(_onSearch, transformer: _debounceTransformer());
    on<ProductFilterRequested>(_onFilter);
    on<FeaturedProductsRequested>(_onLoadFeatured);
    on<CategoriesLoadRequested>(_onLoadCategories);
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Debounce transformer for search events
  EventTransformer<ProductSearchRequested> _debounceTransformer() {
    return (events, mapper) {
      return events
          .debounceTime(_debounceDuration)
          .asyncExpand(mapper);
    };
  }

  Future<void> _onLoadProducts(
    ProductsLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading(isLoadingMore: false));
    try {
      final products = await getProductsUseCase();
      final featured = await productRepository.getFeaturedProducts();
      final categories = await productRepository.getCategories();
      
      emit(ProductsLoaded(
        products: products,
        featuredProducts: featured,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadDetails(
    ProductDetailsRequested event,
    Emitter<ProductState> emit,
  ) async {
    // ✅ FIX: Don't show loading if we already have products loaded
    if (state is! ProductsLoaded) {
      emit(const ProductLoading());
    }
    
    try {
      final product = await getProductDetailsUseCase(event.productId);
      emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearch(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    // ✅ FIX: Show loading only for first search, not during typing
    if (event.query.isEmpty) {
      add(ProductsLoadRequested());
      return;
    }

    emit(const ProductLoading());
    try {
      final results = await searchProductsUseCase(event.query);
      emit(ProductSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onFilter(
    ProductFilterRequested event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    List<Category> categories = [];
    List<Product> featured = [];

    if (currentState is ProductsLoaded) {
      categories = currentState.categories;
      featured = currentState.featuredProducts;
    }

    emit(const ProductLoading(isLoadingMore: false));
    try {
      final products = await filterProductsUseCase(
        categoryId: event.categoryId,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        minRating: event.minRating,
        sortBy: event.sortBy,
        ecoFriendlyOnly: event.ecoFriendlyOnly,
      );

      final filters = FilterCriteria(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        categories: event.categoryId != null ? [event.categoryId!] : null,
        minRating: event.minRating,
        ecoFriendly: event.ecoFriendlyOnly,
        sortBy: event.sortBy,
      );

      emit(ProductsLoaded(
        products: products,
        featuredProducts: featured,
        categories: categories,
        currentFilter: event.categoryId,
        currentSort: event.sortBy,
        currentFilters: filters,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadFeatured(
    FeaturedProductsRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final featured = await productRepository.getFeaturedProducts();
      final currentState = state;
      
      if (currentState is ProductsLoaded) {
        emit(currentState.copyWith(featuredProducts: featured));
      } else {
        emit(ProductsLoaded(featuredProducts: featured));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    CategoriesLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await productRepository.getCategories();
      final currentState = state;
      
      if (currentState is ProductsLoaded) {
        emit(currentState.copyWith(categories: categories));
      } else {
        emit(ProductsLoaded(categories: categories));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
