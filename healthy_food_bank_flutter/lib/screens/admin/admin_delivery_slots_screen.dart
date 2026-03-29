import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/delivery_slot.dart';
import '../../providers/admin_delivery_slots_provider.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../widgets/empty_state.dart';

class AdminDeliverySlotsScreen extends ConsumerStatefulWidget {
  const AdminDeliverySlotsScreen({super.key});

  @override
  ConsumerState<AdminDeliverySlotsScreen> createState() =>
      _AdminDeliverySlotsScreenState();
}

class _AdminDeliverySlotsScreenState
    extends ConsumerState<AdminDeliverySlotsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(deliverySlotsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'Delivery Slots',
              subtitle: 'Manage delivery schedules',
              gradient: PremiumGradients.header(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: _showCreateSlotDialog,
                ),
              ],
            ),
            // Filter chips
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.white,
              child: Row(
                children: [
                  _buildFilterChip('All', slotsState.statusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', slotsState.statusFilter),
                  const SizedBox(width: 8),
                  _buildFilterChip('Inactive', slotsState.statusFilter),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _buildContent(slotsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? currentFilter) {
    final isSelected = currentFilter == label;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(deliverySlotsProvider.notifier).setStatusFilter(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DeliverySlotsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text('Failed to load delivery slots',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(deliverySlotsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredSlots.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No Delivery Slots',
        subtitle: state.statusFilter != 'All'
            ? 'No ${state.statusFilter?.toLowerCase()} slots found'
            : 'Create your first delivery slot',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(deliverySlotsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.filteredSlots.length,
        itemBuilder: (context, index) {
          final slot = state.filteredSlots[index];
          return StaggeredListItem(
            index: index,
            animation: _animationController,
            child: _buildSlotCard(slot),
          );
        },
      ),
    );
  }

  Widget _buildSlotCard(DeliverySlot slot) {
    final now = DateTime.now();
    final isPast = slot.cutoffDateTime.isBefore(now);
    final isUpcoming = slot.active && !isPast;

    // Format dates
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final deliveryDateStr =
        '${weekdays[slot.deliveryDate.weekday - 1]}, ${months[slot.deliveryDate.month - 1]} ${slot.deliveryDate.day}, ${slot.deliveryDate.year}';

    final cutoffHour = slot.cutoffDateTime.hour > 12
        ? slot.cutoffDateTime.hour - 12
        : (slot.cutoffDateTime.hour == 0 ? 12 : slot.cutoffDateTime.hour);
    final cutoffAmPm = slot.cutoffDateTime.hour >= 12 ? 'PM' : 'AM';
    final cutoffMin = slot.cutoffDateTime.minute.toString().padLeft(2, '0');
    final cutoffDateStr =
        '${weekdays[slot.cutoffDateTime.weekday - 1]}, ${months[slot.cutoffDateTime.month - 1]} ${slot.cutoffDateTime.day} at $cutoffHour:$cutoffMin $cutoffAmPm';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: premiumCardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSlotActions(slot),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Calendar icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUpcoming
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: isUpcoming ? AppColors.primary : Colors.grey,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delivery date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery: $deliveryDateStr',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isPast
                                  ? AppColors.textHint
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cutoff: $cutoffDateStr',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: slot.active
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: slot.active
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        slot.active ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: slot.active
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Past indicator
                if (isPast) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Cutoff passed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSlotActions(DeliverySlot slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delivery Slot Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.edit_rounded, color: AppColors.primary),
                  title: const Text('Edit Slot'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditSlotDialog(slot);
                  },
                ),
                ListTile(
                  leading: Icon(
                    slot.active
                        ? Icons.toggle_off_rounded
                        : Icons.toggle_on_rounded,
                    color: slot.active ? Colors.orange : Colors.green,
                  ),
                  title: Text(slot.active ? 'Deactivate' : 'Activate'),
                  onTap: () {
                    Navigator.pop(context);
                    if (slot.id != null) {
                      ref
                          .read(deliverySlotsProvider.notifier)
                          .toggleSlot(slot.id!);
                    }
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteSlot(slot);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteSlot(DeliverySlot slot) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Delivery Slot?'),
          content: const Text(
              'This action cannot be undone. Are you sure you want to delete this delivery slot?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (slot.id != null) {
                  ref
                      .read(deliverySlotsProvider.notifier)
                      .deleteSlot(slot.id!);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateSlotDialog() {
    _showSlotFormDialog(null);
  }

  void _showEditSlotDialog(DeliverySlot slot) {
    _showSlotFormDialog(slot);
  }

  void _showSlotFormDialog(DeliverySlot? existingSlot) {
    DateTime selectedDeliveryDate =
        existingSlot?.deliveryDate ?? DateTime.now().add(const Duration(days: 7));
    DateTime selectedCutoffDate =
        existingSlot?.cutoffDateTime ?? DateTime.now().add(const Duration(days: 5));
    TimeOfDay selectedCutoffTime = existingSlot != null
        ? TimeOfDay(
            hour: existingSlot.cutoffDateTime.hour,
            minute: existingSlot.cutoffDateTime.minute)
        : const TimeOfDay(hour: 20, minute: 0);
    bool isActive = existingSlot?.active ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            const weekdays = [
              'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
            ];
            const months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];

            final deliveryStr =
                '${weekdays[selectedDeliveryDate.weekday - 1]}, ${months[selectedDeliveryDate.month - 1]} ${selectedDeliveryDate.day}, ${selectedDeliveryDate.year}';
            final cutoffDateStr =
                '${weekdays[selectedCutoffDate.weekday - 1]}, ${months[selectedCutoffDate.month - 1]} ${selectedCutoffDate.day}, ${selectedCutoffDate.year}';
            final cutoffTimeStr = selectedCutoffTime.format(context);

            return AlertDialog(
              title: Text(existingSlot != null
                  ? 'Edit Delivery Slot'
                  : 'Create Delivery Slot'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Date
                    Text('Delivery Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDeliveryDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(
                              () => selectedDeliveryDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(deliveryStr,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cutoff Date
                    Text('Cutoff Date',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedCutoffDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(
                              () => selectedCutoffDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(cutoffDateStr,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cutoff Time
                    Text('Cutoff Time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedCutoffTime,
                        );
                        if (picked != null) {
                          setDialogState(
                              () => selectedCutoffTime = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Text(cutoffTimeStr,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Active',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            )),
                        Switch(
                          value: isActive,
                          onChanged: (val) =>
                              setDialogState(() => isActive = val),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final cutoffDateTime = DateTime(
                      selectedCutoffDate.year,
                      selectedCutoffDate.month,
                      selectedCutoffDate.day,
                      selectedCutoffTime.hour,
                      selectedCutoffTime.minute,
                    );

                    final slot = DeliverySlot(
                      id: existingSlot?.id,
                      deliveryDate: selectedDeliveryDate,
                      cutoffDateTime: cutoffDateTime,
                      active: isActive,
                    );

                    if (existingSlot != null && existingSlot.id != null) {
                      ref
                          .read(deliverySlotsProvider.notifier)
                          .updateSlot(existingSlot.id!, slot);
                    } else {
                      ref.read(deliverySlotsProvider.notifier).createSlot(slot);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(existingSlot != null ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
