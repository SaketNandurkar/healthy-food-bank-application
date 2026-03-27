import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../models/pickup_point.dart';
import '../../providers/auth_provider.dart';
import '../../services/pickup_point_service.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _vendorCodeCtrl = TextEditingController();

  String _selectedRole = 'CUSTOMER';
  int? _selectedPickupPointId;
  List<PickupPoint> _pickupPoints = [];
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isValidatingCode = false;
  bool? _isCodeValid;
  late AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loadPickupPoints();
  }

  Future<void> _loadPickupPoints() async {
    try {
      final points = await PickupPointService().getActivePickupPoints();
      if (mounted) setState(() => _pickupPoints = points);
    } catch (_) {}
  }

  Future<void> _validateVendorCode(String code) async {
    if (code.length < 5) {
      setState(() => _isCodeValid = null);
      return;
    }
    setState(() => _isValidatingCode = true);
    try {
      final valid =
          await ref.read(authServiceProvider).validateVendorCode(code);
      if (mounted) {
        setState(() {
          _isCodeValid = valid;
          _isValidatingCode = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCodeValid = false;
          _isValidatingCode = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();

    final user = User(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phoneNumber: _phoneCtrl.text.trim(),
      role: UserRole.values.firstWhere(
        (r) => r.toString().split('.').last == _selectedRole,
      ),
      userName: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      pickupPointId: _selectedPickupPointId,
    );

    final message = await ref.read(authStateProvider.notifier).register(
          user,
          vendorCode:
              _selectedRole == 'VENDOR' ? _vendorCodeCtrl.text.trim() : null,
        );

    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _vendorCodeCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Flat white header with back button
          _buildFlatHeader(),

          // Scrollable form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // Error banner
                  _buildErrorBanner(authState),

                  // Form card
                  StaggeredListItem(
                    index: 0,
                    animation: _entranceCtrl,
                    child: _buildFormCard(authState),
                  ),

                  const SizedBox(height: 24),

                  // Sign in link
                  StaggeredListItem(
                    index: 1,
                    animation: _entranceCtrl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Sign in here',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Green header — back button + title
  // ---------------------------------------------------------------------------
  Widget _buildFlatHeader() {
    return PremiumHeader(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            PressableScale(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error banner
  // ---------------------------------------------------------------------------
  Widget _buildErrorBanner(AuthState authState) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: authState.error != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: const TextStyle(
                        color: AppColors.errorText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ---------------------------------------------------------------------------
  // Form card — white bg, subtle border, all fields inside
  // ---------------------------------------------------------------------------
  Widget _buildFormCard(AuthState authState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: PremiumShadows.subtle(),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Personal Information ──
            _buildSectionLabel('Personal Information'),
            const SizedBox(height: 12),

            // First Name + Last Name in a row
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    icon: Icons.person_outlined,
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    icon: Icons.person_outlined,
                    validator: (v) =>
                        (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Email
            _buildField(
              controller: _emailCtrl,
              label: 'Email (optional)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              required: false,
            ),
            const SizedBox(height: 14),

            // Phone
            _buildField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) =>
                  (v == null || v.length != 10) ? '10-digit number required' : null,
            ),

            const SizedBox(height: 20),

            // ── Role Selection ──
            _buildSectionLabel('Select Role'),
            const SizedBox(height: 10),
            _buildRoleSelector(),

            const SizedBox(height: 16),

            // ── Conditional Fields ──
            // Vendor code field
            if (_selectedRole == 'VENDOR') ...[
              _buildVendorCodeField(),
              const SizedBox(height: 14),
            ],

            // Pickup point dropdown
            if (_selectedRole == 'CUSTOMER' && _pickupPoints.isNotEmpty) ...[
              _buildPickupPointDropdown(),
              const SizedBox(height: 14),
            ],

            const SizedBox(height: 6),

            // ── Account Details ──
            _buildSectionLabel('Account Details'),
            const SizedBox(height: 12),

            // Username
            _buildField(
              controller: _usernameCtrl,
              label: 'Username',
              icon: Icons.badge_outlined,
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Min 3 characters' : null,
            ),
            const SizedBox(height: 14),

            // Password
            _buildPasswordField(
              controller: _passwordCtrl,
              label: 'Password',
              hint: 'Min 6 characters',
              obscure: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 14),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPasswordCtrl,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your password';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // ── Submit Button ──
            _buildSubmitButton(authState),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section label
  // ---------------------------------------------------------------------------
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Role selector — 3 pill buttons: Customer / Vendor / Admin
  // ---------------------------------------------------------------------------
  Widget _buildRoleSelector() {
    return Row(
      children: ['CUSTOMER', 'VENDOR', 'ADMIN'].map((role) {
        final isSelected = _selectedRole == role;
        final label = role[0] + role.substring(1).toLowerCase();
        final IconData icon;
        switch (role) {
          case 'CUSTOMER':
            icon = Icons.shopping_bag_outlined;
            break;
          case 'VENDOR':
            icon = Icons.store_outlined;
            break;
          default:
            icon = Icons.admin_panel_settings_outlined;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: role == 'CUSTOMER' ? 0 : 4,
              right: role == 'ADMIN' ? 0 : 4,
            ),
            child: PressableScale(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedRole = role;
                  // Reset conditional fields
                  if (role != 'VENDOR') {
                    _vendorCodeCtrl.clear();
                    _isCodeValid = null;
                  }
                  if (role != 'CUSTOMER') {
                    _selectedPickupPointId = null;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Vendor code field with validation indicator
  // ---------------------------------------------------------------------------
  Widget _buildVendorCodeField() {
    return TextFormField(
      controller: _vendorCodeCtrl,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Vendor Code',
        hintText: 'Enter vendor code',
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: _buildPrefixIcon(Icons.vpn_key_outlined),
        suffixIcon: _isValidatingCode
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : _isCodeValid == true
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : _isCodeValid == false
                    ? const Icon(Icons.cancel, color: AppColors.error)
                    : null,
      ),
      onChanged: (v) => _validateVendorCode(v),
      validator: (v) =>
          (v == null || v.length < 5) ? 'Valid vendor code required' : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Pickup point dropdown
  // ---------------------------------------------------------------------------
  Widget _buildPickupPointDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedPickupPointId,
      isExpanded: true,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Pickup Point',
        hintText: 'Select pickup point',
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: _buildPrefixIcon(Icons.location_on_outlined),
      ),
      items: _pickupPoints.map((p) {
        return DropdownMenuItem(
          value: p.id,
          child: Text(
            p.displayText,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _selectedPickupPointId = v),
      validator: (v) => v == null ? 'Please select a pickup point' : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Generic text field
  // ---------------------------------------------------------------------------
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: _buildPrefixIcon(icon),
      ),
      validator: required
          ? validator ??
              ((v) =>
                  (v == null || v.trim().isEmpty) ? '$label is required' : null)
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Password field with visibility toggle
  // ---------------------------------------------------------------------------
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: _buildPrefixIcon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
    );
  }

  // ---------------------------------------------------------------------------
  // Prefix icon — small colored circle with icon
  // ---------------------------------------------------------------------------
  Widget _buildPrefixIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.primary.withOpacity(0.7),
        size: 18,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Submit button — flat green, no gradient shadow
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton(AuthState authState) {
    return PressableScale(
      onTap: authState.isLoading ? null : _handleRegister,
      enableHaptic: false,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: authState.isLoading
              ? AppColors.textHint
              : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: authState.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}
