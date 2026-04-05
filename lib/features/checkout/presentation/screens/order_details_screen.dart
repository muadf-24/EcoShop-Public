import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/order.dart' as entity;

class OrderDetailsScreen extends StatelessWidget {
  final entity.Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(context),
            const SizedBox(height: AppTheme.spacingLg),

            // Order Info
            Text('Order Date', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            Text(dateFormat.format(order.createdAt), style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppTheme.spacingLg),

            // Itemized Receipt
            _buildItemizedReceipt(context),
            const SizedBox(height: AppTheme.spacingLg),

            // Shipping & Payment
            _buildShippingAndPayment(context),
            const SizedBox(height: AppTheme.spacingLg),

            // Price Breakdown
            _buildPriceBreakdown(context),
            const SizedBox(height: AppTheme.spacingXxl),

            // Reorder Button
            CustomButton(
              text: 'Reorder All Items',
              icon: Icons.replay_rounded,
              useGradient: true,
              onPressed: () {
                for (final item in order.items) {
                  context.read<CartBloc>().add(CartItemAdded(
                    productId: item.productId,
                    productName: item.productName,
                    productImage: item.productImage,
                    price: item.price,
                  ));
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Items added back to your cart!')),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'shipped':
        statusColor = colorScheme.primary;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'cancelled':
        statusColor = colorScheme.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.history_toggle_off_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: AppTheme.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.status.toUpperCase(),
                style: textTheme.titleMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w900, letterSpacing: 1.1),
              ),
              if (order.estimatedDelivery != null && order.status.toLowerCase() != 'delivered')
                Text(
                  'Estimated Delivery: ${DateFormat('MMM dd').format(order.estimatedDelivery!)}',
                  style: textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedReceipt(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ITEMIZED RECEIPT', style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.spacingSm),
        ...order.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Image.network(item.productImage, width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)}', style: textTheme.bodySmall),
                  ],
                ),
              ),
              Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: textTheme.titleSmall),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildShippingAndPayment(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SHIPPING TO', style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(order.shippingAddress.fullName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(order.shippingAddress.street, style: textTheme.bodySmall),
              Text('${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.zipCode}', style: textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PAYMENT METHOD', style: textTheme.labelSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(order.paymentMethod, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        _buildPriceRow('Subtotal', order.subtotal, textTheme),
        _buildPriceRow('Shipping', order.shipping, textTheme),
        _buildPriceRow('Tax', order.tax, textTheme),
        if (order.discount > 0)
          _buildPriceRow('Discount', -order.discount, textTheme, isDiscount: true, colorScheme: colorScheme),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TOTAL', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, TextTheme textTheme, {bool isDiscount = false, ColorScheme? colorScheme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            '${amount < 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(
              color: isDiscount ? colorScheme?.primary : null,
              fontWeight: isDiscount ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
