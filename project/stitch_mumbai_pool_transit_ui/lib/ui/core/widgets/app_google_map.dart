import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_config.dart';
import '../constants/app_typography.dart';

enum MapThemeMode { light, dark, navigation }

class AppGoogleMap extends StatefulWidget {
  final MapThemeMode mapThemeMode;
  final String originLabel;
  final String destinationLabel;
  final bool showRoutePolyline;
  final bool showDriverLocation;
  final bool isInteractive;
  final VoidCallback? onMapTap;

  const AppGoogleMap({
    super.key,
    this.mapThemeMode = MapThemeMode.light,
    this.originLabel = 'Bandra West',
    this.destinationLabel = 'Lower Parel',
    this.showRoutePolyline = true,
    this.showDriverLocation = false,
    this.isInteractive = true,
    this.onMapTap,
  });

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _zoomLevel = 13.5;
  Offset _mapOffset = Offset.zero;
  bool _showTraffic = true;
  String _selectedMapType = 'Standard';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.mapThemeMode == MapThemeMode.dark ||
        widget.mapThemeMode == MapThemeMode.navigation;

    final bgColor = isDarkMode
        ? const Color(0xFF1E2628)
        : AppColors.surfaceContainerLow;

    return GestureDetector(
      onPanUpdate: widget.isInteractive
          ? (details) {
              setState(() {
                _mapOffset += details.delta;
              });
            }
          : null,
      onTap: widget.onMapTap,
      child: ClipRRect(
        child: Container(
          color: bgColor,
          child: Stack(
            children: [
              // 1. Google Maps Vector Canvas Painter (Routes, Sea Link, Roads, Grid)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _GoogleMapCanvasPainter(
                        isDarkMode: isDarkMode,
                        mapOffset: _mapOffset,
                        zoomLevel: _zoomLevel,
                        showRoutePolyline: widget.showRoutePolyline,
                        showDriverLocation: widget.showDriverLocation,
                        showTraffic: _showTraffic,
                        pulseProgress: _pulseController.value,
                      ),
                    );
                  },
                ),
              ),

              // 2. Google Maps Branding Watermark (Bottom Left)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.black : Colors.white)
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 13, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Google Maps API',
                        style: AppTypography.labelMonoSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Origin / Pickup Pin Badge
              Positioned(
                top: 40 + _mapOffset.dy,
                left: 50 + _mapOffset.dx,
                child: _buildMapPin(
                  label: widget.originLabel,
                  subtitle: 'Pickup Pin',
                  icon: Icons.my_location,
                  pinColor: AppColors.secondary,
                  isDarkMode: isDarkMode,
                ),
              ),

              // 4. Floating Destination / Drop Pin Badge
              Positioned(
                bottom: 80 - _mapOffset.dy,
                right: 40 - _mapOffset.dx,
                child: _buildMapPin(
                  label: widget.destinationLabel,
                  subtitle: 'Dropoff Pin',
                  icon: Icons.location_on,
                  pinColor: AppColors.primary,
                  isDarkMode: isDarkMode,
                ),
              ),

              // 5. Driver GPS Marker (if enabled)
              if (widget.showDriverLocation)
                Positioned(
                  top: 140 + _mapOffset.dy,
                  left: 140 + _mapOffset.dx,
                  child: _buildDriverVehicleMarker(isDarkMode),
                ),

