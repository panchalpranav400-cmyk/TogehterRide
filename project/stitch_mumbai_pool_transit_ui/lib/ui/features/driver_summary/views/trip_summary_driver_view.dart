import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class TripSummaryDriverView extends StatelessWidget {
  final VoidCallback onReturnHome;

  const TripSummaryDriverView({super.key, required this.onReturnHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: onReturnHome,
        ),
        title: Text('Trip Summary', style: AppTypography.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              children: [
                // Success Hero Section
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: AppColors.primary, size: 44),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Trip Completed',
                      style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Great job! Here is the summary of your recent ride.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Earnings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('TOTAL EARNINGS', style: AppTypography.labelMonoSmall),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('₹', style: AppTypography.headlineMedium.copyWith(color: AppColors.primary)),
                          Text('345', style: AppTypography.headlineLarge.copyWith(fontSize: 44, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.timer, color: AppColors.secondary, size: 20),
                                  const SizedBox(height: 4),
                                  Text('DURATION', style: AppTypography.labelMonoSmall),
                                  Text('42 min', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.route, color: AppColors.secondary, size: 20),
                                  const SizedBox(height: 4),
                                  Text('DISTANCE', style: AppTypography.labelMonoSmall),
                                  Text('14.2 km', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Passenger Details Snippet
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text('RD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rohan Desai', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: AppColors.tertiaryFixedDim),
                                const SizedBox(width: 2),
                                Text('4.9 Rating', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceVariant,
                        child: Icon(Icons.chat, size: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Route Timeline
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PICKUP • 08:30 AM', style: AppTypography.labelMonoSmall),
                              Text('Bandra Kurla Complex', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.secondary, width: 2.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DROP-OFF • 09:12 AM', style: AppTypography.labelMonoSmall),
                              Text('Lower Parel Business Park', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Status & Action Anchored
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, -6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Online', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        Text('Waiting for next match...', style: AppTypography.labelMonoSmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onReturnHome,
                      child: Text('Return to Dashboard', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: Colors.white)),
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
