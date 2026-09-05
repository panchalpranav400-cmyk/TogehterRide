import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_osm_map.dart';

class ActiveTripDriverView extends StatefulWidget {
  final VoidCallback onCompleteTrip;

  const ActiveTripDriverView({super.key, required this.onCompleteTrip});

  @override
  State<ActiveTripDriverView> createState() => _ActiveTripDriverViewState();
}

class _ActiveTripDriverViewState extends State<ActiveTripDriverView> {
  LatLng? _driverLocation;

  @override
  void initState() {
    super.initState();
    _loadDriverLocation();
  }

  Future<void> _loadDriverLocation() async {
    final result = await LocationService.getCurrentLocation();
    if (!mounted || !result.isSuccess) return;
    setState(() => _driverLocation = result.coordinate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191C1D), // Dark mode background
      body: Stack(
        children: [
          // Mapbox Dark Navigation View
          Positioned.fill(
            child: AppOsmMap(
              mapThemeMode: MapThemeMode.navigation,
              originLabel: 'WEH Bandra Flyover',
              destinationLabel: 'Lower Parel Hub',
              driverCoordinate: _driverLocation,
              showRoutePolyline: true,
              showDriverLocation: true,
              isInteractive: true,
            ),
          ),

          // Top Turn Instruction Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.turn_right, color: AppColors.primaryFixed, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Turn Right',
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 22,
                            color: AppColors.primaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'in 200m on Linking Road',
                          style: AppTypography.headlineSmall.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryFixedDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Current Trip Sequence Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle Bar
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

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Trip',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.outline),
                            const SizedBox(width: 4),
                            Text('14 mins left', style: AppTypography.labelMonoSmall),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sequence Stop 1
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.secondary,
                        child: Text('1', style: AppTypography.labelMonoSmall.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NEXT STOP', style: AppTypography.labelMonoSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                            Text('Pickup Priya', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            Text('Bandra West Station', style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.surfaceContainerLow,
                        child: Icon(Icons.person, size: 18, color: AppColors.primary),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                    child: Divider(),
                  ),

                  // Sequence Stop 2
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        child: Text('2', style: AppTypography.labelMonoSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Drop Aarav', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            Text('BKC Complex', style: AppTypography.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: widget.onCompleteTrip,
                            child: Text('Complete Stop', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.sos, color: AppColors.error, size: 26),
                          onPressed: () {},
                        ),
                      ),
                    ],
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
