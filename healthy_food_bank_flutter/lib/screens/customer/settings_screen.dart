import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          PremiumHeader(
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  _buildBackButton(),
                  const SizedBox(width: 12),
                  const Text('Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredListItem(index: 0, animation: _entranceCtrl, child: _buildSectionTitle('App Info')),
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          _buildSettingsTile(
                            icon: Icons.info_outline,
                            color: AppColors.primary,
                            title: 'Version',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('1.0.0',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ),
                          ),
                          _buildDivider(),
                          PressableScale(
                            onTap: () => _showAbout(context),
                            child: _buildSettingsTile(
                              icon: Icons.description_outlined,
                              color: AppColors.info,
                              title: 'About',
                              trailing: _buildChevron(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredListItem(index: 2, animation: _entranceCtrl, child: _buildSectionTitle('Appearance')),
                  StaggeredListItem(
                    index: 3,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: _buildSettingsTile(
                        icon: Icons.light_mode_outlined,
                        color: AppColors.warning,
                        title: 'Theme',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.light_mode, size: 13, color: AppColors.warningText),
                              SizedBox(width: 4),
                              Text('Light', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warningText)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredListItem(index: 4, animation: _entranceCtrl, child: _buildSectionTitle('Account')),
                  StaggeredListItem(
                    index: 5,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          PressableScale(
                            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                            child: _buildSettingsTile(
                              icon: Icons.lock_outline,
                              color: AppColors.primary,
                              title: 'Change Password',
                              trailing: _buildChevron(),
                            ),
                          ),
                          _buildDivider(),
                          PressableScale(
                            onTap: () => _showClearCartDialog(context),
                            child: _buildSettingsTile(
                              icon: Icons.remove_shopping_cart_outlined,
                              color: AppColors.error,
                              title: 'Clear Cart',
                              trailing: _buildChevron(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  StaggeredListItem(
                    index: 6,
                    animation: _entranceCtrl,
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primarySubtle,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(height: 8),
                          const Text('Healthy Food Bank',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHint)),
                          const SizedBox(height: 2),
                          const Text('Fresh & Healthy, Delivered to You',
                              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textHint, letterSpacing: 0.8)),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildChevron() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
      child: const Icon(Icons.chevron_right, color: AppColors.textHint, size: 16),
    );
  }

  void _showAbout(BuildContext context) {
    HapticFeedback.lightImpact();
    showAboutDialog(
      context: context,
      applicationName: 'Healthy Food Bank',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.primarySubtle, shape: BoxShape.circle),
        child: const Icon(Icons.eco, color: AppColors.primary, size: 28),
      ),
      children: [
        const Text(
          'Your trusted marketplace for fresh, healthy food. '
          'Connect with local vendors and get quality produce delivered to your nearest pickup point.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('Remove all items from your shopping cart?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
