import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: Formatters.currency(subtotal), textTheme: textTheme, colorScheme: colorScheme),
          _SummaryRow(label: 'Shipping', value: shipping == 0 ? 'FREE' : Formatters.currency(shipping), textTheme: textTheme, colorScheme: colorScheme),
          _SummaryRow(label: 'Tax', value: Formatters.currency(tax), textTheme: textTheme, colorScheme: colorScheme),
          const Divider(),
          _SummaryRow(label: 'Total', value: Formatters.currency(total), textTheme: textTheme, colorScheme: colorScheme, isBold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700) : textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
          Text(value, style: isBold ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.primary) : textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
