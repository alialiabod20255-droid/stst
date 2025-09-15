import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPink,
                  AppTheme.accentPurple,
                ],
              ),
            ),
            child: const Icon(
              Icons.local_florist,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Welcome Text
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.fullName ?? 'زائر',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Notifications
          IconButton(
            onPressed: () {
              // TODO: Navigate to notifications
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: theme.colorScheme.onBackground,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Profile
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppConfig.profileRoute);
            },
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.lightPink,
                  backgroundImage: authProvider.currentUser?.profileImage != null
                      ? NetworkImage(authProvider.currentUser!.profileImage!)
                      : null,
                  child: authProvider.currentUser?.profileImage == null
                      ? Icon(
                          Icons.person,
                          color: AppTheme.primaryPink,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}