import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// Compact quantity stepper (Blinkit-style: green border, +/- buttons).
class QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QtyStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = compact ? 28.0 : 32.0;
    final iconSize = compact ? 14.0 : 16.0;
    final fontSize = compact ? 13.0 : 14.0;

    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.remove, onDecrement, iconSize, height),
          Container(
            constraints: BoxConstraints(minWidth: compact ? 28 : 32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          _buildButton(Icons.add, onIncrement, iconSize, height),
        ],
      ),
    );
  }

  Widget _buildButton(
      IconData icon, VoidCallback onTap, double iconSize, double height) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: height,
        height: height,
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: AppColors.primary),
      ),
    );
  }
}
