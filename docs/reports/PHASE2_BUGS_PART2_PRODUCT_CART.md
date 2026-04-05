# Phase 2: Bug Catalog - Product & Cart Modules

**Modules:** Product, Cart  
**Review Date:** February 24, 2026  
**Severity Levels:** CRITICAL | HIGH | MEDIUM | LOW

---

## 🔴 CRITICAL BUGS

### BUG-PROD-001: Loading State Replaces All Content
**File:** `lib/features/product/presentation/screens/home_screen.dart:46-48`  
**Severity:** CRITICAL  
**Category:** State Management Error  
**Impact:** Entire screen flashes on every product load, terrible UX

**Current Code:**
```dart
if (state is ProductLoading) {
  return const ProductGridShimmer(); // ❌ Replaces entire screen
}
```

**Issue:**
- Every product action (search, filter, load) shows full-screen shimmer
- Destroys existing UI and rebuilds from scratch
- Causes jarring flash and content jump
- User loses scroll position
- Cart badge disappears during loading

**Fix Priority:** P0 (Critical UX Issue)  
**Estimated Effort:** 3 hours

**Recommended Fix:**
```dart
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    final isInitialLoad = state is ProductLoading && 
                          previousState is! ProductsLoaded;
    
    if (isInitialLoad) {
      return const ProductGridShimmer();
    }
    
    return CustomScrollView(
      slivers: [
        // ... keep existing UI
        if (state is ProductLoading)
          SliverToBoxAdapter(
            child: LinearProgressIndicator(), // ✅ Subtle loading
          ),
        // ... rest of content
      ],
    );
  },
)
```

---

### BUG-PROD-002: Filter Loses Featured and Categories
**File:** `lib/features/product/presentation/bloc/product_bloc.dart:90`  
**Severity:** CRITICAL  
**Category:** Data Loss on Filter  
**Impact:** Filtering products removes featured items and categories from state

**Current Code:**
```dart
Future<void> _onFilter(
  ProductFilterRequested event,
  Emitter<ProductState> emit,
) async {
  emit(ProductLoading());
  try {
    final products = await filterProductsUseCase(...);
    emit(ProductsLoaded(products: products)); // ❌ Only products, no featured/categories
  } catch (e) {
    emit(ProductError(e.toString()));
  }
}
```

**Issue:**
- `ProductsLoaded` state initialized with only `products` parameter
- `featuredProducts` and `categories` default to empty lists
- UI loses featured section and category chips
- User experience severely degraded

**Fix Priority:** P0 (Critical)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
Future<void> _onFilter(
  ProductFilterRequested event,
  Emitter<ProductState> emit,
) async {
  emit(ProductLoading());
  try {
    final products = await filterProductsUseCase(...);
    
    // ✅ Preserve existing featured and categories
    final currentState = state;
    final featured = currentState is ProductsLoaded 
      ? currentState.featuredProducts 
      : await productRepository.getFeaturedProducts();
    final categories = currentState is ProductsLoaded 
      ? currentState.categories 
      : await productRepository.getCategories();
    
    emit(ProductsLoaded(
      products: products,
      featuredProducts: featured,
      categories: categories,
    ));
  } catch (e) {
    emit(ProductError(e.toString()));
  }
}
```

---

## 🟠 HIGH SEVERITY BUGS

### BUG-PROD-003: Search Results Don't Preserve Previous State
**File:** `lib/features/product/presentation/bloc/product_bloc.dart:63-74`  
**Severity:** HIGH  
**Category:** State Management  
**Impact:** Search emits new state type, breaking navigation flow

**Current Code:**
```dart
Future<void> _onSearch(
  ProductSearchRequested event,
  Emitter<ProductState> emit,
) async {
  emit(ProductLoading());
  try {
    final results = await searchProductsUseCase(event.query);
    emit(ProductSearchResults(results: results, query: event.query));
  } catch (e) {
    emit(ProductError(e.toString()));
  }
}
```

**Issue:**
- `ProductSearchResults` is separate state from `ProductsLoaded`
- UI must handle different state types
- Inconsistent with filter flow
- Navigation back from search doesn't restore previous state

**Fix Priority:** P1 (High)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
// Option 1: Use same ProductsLoaded state
emit(ProductsLoaded(
  products: results,
  searchQuery: event.query, // Add searchQuery field
));

// Option 2: Store previous state for restoration
final previousState = state;
// ... then restore on back navigation
```

---

### BUG-PROD-004: Cart Item ID Uses Timestamp - Race Condition
**File:** `lib/features/cart/presentation/bloc/cart_bloc.dart:49`  
**Severity:** HIGH  
**Category:** Race Condition / Data Integrity  
**Impact:** Duplicate cart IDs if items added quickly

**Current Code:**
```dart
final item = CartItem(
  id: 'cart_${event.productId}_${DateTime.now().millisecondsSinceEpoch}',
  productId: event.productId,
  // ...
);
```

