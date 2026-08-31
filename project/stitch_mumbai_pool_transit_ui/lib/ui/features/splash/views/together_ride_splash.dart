import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class TogetherRideSplashScreen extends StatefulWidget {
  final VoidCallback onSplashComplete;

  const TogetherRideSplashScreen({
    super.key,
    required this.onSplashComplete,
  });

  @override
  State<TogetherRideSplashScreen> createState() => _TogetherRideSplashScreenState();
}

class _TogetherRideSplashScreenState extends State<TogetherRideSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _carTravelAnimation;
  late Animation<double> _brandFadeAnimation;
  late Animation<double> _brandScaleAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Car silhouette moves smoothly along road curve from 0.0 to 1.0 (between 0% and 75% of duration)
    _carTravelAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.70, curve: Curves.easeInOutCubic),
    );

    // TogetherRide Title fades in (between 30% and 75%)
    _brandFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );

    // TogetherRide Title scales gently into position
    _brandScaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // Tagline / Subtitle fades in (between 55% and 90%)
    _taglineFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.90, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          widget.onSplashComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Branded Ambient Background Layer with subtle gradient lighting
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.2),
                      radius: 1.2,
                      colors: [
                        Color(0xFF0D3B41), // Deep Teal lighter center
                        AppColors.primary, // #002429 primary base
                      ],
                    ),
                  ),
                ),
              ),

              // Animated Intersecting Road / Connection Curves
              Positioned.fill(
                child: CustomPaint(
                  painter: _SplashRoadPainter(
                    progress: _carTravelAnimation.value,
                  ),
                ),
              ),

              // Main Content: Brand Logo & Text Reveal
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Animated Icon / Emblem with Motion Accent
                      Transform.scale(
                        scale: _brandScaleAnimation.value,
                        child: Opacity(
                          opacity: _brandFadeAnimation.value,
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.45),
                                  blurRadius: 28,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Dominant Brand Name: TOGETHER RIDE
                      Transform.scale(
                        scale: _brandScaleAnimation.value,
                        child: Opacity(
                          opacity: _brandFadeAnimation.value,
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'TOGETHER',
                                      style: AppTypography.headlineLarge.copyWith(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'RIDE',
                                      style: AppTypography.headlineLarge.copyWith(
                                        color: AppColors.actionCoral,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 48,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.actionCoral,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle Tagline communicating movement & connection
                      Opacity(
                        opacity: _taglineFadeAnimation.value,
                        child: Text(
                          'RIDE  •  CONNECT  •  COMMUTE',
                          style: AppTypography.labelMonoMedium.copyWith(
                            color: Colors.white70,
                            letterSpacing: 3.0,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Subtle Loading Indicator / Footer Badge
                      Opacity(
                        opacity: _taglineFadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: AppColors.primaryFixedDim,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Verified Mumbai Community',
                                style: AppTypography.labelMonoSmall.copyWith(
                                  color: AppColors.primaryFixedDim,
                                  fontSize: 11,
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
            ],
          );
        },
      ),
    );
  }
}

/// Custom painter rendering smooth road curves and a car silhouette driving along the path
class _SplashRoadPainter extends CustomPainter {
  final double progress;

  _SplashRoadPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = AppColors.primaryFixed.withValues(alpha: 0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final activePathPaint = Paint()
      ..color = AppColors.actionCoral.withValues(alpha: 0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(-size.width * 0.1, size.height * 0.65);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.65,
      size.height * 0.35,
      size.width * 1.1,
      size.height * 0.45,
    );

    // Draw background road path
    canvas.drawPath(path, pathPaint);

    // Calculate current car position on path
    final metrics = path.computeMetrics().firstOrNull;
    if (metrics != null) {
      final currentDistance = metrics.length * progress;
      final extractPath = metrics.extractPath(0, currentDistance);
      canvas.drawPath(extractPath, activePathPaint);

      final tangent = metrics.getTangentForOffset(currentDistance);
      if (tangent != null) {
        final position = tangent.position;
        final angle = tangent.angle;

        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(angle);

        // Motion trail behind car
        final trailPaint = Paint()
          ..color = AppColors.actionCoral.withValues(alpha: 0.6)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(-18, 0), const Offset(-4, 0), trailPaint);

        // Car Body Silhouette
        final carPaint = Paint()..color = AppColors.actionCoral;
        final carRect = RRect.fromLTRBR(-8, -5, 8, 5, const Radius.circular(3));
        canvas.drawRRect(carRect, carPaint);

        // Car Roof / Window Accent
        final roofPaint = Paint()..color = Colors.white;
        canvas.drawRect(const Rect.fromLTWH(-3, -3, 6, 6), roofPaint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashRoadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
