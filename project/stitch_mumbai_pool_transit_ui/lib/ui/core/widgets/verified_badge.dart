import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class VerifiedBadge extends StatelessWidget {
  final String label;

  const VerifiedBadge({super.key, this.label = 'Verified'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warmAmber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.warmAmber, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.tertiaryContainer),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelMonoSmall.copyWith(
              color: AppColors.tertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