**Issue:**
- Millisecond timestamps can collide if user taps quickly
- Multiple taps within 1ms generate same ID
- Causes cart items to overwrite each other
- Data loss for rapid users

**Fix Priority:** P1 (High)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
import 'package:uuid/uuid.dart';

final item = CartItem(
  id: const Uuid().v4(), // ✅ Guaranteed unique
  productId: event.productId,
  // ...
);
```

**Alternative:**
```dart
// Use existing product if already in cart
final existingIndex = await getCartItemsUseCase()
  .then((items) => items.indexWhere((i) => i.productId == event.productId));

if (existingIndex >= 0) {
  // Update quantity instead of creating new item
  final existing = items[existingIndex];
  await updateQuantityUseCase(existing.id, existing.quantity + event.quantity);
} else {
  // Create new item with UUID
}
```

---

### BUG-PROD-005: Cart Success State Immediately Replaced
**File:** `lib/features/cart/presentation/bloc/cart_bloc.dart:56-59`  
**Severity:** HIGH  
**Category:** State Management Logic Error  
**Impact:** Success snackbar doesn't show because state changes immediately

**Current Code:**
```dart
await addToCartUseCase(item);
emit(CartItemAddedSuccess(event.productName)); // ❌ Emitted
final items = await getCartItemsUseCase();
emit(CartLoaded(items: items)); // ❌ Immediately replaced
```

**Issue:**
- `CartItemAddedSuccess` state emitted
- Immediately followed by `CartLoaded` in same event handler
- BlocListener only sees final state
- Success message never displays

**Fix Priority:** P1 (High)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
await addToCartUseCase(item);
final items = await getCartItemsUseCase();
emit(CartLoaded(
  items: items,
  lastAddedProduct: event.productName, // ✅ Add field to state
));

// In UI:
listener: (context, state) {
  if (state is CartLoaded && state.lastAddedProduct != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${state.lastAddedProduct} added to cart')),
    );
  }
}
```

---

### BUG-PROD-006: Hardcoded Demo Message in Production
**File:** `lib/features/authentication/presentation/screens/login_screen.dart:264`  
**Severity:** HIGH  
**Category:** Development Code in Production  
**Impact:** Shows "Demo" message to real users

**Current Code:**
```dart
Text(
  'Demo: Use any email and 8+ char password',
  style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
),
```

**Issue:**
- Development hint shown in production
- Confuses users about authentication requirements
- Unprofessional appearance
- Security implication (reveals password rules)

**Fix Priority:** P1 (High)  
**Estimated Effort:** 15 minutes

**Recommended Fix:**
```dart
// Wrap in kDebugMode check
if (kDebugMode)
  Text('Demo: Use any email and 8+ char password', ...),
```

---

## 🟡 MEDIUM SEVERITY BUGS

### BUG-PROD-007: No Empty State for Filtered Products
**File:** `lib/features/product/presentation/screens/home_screen.dart`  
**Severity:** MEDIUM  
**Category:** Missing Empty State  
**Impact:** Shows empty grid when filter returns no results

**Issue:**
- Filtering can result in zero products
- UI shows empty space with no feedback
- User doesn't know if it's loading or no results
- Poor UX

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
if (state is ProductsLoaded && state.products.isEmpty && _selectedCategoryId != null) {
  SliverFillRemaining(
    child: EmptyStateWidget(
      icon: Icons.filter_alt_off,
      title: 'No products found',
      subtitle: 'Try selecting a different category',
      actionText: 'Clear Filter',
      onAction: () {
        setState(() => _selectedCategoryId = null);
        context.read<ProductBloc>().add(ProductsLoadRequested());
      },
    ),
  );
}
```

---

### BUG-PROD-008: Cart Badge Counter Uses Item Count Not Product Count
**File:** `lib/features/cart/presentation/bloc/cart_state.dart:18`  
**Severity:** MEDIUM  
**Category:** Business Logic Error  
**Impact:** Misleading cart count

**Current Code:**
```dart
int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
```

**Issue:**
- Shows total quantity, not unique products
- If user has 5x same product, badge shows "5"
- Industry standard is unique product count
- User expectation mismatch

**Example:**
- Cart: 3x Product A, 2x Product B
- Current badge: **5** items
- Expected badge: **2** items

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 30 minutes

**Recommended Fix:**
```dart
int get itemCount => items.length; // ✅ Count unique products
int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

// In UI:
Text('${state.itemCount}') // Badge shows 2
Text('Subtotal (${state.totalQuantity} items)') // Detail shows 5
```

---

### BUG-PROD-009: Product Detail Doesn't Handle Navigation Back
**File:** `lib/features/product/presentation/screens/product_detail_screen.dart:36`  
**Severity:** MEDIUM  
**Category:** State Management  
**Impact:** Navigating back from detail shows loading screen briefly

**Issue:**
- Detail screen fires `ProductDetailsRequested` on init
- Changes global ProductBloc state
- Original screen (Home/Search) now has `ProductDetailsLoaded` state
- Causes UI to show wrong content briefly

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 3 hours

**Recommended Fix:**
```dart
// Option 1: Use separate bloc for details
BlocProvider(
  create: (_) => ProductDetailBloc(getProductDetailsUseCase)
    ..add(ProductDetailsRequested(productId)),
  child: ProductDetailScreen(productId: productId),
);