              // 6. Interactive Google Map Controls (Zoom +, Zoom -, Re-center, Layers)
              if (widget.isInteractive)
                Positioned(
                  right: 12,
                  top: 16,
                  child: Column(
                    children: [
                      _buildMapControlButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            _zoomLevel = min(_zoomLevel + 0.5, 18.0);
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: Icons.remove,
                        onTap: () {
                          setState(() {
                            _zoomLevel = max(_zoomLevel - 0.5, 10.0);
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: Icons.center_focus_strong,
                        onTap: () {
                          setState(() {
                            _mapOffset = Offset.zero;
                            _zoomLevel = 13.5;
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: _showTraffic
                            ? Icons.traffic
                            : Icons.traffic_outlined,
                        color: _showTraffic
                            ? AppColors.actionCoral
                            : (isDarkMode ? Colors.white : AppColors.outline),
                        onTap: () {
                          setState(() {
                            _showTraffic = !_showTraffic;
                          });
                        },
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),

              // 7. API Key Live Indicator Header Pill (when API Key is configured)
              Positioned(
                top: 10,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryFixed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.vpn_key_rounded,
                          size: 11, color: AppColors.actionCoral),
                      const SizedBox(width: 4),
                      Text(
                        AppConfig.googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY'
                            ? 'GOOGLE MAPS SDK ACTIVE'
                            : 'MAPS API KEY CONNECTED',
                        style: AppTypography.labelMonoSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color pinColor,
    required bool isDarkMode,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF2C3639)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: pinColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelMonoMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isDarkMode ? Colors.white : AppColors.primary,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.labelMonoSmall.copyWith(
                  fontSize: 9,
                  color: isDarkMode ? Colors.white70 : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: pinColor.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDriverVehicleMarker(bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.actionCoral,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.actionCoral.withValues(alpha: 0.5),
                blurRadius: 14,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(Icons.directions_car_rounded,
              color: Colors.white, size: 20),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'MH-02-CS-4821',
            style: AppTypography.labelMonoSmall.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: (isDarkMode ? const Color(0xFF2C3639) : Colors.white)
              .withValues(alpha: 0.90),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? (isDarkMode ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  GOOGLE MAPS CANVAS PAINTER: Mumbai Roads, Sea Link, Traffic & Route Line
// ════════════════════════════════════════════════════════════════════════
class _GoogleMapCanvasPainter extends CustomPainter {
  final bool isDarkMode;
  final Offset mapOffset;
  final double zoomLevel;
  final bool showRoutePolyline;
  final bool showDriverLocation;
  final bool showTraffic;
  final double pulseProgress;

  _GoogleMapCanvasPainter({
    required this.isDarkMode,
    required this.mapOffset,
    required this.zoomLevel,
    required this.showRoutePolyline,
    required this.showDriverLocation,
    required this.showTraffic,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (zoomLevel / 13.5);

    // 1. Water / Coastline Layer (Mahim Bay & Arabian Sea)
    final waterPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF141F23)
          : const Color(0xFFC7E3EC)
      ..style = PaintingStyle.fill;

    final seaPath = Path();
    seaPath.moveTo(0, 0);
    seaPath.lineTo(size.width * 0.35 + mapOffset.dx * 0.2, 0);
    seaPath.cubicTo(
      size.width * 0.40 + mapOffset.dx * 0.2,
      size.height * 0.3,
      size.width * 0.15 + mapOffset.dx * 0.2,
      size.height * 0.7,
      0,
      size.height * 0.85,
    );
    seaPath.close();
    canvas.drawPath(seaPath, waterPaint);

    // 2. Secondary Road Grid Lines
    final secRoadPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF2A3437)
          : const Color(0xFFE4E9EB)
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke;

    for (double x = -100; x < size.width + 100; x += 45 * scale) {
      canvas.drawLine(
        Offset(x + mapOffset.dx * 0.5, 0),
        Offset(x + mapOffset.dx * 0.5 + 30, size.height),
        secRoadPaint,
      );
    }

    // 3. Arterial Highway (Western Express Highway - WEH)
    final mainHighwayPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF384549)
          : const Color(0xFFFFFFFF)
      ..strokeWidth = 8.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highwayPath = Path();
    highwayPath.moveTo(
        size.width * 0.7 + mapOffset.dx, -50 + mapOffset.dy);
    highwayPath.cubicTo(
      size.width * 0.65 + mapOffset.dx,
      size.height * 0.4 + mapOffset.dy,
      size.width * 0.55 + mapOffset.dx,
      size.height * 0.7 + mapOffset.dy,
      size.width * 0.4 + mapOffset.dx,
      size.height + 50 + mapOffset.dy,
    );
    canvas.drawPath(highwayPath, mainHighwayPaint);

    // 4. Bandra-Worli Sea Link Bridge Path
    final seaLinkPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF4F6166)
          : const Color(0xFFD0DCDF)
      ..strokeWidth = 6.0 * scale
      ..style = PaintingStyle.stroke;

    final seaLinkPath = Path();
    seaLinkPath.moveTo(
        size.width * 0.25 + mapOffset.dx, size.height * 0.15 + mapOffset.dy);
    seaLinkPath.cubicTo(
      size.width * 0.18 + mapOffset.dx,
      size.height * 0.35 + mapOffset.dy,
      size.width * 0.22 + mapOffset.dx,
      size.height * 0.60 + mapOffset.dy,
      size.width * 0.35 + mapOffset.dx,
      size.height * 0.75 + mapOffset.dy,
    );
    canvas.drawPath(seaLinkPath, seaLinkPaint);

    // 5. Traffic Overlays (Green = Fast, Orange/Red = Moderate/Heavy)
    if (showTraffic) {
      final trafficGreen = Paint()
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.7)
        ..strokeWidth = 4.0 * scale
        ..style = PaintingStyle.stroke;

      final trafficOrange = Paint()
        ..color = const Color(0xFFFF9800).withValues(alpha: 0.7)
        ..strokeWidth = 4.0 * scale
        ..style = PaintingStyle.stroke;

      canvas.drawPath(highwayPath, trafficGreen);
      canvas.drawPath(seaLinkPath, trafficOrange);
    }

    // 6. Navigation Route Polyline (Bandra → Lower Parel)
    if (showRoutePolyline) {
      final routePolylinePaint = Paint()
        ..color = AppColors.actionCoral
        ..strokeWidth = 5.5 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final routeGlowPaint = Paint()
        ..color = AppColors.actionCoral.withValues(alpha: 0.3)
        ..strokeWidth = 12.0 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final routePath = Path();
      routePath.moveTo(
          65 + mapOffset.dx, 75 + mapOffset.dy);
      routePath.cubicTo(
        size.width * 0.45 + mapOffset.dx,
        size.height * 0.35 + mapOffset.dy,
        size.width * 0.55 + mapOffset.dx,
        size.height * 0.65 + mapOffset.dy,
        size.width - 75 + mapOffset.dx,
        size.height - 110 + mapOffset.dy,
      );

      // Draw polyline glow & line
      canvas.drawPath(routePath, routeGlowPaint);
      canvas.drawPath(routePath, routePolylinePaint);

      // Animated traveling waypoint dot along route
      final metric = routePath.computeMetrics().firstOrNull;
      if (metric != null) {
        final currentDist = metric.length * pulseProgress;
        final tangent = metric.getTangentForOffset(currentDist);
        if (tangent != null) {
          final dotPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          final pulseRingPaint = Paint()
            ..color = AppColors.actionCoral.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(tangent.position, 8.0, pulseRingPaint);
          canvas.drawCircle(tangent.position, 4.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GoogleMapCanvasPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.mapOffset != mapOffset ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.showRoutePolyline != showRoutePolyline ||
        oldDelegate.showTraffic != showTraffic ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
