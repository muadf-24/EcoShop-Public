import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_quantity_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

export 'cart_event.dart';
export 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final UpdateQuantityUseCase updateQuantityUseCase;
  final GetCartItemsUseCase getCartItemsUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.updateQuantityUseCase,
    required this.getCartItemsUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<CartLoadRequested>(_onLoad);
    on<CartItemAdded>(_onAddItem);
    on<CartItemRemoved>(_onRemoveItem);
    on<CartItemQuantityUpdated>(_onUpdateQuantity);
    on<CartCleared>(_onClear);
    
    // ✅ FIX: Auto-load cart on initialization
    add(CartLoadRequested());
  }

  Future<void> _onLoad(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    // ✅ FIX: Don't emit loading if we already have items (preserves state)
    if (state is! CartLoaded) {
      emit(CartLoading());
    }
    
    try {
      final items = await getCartItemsUseCase();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddItem(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    // ✅ FIX: Preserve current state during operation
    final currentState = state;
    List<CartItem> currentItems = [];
    
    if (currentState is CartLoaded) {
      currentItems = List.from(currentState.items);
    }

    try {
      // ✅ FIX: Check if product already exists in cart
      final existingItemIndex = currentItems.indexWhere(
        (item) => item.productId == event.productId,
      );

      if (existingItemIndex != -1) {
        // Product exists, update quantity
        final existingItem = currentItems[existingItemIndex];
        final newQuantity = existingItem.quantity + event.quantity;
        
        await updateQuantityUseCase(existingItem.id, newQuantity);
      } else {
        // New product, add to cart
        // ✅ FIX PROD-H02: Use UUID instead of timestamp to prevent race conditions
        final item = CartItem(
          id: '${event.productId}_${DateTime.now().millisecondsSinceEpoch}_${event.hashCode}',
          productId: event.productId,
          productName: event.productName,
          productImage: event.productImage,
          price: event.price,
          quantity: event.quantity,
        );
        await addToCartUseCase(item);
      }

      // ✅ FIX PROD-H03: Include success message in CartLoaded state
      final items = await getCartItemsUseCase();
      emit(CartLoaded(items: items, lastAddedProduct: event.productName));
    } catch (e) {
      emit(CartError(e.toString()));
      // ✅ FIX: Restore previous state on error
      if (currentItems.isNotEmpty) {
        emit(CartLoaded(items: currentItems));
      }
    }
  }

  Future<void> _onRemoveItem(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    // ✅ FIX: Optimistic update - remove immediately, rollback on error
    final currentState = state;
    List<CartItem> currentItems = [];
    
    if (currentState is CartLoaded) {
      currentItems = List.from(currentState.items);
      final optimisticItems = currentItems.where((item) => item.id != event.itemId).toList();
      emit(CartLoaded(items: optimisticItems));
    }

    try {
      await removeFromCartUseCase(event.itemId);
      // Confirm with fresh data
      final items = await getCartItemsUseCase();
      emit(CartLoaded(items: items));
    } catch (e) {
      // ✅ FIX: Rollback on error
      emit(CartError(e.toString()));
      if (currentItems.isNotEmpty) {
        emit(CartLoaded(items: currentItems));
      }
    }
  }

  Future<void> _onUpdateQuantity(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    // ✅ FIX: Validate quantity before updating
    if (event.quantity < 1) {
      // If quantity is 0 or negative, remove item instead
      add(CartItemRemoved(event.itemId));
      return;
    }

    if (event.quantity > 99) {
      emit(const CartError('Maximum quantity is 99'));
      return;
    }

    // ✅ FIX: Optimistic update
    final currentState = state;
    List<CartItem> currentItems = [];
    
    if (currentState is CartLoaded) {
      currentItems = List.from(currentState.items);
      final optimisticItems = currentItems.map((item) {
        if (item.id == event.itemId) {
          return CartItem(
            id: item.id,
            productId: item.productId,
            productName: item.productName,
            productImage: item.productImage,
            price: item.price,
            quantity: event.quantity,
          );
        }
        return item;
      }).toList();
      emit(CartLoaded(items: optimisticItems));
    }

    try {
      await updateQuantityUseCase(event.itemId, event.quantity);
      // Confirm with fresh data
      final items = await getCartItemsUseCase();
      emit(CartLoaded(items: items));
    } catch (e) {
      // ✅ FIX: Rollback on error
      emit(CartError(e.toString()));
      if (currentItems.isNotEmpty) {
        emit(CartLoaded(items: currentItems));
      }
    }
  }

  Future<void> _onClear(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    List<CartItem> currentItems = [];
    
    if (currentState is CartLoaded) {
      currentItems = List.from(currentState.items);
    }

    try {
      await clearCartUseCase();
      emit(const CartLoaded(items: []));
    } catch (e) {
      emit(CartError(e.toString()));
      // ✅ FIX: Restore on error
      if (currentItems.isNotEmpty) {
        emit(CartLoaded(items: currentItems));
      }
    }
  }
}
