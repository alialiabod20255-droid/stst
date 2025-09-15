import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _discountController = TextEditingController();

  String _selectedCategory = 'باقات الحب';
  bool _isFeatured = false;
  List<String> _images = [];
  List<String> _sizes = [];
  List<String> _colors = [];
  List<String> _tags = [];

  final List<String> _categories = [
    'باقات الحب',
    'باقات الزفاف',
    'باقات التخرج',
    'باقات المناسبات',
  ];

  final List<String> _availableSizes = [
    'صغير',
    'متوسط',
    'كبير',
    'كبير جداً',
  ];

  final List<String> _availableColors = [
    'أحمر',
    'أبيض',
    'وردي',
    'أصفر',
    'بنفسجي',
    'برتقالي',
    'متعدد الألوان',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || !authProvider.currentUser!.isVendor) {
      return;
    }

    // Add default image if no images provided
    if (_images.isEmpty) {
      _images.add('https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg');
    }

    final success = await vendorProvider.addProduct(
      vendorId: authProvider.currentUser!.id,
      vendorName: authProvider.currentUser!.fullName,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      images: _images,
      category: _selectedCategory,
      stock: int.parse(_stockController.text),
      sizes: _sizes,
      colors: _colors,
      tags: _tags,
      isFeatured: _isFeatured,
      discount: _discountController.text.isEmpty 
          ? null 
          : double.parse(_discountController.text),
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إضافة المنتج بنجاح'),
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
        title: const Text('إضافة منتج جديد'),
        actions: [
          Consumer<VendorProvider>(
            builder: (context, vendorProvider, child) {
              return TextButton(
                onPressed: vendorProvider.isLoading ? null : _addProduct,
                child: Text(
                  'حفظ',
                  style: TextStyle(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images
              Text(
                'صور المنتج',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _images.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'إضافة صور المنتج',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () {
                                  // Add default image for demo
                                  setState(() {
                                    _images.add('https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg');
                                  });
                                },
                                child: const Text('إضافة صورة تجريبية'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _images.length) {
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // Add more images
                                  setState(() {
                                    _images.add('https://images.pexels.com/photos/1022385/pexels-photo-1022385.jpeg');
                                  });
                                },
                                icon: const Icon(Icons.add),
                              ),
                            );
                          }
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _images[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المنتج',
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال اسم المنتج';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المنتج',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال وصف المنتج';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price and Stock
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر (ر.س)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال السعر';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'سعر غير صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'الكمية المتاحة',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'يرجى إدخال الكمية';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'كمية غير صحيحة';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Discount
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  labelText: 'نسبة الخصم (اختياري)',
                  prefixIcon: Icon(Icons.percent),
                  hintText: 'مثال: 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final discount = double.tryParse(value);
                    if (discount == null || discount < 0 || discount > 100) {
                      return 'نسبة خصم غير صحيحة (0-100)';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Sizes
              Text(
                'الأحجام المتاحة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableSizes.map((size) {
                  final isSelected = _sizes.contains(size);
                  return FilterChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _sizes.add(size);
                        } else {
                          _sizes.remove(size);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryPink.withOpacity(0.3),
                    checkmarkColor: AppTheme.primaryPink,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Colors
              Text(
                'الألوان المتاحة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  final isSelected = _colors.contains(color);
                  return FilterChip(
                    label: Text(color),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _colors.add(color);
                        } else {
                          _colors.remove(color);
                        }
                      });
                    },
                    selectedColor: AppTheme.accentPurple.withOpacity(0.3),
                    checkmarkColor: AppTheme.accentPurple,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Featured Product
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
                      Icons.star_outline,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'منتج مميز',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'سيظهر في قسم المنتجات المميزة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value;
                        });
                      },
                      activeColor: AppTheme.primaryPink,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Add Product Button
              Consumer<VendorProvider>(
                builder: (context, vendorProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vendorProvider.isLoading ? null : _addProduct,
                      child: vendorProvider.isLoading
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
                          : const Text('إضافة المنتج'),
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
}