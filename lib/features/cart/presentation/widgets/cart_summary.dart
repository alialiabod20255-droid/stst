import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Details
          _buildSummaryRow('المجموع الفرعي', subtotal, theme),
          const SizedBox(height: 8),
          _buildSummaryRow('الضريبة (15%)', tax, theme),
          const SizedBox(height: 8),
          _buildSummaryRow(
            shipping == 0 ? 'الشحن (مجاني)' : 'الشحن', 
            shipping, 
            theme,
            isShipping: true,
          ),
          
          const Divider(height: 24),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total.toInt()} ر.س',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Checkout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إتمام الطلب',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          // Free Shipping Notice
          if (subtotal < 200)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'أضف ${(200 - subtotal).toInt()} ر.س للحصول على شحن مجاني',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme, {bool isShipping = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge,
        ),
        Text(
          isShipping && amount == 0 
              ? 'مجاني'
              : '${amount.toInt()} ر.س',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isShipping && amount == 0 
                ? Colors.green
                : null,
          ),
        ),
      ],
    );
  }
}