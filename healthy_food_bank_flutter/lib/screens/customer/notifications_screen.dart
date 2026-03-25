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
            child: Row(
              children: [
                PressableScale(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                ),
              ],
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
                          _buildToggleItem(
                            'Order Updates',
                            'Get notified about order status changes',
                            Icons.local_shipping_outlined,
                            'notif_order_updates',
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 64),
                            child: Divider(height: 1),
                          ),
                          _buildToggleItem(
                            'Delivery Alerts',
                            'Notifications when your order is ready for pickup',
                            Icons.notifications_active_outlined,
                            'notif_delivery_alerts',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          _buildToggleItem(
                            'Promotions',
                            'Special offers and seasonal discounts',
                            Icons.local_offer_outlined,
                            'notif_promotions',
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 64),
                            child: Divider(height: 1),
                          ),
                          _buildToggleItem(
                            'New Products',
                            'Be the first to know about new items',
                            Icons.new_releases_outlined,
                            'notif_new_products',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  StaggeredListItem(
                    index: 4,
                    animation: _entranceCtrl,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary.withOpacity(0.6), size: 18),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, IconData icon, String prefKey) {
    final isEnabled = _prefs[prefKey] ?? true;
    return InkWell(
      onTap: () => _togglePref(prefKey),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isEnabled ? AppColors.primary : AppColors.textHint).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isEnabled ? AppColors.primary : AppColors.textHint, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
