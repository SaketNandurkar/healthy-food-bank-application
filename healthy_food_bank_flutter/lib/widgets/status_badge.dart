import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order.dart';

/// Compact pill badge for stock status and order status.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const StatusBadge._({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  /// Stock status badge.
  factory StatusBadge.stock(String status) {
    switch (status) {
      case 'In Stock':
        return const StatusBadge._(
          label: 'IN STOCK',
          bgColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
      case 'Low Stock':
        return const StatusBadge._(
          label: 'LOW STOCK',
          bgColor: AppColors.warningLight,
          textColor: AppColors.warningText,
        );
      case 'Out of Stock':
        return const StatusBadge._(
          label: 'OUT OF STOCK',
          bgColor: AppColors.errorLight,
          textColor: AppColors.errorText,
        );
      default:
        return StatusBadge._(
          label: status.toUpperCase(),
          bgColor: AppColors.surfaceAlt,
          textColor: AppColors.textMuted,
        );
    }
  }

  /// Order status badge.
  factory StatusBadge.order(OrderStatus status) {
    switch (status) {
      case OrderStatus.DELIVERED:
        return const StatusBadge._(
          label: 'DELIVERED',
          bgColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
      case OrderStatus.PROCESSING:
        return const StatusBadge._(
          label: 'PROCESSING',
          bgColor: AppColors.infoLight,
          textColor: AppColors.infoText,
        );
      case OrderStatus.CANCELLED:
      case OrderStatus.CANCELLED_BY_VENDOR:
        return StatusBadge._(
          label: status == OrderStatus.CANCELLED ? 'CANCELLED' : 'VENDOR CANCELLED',
          bgColor: AppColors.errorLight,
          textColor: AppColors.errorText,
        );
      case OrderStatus.SCHEDULED:
        return const StatusBadge._(
          label: 'SCHEDULED',
          bgColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
      case OrderStatus.ISSUED:
        return const StatusBadge._(
          label: 'ISSUED',
          bgColor: AppColors.infoLight,
          textColor: AppColors.infoText,
        );
      case OrderStatus.PENDING:
      default:
        return const StatusBadge._(
          label: 'PENDING',
          bgColor: AppColors.warningLight,
          textColor: AppColors.warningText,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
