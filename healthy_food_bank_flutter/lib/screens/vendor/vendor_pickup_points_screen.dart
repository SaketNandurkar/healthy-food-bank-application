import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/pickup_point.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_pickup_point_provider.dart';
import '../../services/pickup_point_service.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';
import '../../widgets/empty_state.dart';

class VendorPickupPointsScreen extends ConsumerStatefulWidget {
  const VendorPickupPointsScreen({super.key});

  @override
  ConsumerState<VendorPickupPointsScreen> createState() => _VendorPickupPointsScreenState();
}

class _VendorPickupPointsScreenState extends ConsumerState<VendorPickupPointsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId != null) {
      ref.read(vendorPickupPointsProvider.notifier).loadPickupPoints(user!.vendorId!);
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorPickupPointsProvider);

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
                  const Expanded(
                    child: Text('My Pickup Points',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${state.activeCount} Active',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading
                ? _buildShimmer()
                : state.pickupPoints.isEmpty
                    ? EmptyState(
                        icon: Icons.location_on_outlined,
                        title: 'No pickup points yet',
                        subtitle: 'Add pickup points where you deliver',
                        actionLabel: 'Add Pickup Point',
                        onAction: () => _showAddSheet(context),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.pickupPoints.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index == state.pickupPoints.length) {
                              return StaggeredListItem(
                                index: index,
                                animation: _entranceCtrl,
                                child: _buildAddButton(),
                              );
                            }
                            final point = state.pickupPoints[index];
                            return StaggeredListItem(
                              index: index,
                              animation: _entranceCtrl,
                              child: _buildPointCard(point),
                            );
                          },
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

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: premiumCardDecoration(),
        child: const ShimmerLoading(height: 100, borderRadius: 12),
      ),
    );
  }

  Widget _buildPointCard(PickupPoint point) {
    final isActive = point.active;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.borderLight,
        ),
        boxShadow: PremiumShadows.card(),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.primary : AppColors.textHint).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: isActive ? AppColors.primary : AppColors.textHint,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      if (point.fullAddress.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          point.fullAddress,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (point.contactNumber != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 12, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(point.contactNumber!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.successLight : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.successText : AppColors.error,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _toggleActive(point),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.warningLight : AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Deactivate' : 'Activate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(point),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Remove',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text('Add Pickup Point',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActive(PickupPoint point) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId == null || point.id == null) return;

    final success = await ref.read(vendorPickupPointsProvider.notifier)
        .togglePickupPoint(user!.vendorId!, point.id!);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${point.name} ${point.active ? "deactivated" : "activated"}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(PickupPoint point) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Pickup Point', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text('Remove "${point.name}" from your service area?',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(authStateProvider).user;
              if (user?.vendorId != null && point.id != null) {
                await ref.read(vendorPickupPointsProvider.notifier)
                    .removePickupPoint(user!.vendorId!, point.id!);
              }
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    final existingIds = ref.read(vendorPickupPointsProvider)
        .pickupPoints.map((p) => p.id).whereType<int>().toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddPickupPointSheet(
        existingPointIds: existingIds,
        onAdd: (pickupPointId) async {
          final user = ref.read(authStateProvider).user;
          if (user?.vendorId != null) {
            final success = await ref.read(vendorPickupPointsProvider.notifier)
                .addPickupPoint(user!.vendorId!, {'pickupPointId': pickupPointId});
            if (mounted && success) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup point added!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class _AddPickupPointSheet extends StatefulWidget {
  final Future<void> Function(int pickupPointId) onAdd;
  final Set<int> existingPointIds;
  const _AddPickupPointSheet({required this.onAdd, required this.existingPointIds});

  @override
  State<_AddPickupPointSheet> createState() => _AddPickupPointSheetState();
}

class _AddPickupPointSheetState extends State<_AddPickupPointSheet> {
  List<PickupPoint> _availablePoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final points = await PickupPointService().getActivePickupPoints();
      final filtered = points.where((p) => !widget.existingPointIds.contains(p.id)).toList();
      if (mounted) setState(() { _availablePoints = filtered; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Pickup Point', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Select delivery location', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Flexible(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                  ))
                : _availablePoints.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No available pickup points', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _availablePoints.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final point = _availablePoints[index];
                          return GestureDetector(
                            onTap: () {
                              if (point.id != null) widget.onAdd(point.id!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: premiumCardDecoration(),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(point.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        if (point.fullAddress.isNotEmpty)
                                          Text(point.fullAddress,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
