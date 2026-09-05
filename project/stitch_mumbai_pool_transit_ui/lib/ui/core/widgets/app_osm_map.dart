import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Interactive OpenStreetMap view powered by flutter_map.
class AppOsmMap extends StatelessWidget {
  const AppOsmMap({super.key});

  static const LatLng _initialCenter = LatLng(37.7749, -122.4194);
  static const double _initialZoom = 14.0;
  static const String _packageName = 'stitch_mumbai_pool_transit_ui';

  static const LatLng _pickupLocation = _initialCenter;
  static const LatLng _driverLocation = LatLng(37.7765, -122.4168);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _initialCenter,
        initialZoom: _initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: _packageName,
        ),
        MarkerLayer(
          markers: [
            const Marker(
              point: _pickupLocation,
              width: 48,
              height: 48,
              alignment: Alignment.bottomCenter,
              child: Tooltip(
                message: 'Pickup Location',
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ),
            Marker(
              point: _driverLocation,
              width: 48,
              height: 48,
              child: Tooltip(
                message: 'Available Driver',
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
