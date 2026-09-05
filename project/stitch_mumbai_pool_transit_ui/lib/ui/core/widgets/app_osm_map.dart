import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';
import '../constants/app_config.dart';

/// Visual theme for [AppOsmMap] — selects the underlying Mapbox style.
enum MapThemeMode { light, dark, navigation }

/// Interactive Mapbox-tiled map view powered by flutter_map.
///
/// Renders real Mapbox tiles using [AppConfig.mapboxAccessToken], with a
/// pickup/dropoff pin pair, an optional route line, an optional driver
/// marker, animated zoom controls, and a "fly to" camera animation whenever
/// the resolved origin/destination changes.
class AppOsmMap extends StatefulWidget {
  final MapThemeMode mapThemeMode;
  final String originLabel;
  final String destinationLabel;

  /// Explicit coordinates (e.g. from geocoding or the device's GPS). When
  /// omitted, the widget falls back to matching [originLabel]/
  /// [destinationLabel] against [AppConfig.mumbaiCoordinates].
  final LatLng? originCoordinate;
  final LatLng? destinationCoordinate;

  /// Explicit driver marker position (e.g. the device's real GPS fix on a
  /// driver-facing screen). When omitted, falls back to a point interpolated
  /// along the origin→destination line, for demo screens with no live driver.
  final LatLng? driverCoordinate;

  final bool showRoutePolyline;
  final bool showDriverLocation;
  final bool isInteractive;
  final VoidCallback? onMapTap;

  const AppOsmMap({
    super.key,
    this.mapThemeMode = MapThemeMode.light,
    this.originLabel = 'Bandra West',
    this.destinationLabel = 'Lower Parel',
    this.originCoordinate,
    this.destinationCoordinate,
    this.driverCoordinate,
    this.showRoutePolyline = true,
    this.showDriverLocation = false,
    this.isInteractive = true,
    this.onMapTap,
  });

  @override
  State<AppOsmMap> createState() => _AppOsmMapState();
}

class _AppOsmMapState extends State<AppOsmMap> with TickerProviderStateMixin {
  static const String _packageName = 'stitch_mumbai_pool_transit_ui';
  static const double _minZoom = 4.0;
  static const double _maxZoom = 18.0;
  static const LatLng _defaultCenter =
      LatLng(AppConfig.defaultLat, AppConfig.defaultLng);

  late final MapController _mapController;
  AnimationController? _flyController;

  late LatLng _origin;
  late LatLng _destination;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _origin = _resolveOrigin(widget);
    _destination = _resolveDestination(widget);

