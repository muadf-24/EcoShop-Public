import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../wishlist/presentation/bloc/wishlist_bloc.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final ProductFilterRequested? initialFilter;

  const ProductListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.initialFilter,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null) {
      context.read<ProductBloc>().add(widget.initialFilter!);
    } else if (widget.categoryId != null) {
      context.read<ProductBloc>().add(ProductFilterRequested(categoryId: widget.categoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No products found in this category.'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppTheme.spacingSm,
                mainAxisSpacing: AppTheme.spacingSm,
              ),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return StaggeredListItem(
                  index: index,
                  child: ProductCard(
                    product: product,
                    heroTagPrefix: 'list_',
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
                            child: ProductDetailScreen(
                              productId: product.id,
                              heroTagPrefix: 'list_',
                            ),
                          ),
                        ),
                      );
                    },
                    onAddToCart: () {
                      context.read<CartBloc>().add(CartItemAdded(
                        productId: product.id,
                        productName: product.name,
                        productImage: product.primaryImage,
                        price: product.price,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.name} added to cart')),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
