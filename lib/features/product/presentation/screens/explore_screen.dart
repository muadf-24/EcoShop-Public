import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'product_list_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final categories = state is ProductsLoaded ? state.categories : [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collections',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _ExploreTile(
                      icon: Icons.local_offer_rounded,
                      label: 'Deals',
                      color: const Color(0xFFD62828),
                      onTap: () {
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
                                title: 'Hot Deals',
                                initialFilter: ProductFilterRequested(sortBy: 'price_low'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _ExploreTile(
                      icon: Icons.eco_rounded,
                      label: 'Eco Certified',
                      color: const Color(0xFF2D6A4F),
                      onTap: () {
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
                                title: 'Eco Certified',
                                initialFilter: ProductFilterRequested(ecoFriendlyOnly: true),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _ExploreTile(
                      icon: Icons.new_releases_rounded,
                      label: 'New Arrivals',
                      color: const Color(0xFF4895EF),
                      onTap: () {
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
                                title: 'New Arrivals',
                                initialFilter: ProductFilterRequested(sortBy: 'newest'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _ExploreTile(
                      icon: Icons.star_rounded,
                      label: 'Best Sellers',
                      color: const Color(0xFFFFB703),
                      onTap: () {
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
                                title: 'Best Sellers',
                                initialFilter: ProductFilterRequested(sortBy: 'popular'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXl),
                Text(
                  'Categories',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                if (categories.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingMd),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return FadeInWidget(
                        delay: Duration(milliseconds: 100 * index),
                        child: _CategoryListTile(
                          name: category.name,
                          count: category.productCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: context.read<ProductBloc>()),
                                    BlocProvider.value(value: context.read<CartBloc>()),
                                    BlocProvider.value(value: context.read<WishlistBloc>()),
                                  ],
                                  child: ProductListScreen(title: category.name, categoryId: category.id),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExploreTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback onTap;

  const _CategoryListTile({
    required this.name,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$count Products', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