    WidgetsBinding.instance.addPostFrameCallback((_) => _flyInOnLoad());
  }

  @override
  void didUpdateWidget(covariant AppOsmMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newOrigin = _resolveOrigin(widget);
    final newDestination = _resolveDestination(widget);
    final driverMoved = widget.showDriverLocation &&
        oldWidget.driverCoordinate != widget.driverCoordinate;

    if (newOrigin != _origin || newDestination != _destination) {
      setState(() {
        _origin = newOrigin;
        _destination = newDestination;
      });
      _flyToBounds();
    } else if (driverMoved) {
      _flyToBounds();
    }
  }

  @override
  void dispose() {
    _flyController?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  static LatLng _coordinateForLabel(String label, LatLng fallback) {
    final normalized = label.toLowerCase();
    for (final entry in AppConfig.mumbaiCoordinates.entries) {
      final keyTokens = entry.key.toLowerCase().split(' ');
      final isMatch = keyTokens.any(
        (token) => token.length > 3 && normalized.contains(token),
      );
      if (isMatch) {
        return LatLng(entry.value[0], entry.value[1]);
      }
    }
    return fallback;
  }

  static LatLng _pointAlong(LatLng a, LatLng b, double t) {
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  LatLng _resolveOrigin(AppOsmMap w) {
    if (w.originCoordinate != null) return w.originCoordinate!;
    return _coordinateForLabel(
      w.originLabel,
      _pointAlong(_defaultCenter, const LatLng(19.08, 72.82), 0.3),
    );
  }

  LatLng _resolveDestination(AppOsmMap w) {
    if (w.destinationCoordinate != null) return w.destinationCoordinate!;
    return _coordinateForLabel(
      w.destinationLabel,
      _pointAlong(_defaultCenter, const LatLng(18.97, 72.85), 0.3),
    );
  }

  LatLng get _driverLocation =>
      widget.driverCoordinate ?? _pointAlong(_origin, _destination, 0.35);

  String get _mapboxStyleId {
    switch (widget.mapThemeMode) {
      case MapThemeMode.dark:
      case MapThemeMode.navigation:
        return 'dark-v11';
      case MapThemeMode.light:
        return 'streets-v12';
    }
  }

  LatLngBounds get _routeBounds => LatLngBounds.fromPoints(
        widget.showDriverLocation
            ? [_origin, _destination, _driverLocation]
            : [_origin, _destination],
      );

  /// Animates the camera from ([fromCenter], [fromZoom]) to ([toCenter],
  /// [toZoom]) over [duration]. Superseded animations cancel cleanly.
  Future<void> _animateCamera({
    required LatLng fromCenter,
    required double fromZoom,
    required LatLng toCenter,
    required double toZoom,
    required Duration duration,
    required Curve curve,
  }) async {
    _flyController?.dispose();
    final controller = AnimationController(vsync: this, duration: duration);
    _flyController = controller;

    final curved = CurvedAnimation(parent: controller, curve: curve);
    final latTween =
        Tween<double>(begin: fromCenter.latitude, end: toCenter.latitude);
    final lngTween =
        Tween<double>(begin: fromCenter.longitude, end: toCenter.longitude);
    final zoomTween = Tween<double>(begin: fromZoom, end: toZoom);

    void listener() {
      if (!mounted) return;
      _mapController.move(
        LatLng(latTween.evaluate(curved), lngTween.evaluate(curved)),
        zoomTween.evaluate(curved),
      );
    }

    controller.addListener(listener);
    try {
      await controller.forward().orCancel;
    } catch (_) {
      // Superseded by a newer animation — nothing to clean up.
    } finally {
      controller.removeListener(listener);
      if (identical(_flyController, controller)) {
        _flyController = null;
      }
      controller.dispose();
    }
  }

  /// One-time "fly in" from a wide, zoomed-out view down to the initial route
  /// on first mount.
  Future<void> _flyInOnLoad() async {
    if (!mounted) return;
    final target = CameraFit.bounds(
      bounds: _routeBounds,
      padding: const EdgeInsets.all(64),
      minZoom: _minZoom,
    ).fit(_mapController.camera);

    await _animateCamera(
      fromCenter: target.center,
      fromZoom: (target.zoom - 4).clamp(_minZoom, _maxZoom),
      toCenter: target.center,
      toZoom: target.zoom,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
    );
  }

  /// "Fly out" of the current view, then "fly in" to the new route bounds —
  /// used whenever the resolved origin/destination changes.
  Future<void> _flyToBounds() async {
    if (!mounted) return;
    final current = _mapController.camera;
    final target = CameraFit.bounds(
      bounds: _routeBounds,
      padding: const EdgeInsets.all(64),
      minZoom: _minZoom,
    ).fit(current);

    final outZoom = (current.zoom - 2.5).clamp(_minZoom, _maxZoom);
    await _animateCamera(
      fromCenter: current.center,
      fromZoom: current.zoom,
      toCenter: current.center,
      toZoom: outZoom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    if (!mounted) return;

    await _animateCamera(
      fromCenter: current.center,
      fromZoom: outZoom,
      toCenter: target.center,
      toZoom: target.zoom,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOutCubic,
    );
  }

  void _zoomBy(double delta) {
    final current = _mapController.camera;
    final targetZoom = (current.zoom + delta).clamp(_minZoom, _maxZoom);
    _animateCamera(
      fromCenter: current.center,
      fromZoom: current.zoom,
      toCenter: current.center,
      toZoom: targetZoom,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _routeBounds.center,
            initialZoom: AppConfig.defaultZoom,
            interactionOptions: InteractionOptions(
              flags: widget.isInteractive
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
            onTap:
                widget.onMapTap == null ? null : (_, __) => widget.onMapTap!(),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/$_mapboxStyleId/tiles/{z}/{x}/{y}@2x?access_token={accessToken}',
              additionalOptions: {
                'accessToken': AppConfig.mapboxAccessToken,
              },
              userAgentPackageName: _packageName,
            ),
            if (widget.showRoutePolyline)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_origin, _destination],
                    strokeWidth: 5,
                    color: AppColors.actionCoral,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _origin,
                  width: 48,
                  height: 48,
                  alignment: Alignment.bottomCenter,
                  child: _PopInMarker(
                    triggerKey: _origin,
                    child: Tooltip(
                      message: widget.originLabel,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Marker(
                  point: _destination,
                  width: 48,
                  height: 48,
                  alignment: Alignment.bottomCenter,
                  child: _PopInMarker(
                    triggerKey: _destination,
                    child: Tooltip(
                      message: widget.destinationLabel,
                      child: const Icon(
                        Icons.flag,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                if (widget.showDriverLocation)
                  Marker(
                    point: _driverLocation,
                    width: 44,
                    height: 44,
                    child: _PopInMarker(
                      triggerKey: _driverLocation,
                      child: Tooltip(
                        message: 'Driver',
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
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
                  ),
              ],
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('Mapbox © OpenStreetMap', onTap: () {}),
              ],
            ),
          ],
        ),
        if (widget.isInteractive)
          Positioned(
            right: 12,
            top: 16,
            child: Column(
              children: [
                _ZoomButton(icon: Icons.add, onTap: () => _zoomBy(1)),
                const SizedBox(height: 8),
                _ZoomButton(icon: Icons.remove, onTap: () => _zoomBy(-1)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Fades + scales its child in whenever [triggerKey] changes, giving markers
/// a "fly in" feel when a new route is resolved.
class _PopInMarker extends StatefulWidget {
  final Object triggerKey;
  final Widget child;

  const _PopInMarker({required this.triggerKey, required this.child});

  @override
  State<_PopInMarker> createState() => _PopInMarkerState();
}

class _PopInMarkerState extends State<_PopInMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _PopInMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerKey != widget.triggerKey) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    return ScaleTransition(
      scale: curved,
      child: FadeTransition(
        opacity: _controller,
        child: widget.child,
      ),
    );
  }
}
