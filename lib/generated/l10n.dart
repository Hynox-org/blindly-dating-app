// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Real connections start here!`
  String get welcomeTagline {
    return Intl.message(
      'Real connections start here!',
      name: 'welcomeTagline',
      desc: '',
      args: [],
    );
  }

  /// `Create an account`
  String get createAccount {
    return Intl.message(
      'Create an account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `I have an account`
  String get haveAccount {
    return Intl.message(
      'I have an account',
      name: 'haveAccount',
      desc: '',
      args: [],
    );
  }

  /// `By signing up, `
  String get bySigningUp {
    return Intl.message(
      'By signing up, ',
      name: 'bySigningUp',
      desc: '',
      args: [],
    );
  }

  /// `you agree to our terms`
  String get termsAgreement {
    return Intl.message(
      'you agree to our terms',
      name: 'termsAgreement',
      desc: '',
      args: [],
    );
  }

  /// `See how we use your`
  String get dataUsage {
    return Intl.message(
      'See how we use your',
      name: 'dataUsage',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Community guidelines`
  String get termsTitle {
    return Intl.message(
      'Community guidelines',
      name: 'termsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.`
  String get termsIntro {
    return Intl.message(
      'Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.',
      name: 'termsIntro',
      desc: '',
      args: [],
    );
  }

  /// `Be kind and respectful`
  String get termsBox1Title {
    return Intl.message(
      'Be kind and respectful',
      name: 'termsBox1Title',
      desc: '',
      args: [],
    );
  }

  /// `Treat others as you would like to be treated. We're all in together to create welcoming environment.`
  String get termsBox1Body {
    return Intl.message(
      'Treat others as you would like to be treated. We\'re all in together to create welcoming environment.',
      name: 'termsBox1Body',
      desc: '',
      args: [],
    );
  }

  /// `Stay authentic`
  String get termsBox2Title {
    return Intl.message(
      'Stay authentic',
      name: 'termsBox2Title',
      desc: '',
      args: [],
    );
  }

  /// `Be genuine in your profile and interactions. We value authenticity and real connections.`
  String get termsBox2Body {
    return Intl.message(
      'Be genuine in your profile and interactions. We value authenticity and real connections.',
      name: 'termsBox2Body',
      desc: '',
      args: [],
    );
  }

  /// `Prioritize safety`
  String get termsBox3Title {
    return Intl.message(
      'Prioritize safety',
      name: 'termsBox3Title',
      desc: '',
      args: [],
    );
  }

  /// `Do not share sensitive and personal information. Protect your self and others in the community.`
  String get termsBox3Body {
    return Intl.message(
      'Do not share sensitive and personal information. Protect your self and others in the community.',
      name: 'termsBox3Body',
      desc: '',
      args: [],
    );
  }

  /// `No hate speech`
  String get termsBox4Title {
    return Intl.message(
      'No hate speech',
      name: 'termsBox4Title',
      desc: '',
      args: [],
    );
  }

  /// `Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.`
  String get termsBox4Body {
    return Intl.message(
      'Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.',
      name: 'termsBox4Body',
      desc: '',
      args: [],
    );
  }

  /// `Help keep us safe`
  String get termsBox5Title {
    return Intl.message(
      'Help keep us safe',
      name: 'termsBox5Title',
      desc: '',
      args: [],
    );
  }

  /// `If you see something that violate our guideline. Please report it. Your help is invaluable.`
  String get termsBox5Body {
    return Intl.message(
      'If you see something that violate our guideline. Please report it. Your help is invaluable.',
      name: 'termsBox5Body',
      desc: '',
      args: [],
    );
  }

  /// `Date with genuine intentions`
  String get termsBox6Title {
    return Intl.message(
      'Date with genuine intentions',
      name: 'termsBox6Title',
      desc: '',
      args: [],
    );
  }

  /// `We're here for real connections. We don't allow catfish or coercion. We don't allow scams, impersonation, or any kind of manipulation for personal or financial gain.`
  String get termsBox6Body {
    return Intl.message(
      'We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.',
      name: 'termsBox6Body',
      desc: '',
      args: [],
    );
  }

  /// `Adults only`
  String get termsBox7Title {
    return Intl.message(
      'Adults only',
      name: 'termsBox7Title',
      desc: '',
      args: [],
    );
  }

  /// `You must be 18 years of age or older to use Blindly. This also means we don't allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.`
  String get termsBox7Body {
    return Intl.message(
      'You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.',
      name: 'termsBox7Body',
      desc: '',
      args: [],
    );
  }

  /// `Agree & Continue`
  String get termsAgreeButton {
    return Intl.message(
      'Agree & Continue',
      name: 'termsAgreeButton',
      desc: '',
      args: [],
    );
  }

  /// `By Continue, you agree to our `
  String get termsFooterPrefix {
    return Intl.message(
      'By Continue, you agree to our ',
      name: 'termsFooterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `terms`
  String get termsFooterTerms {
    return Intl.message('terms', name: 'termsFooterTerms', desc: '', args: []);
  }

  /// `. See how we use your data in our `
  String get termsFooterMiddle {
    return Intl.message(
      '. See how we use your data in our ',
      name: 'termsFooterMiddle',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get termsFooterPrivacy {
    return Intl.message(
      'privacy policy',
      name: 'termsFooterPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get termsFooterSuffix {
    return Intl.message('.', name: 'termsFooterSuffix', desc: '', args: []);
  }

  /// `What's your age?`
  String get ageTitle {
    return Intl.message(
      'What\'s your age?',
      name: 'ageTitle',
      desc: '',
      args: [],
    );
  }

  /// `This help us show you relevant age profiles and find your matches`
  String get ageSubtitle {
    return Intl.message(
      'This help us show you relevant age profiles and find your matches',
      name: 'ageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Age: 20-23`
  String get ageRange1 {
    return Intl.message('Age: 20-23', name: 'ageRange1', desc: '', args: []);
  }

  /// `Age: 24-27`
  String get ageRange2 {
    return Intl.message('Age: 24-27', name: 'ageRange2', desc: '', args: []);
  }

  /// `Age: 28-32`
  String get ageRange3 {
    return Intl.message('Age: 28-32', name: 'ageRange3', desc: '', args: []);
  }

  /// `Age: 32-38`
  String get ageRange4 {
    return Intl.message('Age: 32-38', name: 'ageRange4', desc: '', args: []);
  }

  /// `Please select your age range`
  String get ageSelectError {
    return Intl.message(
      'Please select your age range',
      name: 'ageSelectError',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get ageContinue {
    return Intl.message('Continue', name: 'ageContinue', desc: '', args: []);
  }

  /// `Login to a Lovely life`
  String get authSelectionTitle {
    return Intl.message(
      'Login to a Lovely life',
      name: 'authSelectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get authSelectionApple {
    return Intl.message(
      'Continue with Apple',
      name: 'authSelectionApple',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Google`
  String get authSelectionGoogle {
    return Intl.message(
      'Continue with Google',
      name: 'authSelectionGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Mobile number`
  String get authSelectionPhone {
    return Intl.message(
      'Continue with Mobile number',
      name: 'authSelectionPhone',
      desc: '',
      args: [],
    );
  }

  /// `By signing up, you agree to our `
  String get authSelectionFooterPrefix {
    return Intl.message(
      'By signing up, you agree to our ',
      name: 'authSelectionFooterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `terms`
  String get authSelectionFooterTerms {
    return Intl.message(
      'terms',
      name: 'authSelectionFooterTerms',
      desc: '',
      args: [],
    );
  }

  /// `. See how we use your data in our `
  String get authSelectionFooterMiddle {
    return Intl.message(
      '. See how we use your data in our ',
      name: 'authSelectionFooterMiddle',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get authSelectionFooterPrivacy {
    return Intl.message(
      'privacy policy',
      name: 'authSelectionFooterPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get authSelectionFooterSuffix {
    return Intl.message(
      '.',
      name: 'authSelectionFooterSuffix',
      desc: '',
      args: [],
    );
  }

  /// `Google Sign-In failed`
  String get authGoogleFailed {
    return Intl.message(
      'Google Sign-In failed',
      name: 'authGoogleFailed',
      desc: '',
      args: [],
    );
  }

  /// `We only use phone numbers to make sure everyone on Blindly is real`
  String get authPhoneInfo {
    return Intl.message(
      'We only use phone numbers to make sure everyone on Blindly is real',
      name: 'authPhoneInfo',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get authPhoneCountry {
    return Intl.message(
      'Country',
      name: 'authPhoneCountry',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get authPhoneNumber {
    return Intl.message(
      'Phone number',
      name: 'authPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 9876543210`
  String get authPhoneHint {
    return Intl.message(
      'e.g. 9876543210',
      name: 'authPhoneHint',
      desc: '',
      args: [],
    );
  }

  /// `By continuing, you agree to our `
  String get authPhoneFooterPrefix {
    return Intl.message(
      'By continuing, you agree to our ',
      name: 'authPhoneFooterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `terms`
  String get authPhoneFooterTerms {
    return Intl.message(
      'terms',
      name: 'authPhoneFooterTerms',
      desc: '',
      args: [],
    );
  }

  /// `. See how we use your data in our `
  String get authPhoneFooterMiddle {
    return Intl.message(
      '. See how we use your data in our ',
      name: 'authPhoneFooterMiddle',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get authPhoneFooterPrivacy {
    return Intl.message(
      'privacy policy',
      name: 'authPhoneFooterPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get authPhoneFooterSuffix {
    return Intl.message('.', name: 'authPhoneFooterSuffix', desc: '', args: []);
  }

  /// `Continue`
  String get authPhoneContinue {
    return Intl.message(
      'Continue',
      name: 'authPhoneContinue',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get authPhoneInvalid {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'authPhoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get authPhoneEnterNumber {
    return Intl.message(
      'Please enter your phone number',
      name: 'authPhoneEnterNumber',
      desc: '',
      args: [],
    );
  }

  /// `Phone number must contain only digits`
  String get authPhoneDigitsOnly {
    return Intl.message(
      'Phone number must contain only digits',
      name: 'authPhoneDigitsOnly',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid 10-digit Indian phone number starting with 6-9`
  String get authPhoneInvalidIndia {
    return Intl.message(
      'Please enter a valid 10-digit Indian phone number starting with 6-9',
      name: 'authPhoneInvalidIndia',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid 10-digit phone number`
  String get authPhoneInvalidUs {
    return Intl.message(
      'Please enter a valid 10-digit phone number',
      name: 'authPhoneInvalidUs',
      desc: '',
      args: [],
    );
  }

  /// `Please enter complete OTP`
  String get authOtpIncomplete {
    return Intl.message(
      'Please enter complete OTP',
      name: 'authOtpIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `Please fill all fields`
  String get authFieldsEmpty {
    return Intl.message(
      'Please fill all fields',
      name: 'authFieldsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get authEmailInvalid {
    return Intl.message(
      'Please enter a valid email address',
      name: 'authEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get authPasswordShort {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'authPasswordShort',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create profile: {error}`
  String authProfileFailed(Object error) {
    return Intl.message(
      'Failed to create profile: $error',
      name: 'authProfileFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Verification failed: {error}`
  String authVerifyFailed(Object error) {
    return Intl.message(
      'Verification failed: $error',
      name: 'authVerifyFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Login failed: {error}`
  String authLoginFailed(Object error) {
    return Intl.message(
      'Login failed: $error',
      name: 'authLoginFailed',
      desc: '',
      args: [error],
    );
  }

  /// `Enter the code we've sent by text to {phone}. `
  String authPhoneOtpHint(Object phone) {
    return Intl.message(
      'Enter the code we\'ve sent by text to $phone. ',
      name: 'authPhoneOtpHint',
      desc: '',
      args: [phone],
    );
  }

  /// `Change number`
  String get authPhoneOtpChangeNumber {
    return Intl.message(
      'Change number',
      name: 'authPhoneOtpChangeNumber',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get authOtpResend {
    return Intl.message(
      'Resend code',
      name: 'authOtpResend',
      desc: '',
      args: [],
    );
  }

  /// `The code should arrive within {seconds}s`
  String authOtpCountdown(Object seconds) {
    return Intl.message(
      'The code should arrive within ${seconds}s',
      name: 'authOtpCountdown',
      desc: '',
      args: [seconds],
    );
  }

  /// `Continue`
  String get authOtpContinue {
    return Intl.message(
      'Continue',
      name: 'authOtpContinue',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your login details below`
  String get authEmailIntro {
    return Intl.message(
      'Please enter your login details below',
      name: 'authEmailIntro',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get authEmailLabel {
    return Intl.message('Email', name: 'authEmailLabel', desc: '', args: []);
  }

  /// `Abcd@gmail.com`
  String get authEmailHint {
    return Intl.message(
      'Abcd@gmail.com',
      name: 'authEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get authPasswordLabel {
    return Intl.message(
      'Password',
      name: 'authPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `Vignesh@98`
  String get authPasswordHint {
    return Intl.message(
      'Vignesh@98',
      name: 'authPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get authForgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'authForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `By continuing, you agree to our `
  String get authEmailFooterPrefix {
    return Intl.message(
      'By continuing, you agree to our ',
      name: 'authEmailFooterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `terms`
  String get authEmailFooterTerms {
    return Intl.message(
      'terms',
      name: 'authEmailFooterTerms',
      desc: '',
      args: [],
    );
  }

  /// `. See how we use your data in our `
  String get authEmailFooterMiddle {
    return Intl.message(
      '. See how we use your data in our ',
      name: 'authEmailFooterMiddle',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get authEmailFooterPrivacy {
    return Intl.message(
      'privacy policy',
      name: 'authEmailFooterPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get authEmailFooterSuffix {
    return Intl.message('.', name: 'authEmailFooterSuffix', desc: '', args: []);
  }

  /// `Continue`
  String get authEmailContinue {
    return Intl.message(
      'Continue',
      name: 'authEmailContinue',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code we've sent by email to\n{email}. `
  String authEmailOtpHint(Object email) {
    return Intl.message(
      'Enter the code we\'ve sent by email to\n$email. ',
      name: 'authEmailOtpHint',
      desc: '',
      args: [email],
    );
  }

  /// `Change email`
  String get authEmailOtpChangeEmail {
    return Intl.message(
      'Change email',
      name: 'authEmailOtpChangeEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your login details below`
  String get authAppleIntro {
    return Intl.message(
      'Please enter your login details below',
      name: 'authAppleIntro',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get authAppleEmailLabel {
    return Intl.message(
      'Email',
      name: 'authAppleEmailLabel',
      desc: '',
      args: [],
    );
  }

  /// `Abcd@gmail.com`
  String get authAppleEmailHint {
    return Intl.message(
      'Abcd@gmail.com',
      name: 'authAppleEmailHint',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get authApplePasswordLabel {
    return Intl.message(
      'Password',
      name: 'authApplePasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `abc@123`
  String get authApplePasswordHint {
    return Intl.message(
      'abc@123',
      name: 'authApplePasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get authAppleForgotPassword {
    return Intl.message(
      'Forgot your password?',
      name: 'authAppleForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `By continuing, you agree to our `
  String get authAppleFooterPrefix {
    return Intl.message(
      'By continuing, you agree to our ',
      name: 'authAppleFooterPrefix',
      desc: '',
      args: [],
    );
  }

  /// `terms`
  String get authAppleFooterTerms {
    return Intl.message(
      'terms',
      name: 'authAppleFooterTerms',
      desc: '',
      args: [],
    );
  }

  /// `. See how we use your data in our `
  String get authAppleFooterMiddle {
    return Intl.message(
      '. See how we use your data in our ',
      name: 'authAppleFooterMiddle',
      desc: '',
      args: [],
    );
  }

  /// `privacy policy`
  String get authAppleFooterPrivacy {
    return Intl.message(
      'privacy policy',
      name: 'authAppleFooterPrivacy',
      desc: '',
      args: [],
    );
  }

  /// `.`
  String get authAppleFooterSuffix {
    return Intl.message('.', name: 'authAppleFooterSuffix', desc: '', args: []);
  }

  /// `Continue`
  String get authAppleContinue {
    return Intl.message(
      'Continue',
      name: 'authAppleContinue',
      desc: '',
      args: [],
    );
  }

  /// `Blindly`
  String get authTitleSelection {
    return Intl.message(
      'Blindly',
      name: 'authTitleSelection',
      desc: '',
      args: [],
    );
  }

  /// `Can I get your number?`
  String get authTitlePhone {
    return Intl.message(
      'Can I get your number?',
      name: 'authTitlePhone',
      desc: '',
      args: [],
    );
  }

  /// `Verify your number`
  String get authTitlePhoneOtp {
    return Intl.message(
      'Verify your number',
      name: 'authTitlePhoneOtp',
      desc: '',
      args: [],
    );
  }

  /// `Login with Gmail`
  String get authTitleEmail {
    return Intl.message(
      'Login with Gmail',
      name: 'authTitleEmail',
      desc: '',
      args: [],
    );
  }

  /// `Verify your google`
  String get authTitleEmailOtp {
    return Intl.message(
      'Verify your google',
      name: 'authTitleEmailOtp',
      desc: '',
      args: [],
    );
  }

  /// `Login with Apple`
  String get authTitleApple {
    return Intl.message(
      'Login with Apple',
      name: 'authTitleApple',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ta'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
