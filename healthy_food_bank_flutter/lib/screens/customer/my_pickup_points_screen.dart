import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/pickup_point.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pickup_point_provider.dart';
import '../../services/pickup_point_service.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';
import '../../widgets/empty_state.dart';

class MyPickupPointsScreen extends ConsumerStatefulWidget {
  const MyPickupPointsScreen({super.key});

  @override
  ConsumerState<MyPickupPointsScreen> createState() => _MyPickupPointsScreenState();
}

class _MyPickupPointsScreenState extends ConsumerState<MyPickupPointsScreen>
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
    if (user?.id != null) {
      ref.read(customerPickupPointsProvider.notifier).loadPickupPoints(user!.id!);
    }
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerPickupPointsProvider);

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
                const Expanded(
                  child: Text(
                    'My Pickup Points',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: state.isLoading
                ? _buildShimmer()
                : state.pickupPoints.isEmpty
                    ? EmptyState(
                        icon: Icons.location_on_outlined,
                        title: 'No pickup points yet',
                        subtitle: 'Add a pickup point to get started',
                        actionLabel: 'Add Pickup Point',
                        onAction: () => _showAddSheet(context),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.pickupPoints.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == state.pickupPoints.length) {
                              return StaggeredListItem(
                                index: index,
                                animation: _entranceCtrl,
                                child: _buildAddButton(),
                              );
                            }
                            final point = state.pickupPoints[index];
                            final isActive = state.activePickupPoint?.id == point.id;
                            return StaggeredListItem(
                              index: index,
                              animation: _entranceCtrl,
                              child: _buildPointCard(point, isActive),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        height: 100,
        decoration: premiumCardDecoration(),
        child: const ShimmerLoading(height: 100, borderRadius: 16),
      ),
    );
  }

  Widget _buildPointCard(PickupPoint point, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: isActive ? AppColors.success : Colors.transparent, width: 4)),
        boxShadow: PremiumShadows.card(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isActive ? AppColors.success : AppColors.primary).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: isActive ? AppColors.success : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2),
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
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.successText, letterSpacing: 0.5),
                    ),
                  ),
              ],
            ),
            if (point.contactNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 44),
                  Icon(Icons.phone_outlined, size: 13, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(point.contactNumber!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                if (!isActive)
                  PressableScale(
                    onTap: () => _setActive(point),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Set Active',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ),
                  ),
                const SizedBox(width: 8),
                PressableScale(
                  onTap: () => _confirmDelete(point),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Remove',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return PressableScale(
      onTap: () => _showAddSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Add Pickup Point',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<void> _setActive(PickupPoint point) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.id == null || point.id == null) return;

    final success = await ref.read(customerPickupPointsProvider.notifier).setActive(user!.id!, point.id!);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${point.name} set as active'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Pickup Point', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Remove "${point.name}" from your pickup points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(authStateProvider).user;
              if (user?.id != null && point.id != null) {
                await ref.read(customerPickupPointsProvider.notifier).removePickupPoint(user!.id!, point.id!);
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
    final existingIds = ref.read(customerPickupPointsProvider)
        .pickupPoints.map((p) => p.id).whereType<int>().toSet();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddPickupPointSheet(
        existingPointIds: existingIds,
        onAdd: (pickupPointId) async {
          final user = ref.read(authStateProvider).user;
          if (user?.id != null) {
            final success = await ref.read(customerPickupPointsProvider.notifier)
                .addPickupPoint(user!.id!, {'pickupPointId': pickupPointId});
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
      // Filter out pickup points the customer already has
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Pickup Point', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Select from available locations', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
                : _availablePoints.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No available pickup points', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _availablePoints.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final point = _availablePoints[index];
                          return PressableScale(
                            onTap: () {
                              if (point.id != null) widget.onAdd(point.id!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: premiumCardDecoration(),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(point.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        if (point.fullAddress.isNotEmpty)
                                          Text(point.fullAddress,
                                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: PremiumGradients.button(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
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
