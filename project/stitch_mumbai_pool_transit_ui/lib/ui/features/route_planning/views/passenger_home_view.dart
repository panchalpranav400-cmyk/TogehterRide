import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_osm_map.dart';

class PassengerHomeView extends StatefulWidget {
  final VoidCallback onSearchPools;

  const PassengerHomeView({super.key, required this.onSearchPools});

  @override
  State<PassengerHomeView> createState() => _PassengerHomeViewState();
}

class _PassengerHomeViewState extends State<PassengerHomeView> {
  final TextEditingController originController = TextEditingController(text: 'Bandra West');
  final TextEditingController destController = TextEditingController();
  int selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // OpenStreetMap Interactive View
          const Positioned.fill(
            child: AppOsmMap(),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
                      onPressed: () {},
                    ),
                    Text(
                      'TogetherRide',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emergency_share, color: AppColors.onSurfaceVariant),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Set Route Sheet (Bottom Main Area)
          Positioned(
            left: 16,
            right: 16,
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Set Route',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Route Inputs with Timeline Decorator
                  Stack(
                    children: [
                      // Timeline Line
                      Positioned(
                        left: 18,
                        top: 18,
                        bottom: 18,
                        child: Container(
                          width: 2,
                          color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      Column(
                        children: [
                          // Origin Input
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: originController,
                                    decoration: const InputDecoration(
                                      hintText: 'Current Location',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Destination Input
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.secondary, width: 2.5),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: destController,
                                    decoration: const InputDecoration(
                                      hintText: 'Where to?',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Find Pooled Ride Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryFixedDim,
                        foregroundColor: AppColors.onTertiaryContainer,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.onSearchPools,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Find a pooled ride',
                            style: AppTypography.headlineSmall.copyWith(
                              fontSize: 18,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.directions_car, color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home, 'Home'),
                  _buildNavItem(1, Icons.alt_route, 'My Trips'),
                  _buildNavItem(2, Icons.person, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = selectedNavIndex == index;
    return InkWell(
      onTap: () => setState(() => selectedNavIndex = index),
      child: isSelected
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(icon, color: AppColors.onPrimaryContainer, size: 24),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTypography.labelMonoSmall),
              ],
            ),
    );
  }
}

