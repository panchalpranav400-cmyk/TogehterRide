import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_google_map.dart';

class LiveTripPassengerView extends StatelessWidget {
  final VoidCallback onTripFinished;

  const LiveTripPassengerView({super.key, required this.onTripFinished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
        title: Text('TogetherRide', style: AppTypography.headlineMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: AppColors.error,
              child: IconButton(
                icon: const Icon(Icons.emergency_share, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps Live Tracking View
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.58,
            child: const AppGoogleMap(
              mapThemeMode: MapThemeMode.light,
              originLabel: 'Bandra Station',
              destinationLabel: 'Lower Parel One International Center',
              showRoutePolyline: true,
              showDriverLocation: true,
              isInteractive: true,
            ),
          ),

          // Bottom Trip Details Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 24, offset: Offset(0, -6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // ETA & Share Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('12 mins', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, fontSize: 32)),
                          Text('Arriving at Drop-off', style: AppTypography.bodyMedium),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.share, size: 16, color: AppColors.primary),
                        label: Text('Share Trip', style: AppTypography.labelMonoMedium.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Driver Info Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text('AS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Arjun S.', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: AppColors.secondary),
                                        const SizedBox(width: 2),
                                        Text('4.9', style: AppTypography.labelMonoSmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('White Maruti Dzire • MH 01 AB 1234', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stops Timeline
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_remove, size: 16, color: AppColors.outline),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Bandra Kurla Complex', style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
                                  Text('Dropping Priya', style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('2 MINS', style: AppTypography.labelMonoSmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Lower Parel Station', style: AppTypography.headlineSmall.copyWith(fontSize: 14, color: AppColors.primary)),
                                  Text('Your Destination', style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('12 MINS', style: AppTypography.labelMonoSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Actions & Simulate Arrival Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            foregroundColor: AppColors.onSurface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.call, size: 18),
                          label: const Text('Call Driver'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            foregroundColor: AppColors.onSurface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.shield, size: 18),
                          label: const Text('Safety Toolkit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onTripFinished,
                      child: Text(
                        'Simulate Arrived at Destination',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
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
