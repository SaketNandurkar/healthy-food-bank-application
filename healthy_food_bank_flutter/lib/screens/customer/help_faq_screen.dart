import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen>
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
                  const Text('Help & FAQ',
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
                    child: _buildSectionTitle('Frequently Asked Questions'),
                  ),
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          _buildFaqSection(
                            'How to Order',
                            Icons.shopping_bag_outlined,
                            AppColors.primary,
                            [
                              (
                                'How do I place an order?',
                                'Browse available products on the Home tab, add items to your cart, and proceed to checkout. Enter your delivery address and phone number to complete your order.'
                              ),
                              (
                                'Can I modify my order after placing it?',
                                'Once an order is placed, it cannot be modified directly. Please contact the vendor or cancel and place a new order.'
                              ),
                              (
                                'What are the minimum order requirements?',
                                'There are no minimum order requirements. You can order as little or as much as you need.'
                              ),
                            ],
                          ),
                          _buildDivider(),
                          _buildFaqSection(
                            'Delivery Information',
                            Icons.local_shipping_outlined,
                            AppColors.info,
                            [
                              (
                                'How does delivery work?',
                                'Orders are delivered to your selected pickup point. You will be notified when your order is ready for collection.'
                              ),
                              (
                                'What are the delivery days?',
                                'Delivery schedules depend on the vendor. Most vendors deliver within 1-3 business days.'
                              ),
                              (
                                'Can I change my pickup point?',
                                'Yes! Go to Profile > My Pickup Points to manage your pickup locations and set an active point.'
                              ),
                            ],
                          ),
                          _buildDivider(),
                          _buildFaqSection(
                            'Returns & Cancellations',
                            Icons.replay_outlined,
                            AppColors.warning,
                            [
                              (
                                'How do I cancel an order?',
                                'Currently, order cancellations must be handled through the vendor. Contact the vendor directly for cancellation requests.'
                              ),
                              (
                                'What is the cancellation policy?',
                                'Orders can typically be cancelled before they are processed. Once a vendor starts preparing your order, cancellation may not be possible.'
                              ),
                              (
                                'Can I return items?',
                                'If you receive damaged or incorrect items, please contact support immediately. We will work with the vendor to resolve the issue.'
                              ),
                            ],
                          ),
                          _buildDivider(),
                          _buildFaqSection(
                            'Account & Profile',
                            Icons.person_outline,
                            AppColors.orange,
                            [
                              (
                                'How do I update my profile?',
                                'Go to Profile > Edit Profile to update your name, email, phone number, or change your password.'
                              ),
                              (
                                'How do I change my password?',
                                'Navigate to Profile > Edit Profile and scroll down to the "Change Password" section.'
                              ),
                              (
                                'How do I logout?',
                                'Go to the Profile tab and tap "Logout" at the bottom of the menu.'
                              ),
                            ],
                          ),
                          _buildDivider(),
                          _buildFaqSection(
                            'Pickup Points',
                            Icons.location_on_outlined,
                            AppColors.success,
                            [
                              (
                                'What is a pickup point?',
                                'A pickup point is a designated location where you can collect your orders. Choose the one most convenient for you.'
                              ),
                              (
                                'How do I add a pickup point?',
                                'Go to Profile > My Pickup Points > Add Pickup Point. Select from available locations near you.'
                              ),
                              (
                                'Can I have multiple pickup points?',
                                'Yes, you can add multiple pickup points and switch between them. Set one as your active point for new orders.'
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredListItem(
                    index: 2,
                    animation: _entranceCtrl,
                    child: _buildSectionTitle('Contact Support'),
                  ),
                  StaggeredListItem(
                    index: 3,
                    animation: _entranceCtrl,
                    child: Container(
                      decoration: premiumCardDecoration(),
                      child: Column(
                        children: [
                          _buildContactTile(Icons.email_outlined, AppColors.info, 'Email', 'support@healthyfoodbank.com'),
                          _buildDivider(),
                          _buildContactTile(Icons.phone_outlined, AppColors.success, 'Phone', '+91 1800-123-4567'),
                          _buildDivider(),
                          _buildContactTile(Icons.schedule_outlined, AppColors.warning, 'Working Hours', 'Mon - Sat, 9:00 AM - 6:00 PM'),
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

  Widget _buildFaqSection(
    String title,
    IconData icon,
    Color color,
    List<(String, String)> items,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.only(left: 56, right: 14, bottom: 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _buildFaqItem(item.$1, item.$2)).toList(),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, Color color, String title, String value) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
