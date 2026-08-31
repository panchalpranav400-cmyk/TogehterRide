import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/splash/views/together_ride_splash.dart';
import 'ui/features/auth/views/login_role_selection_view.dart';
import 'ui/features/auth/views/role_selection_view.dart';
import 'ui/features/route_planning/views/passenger_home_view.dart';
import 'ui/features/ride_matching/views/ride_matching_waiting_view.dart';
import 'ui/features/ride_matching/views/match_found_view.dart';
import 'ui/features/driver_requests/views/ride_request_driver_view.dart';
import 'ui/features/driver_navigation/views/active_trip_driver_view.dart';
import 'ui/features/live_tracking/views/live_trip_passenger_view.dart';
import 'ui/features/passenger_feedback/views/trip_complete_passenger_view.dart';
import 'ui/features/driver_summary/views/trip_summary_driver_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zmuxmtumlbnkpfnkzlfc.supabase.co',
    publishableKey: 'sb_publishable_bsflwfhIxAxJVa12hqjpBQ_1MpcuKEL',
  );

  runApp(const TogetherRideApp());
}

class TogetherRideApp extends StatelessWidget {
  const TogetherRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TogetherRide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationFlow(),
    );
  }
}

class MainNavigationFlow extends StatefulWidget {
  const MainNavigationFlow({super.key});

  @override
  State<MainNavigationFlow> createState() => _MainNavigationFlowState();
}

class _MainNavigationFlowState extends State<MainNavigationFlow> {
  // Application splash & step navigation:
  // showSplash: Premium launch splash screen
  // 0: Email + Password Login / Sign Up
  // 9: Role Selection (Passenger vs Driver)
  // 1: Passenger Home / Route Planning
  // 8: Ride Matching Animated Waiting State
  // 2: Match Found / Select Seat & Fare
  // 3: Live Trip Passenger / Safety SOS
  // 4: Trip Complete & Rate (Passenger)
  // 5: Driver Ride Request (Accept/Decline)
  // 6: Active Trip Navigation (Driver)
  // 7: Driver Trip Summary & Earnings
  bool showSplash = true;
  // Start at step 9 (role selection) if user already has an active session
  int currentStep =
      Supabase.instance.client.auth.currentSession != null ? 9 : 0;
  String currentRole = 'passenger';

  void handleRoleSelected(String role) {
    setState(() {
      currentRole = role;
      if (role == 'passenger') {
        currentStep = 1; // Passenger Home
      } else {
        currentStep = 5; // Driver Ride Request
      }
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      Supabase.instance.client
          .from('profiles')
          .update({'role': role})
          .eq('id', user.id)
          .then((_) {
            debugPrint('Successfully updated user role to $role in Supabase');
          })
          .catchError((e) {
            debugPrint('Failed to update user role in Supabase: $e');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return TogetherRideSplashScreen(
        onSplashComplete: () {
          setState(() {
            showSplash = false;
          });
        },
      );
    }

    switch (currentStep) {
      case 0:
        return LoginRoleSelectionView(
          onAuthenticated: () => setState(() => currentStep = 9),
        );

      case 9:
        return RoleSelectionView(onRoleSelected: handleRoleSelected);

      case 1:
        return PassengerHomeView(
          onSearchPools: () => setState(() => currentStep = 8), // Show Ride Matching Waiting Animation
        );

      case 8:
        return RideMatchingWaitingView(
          onMatchFound: () => setState(() => currentStep = 2), // Match completed
          onCancel: () => setState(() => currentStep = 1), // Return to Passenger Home
        );

      case 2:
        return MatchFoundView(
          onConfirmBooking: () => setState(() => currentStep = 3),
          onBack: () => setState(() => currentStep = 1),
        );

      case 3:
        return LiveTripPassengerView(
          onTripFinished: () => setState(() => currentStep = 4),
        );

      case 4:
        return TripCompletePassengerView(
          onReturnHome: () => setState(() => currentStep = 0),
        );

      case 5:
        return RideRequestDriverView(
          onAcceptRequest: () => setState(() => currentStep = 6),
          onDeclineRequest: () => setState(() => currentStep = 0),
        );

      case 6:
        return ActiveTripDriverView(
          onCompleteTrip: () => setState(() => currentStep = 7),
        );

      case 7:
        return TripSummaryDriverView(
          onReturnHome: () => setState(() => currentStep = 0),
        );

      default:
        return LoginRoleSelectionView(
          onAuthenticated: () => setState(() => currentStep = 9),
        );
    }
  }
}
