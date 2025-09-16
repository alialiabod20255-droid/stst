import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'يرجى تسجيل الدخول',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppConfig.loginRoute);
                    },
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                ProfileHeader(user: authProvider.currentUser!),

                const SizedBox(height: 24),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Account Section
                      _buildSectionTitle('الحساب', theme),
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'تعديل الملف الشخصي',
                        onTap: () {
                          Navigator.pushNamed(context, '/edit-profile');
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        title: l10n.addresses,
                        onTap: () {
                          Navigator.pushNamed(context, '/addresses');
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.payment_outlined,
                        title: l10n.paymentMethods,
                        onTap: () {
                          Navigator.pushNamed(context, '/payment-methods');
                        },
                      ),

                      const SizedBox(height: 24),

                      // Orders Section
                      _buildSectionTitle('الطلبات', theme),
                      ProfileMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.orders,
                        onTap: () {
                          Navigator.pushNamed(context, AppConfig.ordersRoute);
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.favorite_outline,
                        title: 'المفضلة',
                        onTap: () {
                          Navigator.pushNamed(context, '/favorites');
                        },
                      ),

                      const SizedBox(height: 24),

                      // Settings Section
                      _buildSectionTitle(l10n.settings, theme),
                      ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        title: l10n.notifications,
                        onTap: () {
                          Navigator.pushNamed(context, AppConfig.notificationSettingsRoute);
                        },
                      ),
                      Consumer<LocaleProvider>(
                        builder: (context, localeProvider, child) {
                          return ProfileMenuItem(
                            icon: Icons.language_outlined,
                            title: l10n.language,
                            subtitle: localeProvider.isArabic ? 'العربية' : 'English',
                            onTap: () {
                              localeProvider.toggleLocale();
                            },
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'المساعدة والدعم',
                        onTap: () {
                          Navigator.pushNamed(context, AppConfig.helpRoute);
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'حول التطبيق',
                        onTap: () {
                          Navigator.pushNamed(context, AppConfig.aboutRoute);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Vendor Section (if applicable)
                      if (authProvider.currentUser?.isVendor == true) ...[
                        _buildSectionTitle('البائع', theme),
                        ProfileMenuItem(
                          icon: Icons.dashboard_outlined,
                          title: l10n.vendorDashboard,
                          onTap: () {
                            Navigator.pushNamed(context, AppConfig.vendorDashboardRoute);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Logout
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: l10n.logout,
                        textColor: Colors.red,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.logout),
                              content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    l10n.logout,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await authProvider.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppConfig.loginRoute,
                              (route) => false,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPink,
          ),
        ),
      ),
    );
  }
}