import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';

enum AuthMethod { selection, phone, phoneOTP, email, emailOTP, facebook }

class AuthenticationScreen extends StatefulWidget {
  final bool isNewUser;

  const AuthenticationScreen({Key? key, this.isNewUser = false})
      : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  AuthMethod _currentMethod = AuthMethod.selection;

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  String _countryCode = '+91';
  String _phoneNumber = '';
  String _email = '';
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpControllers.forEach((c) => c.dispose());
    _otpFocusNodes.forEach((f) => f.dispose());
    super.dispose();
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

  void _changeMethod(AuthMethod method) {
    setState(() => _currentMethod = method);
  }

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
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your phone number'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Check if contains only digits
  if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number must contain only digits'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Validate based on country code
  if (!_isValidPhoneNumber(phone, _countryCode)) {
    String message = 'Please enter a valid phone number';
    
    if (_countryCode == '+91') {
      message = 'Please enter a valid 10-digit Indian phone number starting with 6-9';
    } else if (_countryCode == '+1') {
      message = 'Please enter a valid 10-digit phone number';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  HapticFeedback.mediumImpact();
  setState(() =>_isLoading = true);
  
  // Simulate API call
  await Future.delayed(const Duration(seconds: 2));
  
  if (mounted) {
    setState(() {
     _isLoading = false;
     _phoneNumber = phone;
     _currentMethod = AuthMethod.phoneOTP;
    });
   _clearOTPFields();
    _startResendTimer();
  }

  }

  Future<void> _handlePhoneOTPVerify() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() => _isLoading = false);

      if (widget.isNewUser) {
        Navigator.pushNamed(context, '/terms');
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
  }

  Future<void> _handleEmailContinue() async {
      final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  
  // Check if fields are empty
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Validate email format
  if (!_isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid email address'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Validate password
  if (!_isValidPassword(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password must be at least 6 characters'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Optional: Use strong password validation
  // String? passwordError = _validateStrongPassword(password);
  // if (passwordError != null) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(passwordError),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  //   return;
  // }
  
  HapticFeedback.mediumImpact();
  setState(() => _isLoading = true);
  
  await Future.delayed(const Duration(seconds: 2));
  
  if (mounted) {
    setState(() {
      _isLoading = false;
      this._email = email;
     _currentMethod = AuthMethod.emailOTP;
    });
    _clearOTPFields();
    _startResendTimer();
  }
  }

  Future<void> _handleEmailOTPVerify() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      HapticFeedback.heavyImpact();
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  Future<void> _handleFacebookContinue() async {
      final email =_emailController.text.trim();
  final password =_passwordController.text.trim();
  
  // Check if fields are empty
  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill all fields'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Validate email format
  if (!_isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid email address'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Validate password
  if (!_isValidPassword(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password must be at least 6 characters'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  HapticFeedback.mediumImpact();
  setState(() =>_isLoading = true);
  
  await Future.delayed(const Duration(seconds: 2));
  
  if (mounted) {
    setState(() => _isLoading = false);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF5F5F5),
      elevation: 0,
      toolbarHeight: 56,  // Add this - standard height
      titleSpacing: 0,    // Already have this
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Color.fromRGBO(0, 0, 0, 1),
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
            // From phone/email/facebook screens, go back to selection
            setState(() {
              _currentMethod = AuthMethod.selection;
            });
          }
        },
      ),
      title: _currentMethod != AuthMethod.selection
          ? Text(
              _getAppBarTitle(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 0, 0, 1),
            ),
            )
          : null, // No title on selection screen
            centerTitle: false,
    ),
    body: _currentMethod != AuthMethod.selection 
    ? _buildCurrentScreen()  // Remove SafeArea wrapper
    : SafeArea(child: _buildCurrentScreen()), 
  );
}


