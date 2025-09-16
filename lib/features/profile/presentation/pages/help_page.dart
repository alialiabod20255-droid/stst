import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Team Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPink.withOpacity(0.1),
                    AppTheme.lightPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPink.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryPink,
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فريق الدعم',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'عبدالولي بازل',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '778447779',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نحن هنا لمساعدتك في أي وقت\nفريق الدعم متاح 24/7',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Options
            Text(
              'طرق التواصل',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.phone,
              title: 'اتصال هاتفي',
              subtitle: '778447779',
              color: Colors.green,
              onTap: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: '778447779');
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                }
              },
            ),

            const SizedBox(height: 12),

            _buildContactCard(
              icon: Icons.message,
              title: 'واتساب',
              subtitle: 'تواصل سريع',
              color: Colors.green[600]!,
              onTap: () async {
                final Uri whatsappUri = Uri.parse(
                  'https://wa.me/966778447779?text=مرحباً، أحتاج مساعدة في تطبيق متجر الورود',
                );
                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri);
                }
              },
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'الأسئلة الشائعة',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              'كيف يمكنني تتبع طلبي؟',
              'يمكنك تتبع طلبك من خلال صفحة "طلباتي" في الملف الشخصي، أو من خلال الرابط المرسل في رسالة التأكيد.',
            ),
            _buildFAQItem(
              'ما هي مدة التوصيل؟',
              'نقوم بتوصيل الطلبات خلال 24-48 ساعة داخل المدن الرئيسية، و3-5 أيام للمناطق الأخرى.',
            ),
            _buildFAQItem(
              'هل يمكنني إلغاء طلبي؟',
              'يمكنك إلغاء الطلب قبل تأكيده من التاجر. بعد التأكيد، يرجى التواصل مع فريق الدعم.',
            ),
            _buildFAQItem(
              'كيف يمكنني استخدام كوبون الخصم؟',
              'أدخل كود الكوبون في صفحة السلة قبل إتمام الشراء، وسيتم تطبيق الخصم تلقائياً.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
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
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}