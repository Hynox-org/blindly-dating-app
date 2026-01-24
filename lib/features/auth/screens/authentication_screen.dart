import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../../onboarding/providers/onboarding_providers.dart';
import '../../../core/utils/app_logger.dart';
import '../../onboarding/presentation/screens/onboarding_shell.dart';
// import '../../discovery/repository/discovery_repository.dart';

enum AuthMethod { selection, phone, phoneOTP, email, emailOTP, apple }

class AuthenticationScreen extends ConsumerStatefulWidget {
  final bool isNewUser;

  const AuthenticationScreen({super.key, this.isNewUser = false});

  @override
  ConsumerState<AuthenticationScreen> createState() =>
      _AuthenticationScreenState();
}

class _AuthenticationScreenState extends ConsumerState<AuthenticationScreen> {
  AuthMethod _currentMethod = AuthMethod.selection;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String _countryCode = '+91';
  String _phoneNumber = '';
  String _email = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;
  String? _inlineError;
  String? _inlineSuccess;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getFriendlyErrorMessage(dynamic error) {
    if (error is AuthException) {
      if (error.statusCode == '429' ||
          (error.message.contains('Too many OTP attempts'))) {
        return 'Too many attempts. Please wait a while before trying again.';
      }
      return error.message;
    }
    return 'Error: ${error.toString()}';
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (_resendTimer > 0 && mounted) {
        setState(() => _resendTimer--);
        return true;
      }
      if (mounted) {
        setState(() => _canResend = true);
      }
      return false;
    });
  }

  /*
  void _changeMethod(AuthMethod method) {
    setState(() {
      _currentMethod = method;
      _inlineError = null;
      _inlineSuccess = null;
    });
  }
  */

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  // Phone number validation
  bool _isValidPhoneNumber(String phone, String countryCode) {
    // Remove any whitespace
    phone = phone.trim();

    // Check if phone contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return false;
    }

    // Country-specific validation
    switch (countryCode) {
      case '+91': // India
        return phone.length == 10 && phone.startsWith(RegExp(r'[6-9]'));
      case '+1': // USA/Canada
        return phone.length == 10;
      case '+44': // UK
        return phone.length == 10 || phone.length == 11;
      case '+86': // China
        return phone.length == 11;
      case '+81': // Japan
        return phone.length == 10 || phone.length == 11;
      default:
        // Generic validation: 7-15 digits
        return phone.length >= 7 && phone.length <= 15;
    }
  }

  // Email validation
  bool _isValidEmail(String email) {
    email = email.trim();
    if (email.isEmpty) return false;

    // Comprehensive email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Password validation
  bool _isValidPassword(String password) {
    if (password.isEmpty) return false;

    // Minimum 6 characters
    if (password.length < 6) return false;

    return true;
  }

  // Apple validation (using email for simplicity/simulation)
  bool _isValidApple(String email) => _isValidEmail(email);

  // Strong password validation (optional - use if you want stricter rules)
  // String? _validateStrongPassword(String password) {
  //   if (password.isEmpty) return 'Password is required';
  //   if (password.length < 8) return 'Password must be at least 8 characters';
  //   if (!password.contains(RegExp(r'[A-Z]'))) return 'Must contain uppercase letter';
  //   if (!password.contains(RegExp(r'[a-z]'))) return 'Must contain lowercase letter';
  //   if (!password.contains(RegExp(r'[0-9]'))) return 'Must contain a number';
  //   if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Must contain special character';
  //   return null;
  // }

  Future<void> _handlePhoneContinue() async {
    final phone = _phoneController.text.trim();

    // Check if empty
    if (phone.isEmpty) {
      if (phone.isEmpty) {
        setState(() => _inlineError = 'Please enter your phone number');
        return;
      }
    }

    // Check if contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() {
        _inlineError = 'Phone number must contain only digits';
      });
      return;
    }

    // Validate based on country code
    if (!_isValidPhoneNumber(phone, _countryCode)) {
      String message = 'Please enter a valid phone number';

      if (_countryCode == '+91') {
        message =
            'Please enter a valid 10-digit Indian phone number starting with 6-9';
      } else if (_countryCode == '+1') {
        message = 'Please enter a valid 10-digit phone number';
      }

      setState(() => _inlineError = message);
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final fullPhone = '$_countryCode$phone';
      AppLogger.info('AUTH_SCREEN: Initiating phone continue for: $fullPhone');

      await ref.read(authRepositoryProvider).signInWithPhone(fullPhone);

      AppLogger.info(
        'AUTH_SCREEN: Phone continue success, switching to OTP screen',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _phoneNumber = fullPhone;
          _currentMethod = AuthMethod.phoneOTP;
        });
        _clearOTPFields();
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inlineError = _getFriendlyErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handlePhoneOTPVerify() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() => _inlineError = 'Please enter complete OTP');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).verifyPhoneOTP(_phoneNumber, otp);

      if (mounted) {
        HapticFeedback.heavyImpact();

        try {
          final userId = ref.read(authRepositoryProvider).currentUser?.id;
          if (userId != null) {
            await ref.read(authRepositoryProvider).createProfile(userId);
          }

          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingShell()),
              (route) => false,
            );
          }
        } catch (e) {
          AppLogger.error('Error creating profile', e);
          if (mounted) {
            setState(() {
              _isLoading = false;
              _inlineError = 'Failed to create profile: ${e.toString()}';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inlineError = _getFriendlyErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handleEmailContinue() async {
    final email = _emailController.text.trim();

    // Check if fields are empty
    if (email.isEmpty) {
      setState(() => _inlineError = 'Please enter your email');
      return;
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      setState(() => _inlineError = 'Please enter a valid email address');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _email = email;
          _currentMethod = AuthMethod.emailOTP;
        });
        _clearOTPFields();
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inlineError = _getFriendlyErrorMessage(e);
        });
      }
    }
  }

  Future<void> _handleEmailOTPVerify() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() => _inlineError = 'Please enter complete OTP');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).verifyEmailOTP(_email, otp);

      if (mounted) {
        HapticFeedback.heavyImpact();

        try {
          final userId = ref.read(authRepositoryProvider).currentUser?.id;
          if (userId != null) {
            await ref.read(authRepositoryProvider).createProfile(userId);
          }

          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingShell()),
              (route) => false,
            );
          }
        } catch (e) {
          AppLogger.error('Error creating profile', e);
          if (mounted) {
            setState(() {
              _isLoading = false;
              _inlineError = 'Failed to create profile: ${e.toString()}';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inlineError = _getFriendlyErrorMessage(e);
        });
      }
    }
  }

  Future<void> _resendPhoneOTP() async {
    _startResendTimer();
    try {
      AppLogger.info('AUTH_SCREEN: Resending phone OTP to $_phoneNumber');
      await ref.read(authRepositoryProvider).signInWithPhone(_phoneNumber);
      if (mounted) {
        setState(() => _inlineSuccess = 'OTP sent successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _inlineError = _getFriendlyErrorMessage(e));
      }
    }
  }

  Future<void> _resendEmailOTP() async {
    _startResendTimer();
    try {
      AppLogger.info('AUTH_SCREEN: Resending email OTP to $_email');
      await ref.read(authRepositoryProvider).signInWithEmail(_email);
      if (mounted) {
        setState(() => _inlineSuccess = 'OTP sent successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _inlineError = _getFriendlyErrorMessage(e));
      }
    }
  }

  Future<void> _handleAppleContinue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Check if fields are empty
    if (email.isEmpty || password.isEmpty) {
      setState(() => _inlineError = 'Please fill all fields');
      return;
    }

    // Validate email format
    if (!_isValidEmail(email)) {
      setState(() => _inlineError = 'Please enter a valid email address');
      return;
    }

    // Validate password
    if (!_isValidPassword(password)) {
      setState(() => _inlineError = 'Password must be at least 6 characters');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithPassword(email, password);

      // Check onboarding status
      try {
        final userId = ref.read(authRepositoryProvider).currentUser?.id;
        if (userId != null) {
          final isOnboarded = await ref
              .read(onboardingRepositoryProvider)
              .checkOnboardingStatus(userId);

          if (mounted) {
            setState(() => _isLoading = false);
            if (isOnboarded) {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingShell()),
                (route) => false,
              );
            }
          }
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          }
        }
      } catch (e) {
        AppLogger.error('Error checking onboarding status', e);
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inlineError = 'Login failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        toolbarHeight: 56, // Add this - standard height
        titleSpacing: 0, // Already have this
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (_currentMethod == AuthMethod.selection) {
              // Go back to previous screen (wherever user came from)
              Navigator.pop(context);
            } else if (_currentMethod == AuthMethod.phoneOTP) {
              setState(() {
                _currentMethod = AuthMethod.phone;
              });
            } else if (_currentMethod == AuthMethod.emailOTP) {
              setState(() {
                _currentMethod = AuthMethod.email;
              });
            } else {
              // From phone/email/apple screens, go back to selection
              setState(() {
                _currentMethod = AuthMethod.selection;
              });
            }
          },
        ),
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: _currentMethod != AuthMethod.selection
          ? _buildCurrentScreen() // Remove SafeArea wrapper
          : SafeArea(child: _buildCurrentScreen()),
    );
  }

  String _getAppBarTitle() {
    switch (_currentMethod) {
      case AuthMethod.phone:
        return 'Can I get your number?'; // Updated
      case AuthMethod.phoneOTP:
        return 'Verify your number'; // Updated
      case AuthMethod.email:
        return 'Login with Email';
      case AuthMethod.emailOTP:
        return 'Verify your email';
      case AuthMethod.apple:
        return 'Login with Apple'; // Updated
      default:
        return 'Blindly';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentMethod) {
      case AuthMethod.selection:
        return _buildSelectionScreen();
      case AuthMethod.phone:
        return _buildPhoneScreen();
      case AuthMethod.phoneOTP:
        return _buildPhoneOTPScreen();
      case AuthMethod.email:
        return _buildEmailScreen();
      case AuthMethod.emailOTP:
        return _buildEmailOTPScreen();
      case AuthMethod.apple:
        return _buildAppleScreen();
    }
  }

  // Selection Screen
  Widget _buildSelectionScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Column(children: [SizedBox(height: 40)]),
          Spacer(),
          Text(
            'Login to a Lovely life',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /*
              // Apple button
              OutlinedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _changeMethod(AuthMethod.apple);
                },
                style:
                    OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
                        width: 1,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.black.withOpacity(0.03);
                        }
                        return null;
                      }),
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apple,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continue with Apple',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              */

              // Google button
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        setState(() => _isLoading = true);
                        try {
                          await ref
                              .read(authRepositoryProvider)
                              .signInWithGoogle();

                          if (mounted) {
                            // Check onboarding status
                            try {
                              final userId = ref
                                  .read(authRepositoryProvider)
                                  .currentUser
                                  ?.id;
                              if (userId != null) {
                                final isOnboarded = await ref
                                    .read(onboardingRepositoryProvider)
                                    .checkOnboardingStatus(userId);

                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  if (isOnboarded) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                      (_) => false,
                                    );
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const OnboardingShell(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              } else {
                                // Fallback if no user found (shouldn't happen on success)
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (_) => false,
                                  );
                                }
                              }
                            } catch (e) {
                              AppLogger.error(
                                'Error checking onboarding status',
                                e,
                              );
                              if (mounted) {
                                setState(() => _isLoading = false);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (_) => false,
                                );
                              }
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            // Ignore cancellation
                            if (e is AuthException &&
                                e.statusCode == 'CANCELLED') {
                              setState(() => _isLoading = false);
                              return;
                            }
                            setState(() {
                              _isLoading = false;
                              _inlineError = 'Google Sign-In failed: $e';
                            });
                          }
                        }
                      },
                style:
                    OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.12),
                        width: 1,
                      ),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.black.withOpacity(0.03);
                        }
                        return null;
                      }),
                    ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.google,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 12),

              /*
              // Email button
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _changeMethod(AuthMethod.email);
                },
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.surface,
                      ),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.pressed)) {
                          return Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.05);
                        }
                        return null;
                      }),
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidEnvelope,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continue with Email',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              */

              /*
              if (!DiscoveryRepository.kDevMode) ...[
                SizedBox(height: 12),

                // Mobile number button
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _changeMethod(AuthMethod.phone);
                  },
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                        overlayColor: WidgetStateProperty.resolveWith<Color?>((
                          Set<WidgetState> states,
                        ) {
                          if (states.contains(WidgetState.pressed)) {
                            return Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.1);
                          }
                          return null;
                        }),
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.phone,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Continue with Mobile number',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              */
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'terms',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface, // Pure black
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: '. See how we use your data in our '),
                      TextSpan(
                        text: 'privacy policy',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface, // Pure black
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneScreen() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We only use phone numbers to make sure everyone on Blindly is real',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface, // Pure black
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Country',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 80),
              Text(
                'Phone number',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CountryCodePicker(
                  onChanged: (code) {
                    setState(() => _countryCode = code.dialCode!);
                  },
                  initialSelection: 'IN',
                  favorite: ['+91', 'IN'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  padding: EdgeInsets.zero,
                  textStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  dialogTextStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  searchStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  dialogBackgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (_) => setState(() {
                    _inlineError = null;
                    _inlineSuccess = null;
                  }),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Theme.of(context).colorScheme.onSurface,
                  ), // Dark grey text
                  decoration: InputDecoration(
                    hintText: 'e.g. 9876543210',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface, // Pure black
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_inlineError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_inlineSuccess != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineSuccess!,
                style: const TextStyle(color: Colors.green, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePhoneContinue,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Phone OTP Screen
  Widget _buildPhoneOTPScreen() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface, // Pure black
              ),
              children: [
                TextSpan(
                  text: 'Enter the code we\'ve sent by text to $_phoneNumber. ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _currentMethod = AuthMethod.phone);
                    },
                    child: Text(
                      'Change number',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface, // Pure black
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 50,
                height: 60,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  autofocus: index == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _inlineError = null;
                      _inlineSuccess = null;
                    });
                    if (value.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      if (index < 5) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_otpFocusNodes[index + 1]);
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_otpFocusNodes[index - 1]);
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _canResend ? _resendPhoneOTP : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    _canResend
                        ? 'Resend code'
                        : 'The code should arrive within ${_resendTimer}s',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _canResend
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: _canResend
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
          Spacer(),
          if (_inlineError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_inlineSuccess != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineSuccess!,
                style: TextStyle(
                  color: Colors
                      .green, // Keep green for success or use a custom theme extension
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePhoneOTPVerify,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Email Login Screen
  Widget _buildEmailScreen() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please enter your login details below',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface, // Pure black
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Email',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            onChanged: (_) => setState(() => _inlineError = null),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ), // No spaces allowed
            ],
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Abcd@gmail.com',
              hintStyle: TextStyle(
                fontFamily: 'Poppins',
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          SizedBox(height: 16),
          // Password field removed for OTP flow
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_inlineError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailContinue,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Email OTP Screen
  Widget _buildEmailOTPScreen() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: 'Enter the code we\'ve sent by email to\n$_email. ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _currentMethod = AuthMethod.email);
                    },
                    child: Text(
                      'Change email',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 50,
                height: 60,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  autofocus: index == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _inlineError = null;
                      _inlineSuccess = null;
                    });
                    if (value.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      if (index < 5) {
                        FocusScope.of(
                          context,
                        ).requestFocus(_otpFocusNodes[index + 1]);
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_otpFocusNodes[index - 1]);
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _canResend ? _resendEmailOTP : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    _canResend
                        ? 'Resend code'
                        : 'The code should arrive within ${_resendTimer}s',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _canResend
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: _canResend
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
          Spacer(),
          if (_inlineError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_inlineSuccess != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineSuccess!,
                style: const TextStyle(
                  color: Colors.green, // Keep green or use theme extension
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailOTPVerify,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Apple Login Screen
  Widget _buildAppleScreen() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please enter your login details below',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface, // Pure black
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Email',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          TextField(
            onChanged: (_) => setState(() => _inlineError = null),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Abcd@gmail.com',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Password',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          TextField(
            onChanged: (_) => setState(() => _inlineError = null),
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'abc@123',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                'Forgot your password?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Theme.of(context).colorScheme.onSurface, // Pure black
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // Pure black
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_inlineError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _inlineError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleAppleContinue,
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withOpacity(0.1);
                    }
                    return null;
                  }),
                ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
