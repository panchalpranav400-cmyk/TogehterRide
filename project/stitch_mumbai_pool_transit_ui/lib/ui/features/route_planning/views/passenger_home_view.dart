import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/trip_route.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/app_osm_map.dart';

class PassengerHomeView extends StatefulWidget {
  final ValueChanged<TripRoute> onSearchPools;

  const PassengerHomeView({super.key, required this.onSearchPools});

  @override
  State<PassengerHomeView> createState() => _PassengerHomeViewState();
}

class _PassengerHomeViewState extends State<PassengerHomeView> {
  final TextEditingController originController = TextEditingController(text: 'Bandra West');
  final TextEditingController destController = TextEditingController();
  int selectedNavIndex = 0;

  LatLng? _originCoord;
  LatLng? _destCoord;
  bool _locatingUser = false;
  bool _searchingRoute = false;

  @override
  void initState() {
    super.initState();
    // Best-effort: prefill the origin with the device's current location.
    _useCurrentLocation(silent: true);
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() => _locatingUser = true);
    final result = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (result.isSuccess) {
      final coord = result.coordinate!;
      final placeName = await GeocodingService.reverseGeocode(coord);
      if (!mounted) return;
      setState(() {
        _originCoord = coord;
        originController.text = placeName ?? 'Current Location';
        _locatingUser = false;
      });
    } else {
      setState(() => _locatingUser = false);
      if (!silent) {
        _showSnack(_messageForLocationFailure(result.failure));
      }
    }
  }

  String _messageForLocationFailure(LocationFailure? failure) {
    switch (failure) {
      case LocationFailure.serviceDisabled:
        return 'Turn on device location to use your current position.';
      case LocationFailure.permissionDenied:
        return 'Location permission denied.';
      case LocationFailure.permissionDeniedForever:
        return 'Location permission is blocked — enable it from app settings.';
      case LocationFailure.unavailable:
      case null:
        return 'Could not get your current location.';
    }
  }

  Future<void> _geocodeOrigin(String text) async {
    if (text.trim().isEmpty) {
      setState(() => _originCoord = null);
      return;
    }
    setState(() => _searchingRoute = true);
    final place = await GeocodingService.forwardGeocode(text);
    if (!mounted) return;
    setState(() => _searchingRoute = false);
    if (place == null) {
      _showSnack('Could not find "$text".');
      return;
    }
    setState(() => _originCoord = place.coordinate);
  }

  Future<void> _geocodeDestination(String text) async {
    if (text.trim().isEmpty) {
      setState(() => _destCoord = null);
      return;
    }
    setState(() => _searchingRoute = true);
    final place = await GeocodingService.forwardGeocode(text);
    if (!mounted) return;
    setState(() => _searchingRoute = false);
    if (place == null) {
      _showSnack('Could not find "$text".');
      return;
    }
    setState(() => _destCoord = place.coordinate);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleFindPooledRide() async {
    // Resolve any text the user typed but never submitted before handing off.
    if (_originCoord == null && originController.text.trim().isNotEmpty) {
      await _geocodeOrigin(originController.text);
    }
    if (_destCoord == null && destController.text.trim().isNotEmpty) {
      await _geocodeDestination(destController.text);
    }
    if (!mounted) return;

    widget.onSearchPools(
      TripRoute(
        originLabel:
            originController.text.isEmpty ? 'Your Location' : originController.text,
        destinationLabel:
            destController.text.isEmpty ? 'Destination' : destController.text,
        originCoordinate: _originCoord,
        destinationCoordinate: _destCoord,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Mapbox Interactive View
          Positioned.fill(
            child: AppOsmMap(
              originLabel: originController.text.isEmpty
                  ? 'Your Location'
                  : originController.text,
              destinationLabel: destController.text.isEmpty
                  ? 'Choose destination'
                  : destController.text,
              originCoordinate: _originCoord,
              destinationCoordinate: _destCoord,
              showRoutePolyline: _originCoord != null && _destCoord != null,
            ),
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
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: _geocodeOrigin,
                                    onChanged: (text) {
                                      if (text.trim().isEmpty) {
                                        setState(() => _originCoord = null);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Current Location',
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 14),
                                      suffixIcon: _locatingUser
                                          ? const Padding(
                                              padding: EdgeInsets.all(14),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.my_location,
                                                  size: 20, color: AppColors.secondary),
                                              tooltip: 'Use current location',
                                              onPressed: () => _useCurrentLocation(),
                                            ),
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
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: _geocodeDestination,
                                    onChanged: (text) {
                                      if (text.trim().isEmpty) {
                                        setState(() => _destCoord = null);
                                      }
                                    },
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

                  if (_searchingRoute) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 2),
                  ],

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
                      onPressed: _handleFindPooledRide,
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

