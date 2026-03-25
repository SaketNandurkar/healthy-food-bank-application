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
      final valid = await ref.read(authServiceProvider).validateVendorCode(code);
      if (mounted) setState(() {
        _isCodeValid = valid;
        _isValidatingCode = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _isCodeValid = false;
        _isValidatingCode = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
      );
      return;
    }
    HapticFeedback.mediumImpact();

    final user = User(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      phoneNumber: _phoneCtrl.text.trim(),
      role: UserRole.values.firstWhere((r) => r.toString().split('.').last == _selectedRole),
      userName: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      pickupPointId: _selectedPickupPointId,
    );

    final message = await ref.read(authStateProvider.notifier).register(
      user,
      vendorCode: _selectedRole == 'VENDOR' ? _vendorCodeCtrl.text.trim() : null,
    );

    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.primary),
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
                    'Create Account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildForm(authState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthState authState) {
    return StaggeredListItem(
      index: 0,
      animation: _entranceCtrl,
      child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: PremiumShadows.elevated(),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: PremiumShadows.glow(AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(authState.error!,
                              style: const TextStyle(color: AppColors.errorText, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],

                _buildField('First Name', _firstNameCtrl, Icons.person_outline,
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Min 2 characters' : null),
                _buildField('Last Name', _lastNameCtrl, Icons.person_outline,
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Min 2 characters' : null),
                _buildField('Email (optional)', _emailCtrl, Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress, required: false),
                _buildField('Phone Number', _phoneCtrl, Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    validator: (v) => (v == null || v.length != 10) ? '10-digit phone number required' : null),

                // Role selection
                const SizedBox(height: 8),
                const Text('Select Role',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: ['CUSTOMER', 'VENDOR', 'ADMIN'].map((role) {
                    final isSelected = _selectedRole == role;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PressableScale(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedRole = role);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: isSelected ? PremiumGradients.button() : null,
                              color: isSelected ? null : AppColors.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppColors.primary.withOpacity(0.15),
                              ),
                              boxShadow: isSelected ? PremiumShadows.glow(AppColors.primary) : null,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  role == 'CUSTOMER' ? Icons.shopping_bag_outlined
                                      : role == 'VENDOR' ? Icons.store_outlined
                                      : Icons.admin_panel_settings_outlined,
                                  size: 22,
                                  color: isSelected ? Colors.white : AppColors.primary,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  role[0] + role.substring(1).toLowerCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Conditional fields
                if (_selectedRole == 'VENDOR') ...[
                  TextFormField(
                    controller: _vendorCodeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Vendor Code',
                      hintText: 'Enter vendor code',
                      prefixIcon: _buildPrefixIcon(Icons.vpn_key_outlined),
                      suffixIcon: _isValidatingCode
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2)))
                          : _isCodeValid == true
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : _isCodeValid == false
                                  ? const Icon(Icons.cancel, color: AppColors.error)
                                  : null,
                    ),
                    onChanged: (v) => _validateVendorCode(v),
                    validator: (v) => (v == null || v.length < 5) ? 'Valid vendor code required' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_selectedRole == 'CUSTOMER' && _pickupPoints.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedPickupPointId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Pickup Point',
                      hintText: 'Select pickup point',
                      prefixIcon: _buildPrefixIcon(Icons.location_on_outlined),
                    ),
                    items: _pickupPoints.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(p.displayText, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedPickupPointId = v),
                    validator: (v) => v == null ? 'Please select a pickup point' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                _buildField('Username', _usernameCtrl, Icons.badge_outlined,
                    validator: (v) => (v == null || v.trim().length < 3) ? 'Min 3 characters' : null),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Min 6 characters',
                    prefixIcon: _buildPrefixIcon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textHint, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: _buildPrefixIcon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textHint, size: 20),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                PressableScale(
                  onTap: authState.isLoading ? null : _handleRegister,
                  enableHaptic: false,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: authState.isLoading ? null : PremiumGradients.button(),
                      color: authState.isLoading ? AppColors.textHint : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: authState.isLoading
                          ? null
                          : [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: authState.isLoading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Create Account',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text('Sign in here',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      child: Icon(icon, color: AppColors.primary.withOpacity(0.7), size: 20),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: _buildPrefixIcon(icon),
        ),
        validator: required
            ? validator ?? ((v) => (v == null || v.trim().isEmpty) ? '$label is required' : null)
            : null,
      ),
    );
  }
}
