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
import 'customer_shell.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class BrowseProductsScreen extends ConsumerStatefulWidget {
  const BrowseProductsScreen({super.key});

  @override
  ConsumerState<BrowseProductsScreen> createState() => _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends ConsumerState<BrowseProductsScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _categories = ['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains', 'Proteins', 'Beverages', 'Organic', 'Others'];
  String _selectedCategory = 'All';
  late AnimationController _gridAnimCtrl;

  @override
  void initState() {
    super.initState();
    _gridAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      _loadActivePickupPoint();
    });
  }

  void _loadProducts() {
    final user = ref.read(authStateProvider).user;
    ref.read(productListProvider.notifier).loadProducts(
      pickupPointId: user?.pickupPointId,
    );
  }

  void _loadActivePickupPoint() {
    final user = ref.read(authStateProvider).user;
    if (user?.id != null) {
      ref.read(customerPickupPointsProvider.notifier).loadActiveOnly(user!.id!);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _gridAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final user = ref.watch(authStateProvider).user;
    final activePickupPoint = ref.watch(customerPickupPointsProvider).activePickupPoint;

    if (!productState.isLoading && productState.filteredProducts.isNotEmpty) {
      if (!_gridAnimCtrl.isCompleted) _gridAnimCtrl.forward();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Premium header
            PremiumHeader(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (user != null)
                              Text(
                                _getGreeting(user.firstName),
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                              ),
                          ],
                        ),
                      ),
                      PressableScale(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              user?.initials ?? 'U',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (activePickupPoint != null) ...[
                    const SizedBox(height: 10),
                    PressableScale(
                      onTap: () => Navigator.pushNamed(context, '/my-pickup-points'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 16, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup Point',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6), letterSpacing: 0.3),
                                  ),
                                  Text(
                                    activePickupPoint.name,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.95)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: Colors.white.withOpacity(0.6)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Search & Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: PremiumShadows.subtle(),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => ref.read(productListProvider.notifier).setSearchQuery(v),
                    decoration: InputDecoration(
                      hintText: 'Search products, vendors...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                _searchCtrl.clear();
                                ref.read(productListProvider.notifier).setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        final meta = CategoryMeta.get(cat);
                        return PressableScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = cat);
                            ref.read(productListProvider.notifier)
                                .setCategory(cat == 'All' ? null : cat.toUpperCase());
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: isSelected ? PremiumGradients.button() : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : AppColors.border),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(meta.icon, size: 15,
                                    color: isSelected ? Colors.white : meta.color),
                                const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Products grid
            Expanded(
              child: productState.isLoading
                  ? _buildShimmerGrid()
                  : productState.error != null
                      ? EmptyState(
                          icon: Icons.error_outline,
                          title: 'Failed to load products',
                          subtitle: productState.error,
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
                                ref.read(productListProvider.notifier).setSearchQuery('');
                                ref.read(productListProvider.notifier).setCategory(null);
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: () async => _loadProducts(),
                              color: AppColors.primary,
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.48,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: productState.filteredProducts.length,
                                itemBuilder: (context, index) {
                                  return StaggeredListItem(
                                    index: index,
                                    animation: _gridAnimCtrl,
                                    child: _ProductCard(product: productState.filteredProducts[index]),
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

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.48, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerProductCard(),
    );
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return '$greeting, $name';
  }
}

class _ProductCard extends ConsumerWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.findByProductId(product.id);
    final isInCart = cartItem != null;

    return PressableScale(
      onTap: () => _showProductDetail(context, ref, product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: PremiumShadows.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!, fit: BoxFit.cover,
                                placeholder: (_, __) => _imagePlaceholder(),
                                errorWidget: (_, __, ___) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(top: 8, left: 8, child: StatusBadge.stock(product.stockStatus)),
                if (product.isOutOfStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Out of Stock',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (product.description != null) ...[
                      const SizedBox(height: 2),
                      Text(product.description!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    if (product.vendorName != null && product.vendorName!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.store_outlined, size: 11, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(product.vendorName!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (product.category != null)
                      Builder(builder: (context) {
                        final catMeta = CategoryMeta.get(product.category!);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catMeta.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(catMeta.icon, size: 10, color: catMeta.color),
                              const SizedBox(width: 4),
                              Text(product.category!,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: catMeta.color, letterSpacing: 0.3)),
                            ],
                          ),
                        );
                      }),
                    const Spacer(),
                    Text(product.pricePerUnit,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    if (product.isOutOfStock)
                      Container(
                        width: double.infinity, height: 36,
                        decoration: BoxDecoration(color: AppColors.textHint.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('Unavailable', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
                      )
                    else if (isInCart)
                      _buildInCartControls(ref, cartItem!)
                    else
                      PressableScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart'), backgroundColor: AppColors.primary, duration: const Duration(seconds: 1)),
                          );
                        },
                        child: Container(
                          width: double.infinity, height: 36,
                          decoration: BoxDecoration(
                            gradient: PremiumGradients.button(),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: const Center(child: Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                        ),
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

  Widget _buildInCartControls(WidgetRef ref, CartItem cartItem) {
    return Column(
      children: [
        Row(children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text('In Cart (${cartItem.quantity})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ]),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQtyButton(Icons.remove, () { HapticFeedback.lightImpact(); ref.read(cartProvider.notifier).decrementQuantity(product.id); }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${cartItem.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            _buildQtyButton(Icons.add, () { HapticFeedback.lightImpact(); ref.read(cartProvider.notifier).incrementQuantity(product.id); }),
          ],
        ),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onPressed) {
    return PressableScale(
      onTap: onPressed, enableHaptic: false,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: Center(child: Icon(Icons.eco, size: 40, color: AppColors.primary.withOpacity(0.2))),
    );
  }

  static void _showProductDetail(BuildContext context, WidgetRef ref, Product product) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductDetailSheet(product: product),
    );
  }
}

/// Premium product detail bottom sheet (Zepto/Blinkit-style)
class _ProductDetailSheet extends ConsumerWidget {
  final Product product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.findByProductId(product.id);
    final isInCart = cartItem != null;
    final catMeta = product.category != null ? CategoryMeta.get(product.category!) : null;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
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
                          child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.imageUrl!, fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: Center(child: Icon(Icons.eco, size: 64, color: AppColors.primary.withOpacity(0.15))),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.surfaceAlt,
                                    child: Center(child: Icon(Icons.eco, size: 64, color: AppColors.primary.withOpacity(0.15))),
                                  ),
                                )
                              : Container(
                                  color: AppColors.surfaceAlt,
                                  child: Center(child: Icon(Icons.eco, size: 64, color: AppColors.primary.withOpacity(0.15))),
                                ),
                        ),
                        // Stock badge
                        Positioned(top: 12, left: 12, child: StatusBadge.stock(product.stockStatus)),
                        // Close button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: PressableScale(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
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
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Out of Stock',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: catMeta.color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catMeta.icon, size: 13, color: catMeta.color),
                                const SizedBox(width: 5),
                                Text(product.category!,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catMeta.color)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Product name
                        Text(product.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),

                        // Vendor
                        if (product.vendorName != null && product.vendorName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.store_rounded, size: 14, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Text('by ${product.vendorName!}',
                                  style: const TextStyle(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
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
                            border: Border.all(color: AppColors.primary.withOpacity(0.12)),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Price', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(product.pricePerUnit,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5)),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Stock', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text('${product.stockQuantity} ${product.productUnit ?? 'units'}',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                                          color: product.isOutOfStock ? AppColors.error : AppColors.textPrimary)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Description
                        if (product.description != null && product.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text(product.description!,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                        ],

                        // Delivery schedule
                        if (product.deliverySchedule != null && product.deliverySchedule!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, size: 18, color: AppColors.info),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(product.deliverySchedule!,
                                      style: TextStyle(fontSize: 13, color: AppColors.infoText, fontWeight: FontWeight.w500)),
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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: product.isOutOfStock
                  ? Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(color: AppColors.textHint.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Currently Unavailable', style: TextStyle(fontSize: 15, color: AppColors.textMuted, fontWeight: FontWeight.w600))),
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
                                      onTap: () { HapticFeedback.lightImpact(); ref.read(cartProvider.notifier).decrementQuantity(product.id); },
                                      child: Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: PremiumShadows.subtle()),
                                        child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                                      ),
                                    ),
                                    Text('${cartItem!.quantity}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                    PressableScale(
                                      onTap: () { HapticFeedback.lightImpact(); ref.read(cartProvider.notifier).incrementQuantity(product.id); },
                                      child: Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(gradient: PremiumGradients.button(), shape: BoxShape.circle),
                                        child: const Icon(Icons.add, color: Colors.white, size: 20),
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
                                CustomerShell.shellKey.currentState?.switchToTab(1);
                              },
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  gradient: PremiumGradients.button(),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: const Center(
                                  child: Text('View Cart', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
                                    const Icon(Icons.check_circle, color: Colors.white, size: 18),
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
                              gradient: PremiumGradients.button(),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
