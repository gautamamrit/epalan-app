import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_form_fields.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pageController = PageController();

  bool _obscurePassword = true;
  bool _showLoginForm = false;
  bool _showResendVerification = false;
  bool _isResending = false;
  int _currentPage = 0;

  List<_OnboardingSlide> _getSlides(AppLocalizations l10n) => [
    _OnboardingSlide(title: l10n.welcomeToEpalan, subtitle: l10n.farmersCompanion, illustrationType: _IllustrationType.farm),
    _OnboardingSlide(title: l10n.smartFarmManagement, subtitle: l10n.smartFarmManagementDesc, illustrationType: _IllustrationType.animals),
    _OnboardingSlide(title: l10n.trackYourAnimals, subtitle: l10n.trackYourAnimalsDesc, illustrationType: _IllustrationType.animals),
    _OnboardingSlide(title: l10n.healthManagement, subtitle: l10n.healthManagementDesc, illustrationType: _IllustrationType.health),
    _OnboardingSlide(title: l10n.liveMarketPrices, subtitle: l10n.liveMarketPricesDesc, illustrationType: _IllustrationType.analytics),
  ];

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Loop back to first slide
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final contact = _emailOrPhoneController.text.trim();
      final isEmail = contact.contains('@');
      final data = isEmail ? {'email': contact} : {'phone': contact};
      final response =
          await ApiClient.instance.post('/auth/resend-verification', data: data);
      if (response.data['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _showResendVerification = false);
      }
    } on DioException catch (e) {
      if (mounted) {
        final message = e.response?.data?['message'] ?? 'Failed to resend';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _showResendVerification = false);

    final success = await ref.read(authProvider.notifier).login(
          emailOrPhone: _emailOrPhoneController.text.trim(),
          password: _passwordController.text,
        );

    // Small delay to allow widget tree to stabilize before any UI updates
    await Future.delayed(const Duration(milliseconds: 50));

    if (!success && mounted) {
      final error = ref.read(authProvider).error;
      final needsVerification =
          error != null && error.contains('verify your email');
      setState(() => _showResendVerification = needsVerification);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (_showLoginForm) {
      return _buildLoginForm(authState);
    }

    return _buildWelcomeScreen();
  }

  Widget _buildWelcomeScreen() {
    final l10n = AppLocalizations.of(context);
    final slides = _getSlides(l10n);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Image carousel — centered on screen
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.50,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.asset('assets/images/welcome_hero.png', fit: BoxFit.contain),
                            ),
                          );
                        }
                        if (index == 1) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.asset('assets/images/onboarding_farm.png', fit: BoxFit.contain),
                            ),
                          );
                        }
                        if (index == 2) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.asset('assets/images/onboarding_track.png', fit: BoxFit.contain),
                            ),
                          );
                        }
                        if (index == 3) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.asset('assets/images/onboarding_health.png', fit: BoxFit.contain),
                            ),
                          );
                        }
                        if (index == 4) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Image.asset('assets/images/onboarding_prices.png', fit: BoxFit.contain),
                            ),
                          );
                        }
                        return Center(child: _buildIllustration(slides[index].illustrationType));
                      },
                    ),
                    if (_currentPage > 0)
                      Positioned(
                        left: 12, top: 0, bottom: 0,
                        child: Center(
                          child: Material(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            shape: const CircleBorder(),
                            elevation: 0,
                            child: InkWell(
                              onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                              customBorder: const CircleBorder(),
                              child: Container(width: 48, height: 48, alignment: Alignment.center,
                                child: const Icon(Icons.chevron_left_rounded, color: AppColors.textOnPrimary, size: 28)),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12, top: 0, bottom: 0,
                      child: Center(
                        child: Material(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          shape: const CircleBorder(),
                          elevation: 0,
                          child: InkWell(
                            onTap: _nextPage,
                            customBorder: const CircleBorder(),
                            child: Container(width: 48, height: 48, alignment: Alignment.center,
                              child: const Icon(Icons.chevron_right_rounded, color: AppColors.textOnPrimary, size: 28)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content layered on top
            Column(
              children: [
            // Language selector (top-right)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: ref.watch(localeProvider).languageCode,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primary),
                        isDense: true,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'ne', child: Text('नेपाली')),
                        ],
                        selectedItemBuilder: (context) => [
                          Row(mainAxisSize: MainAxisSize.min, children: const [
                            Icon(Icons.language, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('English', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                          ]),
                          Row(mainAxisSize: MainAxisSize.min, children: const [
                            Icon(Icons.language, size: 16, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('नेपाली', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                          ]),
                        ],
                        onChanged: (code) {
                          if (code != null) ref.read(localeProvider.notifier).setLocale(code);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title and subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (_currentPage == 0) ...[
                    const Text(
                      'ePalan',
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: -1.12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.slogan,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                  else
                    Text(
                      slides[_currentPage].title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (_currentPage > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      slides[_currentPage].subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Bottom section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // Login button
                  AppPrimaryButton(
                    label: l10n.logIn,
                    onPressed: () {
                      setState(() {
                        _showLoginForm = true;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // Register button
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                      if (mounted) {
                        setState(() => _showLoginForm = result == 'login');
                      }
                    },
                    child: Text(
                      l10n.createNewAccount,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // end inner Column
          ], // end Stack children
        ), // end Stack
      ),
    );
  }

  Widget _buildIllustration(_IllustrationType type) {
    switch (type) {
      case _IllustrationType.farm:
        return _buildFarmIllustration();
      case _IllustrationType.animals:
        return _buildAnimalsIllustration();
      case _IllustrationType.health:
        return _buildHealthIllustration();
      case _IllustrationType.analytics:
        return _buildAnalyticsIllustration();
    }
  }

  Widget _buildFarmIllustration() {
    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ground/grass
          Positioned(
            bottom: 0,
            child: Container(
              width: 260,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Barn
          Positioned(
            bottom: 30,
            child: _buildBarn(),
          ),
          // Sun
          Positioned(
            top: 0,
            right: 30,
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Chicken on left
          Positioned(
            bottom: 40,
            left: 10,
            child: _buildChicken(),
          ),
          // Chicken on right
          Positioned(
            bottom: 45,
            right: 50,
            child: _buildChicken(),
          ),
          // Tree left
          Positioned(
            bottom: 40,
            left: 0,
            child: _buildTree(),
          ),
          // Tree right
          Positioned(
            bottom: 40,
            right: 20,
            child: _buildTree(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalsIllustration() {
    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Clipboard
          Container(
            width: 130,
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 10,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: index == 0 ? AppColors.success : AppColors.warning.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: index == 0
                            ? const Icon(Icons.check, color: AppColors.textOnPrimary, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          // Chickens around
          Positioned(bottom: 15, left: 25, child: _buildChicken()),
          Positioned(bottom: 25, right: 35, child: _buildChicken()),
          Positioned(top: 35, right: 25, child: _buildChicken()),
        ],
      ),
    );
  }

  Widget _buildHealthIllustration() {
    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Shield with cross
          Container(
            width: 110,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(55),
                topRight: Radius.circular(55),
                bottomLeft: Radius.circular(65),
                bottomRight: Radius.circular(65),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppColors.success, width: 3),
            ),
            child: const Icon(Icons.add, size: 55, color: AppColors.success),
          ),
          // Floating icons
          Positioned(
            top: 25,
            left: 35,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.vaccines, color: AppColors.info, size: 22),
            ),
          ),
          Positioned(
            top: 45,
            right: 25,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medication, color: AppColors.warning, size: 22),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 45,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsIllustration() {
    return SizedBox(
      width: 280,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Chart card
          Container(
            width: 160,
            height: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.success, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar(35, AppColors.primary.withValues(alpha: 0.3)),
                    _buildBar(50, AppColors.primary.withValues(alpha: 0.5)),
                    _buildBar(40, AppColors.primary.withValues(alpha: 0.4)),
                    _buildBar(70, AppColors.primary),
                    _buildBar(48, AppColors.primary.withValues(alpha: 0.6)),
                  ],
                ),
              ],
            ),
          ),
          // Floating stats
          Positioned(
            top: 15,
            right: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.egg, color: AppColors.textOnPrimary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '1.2K',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monitor_weight, color: AppColors.textOnPrimary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '2.4kg',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 18,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBarn() {
    return SizedBox(
      width: 150,
      height: 130,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: AppColors.textOnPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(150, 55),
              painter: _RoofPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChicken() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.warning,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.egg_alt,
        color: AppColors.textOnPrimary,
        size: 18,
      ),
    );
  }

  Widget _buildTree() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        Container(
          width: 7,
          height: 18,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthState authState) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppBackButton(
          onTap: () => setState(() => _showLoginForm = false),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Text(
                  l10n.logIn,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.enterCredentials,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AppTextField(
                  controller: _emailOrPhoneController,
                  label: l10n.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: l10n.logIn,
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                // Resend verification link (shown when user needs to verify)
                if (_showResendVerification) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isResending ? null : _resendVerificationEmail,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isResending)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.warning),
                            )
                          else
                            const Icon(Icons.mail_outline,
                                color: AppColors.warning, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _isResending
                                ? 'Sending...'
                                : 'Resend verification email',
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                        if (mounted && result != 'login') {
                          setState(() => _showLoginForm = false);
                        }
                      },
                      child: Text(
                        l10n.signUp,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;
  final _IllustrationType illustrationType;

  _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.illustrationType,
  });
}

enum _IllustrationType {
  farm,
  animals,
  health,
  analytics,
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final edgePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path, edgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
