import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/addresses_provider.dart';
import '../widgets/address_card.dart';
import 'add_address_page.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressesProvider = Provider.of<AddressesProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await addressesProvider.loadAddresses(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عناوين التوصيل'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAddressPage(),
                ),
              ).then((_) => _loadAddresses());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<AddressesProvider>(
        builder: (context, addressesProvider, child) {
          if (addressesProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            );
          }

          if (addressesProvider.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد عناوين محفوظة',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف عنوان جديد لتسهيل عملية التوصيل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddAddressPage(),
                        ),
                      ).then((_) => _loadAddresses());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة عنوان جديد'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            color: AppTheme.primaryPink,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressesProvider.addresses.length,
              itemBuilder: (context, index) {
                final address = addressesProvider.addresses[index];
                return AddressCard(
                  address: address,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAddressPage(address: address),
                      ),
                    ).then((_) => _loadAddresses());
                  },
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('حذف العنوان'),
                        content: const Text('هل أنت متأكد من حذف هذا العنوان؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await addressesProvider.deleteAddress(
                        authProvider.currentUser!.id,
                        address.id,
                      );
                    }
                  },
                  onSetDefault: () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    await addressesProvider.setDefaultAddress(
                      authProvider.currentUser!.id,
                      address.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAddressPage(),
            ),
          ).then((_) => _loadAddresses());
        },
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}