import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../core/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text('Order Placed!', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Your order has been placed successfully.\nThank you for shopping sustainably! 🌿',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingXl),
                CustomButton(text: 'Continue Shopping', useGradient: true, onPressed: () => Navigator.popUntil(context, (route) => route.isFirst)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
