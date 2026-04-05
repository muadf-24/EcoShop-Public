import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../features/wishlist/presentation/bloc/wishlist_event.dart';

class SyncService {
  final Connectivity _connectivity;
  final CartBloc _cartBloc;
  final WishlistBloc _wishlistBloc;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);

  SyncService(this._connectivity, this._cartBloc, this._wishlistBloc) {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
      );
    } catch (e) {
      debugPrint('SyncService: Failed to initialize connectivity: $e');
      isOnline.value = true; // Assume online if we can't check
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final hasConnection = result.isNotEmpty && 
        !result.every((r) => r == ConnectivityResult.none);
    
    if (isOnline.value != hasConnection) {
      isOnline.value = hasConnection;
      debugPrint('SyncService: Connection status changed - ${hasConnection ? "Online" : "Offline"}');
      
      if (hasConnection) {
        // Trigger sync when coming back online
        unawaited(syncData());
      }
    }
  }

  Future<void> syncData() async {
    if (!isOnline.value || isSyncing.value) return;

    isSyncing.value = true;
    try {
      debugPrint('SyncService: Starting data sync (Cart/Wishlist)...');
      
      // 1. Sync Wishlist (Real-time Stream will handle most, but force a refresh)
      _wishlistBloc.add(WishlistLoadRequested());
      
      // 2. Sync Cart (Local Hive -> Firestore if logged in)
      // For now, ensure local cart is loaded after reconnection
      _cartBloc.add(CartLoadRequested());
      
      // 3. Optional: Mock heavy sync delay to show UI state if needed
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('SyncService: Data reconciliation completed');
    } catch (e) {
      debugPrint('SyncService: Sync failed - $e');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> forceSyncNow() async {
    if (!isOnline.value) {
      throw Exception('Cannot sync while offline');
    }
    await syncData();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    isOnline.dispose();
    isSyncing.dispose();
  }
}