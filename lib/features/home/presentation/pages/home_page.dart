import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../splash/presentation/widgets/animated_background.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _bannerImages = [
    'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    'https://images.pexels.com/photos/1022385/pexels-photo-1022385.jpeg',
    'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg',
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'باقات الحب',
      'icon': Icons.favorite,
      'color': AppTheme.primaryPink,
      'image': 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    },
    {
      'name': 'باقات الزفاف',
      'icon': Icons.celebration,
      'color': AppTheme.lightPurple,
      'image': 'https://images.pexels.com/photos/1022385/pexels-photo-1022385.jpeg',
    },
    {
      'name': 'باقات التخرج',
      'icon': Icons.school,
      'color': AppTheme.accentPurple,
      'image': 'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg',
    },
    {
      'name': 'باقات المناسبات',
      'icon': Icons.cake,
      'color': AppTheme.roseGold,
      'image': 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadData() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load products without triggering setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await productsProvider.loadProducts();
    });
    
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await cartProvider.loadCart(authProvider.currentUser!.id);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    const SliverToBoxAdapter(
                      child: HomeAppBar(),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SearchBarWidget(
                          onSearch: (query) {
                            Navigator.pushNamed(
                              context,
                              '/products',
                              arguments: {'search': query},
                            );
                          },
                        ),
                      ),
                    ),

                    // Banner Carousel
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            autoPlayInterval: const Duration(seconds: 4),
                          ),
                          items: _bannerImages.map((image) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryPink.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      right: 20,
                                      child: Text(
                                        'عروض خاصة على باقات الورود',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Categories Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الفئات',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  return CategoryCard(
                                    name: category['name'],
                                    icon: category['icon'],
                                    color: category['color'],
                                    image: category['image'],
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppConfig.productsListRoute,
                                        arguments: {'category': category['name']},
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Featured Products
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المنتجات المميزة',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppConfig.productsListRoute);
                              },
                              child: Text(
                                'عرض الكل',
                                style: TextStyle(
                                  color: AppTheme.primaryPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Products Grid
                    Consumer<ProductsProvider>(
                      builder: (context, productsProvider, child) {
                        if (productsProvider.isLoading) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        final featuredProducts = productsProvider.products
                            .where((product) => product.isFeatured)
                            .take(6)
                            .toList();

                        if (featuredProducts.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.local_florist_outlined,
                                      size: 64,
                                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد منتجات مميزة حالياً',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = featuredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppConfig.productDetailsRoute,
                                      arguments: {'productId': product.id},
                                    );
                                  },
                                );
                              },
                              childCount: featuredProducts.length,
                            ),
                          ),
                        );
                      },
                    ),

                    // Bottom Spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.itemCount == 0) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, AppConfig.cartRoute);
            },
            backgroundColor: AppTheme.primaryPink,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              '${cartProvider.itemCount}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}