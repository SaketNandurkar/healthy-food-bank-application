import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_navigation_provider.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green gradient profile header
            _buildProfileHeader(user),

            const SizedBox(height: 20),

            // Menu sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // == ADMIN ==
                  StaggeredListItem(
                    index: 0,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Admin'),
                  ),
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: _buildMenuCard([
                      _MenuItem(
                        Icons.dashboard_outlined,
                        'Dashboard',
                        AppColors.primary,
                        () => ref.read(adminNavigationProvider.notifier).state = 0,
                      ),
                      _MenuItem(
                        Icons.people_outlined,
                        'Manage Users',
                        AppColors.info,
                        () => ref.read(adminNavigationProvider.notifier).state = 1,
                      ),
                      _MenuItem(
                        Icons.qr_code_outlined,
                        'Vendor Codes',
                        AppColors.warning,
                        () => ref.read(adminNavigationProvider.notifier).state = 2,
                      ),
                      _MenuItem(
                        Icons.location_on_outlined,
                        'Pickup Points',
                        AppColors.success,
                        () => ref.read(adminNavigationProvider.notifier).state = 3,
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // == ACCOUNT ==
                  StaggeredListItem(
                    index: 2,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Account'),
                  ),
                  StaggeredListItem(
                    index: 3,
                    animation: _entranceCtrl,
                    child: _buildMenuCard([
                      _MenuItem(
                        Icons.person_outline,
                        'Edit Profile',
                        AppColors.primary,
                        () => Navigator.pushNamed(context, '/edit-profile'),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // == PREFERENCES ==
                  StaggeredListItem(
                    index: 4,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Preferences'),
                  ),
                  StaggeredListItem(
                    index: 5,
                    animation: _entranceCtrl,
                    child: _buildMenuCard([
                      _MenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        AppColors.orange,
                        () => Navigator.pushNamed(context, '/notifications'),
                      ),
                      _MenuItem(
                        Icons.settings_outlined,
                        'Settings',
                        AppColors.textSecondary,
                        () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // == SUPPORT ==
                  StaggeredListItem(
                    index: 6,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Support'),
                  ),
                  StaggeredListItem(
                    index: 7,
                    animation: _entranceCtrl,
                    child: _buildMenuCard([
                      _MenuItem(
                        Icons.help_outline,
                        'Help & FAQ',
                        AppColors.success,
                        () => Navigator.pushNamed(context, '/help-faq'),
                      ),
                      _MenuItem(
                        Icons.analytics_outlined,
                        'System Reports',
                        AppColors.info,
                        () {
                          // TODO: Navigate to reports
                        },
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Logout button
                  StaggeredListItem(
                    index: 8,
                    animation: _entranceCtrl,
                    child: PressableScale(
                      onTap: () => _showLogoutDialog(context, ref),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.15),
                          ),
                          boxShadow: PremiumShadows.subtle(),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: AppColors.error,
                              size: 18,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // App version
                  StaggeredListItem(
                    index: 9,
                    animation: _entranceCtrl,
                    child: Center(
                      child: Text(
                        'Healthy Food Bank v1.0.0 - Admin',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return PremiumHeader(
      padding:
          const EdgeInsets.only(top: 60, bottom: 32, left: 20, right: 20),
      bottomRadius: 24,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar circle with initials
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.initials ?? 'A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Full name
            Text(
              user?.fullName ?? 'Admin',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Email
            if (user?.email != null) ...[
              const SizedBox(height: 4),
              Text(
                user!.email!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 10),

            // Role badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: PremiumShadows.subtle(),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              PressableScale(
                onTap: item.onTap,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  ),
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 64),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PressableScale(
            onTap: () async {
              HapticFeedback.mediumImpact();
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.color, this.onTap);
}
