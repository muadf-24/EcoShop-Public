import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import '../../domain/usecases/watch_wishlist_usecase.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlistUseCase getWishlistUseCase;
  final AddToWishlistUseCase addToWishlistUseCase;
  final RemoveFromWishlistUseCase removeFromWishlistUseCase;
  final WatchWishlistUseCase watchWishlistUseCase;
  final WishlistRepository repository;

  StreamSubscription<List<WishlistItem>>? _wishlistSubscription;

  WishlistBloc({
    required this.getWishlistUseCase,
    required this.addToWishlistUseCase,
    required this.removeFromWishlistUseCase,
    required this.watchWishlistUseCase,
    required this.repository,
  }) : super(WishlistInitial()) {
    on<WishlistLoadRequested>(_onLoad);
    on<WishlistSubscriptionRequested>(_onSubscriptionRequested);
    on<WishlistUpdated>(_onUpdated);
    on<WishlistProductAdded>(_onAdd);
    on<WishlistProductRemoved>(_onRemove);
    on<WishlistCleared>(_onClear);
    on<WishlistToggleProduct>(_onToggle);
    
    // Auto-start wishlist sync on init
    add(WishlistSubscriptionRequested());
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }

  void _onSubscriptionRequested(
    WishlistSubscriptionRequested event,
    Emitter<WishlistState> emit,
  ) {
    emit(WishlistLoading());
    _wishlistSubscription?.cancel();
    _wishlistSubscription = watchWishlistUseCase().listen(
      (items) => add(WishlistUpdated(items)),
      onError: (e) => emit(WishlistError(e.toString())),
    );
  }

  void _onUpdated(
    WishlistUpdated event,
    Emitter<WishlistState> emit,
  ) {
    emit(WishlistLoaded(items: event.items));
  }

  Future<void> _onLoad(
    WishlistLoadRequested event,
    Emitter<WishlistState> emit,
  ) async {
    if (state is! WishlistLoaded) {
      emit(WishlistLoading());
    }
    
    try {
      final items = await getWishlistUseCase();
      emit(WishlistLoaded(items: items));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onAdd(
    WishlistProductAdded event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;
    List<WishlistItem> currentItems = [];
    
    if (currentState is WishlistLoaded) {
      currentItems = List.from(currentState.items);
    }

    try {
      // Check if already in wishlist
      final exists = currentItems.any((item) => item.productId == event.productId);
      if (exists) {
        emit(WishlistLoaded(
          items: currentItems,
          lastActionMessage: '${event.productName} is already in your wishlist',
        ));
        return;
      }

      final newItem = WishlistItem(
        id: event.productId, // Product ID as item ID
        productId: event.productId,
        productName: event.productName,
        productImage: event.productImage,
        price: event.price,
        addedAt: DateTime.now(),
      );

      // Optimistic Update
      final updatedItems = [newItem, ...currentItems];
      emit(WishlistLoaded(
        items: updatedItems,
        lastActionMessage: 'Added ${event.productName} to wishlist',
      ));

      await addToWishlistUseCase(newItem);
    } catch (e) {
      emit(WishlistError(e.toString()));
      if (currentItems.isNotEmpty) {
        emit(WishlistLoaded(items: currentItems));
      }
    }
  }

  Future<void> _onRemove(
    WishlistProductRemoved event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;
    List<WishlistItem> currentItems = [];
    
    if (currentState is WishlistLoaded) {
      currentItems = List.from(currentState.items);
      
      // Optimistic Update
      final updatedItems = currentItems.where((item) => item.productId != event.productId).toList();
      emit(WishlistLoaded(
        items: updatedItems,
        lastActionMessage: 'Removed from wishlist',
      ));
    }

    try {
      await removeFromWishlistUseCase(event.productId);
    } catch (e) {
      emit(WishlistError(e.toString()));
      if (currentItems.isNotEmpty) {
        emit(WishlistLoaded(items: currentItems));
      }
    }
  }

  Future<void> _onClear(
    WishlistCleared event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await repository.clearWishlist();
      emit(const WishlistLoaded(items: []));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onToggle(
    WishlistToggleProduct event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;
    if (currentState is WishlistLoaded) {
      if (currentState.isFavorite(event.productId)) {
        add(WishlistProductRemoved(event.productId));
      } else {
        add(WishlistProductAdded(
          productId: event.productId,
          productName: event.productName,
          productImage: event.productImage,
          price: event.price,
        ));
      }
    } else {
      // If not loaded, just add
      add(WishlistProductAdded(
        productId: event.productId,
        productName: event.productName,
        productImage: event.productImage,
        price: event.price,
      ));
    }
  }
}
