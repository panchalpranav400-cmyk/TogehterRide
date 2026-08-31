import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class RoleSelectionView extends StatelessWidget {
  final Function(String role) onRoleSelected;

  const RoleSelectionView({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TogetherRide',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 26,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Verified badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Email Verified Successfully',
                      style: AppTypography.labelMonoMedium.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ──
              Text(
                'Choose Your\nRole',
                style: AppTypography.headlineLarge.copyWith(
                  fontSize: 34,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How would you like to use TogetherRide?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 36),

              // ── Passenger Button ──
              _RoleCard(
                label: 'Passenger',
                subtitle: 'Find & join pooled rides easily',
                description: 'Search for available pools, split costs with fellow commuters, and arrive safely.',
                icon: Icons.directions_car_rounded,
                badgeText: 'POPULAR',
                isPrimary: true,
                onTap: () => onRoleSelected('passenger'),
              ),

              const SizedBox(height: 16),

              // ── Driver Button ──
              _RoleCard(
                label: 'Driver',
                subtitle: 'Offer seats & split fuel costs',
                description: 'Share your daily route, earn money on every trip, and build a trusted community.',
                icon: Icons.vpn_key_rounded,
                badgeText: 'EARN',
                isPrimary: false,
                onTap: () => onRoleSelected('driver'),
              ),

              const Spacer(),

              // ── Footer ──
              Center(
                child: Text(
                  'You can switch roles anytime in settings.',
                  style: AppTypography.labelMonoSmall.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
//  ROLE CARD — Full-width premium card with description
// ──────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final String label;
  final String subtitle;
  final String description;
  final IconData icon;
  final String badgeText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.badgeText,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary ? AppColors.secondary : Colors.transparent;
    final fgColor = widget.isPrimary ? AppColors.onSecondary : AppColors.surfaceTint;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppColors.surfaceTint, width: 1.5),
            boxShadow: [
              if (widget.isPrimary)
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: _pressed ? 0.42 : 0.25),
                  blurRadius: _pressed ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              if (!widget.isPrimary && _pressed)
                BoxShadow(
                  color: AppColors.surfaceTint.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isPrimary
                          ? Colors.white.withValues(alpha: 0.22)
                          : AppColors.surfaceTint.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: fgColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.label,
                              style: AppTypography.headlineSmall.copyWith(
                                color: fgColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.isPrimary
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : AppColors.surfaceTint.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.badgeText,
                                style: AppTypography.labelMonoSmall.copyWith(
                                  fontSize: 9,
                                  color: fgColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: AppTypography.labelMonoSmall.copyWith(
                            color: fgColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: fgColor.withValues(alpha: 0.8), size: 22),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: fgColor.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: fgColor.withValues(alpha: 0.80),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