  String _getAppBarTitle() {
  switch (_currentMethod) {
    case AuthMethod.phone:
      return 'Can I get your number?';  // Updated
    case AuthMethod.phoneOTP:
      return 'Verify your number';  // Updated
    case AuthMethod.email:
      return 'Login with Gmail';  // Already correct
    case AuthMethod.emailOTP:
      return 'Verify your gmail';  // Updated (lowercase 'g')
    case AuthMethod.facebook:
      return 'Login with Facebook';  // Already correct
    default:
      return '';
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
      case AuthMethod.facebook:
        return _buildFacebookScreen();
    }
  }
  // Selection Screen
  Widget _buildSelectionScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assests/images/logo.png',
                width: 60,
                height: 60,
              ),
              SizedBox(height: 8),
              Image.asset(
                'assests/images/blindly-text-logo.png',
                width: 120, // Adjust width as needed
                height: 30, // Adjust height as needed
                fit: BoxFit.contain,
              ),
              SizedBox(height: 4),
              Text(
                'The joyful journey',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color.fromRGBO(0, 0, 0, 1),
                ),
                 ),
            ],
          ),
          Spacer(),
          Text(
  'Login to a Lovely life',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color.fromRGBO(0, 0, 0, 1),
  ),
),
Spacer(),
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // Quick Sign in button
    OutlinedButton(
      onPressed: () {
        HapticFeedback.selectionClick();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assests/images/signin.png',
            width: 20,
            height: 20,
          ),
          SizedBox(width: 12),  // Gap between icon and text
          Text(
            'Quick Sign in',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.03);
            }
            return null;
          },
        ),
      ),
    ),
    SizedBox(height: 12),
    
    // Facebook button
    OutlinedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _changeMethod(AuthMethod.facebook);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assests/images/facebook.png',
            width: 20,
            height: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Facebook',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.03);
            }
            return null;
          },
        ),
      ),
    ),
    SizedBox(height: 12),
    
    // Gmail button
    OutlinedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _changeMethod(AuthMethod.email);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assests/images/google.png',
            width: 20,
            height: 20,
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Gmail',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black.withOpacity(0.03);
            }
            return null;
          },
        ),
      ),
    ),
    SizedBox(height: 12),
    
    // Mobile number button
    ElevatedButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _changeMethod(AuthMethod.phone);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assests/images/telephone.png',
            width: 20,
            height: 20,
            // color: Colors.(#e6c97a), // Print the image white to match button color
          ),
          SizedBox(width: 12),
          Text(
            'Continue with Mobile number',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color.fromRGBO(230, 201, 122, 1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF4A5D4F),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
    ),

              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'terms',
                        style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                        ),
                      ),
                      TextSpan(text: '. See how we use your data in our '),
                      TextSpan(
                        text: 'privacy policy',
                        style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
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
              color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
              height: 1.4,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Country',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14 ,height: 1.4, color: Color.fromRGBO(0, 0, 0, 1),),
              ),
              SizedBox(width: 80),
              Text(
                'Phone number',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14 , color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  textStyle: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  style: TextStyle(fontFamily: 'Poppins', color: Color.fromRGBO(0, 0, 0, 1)),  // Dark grey text
                  decoration: InputDecoration(
                    hintText: 'e.g. 9876543210',
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
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
                      borderSide: BorderSide(color: Color(0xFF4A5D4F)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                   color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                   height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePhoneContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A5D4F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
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
                      color: Color.fromRGBO(230, 201, 122, 1),
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
                color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
              ),
              children: [
                TextSpan(
                  text: 'Enter the code we\'ve sent by text to $_countryCode $_phoneNumber. ',
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
                        color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
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
                  ),
                  decoration: InputDecoration(
                    counterText: '',
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
                      borderSide: BorderSide(color: Color(0xFF4A5D4F), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      if (index < 5) {
                        FocusScope.of(context)
                            .requestFocus(_otpFocusNodes[index + 1]);
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(context)
                          .requestFocus(_otpFocusNodes[index - 1]);
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
                  onPressed: _canResend ? _startResendTimer : null,
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
                      color: _canResend ? Color(0xFF4A5D4F) : Colors.grey[600],
                      fontWeight: _canResend ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _handlePhoneOTPVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A5D4F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
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
                      color: Color.fromRGBO(230, 201, 122, 1),
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
              color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Email',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1), ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
             inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces allowed
            ],
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Abcd@gmail.com',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
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
                borderSide: BorderSide(color: Color(0xFF4A5D4F)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Password',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1), ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Vignesh@98',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
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
                borderSide: BorderSide(color: Color(0xFF4A5D4F)),
              ),
              filled: true,
              fillColor: Colors.white,
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
                  color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
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
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A5D4F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
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
                      color: Color.fromRGBO(230, 201, 122, 1),
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
                  color: Color.fromRGBO(0, 0, 0, 1), 
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
                      'Change Gmail',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                        color: Color(0xFF4A5D4F),
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
                  ),
                  decoration: InputDecoration(
                    counterText: '',
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
                      borderSide: BorderSide(color: Color(0xFF4A5D4F), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      if (index < 5) {
                        FocusScope.of(context)
                            .requestFocus(_otpFocusNodes[index + 1]);
                      } else {
                        _otpFocusNodes[index].unfocus();
                      }
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(context)
                          .requestFocus(_otpFocusNodes[index - 1]);
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
                  onPressed: _canResend ? _startResendTimer : null,
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
                      color: _canResend ? Color(0xFF4A5D4F) : Colors.grey[600],
                      fontWeight: _canResend ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleEmailOTPVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A5D4F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
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
                      color: Color.fromRGBO(230, 201, 122, 1),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Facebook Login Screen
  Widget _buildFacebookScreen() {
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
              color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Email',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1), ),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'Abcd@gmail.com',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
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
                borderSide: BorderSide(color: Color(0xFF4A5D4F)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Password',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color.fromRGBO(0, 0, 0, 1), ),
          ),
          SizedBox(height: 4),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: 'abc@123',
              hintStyle: TextStyle(fontFamily: 'Poppins'),
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
                borderSide: BorderSide(color: Color(0xFF4A5D4F)),
              ),
              filled: true,
              fillColor: Colors.white,
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
                  color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
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
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By continuing, you agree to our '),
                  TextSpan(
                    text: 'terms',
                    style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '. See how we use your data in our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),  // Pure black
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleFacebookContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4A5D4F),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              minimumSize: Size(double.infinity, 50),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Color(0xFF4A5D4F)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white.withOpacity(0.1);
                  }
                  return null;
                },
              ),
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
                      color: Color.fromRGBO(230, 201, 122, 1),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
