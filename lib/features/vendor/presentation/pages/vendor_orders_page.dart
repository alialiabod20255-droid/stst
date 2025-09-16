import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/order_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../../../orders/presentation/widgets/order_card.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.currentUser!.isVendor) {
      await vendorProvider.loadVendorData(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المتجر'),
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, child) {
          if (vendorProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            );
          }

          if (vendorProvider.vendorOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا توجد طلبات',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ستظهر هنا جميع الطلبات على منتجاتك',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppTheme.primaryPink,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendorProvider.vendorOrders.length,
              itemBuilder: (context, index) {
                final order = vendorProvider.vendorOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/order-details',
                      arguments: {'orderId': order.id},
                    );
                  },
                  onCancel: null, // Vendors can't cancel orders
                );
              },
            ),
          );
        },
      ),
    );
  }
}