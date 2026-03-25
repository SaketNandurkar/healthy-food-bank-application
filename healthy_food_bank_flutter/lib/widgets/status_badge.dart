import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../utils/premium_decorations.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 10,
  });

  factory StatusBadge.stock(String status) {
    switch (status) {
      case 'Out of Stock':
        return const StatusBadge(
          text: 'OUT OF STOCK',
          backgroundColor: AppColors.errorLight,
          textColor: AppColors.errorText,
        );
      case 'Low Stock':
        return const StatusBadge(
          text: 'LOW STOCK',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warningText,
        );
      default:
        return const StatusBadge(
          text: 'IN STOCK',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
    }
  }

  factory StatusBadge.order(OrderStatus status) {
    switch (status) {
      case OrderStatus.DELIVERED:
        return const StatusBadge(
          text: 'DELIVERED',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
      case OrderStatus.PROCESSING:
        return const StatusBadge(
          text: 'PROCESSING',
          backgroundColor: AppColors.infoLight,
          textColor: AppColors.infoText,
        );
      case OrderStatus.CANCELLED:
        return const StatusBadge(
          text: 'CANCELLED',
          backgroundColor: AppColors.errorLight,
          textColor: AppColors.errorText,
        );
      case OrderStatus.CANCELLED_BY_VENDOR:
        return const StatusBadge(
          text: 'CANCELLED BY VENDOR',
          backgroundColor: AppColors.errorLight,
          textColor: AppColors.errorText,
        );
      case OrderStatus.ISSUED:
        return const StatusBadge(
          text: 'ISSUED',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warningText,
        );
      case OrderStatus.SCHEDULED:
        return const StatusBadge(
          text: 'SCHEDULED',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.successText,
        );
      default:
        return const StatusBadge(
          text: 'PENDING',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warningText,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: PremiumShadows.glow(textColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
