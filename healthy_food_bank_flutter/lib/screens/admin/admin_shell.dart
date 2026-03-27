import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/admin_navigation_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_vendor_codes_screen.dart';
import 'admin_pickup_points_screen.dart';
import 'admin_profile_screen.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  static const _screens = [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminVendorCodesScreen(),
    AdminPickupPointsScreen(),
    AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(adminNavigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  ref,
                  Icons.dashboard_outlined,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  0,
                ),
                _buildNavItem(
                  context,
                  ref,
                  Icons.people_outline_rounded,
                  Icons.people_rounded,
                  'Users',
                  1,
                ),
                _buildNavItem(
                  context,
                  ref,
                  Icons.qr_code_outlined,
                  Icons.qr_code_rounded,
                  'Codes',
                  2,
                ),
                _buildNavItem(
                  context,
                  ref,
                  Icons.location_on_outlined,
                  Icons.location_on_rounded,
                  'Pickups',
                  3,
                ),
                _buildNavItem(
                  context,
                  ref,
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  'Profile',
                  4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    IconData activeIcon,
    String label,
    int index, {
    int? badgeCount,
  }) {
    final currentIndex = ref.watch(adminNavigationProvider);
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textHint;

    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          HapticFeedback.lightImpact();
          ref.read(adminNavigationProvider.notifier).state = index;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional badge
            SizedBox(
              width: 28,
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  if (badgeCount != null)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
