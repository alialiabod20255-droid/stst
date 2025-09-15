import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/addresses_provider.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: AppTheme.primaryPink, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    address.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'افتراضي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Address
            Text(
              address.address,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 4),

            // City
            Text(
              address.city,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 4),

            // Phone
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  address.phone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                if (!address.isDefault)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSetDefault,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryPink),
                      ),
                      child: Text(
                        'تعيين كافتراضي',
                        style: TextStyle(color: AppTheme.primaryPink),
                      ),
                    ),
                  ),
                if (!address.isDefault) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    child: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}