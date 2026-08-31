import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_google_map.dart';

class MatchFoundView extends StatelessWidget {
  final VoidCallback onConfirmBooking;
  final VoidCallback onBack;

  const MatchFoundView({
    super.key,
    required this.onConfirmBooking,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Google Maps Match Route Preview Canvas
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: const AppGoogleMap(
              mapThemeMode: MapThemeMode.light,
              originLabel: 'Bandra Station West',
              destinationLabel: 'Lower Parel Hub',
              showRoutePolyline: true,
              showDriverLocation: true,
              isInteractive: true,
            ),
          ),

          // Top Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: onBack,
              ),
            ),
          ),

          // Bottom Sheet Match Details
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 32,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header & Verified Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pool Match Found',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text('Pickup in 3 mins', style: AppTypography.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixedDim.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.tertiaryFixedDim.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield, size: 16, color: AppColors.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              'VERIFIED',
                              style: AppTypography.labelMonoSmall.copyWith(
                                color: AppColors.tertiary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bento Grid Metrics
                  Row(
                    children: [
                      // Match Overlap
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryContainer,
                                    child: Icon(Icons.route, size: 14, color: AppColors.onPrimaryContainer),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Overlap', style: AppTypography.labelMonoMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('90%', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary)),
                              Text('+4 min detour', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Fare Split
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.secondaryContainer.withValues(alpha: 0.2),
                                    child: const Icon(Icons.payments, size: 14, color: AppColors.secondary),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Fare Split', style: AppTypography.labelMonoMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('₹120', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary)),
                              Text('Saved ₹85', style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Co-Passengers Overview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('2 Co-passengers', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                            Text('Verified corporate profiles', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                          ],
                        ),
                        Row(
                          children: [
                            const CircleAvatar(radius: 16, backgroundColor: AppColors.primaryContainer, child: Text('PD', style: TextStyle(color: Colors.white, fontSize: 10))),
                            const SizedBox(width: 4),
                            const CircleAvatar(radius: 16, backgroundColor: AppColors.secondary, child: Text('AM', style: TextStyle(color: Colors.white, fontSize: 10))),
                            const SizedBox(width: 4),
                            CircleAvatar(radius: 16, backgroundColor: AppColors.surfaceContainerHigh, child: Text('+1', style: AppTypography.labelMonoSmall)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onConfirmBooking,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Confirm & Join Pool', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: onBack,
                      child: Text('Decline Match', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.7)
      ..cubicTo(size.width * 0.3, size.height * 0.5, size.width * 0.6, size.height * 0.4, size.width * 0.9, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
