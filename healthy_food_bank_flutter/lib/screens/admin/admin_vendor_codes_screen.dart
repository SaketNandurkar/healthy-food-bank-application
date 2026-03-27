import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../providers/admin_vendor_codes_provider.dart';
import 'package:intl/intl.dart';

class AdminVendorCodesScreen extends ConsumerStatefulWidget {
  const AdminVendorCodesScreen({super.key});

  @override
  ConsumerState<AdminVendorCodesScreen> createState() =>
      _AdminVendorCodesScreenState();
}

class _AdminVendorCodesScreenState
    extends ConsumerState<AdminVendorCodesScreen> with TickerProviderStateMixin {
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
    ref.read(vendorCodesProvider.notifier).setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'Vendor Codes',
              subtitle: 'Manage vendor registration codes',
              gradient: PremiumGradients.header(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  onPressed: _showCreateCodeDialog,
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
                      hintText: 'Search vendor codes...',
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
                        _buildFilterChip('All', Icons.qr_code_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Active', Icons.check_circle_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Used', Icons.person_rounded),
                        const SizedBox(width: AppSpacing.xs),
                        _buildFilterChip('Inactive', Icons.cancel_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Codes List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                child: _buildCodesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final codesState = ref.watch(vendorCodesProvider);
    final currentFilter = codesState.statusFilter ?? 'All';
    final isSelected = currentFilter == label;
    return PressableScale(
      onTap: () {
        ref.read(vendorCodesProvider.notifier).setStatusFilter(label);
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

  Widget _buildCodesList() {
    final codesState = ref.watch(vendorCodesProvider);

    if (codesState.isLoading && codesState.codes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (codesState.error != null && codesState.codes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Error loading vendor codes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              codesState.error!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(vendorCodesProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final codes = codesState.filteredCodes;

    if (codes.isEmpty) {
      return const EmptyState(
        icon: Icons.qr_code_outlined,
        title: 'No Vendor Codes',
        subtitle: 'Create your first vendor registration code',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: codes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          animation: _animationController,
          child: _buildCodeCard(codes[index]),
        );
      },
    );
  }

  Widget _buildCodeCard(code) {
    final isActive = code.isActive;
    final isUsed = code.isUsed;
    final createdDate = code.createdDate != null
        ? DateFormat('MMM dd, yyyy').format(code.createdDate!)
        : 'Unknown';

    return PressableScale(
      onTap: () => _showCodeDetails(code),
      child: Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Code Icon
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
                    Icons.qr_code_rounded,
                    color: isActive ? Colors.white : AppColors.textHint,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Code Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              code.code,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            onPressed: () => _copyCode(code.code),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: $createdDate',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                    if (isActive && !isUsed)
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
                    if (!isUsed)
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
                      _handleCodeAction(value as String, code),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Status Badges
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                _buildStatusBadge(
                  isActive ? 'Active' : 'Inactive',
                  isActive ? AppColors.success : AppColors.textHint,
                  isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                ),
                if (isUsed)
                  _buildStatusBadge(
                    'Used by ${code.usedBy ?? 'Unknown'}',
                    AppColors.info,
                    Icons.person_rounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCodeDialog() {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Create Vendor Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Code (leave empty for auto-generate)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'If you leave the code empty, a unique code will be automatically generated.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final customCode = codeController.text.trim();
              try {
                await ref.read(vendorCodesProvider.notifier).createCode(
                      customCode: customCode.isEmpty ? null : customCode,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vendor code created successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create code: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCodeDetails(code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Code Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Code', code.code),
            const Divider(),
            _buildDetailRow('Status', code.isActive ? 'Active' : 'Inactive'),
            const Divider(),
            _buildDetailRow('Used', code.isUsed ? 'Yes' : 'No'),
            if (code.isUsed) ...[
              const Divider(),
              _buildDetailRow('Used By', code.usedBy ?? 'Unknown'),
            ],
            if (code.createdDate != null) ...[
              const Divider(),
              _buildDetailRow(
                'Created',
                DateFormat('MMM dd, yyyy hh:mm a').format(code.createdDate!),
              ),
            ],
            if (code.usedAt != null) ...[
              const Divider(),
              _buildDetailRow(
                'Used At',
                DateFormat('MMM dd, yyyy hh:mm a').format(code.usedAt!),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
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

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $code'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleCodeAction(String action, code) async {
    if (action == 'view') {
      _showCodeDetails(code);
    } else if (action == 'activate') {
      try {
        await ref
            .read(vendorCodesProvider.notifier)
            .updateCode(code.id!, {'isActive': true});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor code activated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate code: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else if (action == 'deactivate') {
      final confirm = await _showConfirmDialog(
        'Deactivate Code',
        'Are you sure you want to deactivate this vendor code? It will no longer be usable for registration.',
      );
      if (confirm) {
        try {
          await ref
              .read(vendorCodesProvider.notifier)
              .updateCode(code.id!, {'isActive': false});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vendor code deactivated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to deactivate code: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } else if (action == 'delete') {
      final confirm = await _showConfirmDialog(
        'Delete Code',
        'Are you sure you want to delete this vendor code? This action cannot be undone.',
      );
      if (confirm) {
        try {
          await ref
              .read(vendorCodesProvider.notifier)
              .deleteCode(code.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vendor code deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete code: $e'),
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
    await ref.read(vendorCodesProvider.notifier).refresh();
  }
}
