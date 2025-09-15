import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_card.dart';
import 'add_payment_method_page.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await paymentProvider.loadPaymentMethods(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPaymentMethodPage(),
                ),
              ).then((_) => _loadPaymentMethods());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryPink,
              ),
            );
          }

          return Column(
            children: [
              // Default Payment Methods
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طرق الدفع المتاحة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cash on Delivery
                    PaymentMethodCard(
                      icon: Icons.money,
                      title: 'الدفع عند الاستلام',
                      subtitle: 'ادفع نقداً عند وصول الطلب',
                      isDefault: true,
                      onTap: () {
                        // Already selected by default
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Stripe Payment
                    PaymentMethodCard(
                      icon: Icons.credit_card,
                      title: 'بطاقة ائتمان/خصم',
                      subtitle: 'ادفع بأمان باستخدام بطاقتك',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddPaymentMethodPage(),
                          ),
                        ).then((_) => _loadPaymentMethods());
                      },
                    ),
                  ],
                ),
              ),

              // Saved Payment Methods
              if (paymentProvider.paymentMethods.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البطاقات المحفوظة',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: paymentProvider.paymentMethods.length,
                    itemBuilder: (context, index) {
                      final paymentMethod = paymentProvider.paymentMethods[index];
                      return PaymentMethodCard(
                        icon: _getCardIcon(paymentMethod.cardType),
                        title: '**** **** **** ${paymentMethod.last4}',
                        subtitle: '${paymentMethod.cardType} • ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}',
                        isDefault: paymentMethod.isDefault,
                        onTap: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await paymentProvider.setDefaultPaymentMethod(
                            authProvider.currentUser!.id,
                            paymentMethod.id,
                          );
                        },
                        onDelete: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('حذف البطاقة'),
                              content: const Text('هل أنت متأكد من حذف هذه البطاقة؟'),
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
                            await paymentProvider.deletePaymentMethod(
                              authProvider.currentUser!.id,
                              paymentMethod.id,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 100,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد بطاقات محفوظة',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أضف بطاقة ائتمان لتسهيل عملية الدفع',
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
                                builder: (context) => const AddPaymentMethodPage(),
                              ),
                            ).then((_) => _loadPaymentMethods());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة بطاقة جديدة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPaymentMethodPage(),
            ),
          ).then((_) => _loadPaymentMethods());
        },
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}