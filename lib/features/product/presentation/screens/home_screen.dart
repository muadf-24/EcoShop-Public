import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/helpers.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chips.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'search_screen.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../home/presentation/screens/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductsLoadRequested());
    context.read<CartBloc>().add(CartLoadRequested());
  }

  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    super.build(context); // CRITICAL: Required for AutomaticKeepAliveClientMixin
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const ProductGridShimmer();
            }

            if (state is ProductError) {
              return Center(child: Text(state.message));
            }

            if (state is ProductsLoaded) {
              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: FadeInWidget(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Helpers.getGreeting(),
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'Discover Eco 🌿',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Cart button with badge
                            BlocBuilder<CartBloc, CartState>(
                              builder: (context, cartState) {
                                final itemCount = cartState is CartLoaded
                                    ? cartState.itemCount
                                    : 0;
                                return Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // CRITICAL FIX: Navigate to Cart tab (index 2)
                                        MainScreen.of(context)?.switchToTab(2);
                                      },
                                      icon: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                        ),
                                        child: const Icon(Icons.shopping_bag_outlined),
                                      ),
                                    ),
                                    if (itemCount > 0)
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                          child: Text(
                                            '$itemCount',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: FadeInWidget(
                      delay: const Duration(milliseconds: 100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                        child: GestureDetector(
                          onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => BlocProvider.value(
                                                            value: context.read<ProductBloc>(),
                                                            child: const SearchScreen(),
                                                          ),
                                                        ),
                                                      );
                            
                          },
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                                const SizedBox(width: AppTheme.spacingSm),
                                Text(
                                  'Search sustainable products...',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),

                  // Featured Banner
                  if (state.featuredProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: FadeInWidget(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Stack(
                            children: [
                              // Decorative circles
                              Positioned(
                                right: -30,
                                top: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 30,
                                bottom: -40,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(AppTheme.spacingLg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                      ),
                                      child: Text(
                                        '🌍 Earth Week',
                                        style: textTheme.labelSmall?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Up to 30% OFF',
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'On all eco-friendly products',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () {
                                        // CRITICAL FIX: Navigate to Explore tab (index 1)
                                        MainScreen.of(context)?.switchToTab(1);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                        ),
                                        child: Text(
                                          'Shop Now',
                                          style: textTheme.labelMedium?.copyWith(
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingLg)),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                            child: Text('Categories', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          CategoryChips(
                            categories: state.categories,
                            selectedCategoryId: _selectedCategoryId,
                            onCategorySelected: (id) {
                              setState(() => _selectedCategoryId = id);
                              if (id != null) {
                                context.read<ProductBloc>().add(ProductFilterRequested(categoryId: id));
                              } else {
                                context.read<ProductBloc>().add(ProductsLoadRequested());
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),

                  // Featured Products
                  if (state.featuredProducts.isNotEmpty && _selectedCategoryId == null) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Featured', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: context.read<ProductBloc>()),
                                        BlocProvider.value(value: context.read<CartBloc>()),
                                        BlocProvider.value(value: context.read<WishlistBloc>()),
                                      ],
                                      child: const ProductListScreen(
                                        title: 'Featured Products',
                                        // Optional: Add logic to filter only featured in ProductListScreen
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                          itemCount: state.featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product = state.featuredProducts[index];
                            return Container(
                              width: 175,
                              margin: const EdgeInsets.only(right: AppTheme.spacingMd),
                              child: ProductCard(
                                product: product,
                                heroTagPrefix: 'featured_',
                                onTap: () => _navigateToDetail(context, product.id, prefix: 'featured_'),
                                onAddToCart: () => _addToCart(context, product),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingMd)),
                  ],

                  // All Products Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategoryId != null ? 'Results' : 'All Products',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${state.products.length} items',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ FIX PROD-H06: Empty state when no products found
                  if (state.products.isEmpty && _selectedCategoryId != null)
                    SliverFillRemaining(
                      child: EmptyStateWidget(
                        icon: Icons.filter_alt_off,
                        title: 'No products found',
                        subtitle: 'Try selecting a different category or clear the filter',
                        actionText: 'Clear Filter',
                        onAction: () {
                          setState(() => _selectedCategoryId = null);
                          context.read<ProductBloc>().add(ProductsLoadRequested());
                        },
                      ),
                    )
                  else
                    // Product Grid
                    SliverPadding(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: AppTheme.spacingSm,
                        mainAxisSpacing: AppTheme.spacingSm,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = state.products[index];
                          return StaggeredListItem(
                            index: index,
                            child: ProductCard(
                              product: product,
                              onTap: () => _navigateToDetail(context, product.id),
                              onAddToCart: () => _addToCart(context, product),
                            ),
                          );
                        },
                        childCount: state.products.length,
                      ),
                    ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String productId, {String? prefix}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProductBloc>()),
            BlocProvider.value(value: context.read<CartBloc>()),
          ],
          child: ProductDetailScreen(productId: productId, heroTagPrefix: prefix ?? ''),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, dynamic product) {
    context.read<CartBloc>().add(CartItemAdded(
          productId: product.id,
          productName: product.name,
          productImage: product.primaryImage,
          price: product.price,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'UNDO', onPressed: () {}),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
