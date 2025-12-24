// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(email) =>
      "Enter the code we\'ve sent by email to\n${email}. ";

  static String m1(error) => "Login failed: ${error}";

  static String m2(seconds) => "The code should arrive within ${seconds}s";

  static String m3(phone) => "Enter the code we\'ve sent by text to ${phone}. ";

  static String m4(error) => "Failed to create profile: ${error}";

  static String m5(error) => "Verification failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ageContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "ageRange1": MessageLookupByLibrary.simpleMessage("Age: 20-23"),
    "ageRange2": MessageLookupByLibrary.simpleMessage("Age: 24-27"),
    "ageRange3": MessageLookupByLibrary.simpleMessage("Age: 28-32"),
    "ageRange4": MessageLookupByLibrary.simpleMessage("Age: 32-38"),
    "ageSelectError": MessageLookupByLibrary.simpleMessage(
      "Please select your age range",
    ),
    "ageSubtitle": MessageLookupByLibrary.simpleMessage(
      "This help us show you relevant age profiles and find your matches",
    ),
    "ageTitle": MessageLookupByLibrary.simpleMessage("What\'s your age?"),
    "authAppleContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "authAppleEmailHint": MessageLookupByLibrary.simpleMessage(
      "Abcd@gmail.com",
    ),
    "authAppleEmailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "authAppleFooterMiddle": MessageLookupByLibrary.simpleMessage(
      ". See how we use your data in our ",
    ),
    "authAppleFooterPrefix": MessageLookupByLibrary.simpleMessage(
      "By continuing, you agree to our ",
    ),
    "authAppleFooterPrivacy": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "authAppleFooterSuffix": MessageLookupByLibrary.simpleMessage("."),
    "authAppleFooterTerms": MessageLookupByLibrary.simpleMessage("terms"),
    "authAppleForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot your password?",
    ),
    "authAppleIntro": MessageLookupByLibrary.simpleMessage(
      "Please enter your login details below",
    ),
    "authApplePasswordHint": MessageLookupByLibrary.simpleMessage("abc@123"),
    "authApplePasswordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "authEmailContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "authEmailFooterMiddle": MessageLookupByLibrary.simpleMessage(
      ". See how we use your data in our ",
    ),
    "authEmailFooterPrefix": MessageLookupByLibrary.simpleMessage(
      "By continuing, you agree to our ",
    ),
    "authEmailFooterPrivacy": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "authEmailFooterSuffix": MessageLookupByLibrary.simpleMessage("."),
    "authEmailFooterTerms": MessageLookupByLibrary.simpleMessage("terms"),
    "authEmailHint": MessageLookupByLibrary.simpleMessage("Abcd@gmail.com"),
    "authEmailIntro": MessageLookupByLibrary.simpleMessage(
      "Please enter your login details below",
    ),
    "authEmailInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "authEmailLabel": MessageLookupByLibrary.simpleMessage("Email"),
    "authEmailOtpChangeEmail": MessageLookupByLibrary.simpleMessage(
      "Change email",
    ),
    "authEmailOtpHint": m0,
    "authFieldsEmpty": MessageLookupByLibrary.simpleMessage(
      "Please fill all fields",
    ),
    "authForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot your password?",
    ),
    "authGoogleFailed": MessageLookupByLibrary.simpleMessage(
      "Google Sign-In failed",
    ),
    "authLoginFailed": m1,
    "authOtpContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "authOtpCountdown": m2,
    "authOtpIncomplete": MessageLookupByLibrary.simpleMessage(
      "Please enter complete OTP",
    ),
    "authOtpResend": MessageLookupByLibrary.simpleMessage("Resend code"),
    "authPasswordHint": MessageLookupByLibrary.simpleMessage("Vignesh@98"),
    "authPasswordLabel": MessageLookupByLibrary.simpleMessage("Password"),
    "authPasswordShort": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "authPhoneContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "authPhoneCountry": MessageLookupByLibrary.simpleMessage("Country"),
    "authPhoneDigitsOnly": MessageLookupByLibrary.simpleMessage(
      "Phone number must contain only digits",
    ),
    "authPhoneEnterNumber": MessageLookupByLibrary.simpleMessage(
      "Please enter your phone number",
    ),
    "authPhoneFooterMiddle": MessageLookupByLibrary.simpleMessage(
      ". See how we use your data in our ",
    ),
    "authPhoneFooterPrefix": MessageLookupByLibrary.simpleMessage(
      "By continuing, you agree to our ",
    ),
    "authPhoneFooterPrivacy": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "authPhoneFooterSuffix": MessageLookupByLibrary.simpleMessage("."),
    "authPhoneFooterTerms": MessageLookupByLibrary.simpleMessage("terms"),
    "authPhoneHint": MessageLookupByLibrary.simpleMessage("e.g. 9876543210"),
    "authPhoneInfo": MessageLookupByLibrary.simpleMessage(
      "We only use phone numbers to make sure everyone on Blindly is real",
    ),
    "authPhoneInvalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid phone number",
    ),
    "authPhoneInvalidIndia": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid 10-digit Indian phone number starting with 6-9",
    ),
    "authPhoneInvalidUs": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid 10-digit phone number",
    ),
    "authPhoneNumber": MessageLookupByLibrary.simpleMessage("Phone number"),
    "authPhoneOtpChangeNumber": MessageLookupByLibrary.simpleMessage(
      "Change number",
    ),
    "authPhoneOtpHint": m3,
    "authProfileFailed": m4,
    "authSelectionApple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "authSelectionFooterMiddle": MessageLookupByLibrary.simpleMessage(
      ". See how we use your data in our ",
    ),
    "authSelectionFooterPrefix": MessageLookupByLibrary.simpleMessage(
      "By signing up, you agree to our ",
    ),
    "authSelectionFooterPrivacy": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "authSelectionFooterSuffix": MessageLookupByLibrary.simpleMessage("."),
    "authSelectionFooterTerms": MessageLookupByLibrary.simpleMessage("terms"),
    "authSelectionGoogle": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "authSelectionPhone": MessageLookupByLibrary.simpleMessage(
      "Continue with Mobile number",
    ),
    "authSelectionTitle": MessageLookupByLibrary.simpleMessage(
      "Login to a Lovely life",
    ),
    "authTitleApple": MessageLookupByLibrary.simpleMessage("Login with Apple"),
    "authTitleEmail": MessageLookupByLibrary.simpleMessage("Login with Gmail"),
    "authTitleEmailOtp": MessageLookupByLibrary.simpleMessage(
      "Verify your google",
    ),
    "authTitlePhone": MessageLookupByLibrary.simpleMessage(
      "Can I get your number?",
    ),
    "authTitlePhoneOtp": MessageLookupByLibrary.simpleMessage(
      "Verify your number",
    ),
    "authTitleSelection": MessageLookupByLibrary.simpleMessage("Blindly"),
    "authVerifyFailed": m5,
    "bySigningUp": MessageLookupByLibrary.simpleMessage("By signing up, "),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create an account"),
    "dataUsage": MessageLookupByLibrary.simpleMessage("See how we use your"),
    "haveAccount": MessageLookupByLibrary.simpleMessage("I have an account"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("privacy policy"),
    "termsAgreeButton": MessageLookupByLibrary.simpleMessage(
      "Agree & Continue",
    ),
    "termsAgreement": MessageLookupByLibrary.simpleMessage(
      "you agree to our terms",
    ),
    "termsBox1Body": MessageLookupByLibrary.simpleMessage(
      "Treat others as you would like to be treated. We\'re all in together to create welcoming environment.",
    ),
    "termsBox1Title": MessageLookupByLibrary.simpleMessage(
      "Be kind and respectful",
    ),
    "termsBox2Body": MessageLookupByLibrary.simpleMessage(
      "Be genuine in your profile and interactions. We value authenticity and real connections.",
    ),
    "termsBox2Title": MessageLookupByLibrary.simpleMessage("Stay authentic"),
    "termsBox3Body": MessageLookupByLibrary.simpleMessage(
      "Do not share sensitive and personal information. Protect your self and others in the community.",
    ),
    "termsBox3Title": MessageLookupByLibrary.simpleMessage("Prioritize safety"),
    "termsBox4Body": MessageLookupByLibrary.simpleMessage(
      "Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.",
    ),
    "termsBox4Title": MessageLookupByLibrary.simpleMessage("No hate speech"),
    "termsBox5Body": MessageLookupByLibrary.simpleMessage(
      "If you see something that violate our guideline. Please report it. Your help is invaluable.",
    ),
    "termsBox5Title": MessageLookupByLibrary.simpleMessage("Help keep us safe"),
    "termsBox6Body": MessageLookupByLibrary.simpleMessage(
      "We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.",
    ),
    "termsBox6Title": MessageLookupByLibrary.simpleMessage(
      "Date with genuine intentions",
    ),
    "termsBox7Body": MessageLookupByLibrary.simpleMessage(
      "You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.",
    ),
    "termsBox7Title": MessageLookupByLibrary.simpleMessage("Adults only"),
    "termsFooterMiddle": MessageLookupByLibrary.simpleMessage(
      ". See how we use your data in our ",
    ),
    "termsFooterPrefix": MessageLookupByLibrary.simpleMessage(
      "By Continue, you agree to our ",
    ),
    "termsFooterPrivacy": MessageLookupByLibrary.simpleMessage(
      "privacy policy",
    ),
    "termsFooterSuffix": MessageLookupByLibrary.simpleMessage("."),
    "termsFooterTerms": MessageLookupByLibrary.simpleMessage("terms"),
    "termsIntro": MessageLookupByLibrary.simpleMessage(
      "Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.",
    ),
    "termsTitle": MessageLookupByLibrary.simpleMessage("Community guidelines"),
    "welcomeTagline": MessageLookupByLibrary.simpleMessage(
      "Real connections start here!",
    ),
  };
}
