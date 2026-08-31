import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/ride_matching_animation.dart';

class RideMatchingWaitingView extends StatefulWidget {
  final VoidCallback onMatchFound;
  final VoidCallback onCancel;

  const RideMatchingWaitingView({
    super.key,
    required this.onMatchFound,
    required this.onCancel,
  });

  @override
  State<RideMatchingWaitingView> createState() => _RideMatchingWaitingViewState();
}

class _RideMatchingWaitingViewState extends State<RideMatchingWaitingView> {
  Timer? _matchingTimer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time matching lookup (2.2 seconds) before finding the match
    _matchingTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        widget.onMatchFound();
      }
    });
  }

  @override
  void dispose() {
    _matchingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Map Background Area (Identical to MatchFoundView for seamless visual continuity)
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            color: AppColors.surfaceContainerLow,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPathPainter(),
                  ),
                ),
                // Location Pulse Marker
                Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Back / Cancel Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surface.withValues(alpha: 0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: widget.onCancel,
              ),
            ),
          ),

          // Bottom Sheet Waiting Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Drag Handle
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header Title
                  Text(
                    'Finding Your Ride',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Matching you with drivers heading your way...',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Animated Ride-Matching Waiting Experience
                  const RideMatchingAnimation(),

                  const SizedBox(height: 24),

                  // Cancel Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.onCancel,
                      child: Text(
                        'Cancel Request',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
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
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.5,
        size.width * 0.6,
        size.height * 0.4,
        size.width * 0.9,
        size.height * 0.2,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