// Option 2: Store previous state and restore
// (More complex, requires state stacking)
```

---

### BUG-PROD-010: Cart Doesn't Prevent Over-Max Quantity
**File:** `lib/features/cart/presentation/screens/cart_screen.dart:163-167`  
**Severity:** MEDIUM  
**Category:** Business Logic Error  
**Impact:** UI prevents adding but BLoC doesn't enforce

**Current Code:**
```dart
// UI check only
if (item.quantity < AppConstants.maxQuantityPerItem) {
  context.read<CartBloc>().add(CartItemQuantityUpdated(...));
}
```

**Issue:**
- Validation only in UI, not in BLoC
- Direct BLoC calls can bypass limit
- Inconsistent with server-side validation (Phase 1)
- Business rule not enforced in domain layer

**Fix Priority:** P2 (Medium)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
// In cart_bloc.dart
Future<void> _onUpdateQuantity(...) async {
  try {
    // ✅ Enforce business rule in BLoC
    if (event.quantity > AppConstants.maxQuantityPerItem) {
      throw Exception('Maximum quantity is ${AppConstants.maxQuantityPerItem}');
    }
    if (event.quantity < 1) {
      throw Exception('Quantity must be at least 1');
    }
    
    await updateQuantityUseCase(event.itemId, event.quantity);
    final items = await getCartItemsUseCase();
    emit(CartLoaded(items: items));
  } catch (e) {
    emit(CartError(e.toString()));
  }
}
```

---

## 🟢 LOW SEVERITY BUGS

### BUG-PROD-011: Search Input Not Debounced
**File:** `lib/features/product/presentation/screens/search_screen.dart:94`  
**Severity:** LOW  
**Category:** Performance Issue  
**Impact:** Fires search on every keystroke change

**Current Code:**
```dart
onChanged: (val) => setState(() {}), // ❌ Only updates UI
onSubmitted: _onSearch, // Only searches on submit
```

**Issue:**
- No live search as user types
- No debouncing if live search added
- Would cause performance issues with many requests

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 1 hour

**Recommended Fix:**
```dart
import 'package:rxdart/rxdart.dart';

final _searchSubject = BehaviorSubject<String>();

@override
void initState() {
  super.initState();
  _searchSubject
    .debounceTime(const Duration(milliseconds: 500))
    .distinct()
    .listen((query) {
      if (query.length >= 2) _onSearch(query);
    });
}

// In TextField
onChanged: (val) {
  setState(() {});
  _searchSubject.add(val);
},
```

---

### BUG-PROD-012: No Maximum Products Displayed Warning
**File:** `lib/features/product/presentation/screens/home_screen.dart`  
**Severity:** LOW  
**Category:** UX Issue  
**Impact:** Large product lists may cause performance issues

**Issue:**
- No pagination implemented
- All products loaded at once into memory
- Could cause performance degradation with 1000+ products
- No warning to user

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 8 hours (full pagination)

**Quick Fix (30 min):**
```dart
if (state.products.length > 100) {
  Text('Showing first 100 products. Use filters to narrow results.');
}
```

---

### BUG-PROD-013: Recent Searches Not Persisted
**File:** `lib/features/product/presentation/screens/search_screen.dart:24-29`  
**Severity:** LOW  
**Category:** Missing Feature  
**Impact:** Recent searches reset on app restart

**Current Code:**
```dart
List<String> _recentSearches = [
  'Organic Cotton',
  'Bamboo Bottle',
  // ... ❌ Hardcoded, not persisted
];
```

**Issue:**
- Recent searches are in-memory only
- Lost when screen disposed
- Not truly "recent" - just demo data

**Fix Priority:** P3 (Low)  
**Estimated Effort:** 2 hours

**Recommended Fix:**
```dart
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadRecentSearches() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
  });
}

Future<void> _saveRecentSearch(String query) async {
  final prefs = await SharedPreferences.getInstance();
  _recentSearches.insert(0, query);
  if (_recentSearches.length > 10) _recentSearches.removeLast();
  await prefs.setStringList('recent_searches', _recentSearches);
}
```

---

## Summary Statistics - Product & Cart

| Module | CRITICAL | HIGH | MEDIUM | LOW | Total |
|--------|----------|------|--------|-----|-------|
| Product | 2 | 3 | 3 | 3 | 11 |
| Cart | 0 | 3 | 2 | 0 | 5 |
| **TOTAL** | **2** | **6** | **5** | **3** | **16** |

**Effort Estimate:** 37 hours

**Next:** Checkout Module Bugs
