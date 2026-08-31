import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

class RideMatchingAnimation extends StatefulWidget {
  final String? statusMessage;

  const RideMatchingAnimation({
    super.key,
    this.statusMessage,
  });

  @override
  State<RideMatchingAnimation> createState() => _RideMatchingAnimationState();
}

class _RideMatchingAnimationState extends State<RideMatchingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _pulseController;
  late AnimationController _textTickerController;

  int _textIndex = 0;
  final List<String> _statusTickerMessages = [
    'Looking for available rides nearby...',
    'Finding best pool matches on your route...',
    'Matching you with verified drivers...',
    'Optimizing fare split & detour...',
  ];

  @override
  void initState() {
    super.initState();
    // Continuous road & car movement controller (looping smoothly)
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Radar pulse wave expansion controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Ticker text cycler
    _textTickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _textIndex = (_textIndex + 1) % _statusTickerMessages.length;
          });
          _textTickerController.forward(from: 0);
        }
      });
    _textTickerController.forward();
  }

  @override
  void dispose() {
    _carController.dispose();
    _pulseController.dispose();
    _textTickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatusText = widget.statusMessage ?? _statusTickerMessages[_textIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated Car & Radar Canvas Container
        SizedBox(
          height: 140,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing Radar Rings
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 140),
                    painter: _RadarPulsePainter(
                      progress: _pulseController.value,
                    ),
                  );
                },
              ),

              // Animated Driving Car on Moving Road
              AnimatedBuilder(
                animation: _carController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(300, 100),
                    painter: _AnimatedDrivingCarPainter(
                      progress: _carController.value,
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Animated Status Indicator Banner
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.actionCoral,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                currentStatusText,
                key: ValueKey<String>(currentStatusText),
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Connecting commuters in real-time',
          style: AppTypography.labelMonoSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Custom Painter for expanding radar scanning waves
class _RadarPulsePainter extends CustomPainter {
  final double progress;

  _RadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.33)) % 1.0;
      final radius = waveProgress * maxRadius;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.3;

      final paint = Paint()
        ..color = AppColors.actionCoral.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Custom Painter for continuous moving road lines and driving car silhouette
class _AnimatedDrivingCarPainter extends CustomPainter {
  final double progress;

  _AnimatedDrivingCarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final roadY = size.height * 0.70;
    const startX = 20.0;
    final endX = size.width - 20.0;
    final roadWidth = endX - startX;

    // 1. Draw Base Road Line
    final roadPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, roadY), Offset(endX, roadY), roadPaint);

    // 2. Draw Scrolling Dashed Motion Lines underneath
    final dashPaint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.3)
      ..strokeWidth = 2.5;

    const dashWidth = 14.0;
    const dashGap = 10.0;
    const totalDashPeriod = dashWidth + dashGap;
    final offsetShift = (progress * totalDashPeriod) % totalDashPeriod;

    for (double x = startX - totalDashPeriod + offsetShift; x < endX; x += totalDashPeriod) {
      final drawX1 = x.clamp(startX, endX);
      final drawX2 = (x + dashWidth).clamp(startX, endX);
      if (drawX2 > drawX1) {
        canvas.drawLine(Offset(drawX1, roadY + 8), Offset(drawX2, roadY + 8), dashPaint);
      }
    }

    // 3. Compute Car X Position (moves smoothly from left to right)
    // To make continuous driving look natural, car moves across the road line repeatedly
    final carX = startX + (roadWidth * ((progress * 0.9 + 0.05) % 1.0));
    final carY = roadY - 10;

    // Motion shadow under car
    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(carX, roadY + 1), width: 36, height: 6),
      shadowPaint,
    );

    canvas.save();
    canvas.translate(carX, carY);

    // Speed Lines behind car
    final speedLinePaint = Paint()
      ..color = AppColors.actionCoral.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-22, -2), const Offset(-14, -2), speedLinePaint);
    canvas.drawLine(const Offset(-26, 2), const Offset(-16, 2), speedLinePaint);

    // Car Outer Body (Minimalist modern sedan silhouette)
    final carBodyPaint = Paint()..color = AppColors.primary;
    final bodyPath = Path();
    bodyPath.moveTo(-16, 4);
    bodyPath.lineTo(-16, -2);
    bodyPath.quadraticBezierTo(-15, -6, -8, -7);
    bodyPath.lineTo(-3, -12);
    bodyPath.lineTo(6, -12);
    bodyPath.quadraticBezierTo(11, -7, 14, -4);
    bodyPath.lineTo(16, 4);
    bodyPath.close();

    canvas.drawPath(bodyPath, carBodyPaint);

    // Car Roof / Windows Accent
    final windowPaint = Paint()..color = AppColors.tertiaryFixedDim;
    final windowPath = Path();
    windowPath.moveTo(-6, -6);
    windowPath.lineTo(-2, -10);
    windowPath.lineTo(5, -10);
    windowPath.lineTo(8, -6);
    windowPath.close();
    canvas.drawPath(windowPath, windowPaint);

    // Wheels
    final wheelPaint = Paint()..color = AppColors.secondary;
    canvas.drawCircle(const Offset(-9, 5), 4, wheelPaint);
    canvas.drawCircle(const Offset(9, 5), 4, wheelPaint);

    // Wheel hubs
    final hubPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-9, 5), 1.5, hubPaint);
    canvas.drawCircle(const Offset(9, 5), 1.5, hubPaint);

    // Headlight Beam Accent
    final headlightPaint = Paint()
      ..color = AppColors.tertiaryFixedDim.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final lightPath = Path();
    lightPath.moveTo(16, 0);
    lightPath.lineTo(24, -4);
    lightPath.lineTo(24, 4);
    lightPath.close();
    canvas.drawPath(lightPath, headlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnimatedDrivingCarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
