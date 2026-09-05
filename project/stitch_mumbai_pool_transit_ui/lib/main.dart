import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';
import 'ui/core/constants/app_config.dart';
import 'ui/core/models/trip_route.dart';
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

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      detectSessionInUri: true,
      detectSessionInUriPredicate: isOAuthCallbackUri,
    ),
  );

  runApp(const TogetherRideApp());
}

/// Global Supabase client — use after [Supabase.initialize] in [main].
final SupabaseClient supabase = Supabase.instance.client;

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

class _MainNavigationFlowState extends State<MainNavigationFlow>
    with WidgetsBindingObserver {
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
  int currentStep = supabase.auth.currentSession != null ? 9 : 0;
  String currentRole = 'passenger';
  TripRoute? _searchedRoute;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('Auth event: ${data.event}, session: ${data.session != null}');
      if (data.session == null) {
        if (data.event == AuthChangeEvent.signedOut && mounted) {
          setState(() {
            currentStep = 0;
          });
        }
        return;
      }

      if (data.event == AuthChangeEvent.signedIn ||
          data.event == AuthChangeEvent.initialSession) {
        _navigateAfterAuthentication();
      }
    });

    // Cold start: app opened directly from OAuth deep link.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateAfterAuthentication();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Warm resume: user returns from OAuth browser back to the app.
    if (state == AppLifecycleState.resumed) {
      _navigateAfterAuthentication();
    }
  }

  void _navigateAfterAuthentication() {
    if (!mounted) return;
    if (supabase.auth.currentSession == null) return;
    if (currentStep != 0 && !showSplash) return;

    setState(() {
      showSplash = false;
      if (currentStep == 0) {
        currentStep = 9;
      }
    });
  }

  void handleRoleSelected(String role) {
    setState(() {
      currentRole = role;
      if (role == 'passenger') {
        currentStep = 1; // Passenger Home
      } else {
        currentStep = 5; // Driver Ride Request
      }
    });

    final user = supabase.auth.currentUser;
    if (user != null) {
      supabase
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
    if (showSplash && supabase.auth.currentSession == null) {
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
          onSearchPools: (route) => setState(() {
            _searchedRoute = route;
            currentStep = 8;
          }),
        );

      case 8:
        return RideMatchingWaitingView(
          onMatchFound: () => setState(() => currentStep = 2),
          onCancel: () => setState(() => currentStep = 1),
        );

      case 2:
        return MatchFoundView(
          tripRoute: _searchedRoute,
          onConfirmBooking: () => setState(() => currentStep = 3),
          onBack: () => setState(() => currentStep = 1),
        );

      case 3:
        return LiveTripPassengerView(
          tripRoute: _searchedRoute,
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
