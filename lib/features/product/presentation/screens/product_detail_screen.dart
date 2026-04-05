import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_event.dart';
import '../../../wishlist/presentation/bloc/wishlist_state.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../widgets/product_image_carousel.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String heroTagPrefix;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroTagPrefix = '',
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductDetailsRequested(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(child: Text(state.message));
          }

          if (state is ProductDetailsLoaded) {
            final product = state.product;
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── Sliver App Bar with Carousel ──────────────────────────
                SliverAppBar(
                  expandedHeight: 450,
                  pinned: true,
                  stretch: true,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, 
                          size: 18, color: colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                        child: BlocBuilder<WishlistBloc, WishlistState>(
                          builder: (context, state) {
                            final isFavorite = state is WishlistLoaded && state.isFavorite(widget.productId);
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite_rounded : Iconsax.heart, 
                                size: 20, 
                                color: isFavorite ? AppColors.error : colorScheme.onSurface,
                              ),
                              onPressed: () {
                                context.read<WishlistBloc>().add(WishlistToggleProduct(
                                  productId: product.id,
                                  productName: product.name,
                                  productImage: product.primaryImage,
                                  price: product.price,
                                ));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                        child: IconButton(
                          icon: Icon(Iconsax.share, size: 20, color: colorScheme.onSurface),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share feature coming soon!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImageCarousel(
                      images: product.images,
                      heroTag: '${widget.heroTagPrefix}product_${product.id}',
                    ),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                  ),
                ),

                // ─── Product Content ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: FadeInWidget(
                    duration: const Duration(milliseconds: 800),
                    slideOffset: const Offset(0, 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category & Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  product.categoryName.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (product.isEcoFriendly)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    border: Border.all(
                                      color: AppColors.success.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.eco_rounded, 
                                        size: 14, color: AppColors.primaryGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ECO-CERTIFIED',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingMd),

                          // Name & Rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, size: 20, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating}',
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${product.reviewCount} Reviews)',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingLg),

                          // Price Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                Formatters.currency(product.price),
                                style: textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 12),
                                Text(
                                  Formatters.currency(product.originalPrice!),
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    Formatters.discount(product.discountPercentage),
                                    style: textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Description
                          Text(
                            'The Story',
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            product.description,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Specifications
                          if (product.specifications != null) ...[
                            Text(
                              'Product Specs',
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              ),
                              child: Column(
                                children: product.specifications!.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.key,
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            entry.value,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 120), // Bottom padding for sticky bar
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      bottomSheet: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductDetailsLoaded) {
            final product = state.product;
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    BlocBuilder<WishlistBloc, WishlistState>(
                      builder: (context, state) {
                        final isFavorite = state is WishlistLoaded && state.isFavorite(product.id);
                        return BounceTap(
                          onTap: () {
                            context.read<WishlistBloc>().add(WishlistToggleProduct(
                              productId: product.id,
                              productName: product.name,
                              productImage: product.primaryImage,
                              price: product.price,
                            ));
                          },
                          child: Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: isFavorite ? colorScheme.error.withValues(alpha: 0.1) : null,
                              border: Border.all(
                                color: isFavorite ? colorScheme.error.withValues(alpha: 0.3) : colorScheme.outline.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite_rounded : Iconsax.heart, 
                              color: isFavorite ? colorScheme.error : colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: CustomButton(
                        text: 'Add to Cart',
                        onPressed: () {
                          context.read<CartBloc>().add(CartItemAdded(
                            productId: product.id,
                            productName: product.name,
                            productImage: product.primaryImage,
                            price: product.price,
                          ));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        icon: Iconsax.shopping_cart,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
