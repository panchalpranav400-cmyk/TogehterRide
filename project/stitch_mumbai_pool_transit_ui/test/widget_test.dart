import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stitch_mumbai_pool_transit_ui/main.dart';
import 'package:stitch_mumbai_pool_transit_ui/ui/core/widgets/verified_badge.dart';
import 'package:stitch_mumbai_pool_transit_ui/ui/features/splash/views/together_ride_splash.dart';

void main() {
  testWidgets('TogetherRideApp loads splash screen successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TogetherRideApp());

    // Verify splash screen widget renders
    expect(find.byType(TogetherRideSplashScreen), findsOneWidget);
    expect(find.textContaining('TOGETHER', findRichText: true), findsOneWidget);
  });

  testWidgets('VerifiedBadge displays correctly with label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VerifiedBadge(label: 'Verified'),
        ),
      ),
    );

    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });
}
