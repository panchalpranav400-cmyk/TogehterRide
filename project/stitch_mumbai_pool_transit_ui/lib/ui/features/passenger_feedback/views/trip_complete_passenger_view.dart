import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class TripCompletePassengerView extends StatefulWidget {
  final VoidCallback onReturnHome;

  const TripCompletePassengerView({super.key, required this.onReturnHome});

  @override
  State<TripCompletePassengerView> createState() => _TripCompletePassengerViewState();
}

class _TripCompletePassengerViewState extends State<TripCompletePassengerView> {
  int rating = 4;
  final TextEditingController feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Circle Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.primary, size: 48),
                ),
                const SizedBox(height: 16),

                Text(
                  'Trip Finished',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have arrived at your destination.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 28),

                // Fare Summary & Rating Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Total Fare Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Fare', style: AppTypography.bodyLarge),
                          Text('₹120', style: AppTypography.headlineLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),

                      // Driver Profile
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rajesh K.', style: AppTypography.headlineSmall.copyWith(fontSize: 16)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.tertiaryFixedDim),
                                    const SizedBox(width: 2),
                                    Text('4.8 • MH 01 AB 1234', style: AppTypography.labelMonoSmall),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Rating Section
                      Text('How was your trip?', style: AppTypography.bodyMedium),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: AppColors.tertiaryFixedDim,
                              size: 36,
                            ),
                            onPressed: () => setState(() => rating = index + 1),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Feedback Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEAVE FEEDBACK (OPTIONAL)', style: AppTypography.labelMonoSmall),
                    const SizedBox(height: 6),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tell us about your experience...',
                        fillColor: AppColors.surfaceContainerLow,
                        filled: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: widget.onReturnHome,
                    child: Text('Book Next Ride', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.surfaceTint, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.download, color: AppColors.surfaceTint, size: 20),
                    label: Text('Download Invoice', style: AppTypography.headlineSmall.copyWith(fontSize: 16, color: AppColors.surfaceTint)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
