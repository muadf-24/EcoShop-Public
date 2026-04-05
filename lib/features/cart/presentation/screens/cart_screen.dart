import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/cart_bloc.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';
import '../../../home/presentation/screens/main_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && !state.isEmpty) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text('Remove all items from your cart?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              context.read<CartBloc>().add(CartCleared());
                              Navigator.pop(context);
                            },
                            child: Text('Clear', style: TextStyle(color: colorScheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Clear', style: TextStyle(color: colorScheme.error)),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: 'Your Cart is Empty',
              subtitle: 'Looks like you haven\'t added any sustainable products yet. Start exploring!',
              actionText: 'Start Shopping',
              onAction: () {
                // CRITICAL FIX: Navigate to Home tab (index 0)
                MainScreen.of(context)?.switchToTab(0);
              },
            );
          }

          if (state is CartLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return FadeInWidget(
                        delay: Duration(milliseconds: index * 80),
                        child: Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppTheme.spacingLg),
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            context.read<CartBloc>().add(CartItemRemoved(item.id));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                            padding: const EdgeInsets.all(AppTheme.spacingSm),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  child: CachedNetworkImage(
                                    imageUrl: item.productImage,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 80,
                                      height: 80,
                                      color: colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingMd),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(Formatters.currency(item.price), style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                // Quantity
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            context.read<CartBloc>().add(CartItemQuantityUpdated(itemId: item.id, quantity: item.quantity - 1));
                                          } else {
                                            context.read<CartBloc>().add(CartItemRemoved(item.id));
                                          }
                                        },
                                      ),
                                      Text('${item.quantity}', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        onPressed: () {
                                          if (item.quantity < AppConstants.maxQuantityPerItem) {
                                            context.read<CartBloc>().add(CartItemQuantityUpdated(itemId: item.id, quantity: item.quantity + 1));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Cart Summary
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal (${state.itemCount} items)', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(Formatters.currency(state.subtotal), style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Shipping', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                            Text(
                              state.subtotal >= AppConstants.freeShippingThreshold ? 'FREE' : Formatters.currency(AppConstants.shippingCost),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: state.subtotal >= AppConstants.freeShippingThreshold ? AppColors.success : null,
                              ),
                            ),
                          ],
                        ),
                        if (state.subtotal < AppConstants.freeShippingThreshold)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Icon(Icons.local_shipping_outlined, size: 16, color: colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Add ${Formatters.currency(AppConstants.freeShippingThreshold - state.subtotal)} more for free shipping',
                                  style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            Text(
                              Formatters.currency(state.subtotal + (state.subtotal >= AppConstants.freeShippingThreshold ? 0 : AppConstants.shippingCost)),
                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        CustomButton(
                          text: 'Proceed to Checkout',
                          useGradient: true,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
