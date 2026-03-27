import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../providers/admin_pickup_points_provider.dart';
import '../../models/pickup_point.dart';

class AdminPickupPointsScreen extends ConsumerStatefulWidget {
  const AdminPickupPointsScreen({super.key});

  @override
  ConsumerState<AdminPickupPointsScreen> createState() =>
      _AdminPickupPointsScreenState();
}

class _AdminPickupPointsScreenState
    extends ConsumerState<AdminPickupPointsScreen>
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
    ref
        .read(pickupPointsProvider.notifier)
        .setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'Pickup Points',
              subtitle: 'Manage collection locations',
              gradient: PremiumGradients.header(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: _showCreatePickupPointDialog,
                ),
              ],
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
                      hintText: 'Search pickup points...',
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
                        _buildFilterChip('All', Icons.location_on_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Active', Icons.check_circle_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Inactive', Icons.cancel_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pickup Points List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: _buildPickupPointsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final pointsState = ref.watch(pickupPointsProvider);
    final currentFilter = pointsState.statusFilter ?? 'All';
    final isSelected = currentFilter == label;
    return PressableScale(
      onTap: () {
        ref.read(pickupPointsProvider.notifier).setStatusFilter(label);
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

  Widget _buildPickupPointsList() {
    final pointsState = ref.watch(pickupPointsProvider);

    if (pointsState.isLoading && pointsState.pickupPoints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pointsState.error != null && pointsState.pickupPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Error loading pickup points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pointsState.error!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(pickupPointsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final pickupPoints = pointsState.filteredPickupPoints;

    if (pickupPoints.isEmpty) {
      return const EmptyState(
        icon: Icons.location_on_outlined,
        title: 'No Pickup Points',
        subtitle: 'Create your first pickup point location',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: pickupPoints.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          animation: _animationController,
          child: _buildPickupPointCard(pickupPoints[index]),
        );
      },
    );
  }

  Widget _buildPickupPointCard(PickupPoint pickupPoint) {
    final isActive = pickupPoint.active;

    return PressableScale(
      onTap: () => _showPickupPointDetails(pickupPoint),
      child: Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Location Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? PremiumGradients.primary()
                        : LinearGradient(
                            colors: [
                              AppColors.textHint.withOpacity(0.3),
                              AppColors.textHint.withOpacity(0.1),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: isActive ? Colors.white : AppColors.textHint,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Point Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pickupPoint.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (isActive
                                      ? AppColors.success
                                      : AppColors.textHint)
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.success
                                        : AppColors.textHint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isActive
                                        ? AppColors.success
                                        : AppColors.textHint,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pickupPoint.fullAddress,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (pickupPoint.contactNumber != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              pickupPoint.contactNumber!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // More Actions
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
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Row(
                          children: [
                            Icon(Icons.cancel_rounded,
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
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) =>
                      _handlePickupPointAction(value as String, pickupPoint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePickupPointDialog({PickupPoint? editPoint}) {
    final nameController = TextEditingController(text: editPoint?.name);
    final addressController = TextEditingController(text: editPoint?.address);
    final cityController = TextEditingController(text: editPoint?.city);
    final stateController = TextEditingController(text: editPoint?.state);
    final zipController = TextEditingController(text: editPoint?.zipCode);
    final contactController =
        TextEditingController(text: editPoint?.contactNumber);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(editPoint == null ? 'Create Pickup Point' : 'Edit Pickup Point'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: zipController,
                      decoration: InputDecoration(
                        labelText: 'Zip Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  addressController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and address are required'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);

              final pickupPoint = PickupPoint(
                id: editPoint?.id,
                name: nameController.text.trim(),
                address: addressController.text.trim(),
                city:
                    cityController.text.isEmpty ? null : cityController.text.trim(),
                state: stateController.text.isEmpty
                    ? null
                    : stateController.text.trim(),
                zipCode:
                    zipController.text.isEmpty ? null : zipController.text.trim(),
                contactNumber: contactController.text.isEmpty
                    ? null
                    : contactController.text.trim(),
                active: editPoint?.active ?? true,
              );

              try {
                if (editPoint == null) {
                  await ref
                      .read(pickupPointsProvider.notifier)
                      .createPickupPoint(pickupPoint);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pickup point created successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  await ref
                      .read(pickupPointsProvider.notifier)
                      .updatePickupPoint(editPoint.id!, pickupPoint);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pickup point updated successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save pickup point: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(editPoint == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showPickupPointDetails(PickupPoint pickupPoint) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Pickup Point Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', pickupPoint.name),
            const Divider(),
            _buildDetailRow('Address', pickupPoint.address),
            if (pickupPoint.city != null) ...[
              const Divider(),
              _buildDetailRow('City', pickupPoint.city!),
            ],
            if (pickupPoint.state != null) ...[
              const Divider(),
              _buildDetailRow('State', pickupPoint.state!),
            ],
            if (pickupPoint.zipCode != null) ...[
              const Divider(),
              _buildDetailRow('Zip Code', pickupPoint.zipCode!),
            ],
            if (pickupPoint.contactNumber != null) ...[
              const Divider(),
              _buildDetailRow('Contact', pickupPoint.contactNumber!),
            ],
            const Divider(),
            _buildDetailRow('Status', pickupPoint.active ? 'Active' : 'Inactive'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showCreatePickupPointDialog(editPoint: pickupPoint);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePickupPointAction(String action, PickupPoint pickupPoint) async {
    if (action == 'view') {
      _showPickupPointDetails(pickupPoint);
    } else if (action == 'edit') {
      _showCreatePickupPointDialog(editPoint: pickupPoint);
    } else if (action == 'activate') {
      try {
        await ref
            .read(pickupPointsProvider.notifier)
            .activatePickupPoint(pickupPoint.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pickup point activated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else if (action == 'deactivate') {
      final confirm = await _showConfirmDialog(
        'Deactivate Pickup Point',
        'Are you sure you want to deactivate ${pickupPoint.name}? It will no longer be available for selection.',
      );
      if (confirm) {
        try {
          await ref
              .read(pickupPointsProvider.notifier)
              .deactivatePickupPoint(pickupPoint.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pickup point deactivated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to deactivate: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } else if (action == 'delete') {
      final confirm = await _showConfirmDialog(
        'Delete Pickup Point',
        'Are you sure you want to delete ${pickupPoint.name}? This action cannot be undone.',
      );
      if (confirm) {
        try {
          await ref
              .read(pickupPointsProvider.notifier)
              .deletePickupPoint(pickupPoint.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pickup point deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
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
    await ref.read(pickupPointsProvider.notifier).refresh();
  }
}
