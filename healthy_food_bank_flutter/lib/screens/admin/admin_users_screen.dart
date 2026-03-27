import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../providers/admin_users_provider.dart';
import '../../models/user.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(usersProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'User Management',
              subtitle: 'Manage system users',
              gradient: PremiumGradients.header(),
            ),
            // Search and Filter
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.white,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', Icons.people_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Customers', Icons.shopping_bag_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Vendors', Icons.store_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Admins', Icons.admin_panel_settings_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: _buildUsersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final usersState = ref.watch(usersProvider);
    final currentFilter = usersState.roleFilter ?? 'All';
    final isSelected = currentFilter == label;

    return PressableScale(
      onTap: () {
        final roleFilter = label == 'All' ? null : label.toUpperCase();
        ref.read(usersProvider.notifier).setRoleFilter(roleFilter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? PremiumGradients.primary() : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final usersState = ref.watch(usersProvider);

    if (usersState.isLoading && usersState.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (usersState.error != null && usersState.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              usersState.error!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(usersProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = usersState.filteredUsers;

    if (users.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No Users Found',
        subtitle: 'No users match your search criteria',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          animation: _animationController,
          child: _buildUserCard(users[index]),
        );
      },
    );
  }

  Widget _buildUserCard(user) {
    final fullName = '${user.firstName} ${user.lastName}';
    final isActive = user.active ?? true;

    return PressableScale(
      onTap: () => _showUserDetails(user),
      child: Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0] : 'U',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _getRoleColor(user.role),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email ?? user.userName ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _buildRoleBadge(user.role),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isActive ? AppColors.success : AppColors.textHint)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.success : AppColors.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                if (isActive)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.block_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Deactivate',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                if (!isActive)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Activate',
                            style: TextStyle(color: AppColors.success)),
                      ],
                    ),
                  ),
              ],
              onSelected: (value) => _handleUserAction(value as String, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final roleStr = role.toString().split('.').last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        roleStr,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getRoleColor(role),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return AppColors.error;
      case UserRole.VENDOR:
        return AppColors.warning;
      case UserRole.CUSTOMER:
        return AppColors.primary;
    }
  }

  void _showUserDetails(user) {
    // TODO: Navigate to user details screen
  }

  void _handleUserAction(String action, user) async {
    if (action == 'deactivate') {
      final confirm = await _showConfirmDialog(
        'Deactivate User',
        'Are you sure you want to deactivate ${user.firstName} ${user.lastName}? They will not be able to login or place orders.',
      );
      if (confirm) {
        await ref.read(usersProvider.notifier).deactivateUser(user.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deactivated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } else if (action == 'activate') {
      await ref.read(usersProvider.notifier).activateUser(user.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User activated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _refresh() async {
    await ref.read(usersProvider.notifier).refresh();
  }
}
