import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguageTitle;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @authTitlePhone.
  ///
  /// In en, this message translates to:
  /// **'Can I get your number?'**
  String get authTitlePhone;

  /// No description provided for @authTitleVerifyNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get authTitleVerifyNumber;

  /// No description provided for @authTitleEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get authTitleEmail;

  /// No description provided for @authTitleVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authTitleVerifyEmail;

  /// No description provided for @authTitleApple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get authTitleApple;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Login to a Lovely life'**
  String get loginTagline;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @termsSignupPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get termsSignupPrefix;

  /// No description provided for @termsContinuePrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get termsContinuePrefix;

  /// No description provided for @termsWord.
  ///
  /// In en, this message translates to:
  /// **'terms'**
  String get termsWord;

  /// No description provided for @termsBridge.
  ///
  /// In en, this message translates to:
  /// **'. See how we use your data in our '**
  String get termsBridge;

  /// No description provided for @privacyPolicyWord.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get privacyPolicyWord;

  /// No description provided for @termsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsSuffix;

  /// No description provided for @phoneRationale.
  ///
  /// In en, this message translates to:
  /// **'We only use phone numbers to make sure everyone on Blindly is real'**
  String get phoneRationale;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 9876543210'**
  String get phoneHint;

  /// No description provided for @otpSentPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we\'ve sent by text to {phone}. '**
  String otpSentPhone(String phone);

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @otpSentEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we\'ve sent by email to\n{email}. '**
  String otpSentEmail(String email);

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeArrivesIn.
  ///
  /// In en, this message translates to:
  /// **'The code should arrive within {seconds}s'**
  String codeArrivesIn(int seconds);

  /// No description provided for @otpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccess;

  /// No description provided for @loginDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your login details below'**
  String get loginDetailsSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Abcd@gmail.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'abc@123'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @errEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get errEnterPhone;

  /// No description provided for @errPhoneDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain only digits'**
  String get errPhoneDigitsOnly;

  /// No description provided for @errInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get errInvalidPhone;

  /// No description provided for @errInvalidPhoneIndia.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit Indian phone number starting with 6-9'**
  String get errInvalidPhoneIndia;

  /// No description provided for @errInvalidPhone10Digit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit phone number'**
  String get errInvalidPhone10Digit;

  /// No description provided for @errEnterCompleteOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete OTP'**
  String get errEnterCompleteOtp;

  /// No description provided for @errEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get errEnterEmail;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errInvalidEmail;

  /// No description provided for @errFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get errFillAllFields;

  /// No description provided for @errPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errPasswordMin;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while before trying again.'**
  String get errTooManyAttempts;

  /// No description provided for @errCreateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to create profile: {error}'**
  String errCreateProfile(String error);

  /// No description provided for @errGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String errGoogleSignIn(String error);

  /// No description provided for @errLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String errLoginFailed(String error);

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errGeneric(String error);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @typesOfConnections.
  ///
  /// In en, this message translates to:
  /// **'Types of Connections'**
  String get typesOfConnections;

  /// No description provided for @connectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'What type of connection are you looking for on Blindly?'**
  String get connectionQuestion;

  /// No description provided for @connectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dates and romances, new friends, or strictly business? You can change this any time.'**
  String get connectionSubtitle;

  /// No description provided for @modeDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a relationship, something casual, or anything in-between'**
  String get modeDateSubtitle;

  /// No description provided for @modeBffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make new friends and find your community'**
  String get modeBffSubtitle;

  /// No description provided for @modeEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find exciting events, book tickets, and more'**
  String get modeEventsSubtitle;

  /// No description provided for @continueWithMode.
  ///
  /// In en, this message translates to:
  /// **'Continue with {mode}'**
  String continueWithMode(String mode);

  /// No description provided for @multiDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Login'**
  String get multiDeviceTitle;

  /// No description provided for @multiDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is active on another device. For security, only one session is allowed.'**
  String get multiDeviceBody;

  /// No description provided for @signedOutOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'Signed out other devices!'**
  String get signedOutOtherDevices;

  /// No description provided for @signOutOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign Out Other Devices'**
  String get signOutOtherDevices;

  /// No description provided for @logOutThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Log Out This Device'**
  String get logOutThisDevice;

  /// No description provided for @swipeRightHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to know more!'**
  String get swipeRightHint;

  /// No description provided for @locationRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequiredTitle;

  /// No description provided for @locationRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'We need your location to find amazing people near you.\n\nPlease tap \"Settings\" to enable location permissions, then hit \"Retry\".'**
  String get locationRequiredBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @notifyMeSnack.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when new people join!'**
  String get notifyMeSnack;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'{value} cm'**
  String heightCm(String value);

  /// No description provided for @completeYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeYourProfile;

  /// No description provided for @completeYourProfileBody.
  ///
  /// In en, this message translates to:
  /// **'You skipped some steps. Complete them to get the most out of the app.'**
  String get completeYourProfileBody;

  /// No description provided for @stepNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This step is not yet available.'**
  String get stepNotAvailable;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get profileNotFound;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile not found or no longer available.'**
  String get profileUnavailable;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile. Please try again.'**
  String get profileLoadFailed;

  /// No description provided for @alreadyLikedProfile.
  ///
  /// In en, this message translates to:
  /// **'You already liked this profile.'**
  String get alreadyLikedProfile;

  /// No description provided for @personAlreadyLikedYou.
  ///
  /// In en, this message translates to:
  /// **'This person already liked you.'**
  String get personAlreadyLikedYou;

  /// No description provided for @youAreMatched.
  ///
  /// In en, this message translates to:
  /// **'You are matched.'**
  String get youAreMatched;

  /// No description provided for @alreadyChatting.
  ///
  /// In en, this message translates to:
  /// **'You already started chatting.'**
  String get alreadyChatting;

  /// No description provided for @profileAlreadySkipped.
  ///
  /// In en, this message translates to:
  /// **'Profile already skipped.'**
  String get profileAlreadySkipped;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @profilePreview.
  ///
  /// In en, this message translates to:
  /// **'Profile Preview'**
  String get profilePreview;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @voiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Voice Intro'**
  String get voiceIntro;

  /// No description provided for @bioTitle.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioTitle;

  /// No description provided for @askAboutMyBio.
  ///
  /// In en, this message translates to:
  /// **'Ask me about my bio!'**
  String get askAboutMyBio;

  /// No description provided for @kudos.
  ///
  /// In en, this message translates to:
  /// **'Kudos'**
  String get kudos;

  /// No description provided for @aPrompt.
  ///
  /// In en, this message translates to:
  /// **'A prompt'**
  String get aPrompt;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Profile Verified'**
  String get profileVerified;

  /// No description provided for @photoVerified.
  ///
  /// In en, this message translates to:
  /// **'Photo Verified'**
  String get photoVerified;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// No description provided for @milesAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} miles away'**
  String milesAway(String distance);

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score: {score}%'**
  String trustScore(String score);

  /// No description provided for @seeHowYouMatch.
  ///
  /// In en, this message translates to:
  /// **'See how you two match'**
  String get seeHowYouMatch;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMe;

  /// No description provided for @imLookingFor.
  ///
  /// In en, this message translates to:
  /// **'I\'m looking for'**
  String get imLookingFor;

  /// No description provided for @quickestWayToHeart.
  ///
  /// In en, this message translates to:
  /// **'The quickest way to my heart is'**
  String get quickestWayToHeart;

  /// No description provided for @myInterests.
  ///
  /// In en, this message translates to:
  /// **'My Interests'**
  String get myInterests;

  /// No description provided for @myLifestyle.
  ///
  /// In en, this message translates to:
  /// **'My Lifestyle'**
  String get myLifestyle;

  /// No description provided for @smokesLabel.
  ///
  /// In en, this message translates to:
  /// **'Smokes: {value}'**
  String smokesLabel(String value);

  /// No description provided for @drinksLabel.
  ///
  /// In en, this message translates to:
  /// **'Drinks: {value}'**
  String drinksLabel(String value);

  /// No description provided for @worksOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Works out: {value}'**
  String worksOutLabel(String value);

  /// No description provided for @myCauses.
  ///
  /// In en, this message translates to:
  /// **'My causes and communities'**
  String get myCauses;

  /// No description provided for @languagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languagesTitle;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocation;

  /// No description provided for @myTopArtist.
  ///
  /// In en, this message translates to:
  /// **'My top artist on spotify'**
  String get myTopArtist;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @youLikedThem.
  ///
  /// In en, this message translates to:
  /// **'You liked them!'**
  String get youLikedThem;

  /// No description provided for @undoNotForMe.
  ///
  /// In en, this message translates to:
  /// **'Undo \'Not for me\''**
  String get undoNotForMe;

  /// No description provided for @notForMe.
  ///
  /// In en, this message translates to:
  /// **'Not for me'**
  String get notForMe;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @outOfSwipesToday.
  ///
  /// In en, this message translates to:
  /// **'Out of swipes for\ntoday'**
  String get outOfSwipesToday;

  /// No description provided for @moreSwipesIn.
  ///
  /// In en, this message translates to:
  /// **'More swipes in'**
  String get moreSwipesIn;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursLabel;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get secondsLabel;

  /// No description provided for @sendAndSeeLikes.
  ///
  /// In en, this message translates to:
  /// **'Sent and see all\nthe likes you want'**
  String get sendAndSeeLikes;

  /// No description provided for @sendUnlimitedSwipes.
  ///
  /// In en, this message translates to:
  /// **'Send unlimited swipes'**
  String get sendUnlimitedSwipes;

  /// No description provided for @advancedSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Advanced search filter'**
  String get advancedSearchFilter;

  /// No description provided for @seeEveryoneWhoLikes.
  ///
  /// In en, this message translates to:
  /// **'See everyone who like you'**
  String get seeEveryoneWhoLikes;

  /// No description provided for @setMoreDatingPrefs.
  ///
  /// In en, this message translates to:
  /// **'Set more dating preference'**
  String get setMoreDatingPrefs;

  /// No description provided for @monthsPlan.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsPlan(String count);

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'most popular'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'best value'**
  String get bestValue;

  /// No description provided for @getWithPlan.
  ///
  /// In en, this message translates to:
  /// **'Get with {plan} for {price}'**
  String getWithPlan(String plan, String price);

  /// No description provided for @offerEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Offers ends in {time}'**
  String offerEndsIn(String time);

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chats;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @recentMatches.
  ///
  /// In en, this message translates to:
  /// **'Recent matches'**
  String get recentMatches;

  /// No description provided for @readyToMakeFirstMove.
  ///
  /// In en, this message translates to:
  /// **'Ready to make the first\nmove?'**
  String get readyToMakeFirstMove;

  /// No description provided for @tapToContinueChatting.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue chatting'**
  String get tapToContinueChatting;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @newMatchesAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your new matches will appear here.'**
  String get newMatchesAppearHere;

  /// No description provided for @endToEndEncrypted.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted'**
  String get endToEndEncrypted;

  /// No description provided for @e2eBanner.
  ///
  /// In en, this message translates to:
  /// **'Messages and calls are end-to-end encrypted. No one outside of this chat, not even Blindly, can read or listen to them. '**
  String get e2eBanner;

  /// No description provided for @encryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted message'**
  String get encryptedMessage;

  /// No description provided for @encryptionKeyNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Encryption key not loaded. Please wait.'**
  String get encryptionKeyNotLoaded;

  /// No description provided for @messageViolatesGuidelines.
  ///
  /// In en, this message translates to:
  /// **'This message may violate our community guidelines and wasn\'t sent.'**
  String get messageViolatesGuidelines;

  /// No description provided for @imageMessage.
  ///
  /// In en, this message translates to:
  /// **' Image message'**
  String get imageMessage;

  /// No description provided for @voiceMessage.
  ///
  /// In en, this message translates to:
  /// **' Voice message'**
  String get voiceMessage;

  /// No description provided for @nSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String nSelected(String count);

  /// No description provided for @editedSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Edited)'**
  String get editedSuffix;

  /// No description provided for @editingMessage.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get editingMessage;

  /// No description provided for @onlyTextEditable.
  ///
  /// In en, this message translates to:
  /// **'Only text messages can be edited'**
  String get onlyTextEditable;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopied;

  /// No description provided for @archiveChat.
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get archiveChat;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get muteNotifications;

  /// No description provided for @reportAndSpam.
  ///
  /// In en, this message translates to:
  /// **'Report and Spam'**
  String get reportAndSpam;

  /// No description provided for @deleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get deleteForMe;

  /// No description provided for @deleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get deleteForEveryone;

  /// No description provided for @showTranslation.
  ///
  /// In en, this message translates to:
  /// **'Show translation'**
  String get showTranslation;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get showOriginal;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @attachmentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Attachment picker coming soon'**
  String get attachmentComingSoon;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large (max 5MB)'**
  String get imageTooLarge;

  /// No description provided for @micPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get micPermissionDenied;

  /// No description provided for @recordingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recording file is empty'**
  String get recordingEmpty;

  /// No description provided for @recordingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recording file not found'**
  String get recordingNotFound;

  /// No description provided for @failedToPlayVoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to play voice message'**
  String get failedToPlayVoice;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failedToLoad;

  /// No description provided for @errorLoadingGif.
  ///
  /// In en, this message translates to:
  /// **'Error loading GIF'**
  String get errorLoadingGif;

  /// No description provided for @errorLoadingSticker.
  ///
  /// In en, this message translates to:
  /// **'Error loading Sticker'**
  String get errorLoadingSticker;

  /// No description provided for @networkErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get networkErrorRetry;

  /// No description provided for @serverSideError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Give it another go.'**
  String get serverSideError;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first'**
  String get pleaseLoginFirst;

  /// No description provided for @icebreakers.
  ///
  /// In en, this message translates to:
  /// **'Icebreakers'**
  String get icebreakers;

  /// No description provided for @iceBreaker.
  ///
  /// In en, this message translates to:
  /// **'Ice Breaker'**
  String get iceBreaker;

  /// No description provided for @couldntLoadIcebreakers.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load icebreakers'**
  String get couldntLoadIcebreakers;

  /// No description provided for @aiAnalyzingProfiles.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing your profiles...'**
  String get aiAnalyzingProfiles;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get categoryDeep;

  /// No description provided for @categoryPlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get categoryPlayful;

  /// No description provided for @categoryQuirky.
  ///
  /// In en, this message translates to:
  /// **'Quirky'**
  String get categoryQuirky;

  /// No description provided for @categoryPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized'**
  String get categoryPersonalized;

  /// No description provided for @categoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get categoryQuestion;

  /// No description provided for @categoryObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get categoryObservation;

  /// No description provided for @categoryFunFact.
  ///
  /// In en, this message translates to:
  /// **'Fun Fact'**
  String get categoryFunFact;

  /// No description provided for @categoryHypothesis.
  ///
  /// In en, this message translates to:
  /// **'Hypothesis'**
  String get categoryHypothesis;

  /// No description provided for @categoryOpeningMove.
  ///
  /// In en, this message translates to:
  /// **'Opening Move'**
  String get categoryOpeningMove;

  /// No description provided for @superpowerPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you could have any superpower, what would it be?'**
  String get superpowerPrompt;

  /// No description provided for @chooseAnOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get chooseAnOption;

  /// No description provided for @invalidMatchData.
  ///
  /// In en, this message translates to:
  /// **'Invalid match data. Please try again.'**
  String get invalidMatchData;

  /// No description provided for @moreOpeningMoves.
  ///
  /// In en, this message translates to:
  /// **'More opening moves'**
  String get moreOpeningMoves;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get onlineNow;

  /// No description provided for @pleaseEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get pleaseEnterMessage;

  /// No description provided for @sendPersonMessage.
  ///
  /// In en, this message translates to:
  /// **'Send {name} a message'**
  String sendPersonMessage(String name);

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @matchHasExpired.
  ///
  /// In en, this message translates to:
  /// **'This match has expired.'**
  String get matchHasExpired;

  /// No description provided for @typeOpeningMove.
  ///
  /// In en, this message translates to:
  /// **'Type your opening move...'**
  String get typeOpeningMove;

  /// No description provided for @use.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get use;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// No description provided for @matchExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Match Expired'**
  String get matchExpiredTitle;

  /// No description provided for @dontLetThemGetAway.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Let {name}\nGet Away!'**
  String dontLetThemGetAway(String name);

  /// No description provided for @limitedTimeBody.
  ///
  /// In en, this message translates to:
  /// **'You have limited time left to make a move. Send a message before the match disappears forever.'**
  String get limitedTimeBody;

  /// No description provided for @letThemGo.
  ///
  /// In en, this message translates to:
  /// **'Let them go'**
  String get letThemGo;

  /// No description provided for @messagePerson.
  ///
  /// In en, this message translates to:
  /// **'Message {name}'**
  String messagePerson(String name);

  /// No description provided for @gifs.
  ///
  /// In en, this message translates to:
  /// **'GIFs'**
  String get gifs;

  /// No description provided for @stickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get stickers;

  /// No description provided for @searchGiphy.
  ///
  /// In en, this message translates to:
  /// **'Search GIPHY'**
  String get searchGiphy;

  /// No description provided for @themOnly.
  ///
  /// In en, this message translates to:
  /// **'Them only'**
  String get themOnly;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @icebreakerSmile.
  ///
  /// In en, this message translates to:
  /// **'What\'s a small thing that made you smile recently?'**
  String get icebreakerSmile;

  /// No description provided for @icebreakerTwoTruths.
  ///
  /// In en, this message translates to:
  /// **'Two truths and a lie: Let\'s go!'**
  String get icebreakerTwoTruths;

  /// No description provided for @icebreakerInteresting.
  ///
  /// In en, this message translates to:
  /// **'What\'s the most interesting thing you\'ve learned lately?'**
  String get icebreakerInteresting;

  /// No description provided for @openingMoveCushions.
  ///
  /// In en, this message translates to:
  /// **'Me and the cushions I made.\nWhat do you think?'**
  String get openingMoveCushions;

  /// No description provided for @openingMove90s.
  ///
  /// In en, this message translates to:
  /// **'I bet you can\'t beat my 90s look'**
  String get openingMove90s;

  /// No description provided for @openingMovePetName.
  ///
  /// In en, this message translates to:
  /// **'Guess my pet\'s name?'**
  String get openingMovePetName;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @likedYou.
  ///
  /// In en, this message translates to:
  /// **'Liked You'**
  String get likedYou;

  /// No description provided for @matchLabel.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchLabel;

  /// No description provided for @passLabel.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get passLabel;

  /// No description provided for @failedToLoadLikes.
  ///
  /// In en, this message translates to:
  /// **'Failed to load likes'**
  String get failedToLoadLikes;

  /// No description provided for @noLikesYet.
  ///
  /// In en, this message translates to:
  /// **'No likes yet, but don\'t\n'**
  String get noLikesYet;

  /// No description provided for @buzzOff.
  ///
  /// In en, this message translates to:
  /// **'buzz off!'**
  String get buzzOff;

  /// No description provided for @keepSwipingBody.
  ///
  /// In en, this message translates to:
  /// **'Keep swiping to find your honey.\nSomeone is bound to like you soon!'**
  String get keepSwipingBody;

  /// No description provided for @keepSwiping.
  ///
  /// In en, this message translates to:
  /// **'Keep swiping'**
  String get keepSwiping;

  /// No description provided for @startSwiping.
  ///
  /// In en, this message translates to:
  /// **'Start Swiping'**
  String get startSwiping;

  /// No description provided for @improveProfile.
  ///
  /// In en, this message translates to:
  /// **'Improve Profile'**
  String get improveProfile;

  /// No description provided for @viewMoreLikes.
  ///
  /// In en, this message translates to:
  /// **'View more likes'**
  String get viewMoreLikes;

  /// No description provided for @seeWhosInterested.
  ///
  /// In en, this message translates to:
  /// **'See Who\'s Interested'**
  String get seeWhosInterested;

  /// No description provided for @matchInstantly.
  ///
  /// In en, this message translates to:
  /// **'Match instantly without the wait. You have {count}+ likes waiting you'**
  String matchInstantly(String count);

  /// No description provided for @superLiked.
  ///
  /// In en, this message translates to:
  /// **'Super Liked'**
  String get superLiked;

  /// No description provided for @itsAMatch.
  ///
  /// In en, this message translates to:
  /// **'It\'s a Match!'**
  String get itsAMatch;

  /// No description provided for @youAndThemLiked.
  ///
  /// In en, this message translates to:
  /// **'You and {name} liked each other.'**
  String youAndThemLiked(String name);

  /// No description provided for @sendAMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get sendAMessage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @loginToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view notifications.'**
  String get loginToViewNotifications;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @reachedEndOfLine.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end\nof the line!'**
  String get reachedEndOfLine;

  /// No description provided for @checkBackSoon.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for more people or try adjusting your filters to see more profiles.'**
  String get checkBackSoon;

  /// No description provided for @seeMorePeople.
  ///
  /// In en, this message translates to:
  /// **'See More Peoples'**
  String get seeMorePeople;

  /// No description provided for @topPicksForYou.
  ///
  /// In en, this message translates to:
  /// **'Top Picks For You'**
  String get topPicksForYou;

  /// No description provided for @sharedInterests.
  ///
  /// In en, this message translates to:
  /// **'Shared Interests'**
  String get sharedInterests;

  /// No description provided for @newFaces.
  ///
  /// In en, this message translates to:
  /// **'New Faces'**
  String get newFaces;

  /// No description provided for @recentlyActive.
  ///
  /// In en, this message translates to:
  /// **'Recently Active'**
  String get recentlyActive;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// No description provided for @letsDiscover.
  ///
  /// In en, this message translates to:
  /// **'Lets Discover!'**
  String get letsDiscover;

  /// No description provided for @viewedAllProfiles.
  ///
  /// In en, this message translates to:
  /// **'You\'re viewed all the profiles matching your current preference. Expand your search or check back soon for new peoples.'**
  String get viewedAllProfiles;

  /// No description provided for @adjustYourFilters.
  ///
  /// In en, this message translates to:
  /// **'Adjust Your Filters'**
  String get adjustYourFilters;

  /// No description provided for @notifyMeNewPeople.
  ///
  /// In en, this message translates to:
  /// **'Notify Me About New People'**
  String get notifyMeNewPeople;

  /// No description provided for @youAndPerson.
  ///
  /// In en, this message translates to:
  /// **'You and {name}'**
  String youAndPerson(String name);

  /// No description provided for @workingOutCommon.
  ///
  /// In en, this message translates to:
  /// **'Working out what you have in common…'**
  String get workingOutCommon;

  /// No description provided for @whyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get whyTitle;

  /// No description provided for @breakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdownTitle;

  /// No description provided for @goesBothWays.
  ///
  /// In en, this message translates to:
  /// **'Does it go both ways?'**
  String get goesBothWays;

  /// No description provided for @eachFitsOther.
  ///
  /// In en, this message translates to:
  /// **'You each fit what the other is looking for: {band}.'**
  String eachFitsOther(String band);

  /// No description provided for @sectionConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get sectionConnections;

  /// No description provided for @typeOfConnection.
  ///
  /// In en, this message translates to:
  /// **'Type of connection'**
  String get typeOfConnection;

  /// No description provided for @dateMode.
  ///
  /// In en, this message translates to:
  /// **'Date mode'**
  String get dateMode;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @sectionAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get sectionAccountSettings;

  /// No description provided for @profileAndVerification.
  ///
  /// In en, this message translates to:
  /// **'Profile & Verification'**
  String get profileAndVerification;

  /// No description provided for @contactAndLoginInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact & Login info'**
  String get contactAndLoginInfo;

  /// No description provided for @subscriptionManagement.
  ///
  /// In en, this message translates to:
  /// **'Subscription Management'**
  String get subscriptionManagement;

  /// No description provided for @sectionAppPreference.
  ///
  /// In en, this message translates to:
  /// **'App Preference'**
  String get sectionAppPreference;

  /// No description provided for @notificationsSetting.
  ///
  /// In en, this message translates to:
  /// **'Notifications setting'**
  String get notificationsSetting;

  /// No description provided for @privacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy controls'**
  String get privacyControls;

  /// No description provided for @sectionSecurityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get sectionSecurityPrivacy;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// No description provided for @blockedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Blocked accounts'**
  String get blockedAccounts;

  /// No description provided for @locationService.
  ///
  /// In en, this message translates to:
  /// **'Location service'**
  String get locationService;

  /// No description provided for @sectionSupportLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get sectionSupportLegal;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @vEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get vEnglish;

  /// No description provided for @vHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get vHindi;

  /// No description provided for @vTamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get vTamil;

  /// No description provided for @vTelugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get vTelugu;

  /// No description provided for @vKannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get vKannada;

  /// No description provided for @vMalayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get vMalayalam;

  /// No description provided for @vMarathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get vMarathi;

  /// No description provided for @vBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get vBengali;

  /// No description provided for @vGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get vGujarati;

  /// No description provided for @vPunjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get vPunjabi;

  /// No description provided for @vOdia.
  ///
  /// In en, this message translates to:
  /// **'Odia'**
  String get vOdia;

  /// No description provided for @vSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get vSpanish;

  /// No description provided for @vFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get vFrench;

  /// No description provided for @vGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get vGerman;

  /// No description provided for @vItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get vItalian;

  /// No description provided for @vPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get vPortuguese;

  /// No description provided for @vRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get vRussian;

  /// No description provided for @vJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get vJapanese;

  /// No description provided for @vKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get vKorean;

  /// No description provided for @vChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get vChinese;

  /// No description provided for @vArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get vArabic;

  /// No description provided for @vTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get vTurkish;

  /// No description provided for @vOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get vOthers;

  /// No description provided for @vOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vOther;

  /// No description provided for @vHindu.
  ///
  /// In en, this message translates to:
  /// **'Hindu'**
  String get vHindu;

  /// No description provided for @vChristian.
  ///
  /// In en, this message translates to:
  /// **'Christian'**
  String get vChristian;

  /// No description provided for @vMuslim.
  ///
  /// In en, this message translates to:
  /// **'Muslim'**
  String get vMuslim;

  /// No description provided for @vSikh.
  ///
  /// In en, this message translates to:
  /// **'Sikh'**
  String get vSikh;

  /// No description provided for @vJain.
  ///
  /// In en, this message translates to:
  /// **'Jain'**
  String get vJain;

  /// No description provided for @vBuddhist.
  ///
  /// In en, this message translates to:
  /// **'Buddhist'**
  String get vBuddhist;

  /// No description provided for @vAtheist.
  ///
  /// In en, this message translates to:
  /// **'Atheist'**
  String get vAtheist;

  /// No description provided for @vAgnostic.
  ///
  /// In en, this message translates to:
  /// **'Agnostic'**
  String get vAgnostic;

  /// No description provided for @vSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get vSpiritual;

  /// No description provided for @vCatholic.
  ///
  /// In en, this message translates to:
  /// **'Catholic'**
  String get vCatholic;

  /// No description provided for @vLatterDaySaint.
  ///
  /// In en, this message translates to:
  /// **'Latter day saint'**
  String get vLatterDaySaint;

  /// No description provided for @vZoroastrian.
  ///
  /// In en, this message translates to:
  /// **'Zoroastrian'**
  String get vZoroastrian;

  /// No description provided for @vJewish.
  ///
  /// In en, this message translates to:
  /// **'Jewish'**
  String get vJewish;

  /// No description provided for @vMormon.
  ///
  /// In en, this message translates to:
  /// **'Mormon'**
  String get vMormon;

  /// No description provided for @vMonogamy.
  ///
  /// In en, this message translates to:
  /// **'Monogamy'**
  String get vMonogamy;

  /// No description provided for @vPolyamory.
  ///
  /// In en, this message translates to:
  /// **'Polyamory'**
  String get vPolyamory;

  /// No description provided for @vOpenRelationship.
  ///
  /// In en, this message translates to:
  /// **'Open relationship'**
  String get vOpenRelationship;

  /// No description provided for @vNonMonogamy.
  ///
  /// In en, this message translates to:
  /// **'Non-monogamy'**
  String get vNonMonogamy;

  /// No description provided for @vOpenToExploring.
  ///
  /// In en, this message translates to:
  /// **'Open to exploring'**
  String get vOpenToExploring;

  /// No description provided for @vShortTerm.
  ///
  /// In en, this message translates to:
  /// **'Short Term'**
  String get vShortTerm;

  /// No description provided for @vLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Long Term'**
  String get vLongTerm;

  /// No description provided for @vStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get vStraight;

  /// No description provided for @vGay.
  ///
  /// In en, this message translates to:
  /// **'Gay'**
  String get vGay;

  /// No description provided for @vLesbian.
  ///
  /// In en, this message translates to:
  /// **'Lesbian'**
  String get vLesbian;

  /// No description provided for @vBisexual.
  ///
  /// In en, this message translates to:
  /// **'Bisexual'**
  String get vBisexual;

  /// No description provided for @vAsexual.
  ///
  /// In en, this message translates to:
  /// **'Asexual'**
  String get vAsexual;

  /// No description provided for @vDemisexual.
  ///
  /// In en, this message translates to:
  /// **'Demisexual'**
  String get vDemisexual;

  /// No description provided for @vPansexual.
  ///
  /// In en, this message translates to:
  /// **'Pansexual'**
  String get vPansexual;

  /// No description provided for @vQueer.
  ///
  /// In en, this message translates to:
  /// **'Queer'**
  String get vQueer;

  /// No description provided for @vQuestioning.
  ///
  /// In en, this message translates to:
  /// **'Questioning'**
  String get vQuestioning;

  /// No description provided for @vWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get vWomen;

  /// No description provided for @vMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get vMen;

  /// No description provided for @vEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get vEveryone;

  /// No description provided for @vMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get vMale;

  /// No description provided for @vFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get vFemale;

  /// No description provided for @vFunCasualDates.
  ///
  /// In en, this message translates to:
  /// **'Fun, causal dates'**
  String get vFunCasualDates;

  /// No description provided for @vLifePartner.
  ///
  /// In en, this message translates to:
  /// **'Life partner'**
  String get vLifePartner;

  /// No description provided for @vLongTermRelationship.
  ///
  /// In en, this message translates to:
  /// **'Long-term relationship'**
  String get vLongTermRelationship;

  /// No description provided for @vShortTermRelationship.
  ///
  /// In en, this message translates to:
  /// **'Short-term relationship'**
  String get vShortTermRelationship;

  /// No description provided for @vStillFiguringOut.
  ///
  /// In en, this message translates to:
  /// **'Still figuring it out'**
  String get vStillFiguringOut;

  /// No description provided for @vLongOpenToShort.
  ///
  /// In en, this message translates to:
  /// **'Long-term, open to short'**
  String get vLongOpenToShort;

  /// No description provided for @vShortOpenToLong.
  ///
  /// In en, this message translates to:
  /// **'Short-term, open to long'**
  String get vShortOpenToLong;

  /// No description provided for @vCasualDating.
  ///
  /// In en, this message translates to:
  /// **'Casual dating'**
  String get vCasualDating;

  /// No description provided for @vNewFriends.
  ///
  /// In en, this message translates to:
  /// **'New friends'**
  String get vNewFriends;

  /// No description provided for @vCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'Close friends'**
  String get vCloseFriends;

  /// No description provided for @vActivityPartners.
  ///
  /// In en, this message translates to:
  /// **'Activity partners'**
  String get vActivityPartners;

  /// No description provided for @vProfessionalNetworking.
  ///
  /// In en, this message translates to:
  /// **'Professional networking'**
  String get vProfessionalNetworking;

  /// No description provided for @vWorkoutBuddy.
  ///
  /// In en, this message translates to:
  /// **'Workout buddy'**
  String get vWorkoutBuddy;

  /// No description provided for @vTravelBuddies.
  ///
  /// In en, this message translates to:
  /// **'Travel buddies'**
  String get vTravelBuddies;

  /// No description provided for @vYesIDrink.
  ///
  /// In en, this message translates to:
  /// **'Yes, i drink'**
  String get vYesIDrink;

  /// No description provided for @vOccasionally.
  ///
  /// In en, this message translates to:
  /// **'Occasionally'**
  String get vOccasionally;

  /// No description provided for @vSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get vSometimes;

  /// No description provided for @vNeverDrink.
  ///
  /// In en, this message translates to:
  /// **'Never drink'**
  String get vNeverDrink;

  /// No description provided for @vRegularly.
  ///
  /// In en, this message translates to:
  /// **'Regularly'**
  String get vRegularly;

  /// No description provided for @vImSober.
  ///
  /// In en, this message translates to:
  /// **'I\'m Sober'**
  String get vImSober;

  /// No description provided for @vSocially.
  ///
  /// In en, this message translates to:
  /// **'Socially'**
  String get vSocially;

  /// No description provided for @vNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get vNever;

  /// No description provided for @vSocialSmoker.
  ///
  /// In en, this message translates to:
  /// **'Social smoker'**
  String get vSocialSmoker;

  /// No description provided for @vSmokerWhenDrinking.
  ///
  /// In en, this message translates to:
  /// **'Smoker when drinking'**
  String get vSmokerWhenDrinking;

  /// No description provided for @vNonSmoker.
  ///
  /// In en, this message translates to:
  /// **'Non-smoker'**
  String get vNonSmoker;

  /// No description provided for @vSmoker.
  ///
  /// In en, this message translates to:
  /// **'Smoker'**
  String get vSmoker;

  /// No description provided for @vTryingToQuit.
  ///
  /// In en, this message translates to:
  /// **'Trying to quit'**
  String get vTryingToQuit;

  /// No description provided for @vDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get vDaily;

  /// No description provided for @vWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get vWeekly;

  /// No description provided for @vHighSchool.
  ///
  /// In en, this message translates to:
  /// **'High school'**
  String get vHighSchool;

  /// No description provided for @vGradeSchool.
  ///
  /// In en, this message translates to:
  /// **'Grade School'**
  String get vGradeSchool;

  /// No description provided for @vDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get vDiploma;

  /// No description provided for @vUnderGraduate.
  ///
  /// In en, this message translates to:
  /// **'Under Graduate'**
  String get vUnderGraduate;

  /// No description provided for @vPostGraduate.
  ///
  /// In en, this message translates to:
  /// **'Post Graduate'**
  String get vPostGraduate;

  /// No description provided for @vDoctorate.
  ///
  /// In en, this message translates to:
  /// **'Doctorate'**
  String get vDoctorate;

  /// No description provided for @vCommunist.
  ///
  /// In en, this message translates to:
  /// **'Communist'**
  String get vCommunist;

  /// No description provided for @vSocialist.
  ///
  /// In en, this message translates to:
  /// **'Socialist'**
  String get vSocialist;

  /// No description provided for @vApolitical.
  ///
  /// In en, this message translates to:
  /// **'Apolitical'**
  String get vApolitical;

  /// No description provided for @vModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get vModerate;

  /// No description provided for @vNotInterested.
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get vNotInterested;

  /// No description provided for @vHaveKids.
  ///
  /// In en, this message translates to:
  /// **'Have kids'**
  String get vHaveKids;

  /// No description provided for @vDontHaveKids.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have kids'**
  String get vDontHaveKids;

  /// No description provided for @vDontWantKids.
  ///
  /// In en, this message translates to:
  /// **'Don\'t want kids'**
  String get vDontWantKids;

  /// No description provided for @vWantKids.
  ///
  /// In en, this message translates to:
  /// **'Want Kids'**
  String get vWantKids;

  /// No description provided for @vOpenToKids.
  ///
  /// In en, this message translates to:
  /// **'Open to kids'**
  String get vOpenToKids;

  /// No description provided for @vNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not Sure'**
  String get vNotSure;

  /// No description provided for @vPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get vPreferNotToSay;

  /// No description provided for @vAries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get vAries;

  /// No description provided for @vTaurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get vTaurus;

  /// No description provided for @vGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get vGemini;

  /// No description provided for @vCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get vCancer;

  /// No description provided for @vLeo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get vLeo;

  /// No description provided for @vVirgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get vVirgo;

  /// No description provided for @vLibra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get vLibra;

  /// No description provided for @vScorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get vScorpio;

  /// No description provided for @vSagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get vSagittarius;

  /// No description provided for @vCapricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get vCapricorn;

  /// No description provided for @vAquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get vAquarius;

  /// No description provided for @vPisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get vPisces;

  /// No description provided for @vHumanRights.
  ///
  /// In en, this message translates to:
  /// **'Human Rights'**
  String get vHumanRights;

  /// No description provided for @vDisabilityRights.
  ///
  /// In en, this message translates to:
  /// **'Disability Rights'**
  String get vDisabilityRights;

  /// No description provided for @vFeminism.
  ///
  /// In en, this message translates to:
  /// **'Feminism'**
  String get vFeminism;

  /// No description provided for @vBlackLivesMatter.
  ///
  /// In en, this message translates to:
  /// **'Black Lives Matter'**
  String get vBlackLivesMatter;

  /// No description provided for @vEnvironmentalism.
  ///
  /// In en, this message translates to:
  /// **'Environmentalism'**
  String get vEnvironmentalism;

  /// No description provided for @vLgbtqRights.
  ///
  /// In en, this message translates to:
  /// **'LGBTQ Rights'**
  String get vLgbtqRights;

  /// No description provided for @vImmigrantRights.
  ///
  /// In en, this message translates to:
  /// **'Immigrant Rights'**
  String get vImmigrantRights;

  /// No description provided for @vEndReligiousHate.
  ///
  /// In en, this message translates to:
  /// **'End Religious Hate'**
  String get vEndReligiousHate;

  /// No description provided for @vIndigenousRights.
  ///
  /// In en, this message translates to:
  /// **'Indigenous Rights'**
  String get vIndigenousRights;

  /// No description provided for @vNeuroDiversity.
  ///
  /// In en, this message translates to:
  /// **'Neuro diversity'**
  String get vNeuroDiversity;

  /// No description provided for @vVoterRights.
  ///
  /// In en, this message translates to:
  /// **'Voter Rights'**
  String get vVoterRights;

  /// No description provided for @vReproductiveRights.
  ///
  /// In en, this message translates to:
  /// **'Reproductive Rights'**
  String get vReproductiveRights;

  /// No description provided for @vAmbition.
  ///
  /// In en, this message translates to:
  /// **'Ambition'**
  String get vAmbition;

  /// No description provided for @vConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get vConfidence;

  /// No description provided for @vEmpathy.
  ///
  /// In en, this message translates to:
  /// **'Empathy'**
  String get vEmpathy;

  /// No description provided for @vHumor.
  ///
  /// In en, this message translates to:
  /// **'Humor'**
  String get vHumor;

  /// No description provided for @vKindness.
  ///
  /// In en, this message translates to:
  /// **'Kindness'**
  String get vKindness;

  /// No description provided for @vOpenness.
  ///
  /// In en, this message translates to:
  /// **'Openness'**
  String get vOpenness;

  /// No description provided for @vOptimism.
  ///
  /// In en, this message translates to:
  /// **'Optimism'**
  String get vOptimism;

  /// No description provided for @vSassiness.
  ///
  /// In en, this message translates to:
  /// **'Sassiness'**
  String get vSassiness;

  /// No description provided for @vPlayfulness.
  ///
  /// In en, this message translates to:
  /// **'Playfulness'**
  String get vPlayfulness;

  /// No description provided for @vLeadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get vLeadership;

  /// No description provided for @vHumility.
  ///
  /// In en, this message translates to:
  /// **'Humility'**
  String get vHumility;

  /// No description provided for @vLoyalty.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get vLoyalty;

  /// No description provided for @vSarcasm.
  ///
  /// In en, this message translates to:
  /// **'Sarcasm'**
  String get vSarcasm;

  /// No description provided for @vGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get vGratitude;

  /// No description provided for @vCuriosity.
  ///
  /// In en, this message translates to:
  /// **'Curiosity'**
  String get vCuriosity;

  /// No description provided for @vEmotionalIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Emotional Intelligence'**
  String get vEmotionalIntelligence;

  /// No description provided for @datingPreference.
  ///
  /// In en, this message translates to:
  /// **'Dating Preference'**
  String get datingPreference;

  /// No description provided for @bffPreference.
  ///
  /// In en, this message translates to:
  /// **'BFF Preference'**
  String get bffPreference;

  /// No description provided for @whoWouldYouDate.
  ///
  /// In en, this message translates to:
  /// **'Who would you like to date?'**
  String get whoWouldYouDate;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age range?'**
  String get ageRange;

  /// No description provided for @yearsOldRange.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} years old'**
  String yearsOldRange(String min, String max);

  /// No description provided for @howFarAway.
  ///
  /// In en, this message translates to:
  /// **'How far away they are?'**
  String get howFarAway;

  /// No description provided for @kilometersAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} kilometers away'**
  String kilometersAway(String distance);

  /// No description provided for @yourInterests.
  ///
  /// In en, this message translates to:
  /// **'Your interests?'**
  String get yourInterests;

  /// No description provided for @errorLoadingInterests.
  ///
  /// In en, this message translates to:
  /// **'Error loading interests'**
  String get errorLoadingInterests;

  /// No description provided for @whichLanguages.
  ///
  /// In en, this message translates to:
  /// **'Which language do you know?'**
  String get whichLanguages;

  /// No description provided for @selectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Select languages'**
  String get selectLanguages;

  /// No description provided for @religionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religionQuestion;

  /// No description provided for @selectReligion.
  ///
  /// In en, this message translates to:
  /// **'Select religion'**
  String get selectReligion;

  /// No description provided for @relationshipTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Relationship type?'**
  String get relationshipTypeQuestion;

  /// No description provided for @relationshipTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship Type'**
  String get relationshipTypeTitle;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get selectType;

  /// No description provided for @sexualOrientationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sexual orientation?'**
  String get sexualOrientationQuestion;

  /// No description provided for @sexualOrientationTitle.
  ///
  /// In en, this message translates to:
  /// **'Sexual Orientation'**
  String get sexualOrientationTitle;

  /// No description provided for @selectOrientation.
  ///
  /// In en, this message translates to:
  /// **'Select orientation'**
  String get selectOrientation;

  /// No description provided for @datingIntentionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Dating intention?'**
  String get datingIntentionQuestion;

  /// No description provided for @datingIntentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Dating Intention'**
  String get datingIntentionTitle;

  /// No description provided for @selectIntention.
  ///
  /// In en, this message translates to:
  /// **'Select intention'**
  String get selectIntention;

  /// No description provided for @filtersCleared.
  ///
  /// In en, this message translates to:
  /// **'Filters cleared successfully!'**
  String get filtersCleared;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @filterByInterests.
  ///
  /// In en, this message translates to:
  /// **'Filter by your interests'**
  String get filterByInterests;

  /// No description provided for @showMe.
  ///
  /// In en, this message translates to:
  /// **'Show me'**
  String get showMe;

  /// No description provided for @errUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String errUpdateFailed(String error);

  /// No description provided for @religionViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Religion View'**
  String get religionViewTitle;

  /// No description provided for @sensitiveInfoNote.
  ///
  /// In en, this message translates to:
  /// **'This is sensitive information that\'ll be on your profile. It\'s Totally optional.'**
  String get sensitiveInfoNote;

  /// No description provided for @zodiacSignTitle.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Sign'**
  String get zodiacSignTitle;

  /// No description provided for @doYouDrink.
  ///
  /// In en, this message translates to:
  /// **'Do you drink?'**
  String get doYouDrink;

  /// No description provided for @doYouSmoke.
  ///
  /// In en, this message translates to:
  /// **'Do you smoke?'**
  String get doYouSmoke;

  /// No description provided for @doYouWorkout.
  ///
  /// In en, this message translates to:
  /// **'Do you have workout?'**
  String get doYouWorkout;

  /// No description provided for @educationLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevelTitle;

  /// No description provided for @politicalViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Political View'**
  String get politicalViewTitle;

  /// No description provided for @doYouHaveKids.
  ///
  /// In en, this message translates to:
  /// **'Do you have kids?'**
  String get doYouHaveKids;

  /// No description provided for @kidsPlanQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are your plan for children\'s?'**
  String get kidsPlanQuestion;

  /// No description provided for @pickYourPronoun.
  ///
  /// In en, this message translates to:
  /// **'Pick Your Pronoun'**
  String get pickYourPronoun;

  /// No description provided for @pronounsBody.
  ///
  /// In en, this message translates to:
  /// **'What are your Pronouns? Pick 3 Pronouns you can remove this at anytime.'**
  String get pronounsBody;

  /// No description provided for @showPronounOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show your pronoun on my profile'**
  String get showPronounOnProfile;

  /// No description provided for @causesTitle.
  ///
  /// In en, this message translates to:
  /// **'Causes & Communities'**
  String get causesTitle;

  /// No description provided for @selectUpTo3Causes.
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 options close to your hearts.'**
  String get selectUpTo3Causes;

  /// No description provided for @maxThreeOptions.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 options'**
  String get maxThreeOptions;

  /// No description provided for @personQualities.
  ///
  /// In en, this message translates to:
  /// **'Person Qualities'**
  String get personQualities;

  /// No description provided for @chooseThreeQualities.
  ///
  /// In en, this message translates to:
  /// **'Choose 3 qualities that would make a connection that much stronger.'**
  String get chooseThreeQualities;

  /// No description provided for @maxThreeQualities.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 qualities only.'**
  String get maxThreeQualities;

  /// No description provided for @howTallAreYou.
  ///
  /// In en, this message translates to:
  /// **'How tall are you?'**
  String get howTallAreYou;

  /// No description provided for @showsOnProfile.
  ///
  /// In en, this message translates to:
  /// **'This will show on your profile'**
  String get showsOnProfile;

  /// No description provided for @yourHeight.
  ///
  /// In en, this message translates to:
  /// **'Your Height'**
  String get yourHeight;

  /// No description provided for @professionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profession'**
  String get professionTitle;

  /// No description provided for @showProfessionOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show your profession on your profile'**
  String get showProfessionOnProfile;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @companyIndustry.
  ///
  /// In en, this message translates to:
  /// **'Company (Industry)'**
  String get companyIndustry;

  /// No description provided for @educatedAt.
  ///
  /// In en, this message translates to:
  /// **'Educated at'**
  String get educatedAt;

  /// No description provided for @showInstitutionOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show your institution on your profile'**
  String get showInstitutionOnProfile;

  /// No description provided for @institutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institutionLabel;

  /// No description provided for @graduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get graduationYear;

  /// No description provided for @enterInstitution.
  ///
  /// In en, this message translates to:
  /// **'Please enter your institution name.'**
  String get enterInstitution;

  /// No description provided for @maxThreeLanguages.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 languages'**
  String get maxThreeLanguages;

  /// No description provided for @whatLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatLookingFor;

  /// No description provided for @maxThreeForMode.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 options for the current mode ({mode}).'**
  String maxThreeForMode(String mode);

  /// No description provided for @errorSavingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error saving preferences: {error}'**
  String errorSavingPreferences(String error);

  /// No description provided for @languagesIKnow.
  ///
  /// In en, this message translates to:
  /// **'Languages I know'**
  String get languagesIKnow;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @searchLanguages.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get searchLanguages;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// No description provided for @allLanguages.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get allLanguages;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @percentTrust.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Trust'**
  String percentTrust(String percent);

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile Completed'**
  String get profileCompleted;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get completeProfile;

  /// No description provided for @higherScoreHelps.
  ///
  /// In en, this message translates to:
  /// **'A higher score helps you get more\nauthentic matches'**
  String get higherScoreHelps;

  /// No description provided for @noBioYet.
  ///
  /// In en, this message translates to:
  /// **'No bio added yet.'**
  String get noBioYet;

  /// No description provided for @askMe.
  ///
  /// In en, this message translates to:
  /// **'Ask me'**
  String get askMe;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @addReligion.
  ///
  /// In en, this message translates to:
  /// **'Add Religion'**
  String get addReligion;

  /// No description provided for @addZodiac.
  ///
  /// In en, this message translates to:
  /// **'Add Zodiac'**
  String get addZodiac;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get premium;

  /// No description provided for @getNoticedSooner.
  ///
  /// In en, this message translates to:
  /// **'Get noticed sooner and\ngo on 3x as many dates'**
  String get getNoticedSooner;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @spotlight.
  ///
  /// In en, this message translates to:
  /// **'Spot light'**
  String get spotlight;

  /// No description provided for @standOut.
  ///
  /// In en, this message translates to:
  /// **'Stand out'**
  String get standOut;

  /// No description provided for @superSwipe.
  ///
  /// In en, this message translates to:
  /// **'Super swipe'**
  String get superSwipe;

  /// No description provided for @getNoticed.
  ///
  /// In en, this message translates to:
  /// **'Get noticed'**
  String get getNoticed;

  /// No description provided for @scoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score breakdown'**
  String get scoreBreakdown;

  /// No description provided for @profilePhotoVerified.
  ///
  /// In en, this message translates to:
  /// **'Profile photo verified'**
  String get profilePhotoVerified;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile details'**
  String get profileDetails;

  /// No description provided for @incompleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incompleteLabel;

  /// No description provided for @connectSocialAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connect social accounts'**
  String get connectSocialAccounts;

  /// No description provided for @waysToImprove.
  ///
  /// In en, this message translates to:
  /// **'Ways to improve'**
  String get waysToImprove;

  /// No description provided for @verifyYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'Verify your photos'**
  String get verifyYourPhotos;

  /// No description provided for @proveYoureReal.
  ///
  /// In en, this message translates to:
  /// **'Prove you\'re real to other members'**
  String get proveYoureReal;

  /// No description provided for @addPromptsInterests.
  ///
  /// In en, this message translates to:
  /// **'Add prompts, interests and other details'**
  String get addPromptsInterests;

  /// No description provided for @verificationDataSecure.
  ///
  /// In en, this message translates to:
  /// **'You\'re verification data is handled secured and is not shared on your public profile. '**
  String get verificationDataSecure;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @improveYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Improve your Profile'**
  String get improveYourProfile;

  /// No description provided for @errorSavingHometown.
  ///
  /// In en, this message translates to:
  /// **'Error saving hometown: {error}'**
  String errorSavingHometown(String error);

  /// No description provided for @searchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get searchCity;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// No description provided for @bioPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t be shy! This is your chance to share your personality with a short bio.'**
  String get bioPrompt;

  /// No description provided for @textHereHint.
  ///
  /// In en, this message translates to:
  /// **'Text Here.....'**
  String get textHereHint;

  /// No description provided for @failedToSaveBio.
  ///
  /// In en, this message translates to:
  /// **'Failed to save bio: {error}'**
  String failedToSaveBio(String error);

  /// No description provided for @selectYourInterests.
  ///
  /// In en, this message translates to:
  /// **'Select Your Interests'**
  String get selectYourInterests;

  /// No description provided for @atLeast5Interests.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 5 interest. This helps us find your peoples'**
  String get atLeast5Interests;

  /// No description provided for @searchForInterest.
  ///
  /// In en, this message translates to:
  /// **'Search for interest'**
  String get searchForInterest;

  /// No description provided for @noInterestsFound.
  ///
  /// In en, this message translates to:
  /// **'No interests found'**
  String get noInterestsFound;

  /// No description provided for @failedLoadInterests.
  ///
  /// In en, this message translates to:
  /// **'Failed to load interests. Please try again.'**
  String get failedLoadInterests;

  /// No description provided for @maxTenInterests.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 10 interests'**
  String get maxTenInterests;

  /// No description provided for @minFiveInterests.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 5 interests'**
  String get minFiveInterests;

  /// No description provided for @errorSavingInterests.
  ///
  /// In en, this message translates to:
  /// **'Error saving interests: {error}'**
  String errorSavingInterests(String error);

  /// No description provided for @lifeStyle.
  ///
  /// In en, this message translates to:
  /// **'Life Style'**
  String get lifeStyle;

  /// No description provided for @lifestylePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tell us more about your habits. Pick what fits you best.'**
  String get lifestylePrompt;

  /// No description provided for @noLifestyleOptions.
  ///
  /// In en, this message translates to:
  /// **'No lifestyle options available'**
  String get noLifestyleOptions;

  /// No description provided for @failedLoadLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lifestyle options. Please try again.'**
  String get failedLoadLifestyle;

  /// No description provided for @selectEachCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select an option for each category, or clear all to skip.'**
  String get selectEachCategory;

  /// No description provided for @findYourCity.
  ///
  /// In en, this message translates to:
  /// **'Find your current city'**
  String get findYourCity;

  /// No description provided for @errorSavingLocation.
  ///
  /// In en, this message translates to:
  /// **'Error saving location: {error}'**
  String errorSavingLocation(String error);

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This permission is required for the app to function correctly. Please enable it in settings.'**
  String get permissionRequiredBody;

  /// No description provided for @cameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get cameraAccess;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// No description provided for @locationAccess.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get locationAccess;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'Notification Access'**
  String get notificationAccess;

  /// No description provided for @microphoneAccess.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get microphoneAccess;

  /// No description provided for @unknownAccess.
  ///
  /// In en, this message translates to:
  /// **'Unknown Access'**
  String get unknownAccess;

  /// No description provided for @cameraReason.
  ///
  /// In en, this message translates to:
  /// **'To take profile photos and verify identity.'**
  String get cameraReason;

  /// No description provided for @photoReason.
  ///
  /// In en, this message translates to:
  /// **'To upload photos from your gallery.'**
  String get photoReason;

  /// No description provided for @locationReason.
  ///
  /// In en, this message translates to:
  /// **'To show you matches nearby.'**
  String get locationReason;

  /// No description provided for @notificationReason.
  ///
  /// In en, this message translates to:
  /// **'To alert you of new matches and messages.'**
  String get notificationReason;

  /// No description provided for @microphoneReason.
  ///
  /// In en, this message translates to:
  /// **'For voice and video interactions.'**
  String get microphoneReason;

  /// No description provided for @appPermissions.
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get appPermissions;

  /// No description provided for @chooseYourPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Prompt'**
  String get chooseYourPrompt;

  /// No description provided for @selectUpTo3Prompts.
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 prompt to showing up your personality.'**
  String get selectUpTo3Prompts;

  /// No description provided for @maxThreePrompts.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 3 prompts.'**
  String get maxThreePrompts;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @removeThisPrompt.
  ///
  /// In en, this message translates to:
  /// **'Want to remove this prompt?'**
  String get removeThisPrompt;

  /// No description provided for @selectThreePrompts.
  ///
  /// In en, this message translates to:
  /// **'Please select 3 prompts to continue.'**
  String get selectThreePrompts;

  /// No description provided for @selectOnePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 prompt.'**
  String get selectOnePrompt;

  /// No description provided for @selectNMorePrompts.
  ///
  /// In en, this message translates to:
  /// **'Please select {count} prompt to continue'**
  String selectNMorePrompts(String count);

  /// No description provided for @noPromptsForCategory.
  ///
  /// In en, this message translates to:
  /// **'No prompts available for this category.'**
  String get noPromptsForCategory;

  /// No description provided for @typeYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get typeYourAnswer;

  /// No description provided for @addPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add Prompt'**
  String get addPrompt;

  /// No description provided for @failedToLoadPrompts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load prompts: {error}'**
  String failedToLoadPrompts(String error);

  /// No description provided for @errorSavingPrompts.
  ///
  /// In en, this message translates to:
  /// **'Error saving prompts: {error}'**
  String errorSavingPrompts(String error);

  /// No description provided for @communityGuidelines.
  ///
  /// In en, this message translates to:
  /// **'Community guidelines'**
  String get communityGuidelines;

  /// No description provided for @agreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree & Continue'**
  String get agreeAndContinue;

  /// No description provided for @termsByContinuePrefix.
  ///
  /// In en, this message translates to:
  /// **'By Continue, you agree to our '**
  String get termsByContinuePrefix;

  /// No description provided for @guidelinesIntro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.'**
  String get guidelinesIntro;

  /// No description provided for @beKindTitle.
  ///
  /// In en, this message translates to:
  /// **'Be kind and respectful'**
  String get beKindTitle;

  /// No description provided for @beKindBody.
  ///
  /// In en, this message translates to:
  /// **'Treat others as you would like to be treated. We\'re all in together to create welcoming environment.'**
  String get beKindBody;

  /// No description provided for @stayAuthenticTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay authentic'**
  String get stayAuthenticTitle;

  /// No description provided for @stayAuthenticBody.
  ///
  /// In en, this message translates to:
  /// **'Be genuine in your profile and interactions. We value authenticity and real connections.'**
  String get stayAuthenticBody;

  /// No description provided for @prioritizeSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Prioritize safety'**
  String get prioritizeSafetyTitle;

  /// No description provided for @prioritizeSafetyBody.
  ///
  /// In en, this message translates to:
  /// **'Do not share sensitive and personal information. Protect your self and others in the community.'**
  String get prioritizeSafetyBody;

  /// No description provided for @noHateTitle.
  ///
  /// In en, this message translates to:
  /// **'No hate speech'**
  String get noHateTitle;

  /// No description provided for @noHateBody.
  ///
  /// In en, this message translates to:
  /// **'Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.'**
  String get noHateBody;

  /// No description provided for @helpKeepSafeTitle.
  ///
  /// In en, this message translates to:
  /// **'Help keep us safe'**
  String get helpKeepSafeTitle;

  /// No description provided for @helpKeepSafeBody.
  ///
  /// In en, this message translates to:
  /// **'If you see something that violate our guideline. Please report it. Your help is invaluable.'**
  String get helpKeepSafeBody;

  /// No description provided for @genuineIntentTitle.
  ///
  /// In en, this message translates to:
  /// **'Date with genuine intentions'**
  String get genuineIntentTitle;

  /// No description provided for @genuineIntentBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.'**
  String get genuineIntentBody;

  /// No description provided for @adultsOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Adults only'**
  String get adultsOnlyTitle;

  /// No description provided for @adultsOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.'**
  String get adultsOnlyBody;

  /// No description provided for @letsIntroduceYou.
  ///
  /// In en, this message translates to:
  /// **'Let\'s introduce you!'**
  String get letsIntroduceYou;

  /// No description provided for @needNameForProfile.
  ///
  /// In en, this message translates to:
  /// **'We need your Name to create your profile'**
  String get needNameForProfile;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name'**
  String get enterYourName;

  /// No description provided for @needDobForProfile.
  ///
  /// In en, this message translates to:
  /// **'We need your DOB to create your profile'**
  String get needDobForProfile;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @birthdayNote.
  ///
  /// In en, this message translates to:
  /// **'Your birthday is used to calculate your age and will be shown on your profile. Your full name will not be public'**
  String get birthdayNote;

  /// No description provided for @failedToSaveData.
  ///
  /// In en, this message translates to:
  /// **'Failed to save data: {error}'**
  String failedToSaveData(String error);

  /// No description provided for @whatsYourGender.
  ///
  /// In en, this message translates to:
  /// **'What\'s your Gender?'**
  String get whatsYourGender;

  /// No description provided for @genderHelpsMatches.
  ///
  /// In en, this message translates to:
  /// **'This help us show you relevant profiles and find your matches'**
  String get genderHelpsMatches;

  /// No description provided for @vNonBinary.
  ///
  /// In en, this message translates to:
  /// **'Non-Binary'**
  String get vNonBinary;

  /// No description provided for @vPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer Not'**
  String get vPreferNot;

  /// No description provided for @failedToSaveGender.
  ///
  /// In en, this message translates to:
  /// **'Failed to save gender: {error}'**
  String failedToSaveGender(String error);

  /// No description provided for @grantPermissionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Please grant {permission} permission to upload photos for your profile.'**
  String grantPermissionPhotos(String permission);

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'Photo Not Accepted'**
  String get photoNotAccepted;

  /// No description provided for @couldNotVerifyPhoto.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your photo because:'**
  String get couldNotVerifyPhoto;

  /// No description provided for @tryDifferentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please try uploading a different photo.'**
  String get tryDifferentPhoto;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @addAtLeast2Photos.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 photos to get your matches! First one is main picture'**
  String get addAtLeast2Photos;

  /// No description provided for @tapPhotoToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap on an added photo to edit or remove it.'**
  String get tapPhotoToEdit;

  /// No description provided for @addOneMorePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add one more photo'**
  String get addOneMorePhoto;

  /// No description provided for @addMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add more photos'**
  String get addMorePhotos;

  /// No description provided for @mainPhotoBadge.
  ///
  /// In en, this message translates to:
  /// **'MAIN'**
  String get mainPhotoBadge;

  /// No description provided for @editPhoto.
  ///
  /// In en, this message translates to:
  /// **'Edit Photo'**
  String get editPhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @realConnectionsStartHere.
  ///
  /// In en, this message translates to:
  /// **'Real connections start here!'**
  String get realConnectionsStartHere;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @iHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get iHaveAnAccount;

  /// No description provided for @agreeToOurTerms.
  ///
  /// In en, this message translates to:
  /// **'you agree to our terms'**
  String get agreeToOurTerms;

  /// No description provided for @findPeopleNearYou.
  ///
  /// In en, this message translates to:
  /// **'Find People Near You'**
  String get findPeopleNearYou;

  /// No description provided for @locationAccessBody.
  ///
  /// In en, this message translates to:
  /// **'To show you potential matches in your area. We need to\nknow your location. This also help us verify your\ngeneral location for authenticity and safety. Don\'t\nworry, your exact location is never shared'**
  String get locationAccessBody;

  /// No description provided for @allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get allowLocationAccess;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @booked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get booked;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No Events Found'**
  String get noEventsFound;

  /// No description provided for @noEventsNearby.
  ///
  /// In en, this message translates to:
  /// **'There are no events happening nearby at the moment. Check back later or adjust your location.'**
  String get noEventsNearby;

  /// No description provided for @refreshEvents.
  ///
  /// In en, this message translates to:
  /// **'Refresh Events'**
  String get refreshEvents;

  /// No description provided for @bookedEvents.
  ///
  /// In en, this message translates to:
  /// **'Booked Events'**
  String get bookedEvents;

  /// No description provided for @ticketsAndReservations.
  ///
  /// In en, this message translates to:
  /// **'Your tickets and reservations'**
  String get ticketsAndReservations;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @eventsYouAreInterested.
  ///
  /// In en, this message translates to:
  /// **'Events you are interested in'**
  String get eventsYouAreInterested;

  /// No description provided for @incomingVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming video call'**
  String get incomingVideoCall;

  /// No description provided for @incomingVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Incoming voice call'**
  String get incomingVoiceCall;

  /// No description provided for @ringing.
  ///
  /// In en, this message translates to:
  /// **'Ringing...'**
  String get ringing;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @videoOff.
  ///
  /// In en, this message translates to:
  /// **'Video Off'**
  String get videoOff;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @callEnded.
  ///
  /// In en, this message translates to:
  /// **'Call Ended'**
  String get callEnded;

  /// No description provided for @howWasCallQuality.
  ///
  /// In en, this message translates to:
  /// **'How was the call quality?'**
  String get howWasCallQuality;

  /// No description provided for @switchToVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Switch to Video Call?'**
  String get switchToVideoCall;

  /// No description provided for @otherWantsVideoOn.
  ///
  /// In en, this message translates to:
  /// **'The other user wants to turn on video.'**
  String get otherWantsVideoOn;

  /// No description provided for @switchToVoiceCall.
  ///
  /// In en, this message translates to:
  /// **'Switch to Voice Call?'**
  String get switchToVoiceCall;

  /// No description provided for @otherWantsVideoOff.
  ///
  /// In en, this message translates to:
  /// **'The other user wants to turn off video.'**
  String get otherWantsVideoOff;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @incomingVideoCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Video Call'**
  String get incomingVideoCallTitle;

  /// No description provided for @incomingVoiceCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Incoming Voice Call'**
  String get incomingVoiceCallTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @peoples.
  ///
  /// In en, this message translates to:
  /// **'Peoples'**
  String get peoples;

  /// No description provided for @chatTab.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTab;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(String percent);

  /// No description provided for @profileStrength.
  ///
  /// In en, this message translates to:
  /// **'Profile strength'**
  String get profileStrength;

  /// No description provided for @photosAndVideos.
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get photosAndVideos;

  /// No description provided for @pickSomeTrueYou.
  ///
  /// In en, this message translates to:
  /// **'Pick some that show the true you.'**
  String get pickSomeTrueYou;

  /// No description provided for @holdDragReorder.
  ///
  /// In en, this message translates to:
  /// **'Hold and drag media to reorder'**
  String get holdDragReorder;

  /// No description provided for @bestPhoto.
  ///
  /// In en, this message translates to:
  /// **'Best photo'**
  String get bestPhoto;

  /// No description provided for @aboutYouSection.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get aboutYouSection;

  /// No description provided for @aboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'About you...'**
  String get aboutYouHint;

  /// No description provided for @writeFunIntro.
  ///
  /// In en, this message translates to:
  /// **'Write a fun intro.'**
  String get writeFunIntro;

  /// No description provided for @letPeopleKnowDate.
  ///
  /// In en, this message translates to:
  /// **'Let people know what it\'s like to date you.'**
  String get letPeopleKnowDate;

  /// No description provided for @addAPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a prompt'**
  String get addAPrompt;

  /// No description provided for @prompts.
  ///
  /// In en, this message translates to:
  /// **'Prompts'**
  String get prompts;

  /// No description provided for @prompt.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get prompt;

  /// No description provided for @addVoiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Add a voice intro'**
  String get addVoiceIntro;

  /// No description provided for @letPeopleHearVoice.
  ///
  /// In en, this message translates to:
  /// **'Let people hear your voice.'**
  String get letPeopleHearVoice;

  /// No description provided for @reRecordIntro.
  ///
  /// In en, this message translates to:
  /// **'Re-record intro'**
  String get reRecordIntro;

  /// No description provided for @deleteVoiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Delete Voice Intro?'**
  String get deleteVoiceIntro;

  /// No description provided for @removeVoiceIntroBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove your voice intro from your profile.'**
  String get removeVoiceIntroBody;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @addFavoriteInterests.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite interests'**
  String get addFavoriteInterests;

  /// No description provided for @getSpecificThingsYouLove.
  ///
  /// In en, this message translates to:
  /// **'Get specific about the things you love.'**
  String get getSpecificThingsYouLove;

  /// No description provided for @lifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyle;

  /// No description provided for @addLifestylePrefs.
  ///
  /// In en, this message translates to:
  /// **'Add your lifestyle preferences'**
  String get addLifestylePrefs;

  /// No description provided for @habitsAndPrefs.
  ///
  /// In en, this message translates to:
  /// **'Your habits and preferences.'**
  String get habitsAndPrefs;

  /// No description provided for @iAmLookingFor.
  ///
  /// In en, this message translates to:
  /// **'I am looking for'**
  String get iAmLookingFor;

  /// No description provided for @addWhatLookingFor.
  ///
  /// In en, this message translates to:
  /// **'Add what you are looking for'**
  String get addWhatLookingFor;

  /// No description provided for @letOthersKnowWant.
  ///
  /// In en, this message translates to:
  /// **'Let others know what you want to find'**
  String get letOthersKnowWant;

  /// No description provided for @qualitiesIValue.
  ///
  /// In en, this message translates to:
  /// **'Qualities i value'**
  String get qualitiesIValue;

  /// No description provided for @addQualitiesYouValue.
  ///
  /// In en, this message translates to:
  /// **'Add qualities you value'**
  String get addQualitiesYouValue;

  /// No description provided for @chooseThreeQualitiesValue.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 3 qualities you value in a person'**
  String get chooseThreeQualitiesValue;

  /// No description provided for @myCausesSection.
  ///
  /// In en, this message translates to:
  /// **'My causes and communities'**
  String get myCausesSection;

  /// No description provided for @addYourCauses.
  ///
  /// In en, this message translates to:
  /// **'Add your causes and communities'**
  String get addYourCauses;

  /// No description provided for @addUpTo3Causes.
  ///
  /// In en, this message translates to:
  /// **'Add up to 3 causes close to your heart.'**
  String get addUpTo3Causes;

  /// No description provided for @addLanguagesYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Add Languages you know'**
  String get addLanguagesYouKnow;

  /// No description provided for @moreAboutYou.
  ///
  /// In en, this message translates to:
  /// **'More about you'**
  String get moreAboutYou;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @pronounsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get pronounsLabel;

  /// No description provided for @pickYourPronouns.
  ///
  /// In en, this message translates to:
  /// **'Pick your pronouns'**
  String get pickYourPronouns;

  /// No description provided for @addYourPronouns.
  ///
  /// In en, this message translates to:
  /// **'Add your pronouns'**
  String get addYourPronouns;

  /// No description provided for @workLabel.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get workLabel;

  /// No description provided for @educationLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Education level'**
  String get educationLevelLabel;

  /// No description provided for @hometownLabel.
  ///
  /// In en, this message translates to:
  /// **'Hometown'**
  String get hometownLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @exerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseLabel;

  /// No description provided for @drinkingLabel.
  ///
  /// In en, this message translates to:
  /// **'Drinking'**
  String get drinkingLabel;

  /// No description provided for @smokingLabel.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smokingLabel;

  /// No description provided for @kidsLabel.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kidsLabel;

  /// No description provided for @kidsPreferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Kids Preference'**
  String get kidsPreferenceLabel;

  /// No description provided for @politicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politicsLabel;

  /// No description provided for @zodiacLabel.
  ///
  /// In en, this message translates to:
  /// **'Zodiac'**
  String get zodiacLabel;

  /// No description provided for @educatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Educated at'**
  String get educatedAtLabel;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected accounts'**
  String get connectedAccounts;

  /// No description provided for @connectMySpotify.
  ///
  /// In en, this message translates to:
  /// **'Connect my spotify'**
  String get connectMySpotify;

  /// No description provided for @showFavoriteMusic.
  ///
  /// In en, this message translates to:
  /// **'Show your favorite music'**
  String get showFavoriteMusic;

  /// No description provided for @spotifyNote.
  ///
  /// In en, this message translates to:
  /// **'Show your top spotify artists on your profile and allow blindly to highlight who have in common with others.'**
  String get spotifyNote;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @invalidLocation.
  ///
  /// In en, this message translates to:
  /// **'Invalid Location'**
  String get invalidLocation;

  /// No description provided for @locationFound.
  ///
  /// In en, this message translates to:
  /// **'Location Found'**
  String get locationFound;

  /// No description provided for @alreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'You have been already verified'**
  String get alreadyVerified;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful'**
  String get verificationSuccessful;

  /// No description provided for @documentNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Document could not be verified.'**
  String get documentNotVerified;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verificationFailed;

  /// No description provided for @veriffReason.
  ///
  /// In en, this message translates to:
  /// **'We could not verify your ID. Veriff provided this reason:'**
  String get veriffReason;

  /// No description provided for @tryClearerImage.
  ///
  /// In en, this message translates to:
  /// **'Please try again with a clearer image.'**
  String get tryClearerImage;

  /// No description provided for @veriffWaiting.
  ///
  /// In en, this message translates to:
  /// **'Veriff finished. Waiting for webhook update...'**
  String get veriffWaiting;

  /// No description provided for @verificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Verification Submitted! Reviewing your ID...'**
  String get verificationSubmitted;

  /// No description provided for @verifyYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Profile'**
  String get verifyYourProfile;

  /// No description provided for @youAreVerified.
  ///
  /// In en, this message translates to:
  /// **'You are Verified!'**
  String get youAreVerified;

  /// No description provided for @quickCheckSafe.
  ///
  /// In en, this message translates to:
  /// **'A quick check to keep you safe'**
  String get quickCheckSafe;

  /// No description provided for @identityConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been confirmed.'**
  String get identityConfirmed;

  /// No description provided for @veriffExplainer.
  ///
  /// In en, this message translates to:
  /// **'To confirm your identity, we use Veriff for secure document scanning.'**
  String get veriffExplainer;

  /// No description provided for @verifyingResults.
  ///
  /// In en, this message translates to:
  /// **'Verifying Results...'**
  String get verifyingResults;

  /// No description provided for @verificationComplete.
  ///
  /// In en, this message translates to:
  /// **'Verification Complete'**
  String get verificationComplete;

  /// No description provided for @tapToScanDocument.
  ///
  /// In en, this message translates to:
  /// **'Tap to Scan Document'**
  String get tapToScanDocument;

  /// No description provided for @prepareIdCard.
  ///
  /// In en, this message translates to:
  /// **'Prepare your physical ID card'**
  String get prepareIdCard;

  /// No description provided for @ensureGoodLighting.
  ///
  /// In en, this message translates to:
  /// **'Ensure good lighting'**
  String get ensureGoodLighting;

  /// No description provided for @readyForSelfie.
  ///
  /// In en, this message translates to:
  /// **'Be ready for a quick selfie'**
  String get readyForSelfie;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @startVerification.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get startVerification;

  /// No description provided for @poweredByVeriff.
  ///
  /// In en, this message translates to:
  /// **'Powered by Veriff'**
  String get poweredByVeriff;

  /// No description provided for @alignWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Align yourself with the camera'**
  String get alignWithCamera;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for verification.'**
  String get cameraPermissionRequired;

  /// No description provided for @noCameraFound.
  ///
  /// In en, this message translates to:
  /// **'No camera found on device.'**
  String get noCameraFound;

  /// No description provided for @reviewingYourPhotos.
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your photos'**
  String get reviewingYourPhotos;

  /// No description provided for @verificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your profile verification is in progress. This usually takes a few seconds.'**
  String get verificationInProgress;

  /// No description provided for @verifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verified Successfully!'**
  String get verifiedSuccessfully;

  /// No description provided for @profileVerificationDone.
  ///
  /// In en, this message translates to:
  /// **'Profile verification successfully completed'**
  String get profileVerificationDone;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @copyThisPose.
  ///
  /// In en, this message translates to:
  /// **'Copy this pose'**
  String get copyThisPose;

  /// No description provided for @selfieVerification.
  ///
  /// In en, this message translates to:
  /// **'Selfie Verification'**
  String get selfieVerification;

  /// No description provided for @proveRealDeal.
  ///
  /// In en, this message translates to:
  /// **'Prove You\'re the\nReal Deal'**
  String get proveRealDeal;

  /// No description provided for @quickHelpsSafe.
  ///
  /// In en, this message translates to:
  /// **'This quick helps takes keep our community safe and authentic'**
  String get quickHelpsSafe;

  /// No description provided for @getVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Get a verified badge'**
  String get getVerifiedBadge;

  /// No description provided for @buildTrustBody.
  ///
  /// In en, this message translates to:
  /// **'Build trust with other users and shown you\'re real.'**
  String get buildTrustBody;

  /// No description provided for @keepCommunitySafe.
  ///
  /// In en, this message translates to:
  /// **'Keep the community safe'**
  String get keepCommunitySafe;

  /// No description provided for @weedOutFakes.
  ///
  /// In en, this message translates to:
  /// **'Help us weed out fake profiles and bots.'**
  String get weedOutFakes;

  /// No description provided for @copySimplePose.
  ///
  /// In en, this message translates to:
  /// **'Copy a simple pose'**
  String get copySimplePose;

  /// No description provided for @quickSelfieConfirm.
  ///
  /// In en, this message translates to:
  /// **'You\'ll take quick selfie to confirm your identity'**
  String get quickSelfieConfirm;

  /// No description provided for @selfieNotOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Note: Your selfie is only for verification and won\'t to be on your profile'**
  String get selfieNotOnProfile;

  /// No description provided for @getVerified.
  ///
  /// In en, this message translates to:
  /// **'Get verified'**
  String get getVerified;

  /// No description provided for @voiceIntroTooShort.
  ///
  /// In en, this message translates to:
  /// **'Voice intro must be at least 1 second'**
  String get voiceIntroTooShort;

  /// No description provided for @recordVoiceIntroFirst.
  ///
  /// In en, this message translates to:
  /// **'Please record a voice intro'**
  String get recordVoiceIntroFirst;

  /// No description provided for @recordingBetween1And30.
  ///
  /// In en, this message translates to:
  /// **'Recording must be between 1 and 30 seconds'**
  String get recordingBetween1And30;

  /// No description provided for @recordShortIntro.
  ///
  /// In en, this message translates to:
  /// **'Record a short intro'**
  String get recordShortIntro;

  /// No description provided for @personalityShine.
  ///
  /// In en, this message translates to:
  /// **'Let your personality shine through. Record a 30 seconds short intro.'**
  String get personalityShine;

  /// No description provided for @recordAgain.
  ///
  /// In en, this message translates to:
  /// **'Record Again'**
  String get recordAgain;

  /// No description provided for @voicePromptsHelp.
  ///
  /// In en, this message translates to:
  /// **'Voice prompts help you stand out and make deeper connections. Share who you really are'**
  String get voicePromptsHelp;

  /// No description provided for @threeXMatches.
  ///
  /// In en, this message translates to:
  /// **'3x more matches in voice record'**
  String get threeXMatches;

  /// No description provided for @startConversationNaturally.
  ///
  /// In en, this message translates to:
  /// **'Start conversation naturally'**
  String get startConversationNaturally;

  /// No description provided for @showYourPersonality.
  ///
  /// In en, this message translates to:
  /// **'Show your personality'**
  String get showYourPersonality;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// No description provided for @failedUploadVoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload voice intro: {error}'**
  String failedUploadVoice(String error);

  /// No description provided for @failedToStartRecording.
  ///
  /// In en, this message translates to:
  /// **'Failed to start recording'**
  String get failedToStartRecording;

  /// No description provided for @failedToStopRecording.
  ///
  /// In en, this message translates to:
  /// **'Failed to stop recording'**
  String get failedToStopRecording;

  /// No description provided for @failedToPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Failed to play audio'**
  String get failedToPlayAudio;

  /// No description provided for @navLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get navLikes;

  /// No description provided for @photoReasonNoFace.
  ///
  /// In en, this message translates to:
  /// **'We could not find a clear face. Use a photo where your face is visible.'**
  String get photoReasonNoFace;

  /// No description provided for @photoReasonGroupPhoto.
  ///
  /// In en, this message translates to:
  /// **'This photo has more than one person. Use a solo photo.'**
  String get photoReasonGroupPhoto;

  /// No description provided for @photoReasonFaceTooSmall.
  ///
  /// In en, this message translates to:
  /// **'Your face is too small in this photo. Move closer or crop in.'**
  String get photoReasonFaceTooSmall;

  /// No description provided for @photoReasonUnsafe.
  ///
  /// In en, this message translates to:
  /// **'This photo does not meet our content guidelines.'**
  String get photoReasonUnsafe;

  /// No description provided for @photoReasonBadImage.
  ///
  /// In en, this message translates to:
  /// **'We could not read this file. Try a JPG or PNG photo.'**
  String get photoReasonBadImage;

  /// No description provided for @photoReasonTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large. Try a smaller one.'**
  String get photoReasonTooLarge;

  /// No description provided for @photoReasonUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We could not check this photo right now.'**
  String get photoReasonUnavailable;

  /// No description provided for @photoTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get photoTryAgainLater;

  /// No description provided for @photoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your photos.'**
  String get photoLoadFailed;

  /// No description provided for @photoSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your photos. Please try again.'**
  String get photoSaveFailed;

  /// No description provided for @photosNotAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} photos could not be added:'**
  String photosNotAdded(int count);

  /// No description provided for @photosExpired.
  ///
  /// In en, this message translates to:
  /// **'Some photos expired and were removed. Please add them again.'**
  String get photosExpired;

  /// No description provided for @spotlightHeadline.
  ///
  /// In en, this message translates to:
  /// **'Be the first card they see'**
  String get spotlightHeadline;

  /// No description provided for @spotlightExplainer.
  ///
  /// In en, this message translates to:
  /// **'For as long as your spotlight runs, you sit at the top of the deck for everyone in your district — even people whose filters you don\'t match.'**
  String get spotlightExplainer;

  /// No description provided for @spotlightDistrictLine.
  ///
  /// In en, this message translates to:
  /// **'Your district: {district}'**
  String spotlightDistrictLine(String district);

  /// No description provided for @spotlightDistrictUnknown.
  ///
  /// In en, this message translates to:
  /// **'Working out where you are…'**
  String get spotlightDistrictUnknown;

  /// No description provided for @spotlightChooseDuration.
  ///
  /// In en, this message translates to:
  /// **'Choose how long'**
  String get spotlightChooseDuration;

  /// No description provided for @spotlightMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String spotlightMinutes(String count);

  /// No description provided for @spotlightOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get spotlightOneHour;

  /// No description provided for @spotlightPrice.
  ///
  /// In en, this message translates to:
  /// **'₹{amount}'**
  String spotlightPrice(String amount);

  /// No description provided for @spotlightBuy.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get spotlightBuy;

  /// No description provided for @spotlightExtend.
  ///
  /// In en, this message translates to:
  /// **'Extend spotlight'**
  String get spotlightExtend;

  /// No description provided for @spotlightLiveIn.
  ///
  /// In en, this message translates to:
  /// **'Live in {district}'**
  String spotlightLiveIn(String district);

  /// No description provided for @spotlightTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'{time} left'**
  String spotlightTimeLeft(String time);

  /// No description provided for @spotlightSuccess.
  ///
  /// In en, this message translates to:
  /// **'You\'re in the spotlight'**
  String get spotlightSuccess;

  /// No description provided for @spotlightNoDistrict.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t work out which district you\'re in. Turn location on and try again.'**
  String get spotlightNoDistrict;

  /// No description provided for @spotlightFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t go through. Please try again.'**
  String get spotlightFailed;

  /// No description provided for @spotlightTestPurchase.
  ///
  /// In en, this message translates to:
  /// **'No payment is taken yet. This completes the purchase for testing.'**
  String get spotlightTestPurchase;

  /// No description provided for @spotlightRuleFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters are ignored — age, distance, interests, everything except who they asked to see.'**
  String get spotlightRuleFilters;

  /// No description provided for @spotlightRuleAudience.
  ///
  /// In en, this message translates to:
  /// **'Only people in the same district as you.'**
  String get spotlightRuleAudience;

  /// No description provided for @spotlightRuleSkipped.
  ///
  /// In en, this message translates to:
  /// **'People who already swiped you, matched you or blocked you will not see you again.'**
  String get spotlightRuleSkipped;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
