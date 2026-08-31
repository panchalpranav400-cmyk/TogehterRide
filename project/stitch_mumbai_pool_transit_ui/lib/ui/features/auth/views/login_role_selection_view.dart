import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/auth_service.dart';

class LoginRoleSelectionView extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LoginRoleSelectionView({super.key, required this.onAuthenticated});

  @override
  State<LoginRoleSelectionView> createState() => _LoginRoleSelectionViewState();
}

class _LoginRoleSelectionViewState extends State<LoginRoleSelectionView>
    with TickerProviderStateMixin {
  // ── Form controllers ──
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true; // true = Login, false = Sign Up
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<Map<String, String>> _mumbaiLandmarks = const [
    {
      'path': 'assets/images/marine_drive.png',
      'label': 'Marine Drive',
      'sublabel': 'South Mumbai'
    },
    {
      'path': 'assets/images/csmt.png',
      'label': 'CSMT Station',
      'sublabel': 'Fort District'
    },
    {
      'path': 'assets/images/palladium.png',
      'label': 'Palladium Mall',
      'sublabel': 'Lower Parel'
    },
    {
      'path': 'assets/images/gateway_of_india.png',
      'label': 'Gateway of India',
      'sublabel': 'Colaba Waterfront'
    },
  ];

  int _currentImageIndex = 0;
  Timer? _carouselTimer;

  // ── Animation controllers ──
  late AnimationController _entranceController;
  late AnimationController _backgroundController;
  late AnimationController _shimmerController;

  // ── Staggered entrance animations ──
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    // 5-second automatic image rotation carousel
    _startCarousel();

    // Entrance stagger (total 1200ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));

    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    ));

    _footerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    // Continuous smooth background animation (loop)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Shimmer effect on card border (infinite loop)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entranceController.forward();
  }

  void _startCarousel() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _mumbaiLandmarks.length;
        });
      }
    });
  }

  void _selectLandmark(int index) {
    setState(() {
      _currentImageIndex = index;
    });
    _startCarousel();
  }

  // ── Form Validation ──
  String? _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty || password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    if (!_isLoginMode) {
      final name = nameController.text.trim();
      final confirmPassword = confirmPasswordController.text;

      if (name.isEmpty) {
        return 'Please enter your name';
      }
      if (password != confirmPassword) {
        return 'Passwords do not match';
      }
    }

    return null;
  }

  // ── Handle Login ──
  Future<void> _handleLogin() async {
    final error = _validateForm();
    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? 'Welcome back!', isError: false);
      widget.onAuthenticated();
    } else {
      _showSnackBar(result['message'] ?? 'Login failed', isError: true);
    }
  }

  // ── Handle Sign Up ──
  Future<void> _handleSignUp() async {
    final error = _validateForm();
    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      name: nameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (result['needsConfirmation'] == true) {
        _showSnackBar(
          result['message'] ?? 'Please check your email to confirm.',
          isError: false,
        );
        // Switch to login mode so user can log in after confirmation
        setState(() => _isLoginMode = true);
      } else {
        _showSnackBar(
            result['message'] ?? 'Account created!', isError: false);
        widget.onAuthenticated();
      }
    } else {
      _showSnackBar(result['message'] ?? 'Sign up failed', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppColors.actionCoral : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _entranceController.dispose();
    _backgroundController.dispose();
    _shimmerController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Rich Animated Background ──
          _buildEnhancedAnimatedBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Hero section ──
                    SlideTransition(
                      position: _heroSlide,
                      child: FadeTransition(
                        opacity: _heroFade,
                        child: _buildHeroSection(),
                      ),
                    ),

                    // ── Community Live Stats Ribbon ──
                    FadeTransition(
                      opacity: _heroFade,
                      child: _buildCommunityRibbon(),
                    ),

                    const SizedBox(height: 16),

                    // ── Auth Card (Login / Sign Up) ──
                    SlideTransition(
                      position: _cardSlide,
                      child: FadeTransition(
                        opacity: _cardFade,
                        child: _buildAuthCard(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Footer ──
                    FadeTransition(
                      opacity: _footerFade,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline_rounded,
                                  size: 13,
                                  color:
                                      AppColors.outline.withValues(alpha: 0.8)),
                              const SizedBox(width: 4),
                              Text(
                                '256-bit Encrypted Security',
                                style: AppTypography.labelMonoSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "By continuing, you agree to TogetherRide's Terms of Service & Privacy Policy.",
                            textAlign: TextAlign.center,
                            style: AppTypography.labelMonoSmall.copyWith(
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  ENHANCED ANIMATED BACKGROUND
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildEnhancedAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, _) {
        final progress = _backgroundController.value;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TransitBackgroundPainter(progress: progress),
              ),
            ),

            // Pulsing Glowing Orbs
            Positioned(
              top: -90 + sin(progress * 2 * pi) * 30,
              right: -60 + cos(progress * 2 * pi) * 25,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryFixed.withValues(alpha: 0.45),
                      AppColors.primaryFixed.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60 + cos(progress * 2 * pi) * 28,
              left: -70 + sin(progress * 2 * pi + 1) * 20,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryContainer.withValues(alpha: 0.25),
                      AppColors.secondaryContainer.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 300 + sin(progress * 2 * pi + 2) * 22,
              right: 15 + cos(progress * 2 * pi + 2) * 16,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.warmAmber.withValues(alpha: 0.18),
                      AppColors.warmAmber.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════
  //  HERO SECTION — Interactive Mumbai Landmarks
  // ═══════════════════════════════════════════════
  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 215,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 36,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Rotating photograph with smooth crossfade
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Image.asset(
                  _mumbaiLandmarks[_currentImageIndex]['path']!,
                  key: ValueKey<int>(_currentImageIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // 2. Multi-stop Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      AppColors.primary.withValues(alpha: 0.50),
                      AppColors.primary.withValues(alpha: 0.70),
                      AppColors.primary.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Content overlay
            Positioned.fill(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top App Header Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.directions_car_rounded,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TogetherRide',
                              style: AppTypography.headlineLarge.copyWith(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        // City Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.actionCoral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'MUMBAI',
                                style: AppTypography.labelMonoSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Middle Tagline & Location pill
                    Column(
                      children: [
                        Text(
                          'Your trusted community ride-sharing app in Mumbai.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dynamic Location Pill
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            key: ValueKey<String>(
                                _mumbaiLandmarks[_currentImageIndex]['label']!),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.secondary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.secondaryContainer
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    size: 12,
                                    color: AppColors.secondaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  '${_mumbaiLandmarks[_currentImageIndex]['label']!} • ${_mumbaiLandmarks[_currentImageIndex]['sublabel']!}',
                                  style: AppTypography.labelMonoSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Landmark Selector Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _mumbaiLandmarks.length,
                        (index) {
                          final isSelected = index == _currentImageIndex;
                          return GestureDetector(
                            onTap: () => _selectLandmark(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 12 : 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.actionCoral
                                    : Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4.0),
                                      child: Icon(Icons.star,
                                          size: 10, color: Colors.white),
                                    ),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  COMMUNITY RIBBON
  // ═══════════════════════════════════════════════
  Widget _buildCommunityRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryFixed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.people_alt_outlined, '12.4k+', 'Active Poolers'),
          Container(
            height: 16,
            width: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          _buildStatItem(Icons.bolt, '< 3 min', 'Match Time'),
          Container(
            height: 16,
            width: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          _buildStatItem(
              Icons.verified_user_outlined, '100%', 'Verified Rides'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.surfaceTint),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTypography.labelMonoMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelMonoSmall.copyWith(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  AUTH CARD — Login / Sign Up with shimmer border
  // ═══════════════════════════════════════════════
  Widget _buildAuthCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerT = _shimmerController.value;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: SweepGradient(
              center: Alignment.center,
              transform: GradientRotation(shimmerT * 2 * pi),
              colors: [
                AppColors.primaryFixed.withValues(alpha: 0.55),
                AppColors.outlineVariant.withValues(alpha: 0.15),
                AppColors.secondaryContainer.withValues(alpha: 0.35),
                AppColors.outlineVariant.withValues(alpha: 0.15),
                AppColors.primaryFixed.withValues(alpha: 0.55),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(26.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Login / Sign Up Toggle ──
                _buildAuthToggle(),
                const SizedBox(height: 18),

                // ── Name Field (Sign Up only) ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isLoginMode
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FULL NAME',
                              style: AppTypography.labelMonoMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: nameController,
                              hint: 'Enter your full name',
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                ),

                // ── Email Field ──
                Text(
                  'EMAIL ADDRESS',
                  style: AppTypography.labelMonoMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: emailController,
                  hint: 'user@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),

                // ── Password Field ──
                Text(
                  'PASSWORD',
                  style: AppTypography.labelMonoMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: passwordController,
                  hint: 'Min 6 characters',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),

                // ── Confirm Password (Sign Up only) ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isLoginMode
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),
                            Text(
                              'CONFIRM PASSWORD',
                              style: AppTypography.labelMonoMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: confirmPasswordController,
                              hint: 'Re-enter your password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility: () {
                                setState(() => _obscureConfirmPassword =
                                    !_obscureConfirmPassword);
                              },
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                // ── Submit Button ──
                _buildSubmitButton(),

                const SizedBox(height: 14),

                // ── Switch Mode Text ──
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: _isLoginMode
                                ? "Don't have an account? "
                                : 'Already have an account? ',
                          ),
                          TextSpan(
                            text: _isLoginMode ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Auth Toggle (Login / Sign Up) ──
  Widget _buildAuthToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isLoginMode
                      ? AppColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isLoginMode
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: _isLoginMode
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelMonoMedium.copyWith(
                        color: _isLoginMode
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            _isLoginMode ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginMode = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isLoginMode
                      ? AppColors.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isLoginMode
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 16,
                      color: !_isLoginMode
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: AppTypography.labelMonoMedium.copyWith(
                        color: !_isLoginMode
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            !_isLoginMode ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable Text Field ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? obscureText : false,
      style: AppTypography.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: isPassword ? 2.0 : 1.0,
      ),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: onToggleVisibility,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.outline,
                    size: 20,
                  ),
                ),
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.outlineVariant,
          fontSize: 14,
        ),
        fillColor: AppColors.surfaceContainerLow,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.surfaceTint,
            width: 1.8,
          ),
        ),
      ),
    );
  }

  // ── Submit Button ──
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : (_isLoginMode ? _handleLogin : _handleSignUp),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary,
              AppColors.secondary.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLoginMode
                        ? Icons.login_rounded
                        : Icons.person_add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLoginMode ? 'Login' : 'Create Account',
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
//  CUSTOM PAINTER: Transit Mesh Grid, Flowing Bezier Routes & Floating Particles
// ════════════════════════════════════════════════════════════════════════
class _TransitBackgroundPainter extends CustomPainter {
  final double progress;

  _TransitBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid Mesh Lines (subtle transit grid)
    final gridPaint = Paint()
      ..color = AppColors.primaryFixed.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Animated Flowing Transit Routes (Curved Beziers across screen)
    final route1Paint = Paint()
      ..color = AppColors.actionCoral.withValues(alpha: 0.15)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final route2Paint = Paint()
      ..color = AppColors.surfaceTint.withValues(alpha: 0.18)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(-20, size.height * 0.25);
    path1.cubicTo(
      size.width * 0.4,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.5,
      size.width + 20,
      size.height * 0.4,
    );
    canvas.drawPath(path1, route1Paint);

    final path2 = Path();
    path2.moveTo(-20, size.height * 0.75);
    path2.cubicTo(
      size.width * 0.3,
      size.height * 0.9,
      size.width * 0.7,
      size.height * 0.55,
      size.width + 20,
      size.height * 0.7,
    );
    canvas.drawPath(path2, route2Paint);

    // 3. Moving Route Pulse Particles
    final metric1 = path1.computeMetrics().firstOrNull;
    if (metric1 != null) {
      final pos1 = (progress * 1.5) % 1.0;
      final tangent1 = metric1.getTangentForOffset(metric1.length * pos1);
      if (tangent1 != null) {
        final nodePaint = Paint()
          ..color = AppColors.actionCoral
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
        canvas.drawCircle(tangent1.position, 4.5, nodePaint);
      }
    }

    final metric2 = path2.computeMetrics().firstOrNull;
    if (metric2 != null) {
      final pos2 = ((progress + 0.5) * 1.2) % 1.0;
      final tangent2 = metric2.getTangentForOffset(metric2.length * pos2);
      if (tangent2 != null) {
        final nodePaint = Paint()
          ..color = AppColors.surfaceTint
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
        canvas.drawCircle(tangent2.position, 4.0, nodePaint);
      }
    }

    // 4. Floating Bokeh Bubbles / Sparkles
    final particlePaint = Paint()..style = PaintingStyle.fill;

    final randomOffset = [
      Offset(size.width * 0.15,
          (size.height * (0.8 - (progress * 0.6))) % size.height),
      Offset(size.width * 0.85,
          (size.height * (0.2 + (progress * 0.7))) % size.height),
      Offset(size.width * 0.45,
          (size.height * (0.5 - (progress * 0.5))) % size.height),
      Offset(size.width * 0.70,
          (size.height * (0.9 - (progress * 0.8))) % size.height),
      Offset(size.width * 0.25,
          (size.height * (0.3 + (progress * 0.4))) % size.height),
    ];

    for (int i = 0; i < randomOffset.length; i++) {
      final pos = randomOffset[i];
      final radius = 2.5 + (i % 3) * 1.5;
      final alpha = 0.12 + (sin((progress * 2 * pi) + i) + 1) * 0.10;
      particlePaint.color = i % 2 == 0
          ? AppColors.actionCoral.withValues(alpha: alpha)
          : AppColors.primaryFixedDim.withValues(alpha: alpha);
      canvas.drawCircle(pos, radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TransitBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
