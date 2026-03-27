import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  Map<String, bool> _prefs = {
    'notif_order_updates': true,
    'notif_delivery_alerts': true,
    'notif_promotions': true,
    'notif_new_products': true,
  };

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (final key in _prefs.keys) {
        _prefs[key] = prefs.getBool(key) ?? true;
      }
    });
  }

  Future<void> _togglePref(String key) async {
    HapticFeedback.selectionClick();
    final newVal = !(_prefs[key] ?? true);
    setState(() => _prefs[key] = newVal);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, newVal);
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
                  const Text('Notifications',
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
                  StaggeredListItem(
                    index: 0,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Order Notifications'),
                  ),
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          _buildToggleItem('Order Updates', 'Get notified about order status changes',
                              Icons.local_shipping_outlined, 'notif_order_updates'),
                          _buildDivider(),
                          _buildToggleItem('Delivery Alerts', 'Notifications when your order is ready',
                              Icons.notifications_active_outlined, 'notif_delivery_alerts'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredListItem(
                    index: 2,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Marketing'),
                  ),
                  StaggeredListItem(
                    index: 3,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          _buildToggleItem('Promotions', 'Special offers and seasonal discounts',
                              Icons.local_offer_outlined, 'notif_promotions'),
                          _buildDivider(),
                          _buildToggleItem('New Products', 'Be the first to know about new items',
                              Icons.new_releases_outlined, 'notif_new_products'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StaggeredListItem(
                    index: 4,
                    animation: _entranceCtrl,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySubtle.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary.withOpacity(0.5), size: 16),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Notification preferences are saved locally on this device.',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildToggleItem(String title, String subtitle, IconData icon, String prefKey) {
    final isEnabled = _prefs[prefKey] ?? true;
    return InkWell(
      onTap: () => _togglePref(prefKey),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isEnabled ? AppColors.primary : AppColors.textHint).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: isEnabled ? AppColors.primary : AppColors.textHint, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: isEnabled,
              onChanged: (_) => _togglePref(prefKey),
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
