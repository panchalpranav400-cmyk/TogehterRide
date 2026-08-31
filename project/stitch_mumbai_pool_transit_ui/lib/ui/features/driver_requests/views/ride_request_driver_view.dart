import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_google_map.dart';

class RideRequestDriverView extends StatelessWidget {
  final VoidCallback onAcceptRequest;
  final VoidCallback onDeclineRequest;

  const RideRequestDriverView({
    super.key,
    required this.onAcceptRequest,
    required this.onDeclineRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: const Icon(Icons.menu, color: AppColors.primary),
        title: Text('TogetherRide', style: AppTypography.headlineMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency_share, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps Driver Request Background Canvas
          const Positioned.fill(
            child: AppGoogleMap(
              mapThemeMode: MapThemeMode.light,
              originLabel: 'Pickup: Bandra West',
              destinationLabel: 'Dropoff: Lower Parel',
              showRoutePolyline: true,
              showDriverLocation: true,
              isInteractive: true,
            ),
          ),

          // Driver Status Pill Top
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiaryFixedDim,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Searching for Pool...', style: AppTypography.labelMonoMedium),
                  ],
                ),
              ),
            ),
          ),

          // Transactional Request Card (Bottom)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Linear Progress Bar Countdown Top
                  const ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    child: LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 4,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Pool Request',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text('Accept within 15s', style: AppTypography.bodyMedium),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.route, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '95% Match',
                                    style: AppTypography.labelMonoSmall.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Bento Grid
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.group, color: AppColors.primary, size: 22),
                                    const SizedBox(height: 8),
                                    Text('3 Passengers', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                                    Text('VERIFIED', style: AppTypography.labelMonoSmall),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.payments, color: AppColors.primary, size: 22),
                                    const SizedBox(height: 8),
                                    Text('+₹120', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                                    Text('EST. EXTRA', style: AppTypography.labelMonoSmall),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Timeline Pickup/Dropoff
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('PICKUP (+2 MIN DETOUR)', style: AppTypography.labelMonoSmall),
                                      Text('Bandra West Station', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.secondary, width: 2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DROPOFF (ON ROUTE)', style: AppTypography.labelMonoSmall),
                                      Text('BKC Complex Gate 4', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: onDeclineRequest,
                                  child: Text('Decline', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: AppColors.primary)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: onAcceptRequest,
                                  child: Text('Accept Pool Request', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
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
}
