import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/vendor_product_provider.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class VendorAddProductScreen extends ConsumerStatefulWidget {
  const VendorAddProductScreen({super.key});

  @override
  ConsumerState<VendorAddProductScreen> createState() =>
      _VendorAddProductScreenState();
}

class _VendorAddProductScreenState
    extends ConsumerState<VendorAddProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _unitQtyCtrl = TextEditingController(text: '1');
  final _imageUrlCtrl = TextEditingController();

  String _selectedUnit = 'kg';
  String _selectedCategory = 'VEGETABLES';
  String? _selectedSchedule;
  bool _isSaving = false;
  bool _isEditMode = false;
  Product? _editProduct;
  XFile? _pickedXFile;
  Uint8List? _pickedBytes;
  String? _previewUrl;

  late AnimationController _entranceCtrl;
  final _imagePicker = ImagePicker();

  static const _units = [
    'kg', 'g', 'L', 'mL', 'unit', 'piece', 'bunch', 'dozen',
  ];

  static const _categories = [
    'VEGETABLES', 'FRUITS', 'DAIRY', 'GRAINS',
    'PROTEINS', 'BEVERAGES', 'ORGANIC', 'OTHERS',
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _imageUrlCtrl.addListener(_onImageUrlChanged);
  }

  void _onImageUrlChanged() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      setState(() {
        _previewUrl = url;
        _pickedXFile = null;
        _pickedBytes = null;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final product = ModalRoute.of(context)?.settings.arguments as Product?;
    if (product != null && !_isEditMode) {
      _isEditMode = true;
      _editProduct = product;
      _nameCtrl.text = product.name;
      _priceCtrl.text = product.price.toString();
      _stockCtrl.text = product.stockQuantity.toString();
      _unitQtyCtrl.text = (product.unitQuantity ?? 1).toString();
      _selectedUnit = product.productUnit ?? 'kg';
      _selectedCategory = product.category ?? 'VEGETABLES';
      _selectedSchedule = product.deliverySchedule;
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        _imageUrlCtrl.text = product.imageUrl!;
        _previewUrl = product.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _unitQtyCtrl.dispose();
    _imageUrlCtrl.removeListener(_onImageUrlChanged);
    _imageUrlCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedXFile = picked;
          _pickedBytes = bytes;
          _previewUrl = null;
          _imageUrlCtrl.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Product Image',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      Icons.camera_alt_rounded,
                      'Camera',
                      AppColors.primary,
                      () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      Icons.photo_library_rounded,
                      'Gallery',
                      AppColors.info,
                      () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      Icons.link_rounded,
                      'URL',
                      AppColors.warning,
                      () {
                        Navigator.pop(ctx);
                        _showUrlDialog();
                      },
                    ),
                  ),
                ],
              ),
              if (_pickedXFile != null || _previewUrl != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _pickedXFile = null;
                        _pickedBytes = null;
                        _previewUrl = null;
                        _imageUrlCtrl.clear();
                      });
                    },
                    child: const Text(
                      'Remove Image',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    final urlCtrl = TextEditingController(text: _imageUrlCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.link_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Image URL',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
        content: TextField(
          controller: urlCtrl,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            labelText: 'Paste image URL',
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _imageUrlCtrl.text = urlCtrl.text.trim();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final user = ref.read(authStateProvider).user;
    if (user?.id == null || user?.vendorId == null) return;

    // Upload picked image to backend if available
    String? imageUrl = _imageUrlCtrl.text.trim().isNotEmpty
        ? _imageUrlCtrl.text.trim()
        : null;

    if (_pickedXFile != null) {
      try {
        final service = ref.read(productServiceProvider);
        imageUrl = await service.uploadProductImage(_pickedXFile!);
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    final data = {
      'productName': _nameCtrl.text.trim(),
      'productPrice': double.parse(_priceCtrl.text.trim()),
      'productQuantity': int.parse(_stockCtrl.text.trim()),
      'productUnit': _selectedUnit,
      'unitQuantity': double.parse(_unitQtyCtrl.text.trim()),
      'category': _selectedCategory,
      'vendorId': user!.vendorId,
      if (_selectedSchedule != null) 'deliverySchedule': _selectedSchedule,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    bool success;
    if (_isEditMode && _editProduct != null) {
      success = await ref
          .read(vendorProductsProvider.notifier)
          .updateProduct(_editProduct!.id, data, user.id!);
    } else {
      success = await ref
          .read(vendorProductsProvider.notifier)
          .createProduct(data, user.id!);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(_isEditMode
                    ? 'Product updated successfully!'
                    : 'Product created successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(vendorProductsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Something went wrong'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                  Text(
                    _isEditMode ? 'Edit Product' : 'Add Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---- Image upload card ----
                  StaggeredListItem(
                    index: 0,
                    animation: _entranceCtrl,
                    child: _buildImageCard(),
                  ),
                  const SizedBox(height: 16),
                  // ---- Form card ----
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: _buildFormCard(),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }

  // ---- Image upload section ----
  Widget _buildImageCard() {
    final hasImage = _pickedBytes != null || (_previewUrl != null && _previewUrl!.isNotEmpty);

    return Container(
      decoration: premiumCardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image preview / placeholder
          GestureDetector(
            onTap: _showImagePickerSheet,
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: hasImage ? _buildImagePreview() : _buildImagePlaceholder(),
            ),
          ),
          // Bottom bar with action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasImage ? 'Image added' : 'Add product image',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasImage ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showImagePickerSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasImage ? 'Change' : 'Upload',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedBytes != null) {
      return Image.memory(
        _pickedBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    if (_previewUrl != null && _previewUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _previewUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => _buildImageLoading(),
        errorWidget: (_, __, ___) => _buildImageError(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceAlt,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.textHint,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap to add product photo',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Camera, Gallery or URL',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageLoading() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: AppColors.textHint, size: 36),
          SizedBox(height: 6),
          Text(
            'Failed to load image',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ---- Form card ----
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: premiumCardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              Icons.inventory_2_rounded,
              AppColors.primary,
              'Product Details',
            ),
            const SizedBox(height: 16),

            _buildField(
              'Product Name',
              _nameCtrl,
              Icons.label_outline,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Min 2 characters'
                  : null,
            ),

            _buildField(
              'Price (\u20b9)',
              _priceCtrl,
              Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Price is required';
                final price = double.tryParse(v);
                if (price == null || price <= 0) return 'Enter a valid price';
                return null;
              },
            ),

            _buildField(
              'Stock Quantity',
              _stockCtrl,
              Icons.inventory_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Stock is required';
                final qty = int.tryParse(v);
                if (qty == null || qty < 0) return 'Enter a valid quantity';
                return null;
              },
            ),

            _buildDropdownField(
              'Product Unit',
              Icons.straighten_outlined,
              _selectedUnit,
              _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
              (v) => setState(() => _selectedUnit = v ?? 'kg'),
            ),

            _buildField(
              'Unit Quantity',
              _unitQtyCtrl,
              Icons.numbers_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Unit quantity is required';
                final qty = double.tryParse(v);
                if (qty == null || qty <= 0) return 'Enter a valid quantity';
                return null;
              },
            ),

            _buildDropdownField(
              'Category',
              Icons.category_outlined,
              _selectedCategory,
              _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0] + c.substring(1).toLowerCase()),
                      ))
                  .toList(),
              (v) => setState(() => _selectedCategory = v ?? 'VEGETABLES'),
            ),

            _buildDropdownField(
              'Delivery Schedule (Optional)',
              Icons.calendar_today_outlined,
              _selectedSchedule,
              [
                const DropdownMenuItem(value: null, child: Text('No specific schedule')),
                const DropdownMenuItem(value: 'SATURDAY', child: Text('Saturday')),
                const DropdownMenuItem(value: 'SUNDAY', child: Text('Sunday')),
              ],
              (v) => setState(() => _selectedSchedule = v),
              isLast: true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving ? AppColors.textHint : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Product' : 'Add Product',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, Color color, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPrefixIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 18),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: _buildPrefixIcon(icon),
        ),
        validator: validator ??
            ((v) => (v == null || v.trim().isEmpty) ? '$label is required' : null),
      ),
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    IconData icon,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: _buildPrefixIcon(icon),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
