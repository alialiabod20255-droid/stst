import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  String _getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'Amex';
    return 'Unknown';
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text.split('/');

    final success = await paymentProvider.addPaymentMethod(
      userId: authProvider.currentUser!.id,
      cardType: _getCardType(cardNumber),
      last4: cardNumber.substring(cardNumber.length - 4),
      expiryMonth: expiry[0],
      expiryYear: expiry[1],
      holderName: _holderNameController.text.trim(),
      isDefault: _isDefault,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة طريقة الدفع بنجاح'),
          backgroundColor: AppTheme.primaryPink,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة بطاقة جديدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Card Preview
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPink,
                      AppTheme.accentPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'متجر الورود',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _getCardType(_cardNumberController.text) == 'Visa'
                                ? Icons.credit_card
                                : Icons.credit_card,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        _cardNumberController.text.isEmpty
                            ? '**** **** **** ****'
                            : _formatCardNumber(_cardNumberController.text),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _holderNameController.text.isEmpty
                                ? 'اسم حامل البطاقة'
                                : _holderNameController.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _expiryController.text.isEmpty
                                ? 'MM/YY'
                                : _expiryController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Card Number Field
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم البطاقة',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال رقم البطاقة';
                  }
                  final cleanValue = value!.replaceAll(' ', '');
                  if (cleanValue.length < 16) {
                    return 'رقم البطاقة غير صحيح';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Expiry and CVV Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال تاريخ الانتهاء';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                          return 'تنسيق غير صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال CVV';
                        }
                        if (value!.length < 3) {
                          return 'CVV غير صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Holder Name Field
              TextFormField(
                controller: _holderNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال اسم حامل البطاقة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Default Payment Method Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightPink.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طريقة الدفع الافتراضية',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'سيتم استخدام هذه البطاقة افتراضياً في الطلبات',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value;
                        });
                      },
                      activeColor: AppTheme.primaryPink,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Consumer<PaymentProvider>(
                builder: (context, paymentProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: paymentProvider.isLoading ? null : _savePaymentMethod,
                      child: paymentProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('إضافة البطاقة'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    return buffer.toString();
  }
}