import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حول التطبيق'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink,
                    AppTheme.accentPurple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_florist,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              'متجر الورود',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'الإصدار 1.0.0',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightPink.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_florist,
                    color: AppTheme.primaryPink,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'متجر الورود هو تطبيق متخصص في بيع أجمل باقات الورود لجميع المناسبات. نحن نقدم تشكيلة واسعة من الورود الطازجة والباقات المصممة بعناية لتناسب جميع الأذواق والمناسبات.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Developer Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryPink,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'طُور من قِبل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'عبدالولي بازل',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppTheme.primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '778447779',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features
            Text(
              'مميزات التطبيق',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureItem(
              Icons.local_florist,
              'تشكيلة واسعة من الورود',
              'باقات متنوعة لجميع المناسبات',
            ),
            _buildFeatureItem(
              Icons.delivery_dining,
              'توصيل سريع',
              'توصيل خلال 24-48 ساعة',
            ),
            _buildFeatureItem(
              Icons.payment,
              'دفع آمن',
              'طرق دفع متعددة وآمنة',
            ),
            _buildFeatureItem(
              Icons.support_agent,
              'دعم فني 24/7',
              'فريق دعم متاح في أي وقت',
            ),

            const SizedBox(height: 32),

            // Contact Info
            Text(
              'تواصل معنا',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactItem(
              Icons.phone,
              'الهاتف',
              '778447779',
              () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: '778447779');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              },
            ),
            _buildContactItem(
              Icons.email,
              'البريد الإلكتروني',
              'support@roses.com',
              () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'support@roses.com',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),

            const SizedBox(height: 32),

            // Copyright
            Text(
              '© 2025 متجر الورود. جميع الحقوق محفوظة.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryPink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPink,
            size: 20,
          ),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }
}