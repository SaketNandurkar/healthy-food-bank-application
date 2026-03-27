import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../models/cart_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/pickup_point_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/qty_stepper.dart';
import 'customer_shell.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class BrowseProductsScreen extends ConsumerStatefulWidget {
  const BrowseProductsScreen({super.key});

  @override
  ConsumerState<BrowseProductsScreen> createState() =>
      _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends ConsumerState<BrowseProductsScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _searchCtrl = TextEditingController();
  final _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Grains',
    'Proteins',
    'Beverages',
    'Organic',
    'Others',
  ];
  String _selectedCategory = 'All';
  late AnimationController _gridAnimCtrl;
  DateTime? _lastRefreshTime;

  // Auto-refresh interval (60 seconds for production)
  static const _autoRefreshInterval = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    _gridAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addObserver(this); // Listen for app lifecycle changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _startAutoRefresh(); // Start periodic refresh
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      print('DEBUG: App resumed - refreshing data');
      _loadData();
    }
  }

  void _startAutoRefresh() {
    Future.delayed(_autoRefreshInterval, () {
      if (mounted) {
        print('DEBUG: Auto-refresh triggered (${DateTime.now()})');
        _loadData().then((_) => _startAutoRefresh()); // Recursive call
      }
    });
  }

  Future<void> _loadData() async {
    final user = ref.read(authStateProvider).user;
    if (user?.id == null) {
      print('DEBUG: No user ID found');
      return;
    }

    try {
      // STEP 1: Load active pickup point FIRST
      print('DEBUG: Loading active pickup point for user ${user!.id}');
      await ref
          .read(customerPickupPointsProvider.notifier)
          .loadActiveOnly(user.id!);

      // STEP 2: Get the active pickup point ID
      final activePickupPoint = ref.read(customerPickupPointsProvider).activePickupPoint;
      print('DEBUG: Active pickup point: ${activePickupPoint?.id} - ${activePickupPoint?.name}');

      // STEP 3: Load products filtered by that pickup point
      if (activePickupPoint?.id != null) {
        print('DEBUG: Loading products for pickup point ${activePickupPoint!.id}');
        await ref.read(productListProvider.notifier).loadProducts(
              pickupPointId: activePickupPoint.id,
            );
      } else {
        // FALLBACK: Load all products if no pickup point selected
        print('DEBUG: No active pickup point - loading all products as fallback');
        await ref.read(productListProvider.notifier).loadProducts();
      }

      final products = ref.read(productListProvider).products;
      print('DEBUG: Loaded ${products.length} products');

      // Update last refresh time
      if (mounted) {
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
      }
    } catch (e) {
      print('ERROR loading data: $e');
      // Fallback: try loading all products
      await ref.read(productListProvider.notifier).loadProducts();
      if (mounted) {
        setState(() {
          _lastRefreshTime = DateTime.now();
        });
      }
    }
  }

  void _loadProducts() {
    _loadData();
  }

  void _loadActivePickupPoint() {
    final user = ref.read(authStateProvider).user;
    if (user?.id != null) {
      ref
          .read(customerPickupPointsProvider.notifier)
          .loadActiveOnly(user!.id!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _searchCtrl.dispose();
    _gridAnimCtrl.dispose();
    super.dispose();
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return '$greeting, $name';
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final user = ref.watch(authStateProvider).user;
    final activePickupPoint =
        ref.watch(customerPickupPointsProvider).activePickupPoint;

    if (!productState.isLoading && productState.filteredProducts.isNotEmpty) {
      if (!_gridAnimCtrl.isCompleted) _gridAnimCtrl.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Flat white header ──
            _buildHeader(user, activePickupPoint),

            // ── Search bar ──
            _buildSearchBar(),

            // ── Category chips ──
            _buildCategoryChips(),

            // ── Products grid ──
            Expanded(
              child: productState.isLoading
                  ? _buildShimmerGrid()
                  : productState.error != null
                      ? EmptyState(
                          icon: Icons.error_outline,
                          title: 'Failed to load products',
                          subtitle: productState.error ?? 'Something went wrong',
                          actionLabel: 'Retry',
                          onAction: _loadProducts,
                        )
                      : productState.filteredProducts.isEmpty
                          ? EmptyState(
                              icon: Icons.search_off,
                              title: 'No products found',
                              subtitle: 'Try adjusting your filters',
                              actionLabel: 'Clear Filters',
                              onAction: () {
                                _searchCtrl.clear();
                                setState(() => _selectedCategory = 'All');
                                ref
                                    .read(productListProvider.notifier)
                                    .setSearchQuery('');
                                ref
                                    .read(productListProvider.notifier)
                                    .setCategory(null);
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: () async => _loadProducts(),
                              color: AppColors.primary,
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.62,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount:
                                    productState.filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return StaggeredListItem(
                                    index: index,
                                    animation: _gridAnimCtrl,
                                    child: _ProductCard(
                                      product: productState
                                          .filteredProducts[index],
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // GREEN HEADER
  // ────────────────────────────────────────────────────────────
  Widget _buildHeader(dynamic user, dynamic activePickupPoint) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        gradient: PremiumGradients.header(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Healthy Food Bank',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (user != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _getGreeting(user.firstName),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.initials ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (activePickupPoint != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/my-pickup-points'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Point',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            activePickupPoint.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18, color: Colors.white.withOpacity(0.7)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // SEARCH BAR
  // ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) =>
            ref.read(productListProvider.notifier).setSearchQuery(v),
        decoration: InputDecoration(
          hintText: 'Search products, vendors...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textHint, size: 22),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchCtrl.clear();
                    ref
                        .read(productListProvider.notifier)
                        .setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // CATEGORY CHIPS — horizontal scroll, pill-shaped
  // ────────────────────────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          final meta = CategoryMeta.get(cat);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedCategory = cat);
              ref
                  .read(productListProvider.notifier)
                  .setCategory(cat == 'All' ? null : cat.toUpperCase());
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meta.icon,
                    size: 15,
                    color: isSelected ? Colors.white : meta.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // SHIMMER GRID
  // ────────────────────────────────────────────────────────────
  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerProductCard(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PRODUCT CARD — Blinkit-style compact card
// ══════════════════════════════════════════════════════════════
class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.findByProductId(product.id);
    final isInCart = cartItem != null;

    return GestureDetector(
      onTap: () => _showProductDetail(context, ref, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ──
            _buildImage(),

            // ── Product info + action ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name — 2 lines max
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3),

                    // Unit info + vendor
                    Text(
                      _buildSubtitle(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price row + ADD button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Price
                        Expanded(
                          child: Text(
                            product.pricePerUnit,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 4),

                        // ADD button or QtyStepper
                        if (product.isOutOfStock)
                          _buildUnavailableChip()
                        else if (isInCart)
                          QtyStepper(
                            quantity: cartItem!.quantity,
                            onIncrement: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(cartProvider.notifier)
                                  .incrementQuantity(product.id);
                            },
                            onDecrement: () {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(cartProvider.notifier)
                                  .decrementQuantity(product.id);
                            },
                            compact: true,
                          )
                        else
                          _buildAddButton(context, ref),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Product image with stock badge overlay
  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 1,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
        ),
        // Stock badge — only show for low stock or out of stock
        if (product.isLowStock || product.isOutOfStock)
          Positioned(
            top: 6,
            left: 6,
            child: StatusBadge.stock(product.stockStatus),
          ),
        // Out of stock overlay
        if (product.isOutOfStock)
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: Center(
        child: Icon(Icons.eco, size: 36, color: AppColors.primary.withOpacity(0.15)),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    final unit = product.unitDisplay;
    if (unit.isNotEmpty) parts.add(unit);
    if (product.vendorName != null && product.vendorName!.isNotEmpty) {
      parts.add(product.vendorName!);
    }
    return parts.join(' \u00b7 ');
  }

  // Green outline ADD button
  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(cartProvider.notifier).addToCart(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Text(
          'ADD',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Unavailable chip for out-of-stock items
  Widget _buildUnavailableChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'N/A',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  // Show product detail bottom sheet
  static void _showProductDetail(
      BuildContext context, WidgetRef ref, Product product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductDetailSheet(product: product),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PRODUCT DETAIL BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _ProductDetailSheet extends ConsumerWidget {
  final Product product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.findByProductId(product.id);
    final isInCart = cartItem != null;
    final catMeta =
        product.category != null ? CategoryMeta.get(product.category!) : null;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: Center(
                                      child: Icon(Icons.eco,
                                          size: 64,
                                          color: AppColors.primary
                                              .withOpacity(0.15)),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: Center(
                                      child: Icon(Icons.eco,
                                          size: 64,
                                          color: AppColors.primary
                                              .withOpacity(0.15)),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surfaceAlt,
                                  child: Center(
                                    child: Icon(Icons.eco,
                                        size: 64,
                                        color: AppColors.primary
                                            .withOpacity(0.15)),
                                  ),
                                ),
                        ),
                        // Stock badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: StatusBadge.stock(product.stockStatus),
                        ),
                        // Close button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        // Out of stock overlay
                        if (product.isOutOfStock)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (catMeta != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: catMeta.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catMeta.icon,
                                    size: 13, color: catMeta.color),
                                const SizedBox(width: 5),
                                Text(
                                  product.category!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: catMeta.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Product name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Vendor
                        if (product.vendorName != null &&
                            product.vendorName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.store_rounded,
                                    size: 14, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'by ${product.vendorName!}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Price + unit info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Price',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.pricePerUnit,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Stock',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.stockQuantity} ${product.productUnit ?? 'units'}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: product.isOutOfStock
                                          ? AppColors.error
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Description
                        if (product.description != null &&
                            product.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],

                        // Delivery schedule
                        if (product.deliverySchedule != null &&
                            product.deliverySchedule!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 18, color: AppColors.info),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    product.deliverySchedule!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.infoText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom action bar
          _buildBottomBar(context, ref, cartItem, isInCart),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, CartItem? cartItem, bool isInCart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: SafeArea(
        child: product.isOutOfStock
            ? Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textHint.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Currently Unavailable',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : isInCart
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PressableScale(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(cartProvider.notifier)
                                      .decrementQuantity(product.id);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: PremiumShadows.subtle(),
                                  ),
                                  child: const Icon(Icons.remove,
                                      color: AppColors.primary, size: 20),
                                ),
                              ),
                              Text(
                                '${cartItem!.quantity}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              PressableScale(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(cartProvider.notifier)
                                      .incrementQuantity(product.id);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PressableScale(
                        onTap: () {
                          Navigator.pop(context);
                          CustomerShell.shellKey.currentState
                              ?.switchToTab(1);
                        },
                        child: Container(
                          height: 52,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'View Cart',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(cartProvider.notifier).addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('${product.name} added to cart'),
                            ],
                          ),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_shopping_cart_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
