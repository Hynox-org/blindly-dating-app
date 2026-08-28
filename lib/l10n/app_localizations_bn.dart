// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get appLanguageTitle => 'অ্যাপের ভাষা';

  @override
  String get systemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String get authTitlePhone => 'আপনার নম্বরটি দিন';

  @override
  String get authTitleVerifyNumber => 'আপনার নম্বর যাচাই করুন';

  @override
  String get authTitleEmail => 'ইমেইল দিয়ে লগইন করুন';

  @override
  String get authTitleVerifyEmail => 'আপনার ইমেইল যাচাই করুন';

  @override
  String get authTitleApple => 'Apple দিয়ে লগইন করুন';

  @override
  String get loginTagline => 'একটি সুন্দর জীবনে লগইন করুন';

  @override
  String get continueWithGoogle => 'Google দিয়ে চালিয়ে যান';

  @override
  String get continueLabel => 'চালিয়ে যান';

  @override
  String get termsSignupPrefix => 'সাইন আপ করে, আপনি আমাদের ';

  @override
  String get termsContinuePrefix => 'চালিয়ে গিয়ে, আপনি আমাদের ';

  @override
  String get termsWord => 'শর্তাবলীতে';

  @override
  String get termsBridge =>
      ' সম্মত হচ্ছেন। আমরা আপনার ডেটা কীভাবে ব্যবহার করি তা দেখুন আমাদের ';

  @override
  String get privacyPolicyWord => 'গোপনীয়তা নীতিতে';

  @override
  String get termsSuffix => '।';

  @override
  String get phoneRationale =>
      'Blindly-তে সবাই আসল কিনা তা নিশ্চিত করতেই আমরা ফোন নম্বর ব্যবহার করি';

  @override
  String get countryLabel => 'দেশ';

  @override
  String get phoneNumberLabel => 'ফোন নম্বর';

  @override
  String get phoneHint => 'যেমন 9876543210';

  @override
  String otpSentPhone(String phone) {
    return '$phone নম্বরে পাঠানো কোডটি লিখুন। ';
  }

  @override
  String get changeNumber => 'নম্বর পরিবর্তন করুন';

  @override
  String otpSentEmail(String email) {
    return '$email ঠিকানায় ইমেইলে পাঠানো কোডটি লিখুন। ';
  }

  @override
  String get changeEmail => 'ইমেইল পরিবর্তন করুন';

  @override
  String get resendCode => 'কোড আবার পাঠান';

  @override
  String codeArrivesIn(int seconds) {
    return 'কোডটি $seconds সেকেন্ডের মধ্যে আসবে';
  }

  @override
  String get otpSentSuccess => 'OTP পাঠানো হয়েছে';

  @override
  String get loginDetailsSubtitle => 'অনুগ্রহ করে নিচে আপনার লগইন তথ্য দিন';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'পাসওয়ার্ড';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get errEnterPhone => 'অনুগ্রহ করে আপনার ফোন নম্বর লিখুন';

  @override
  String get errPhoneDigitsOnly => 'ফোন নম্বরে শুধু সংখ্যা থাকতে হবে';

  @override
  String get errInvalidPhone => 'অনুগ্রহ করে একটি বৈধ ফোন নম্বর লিখুন';

  @override
  String get errInvalidPhoneIndia =>
      '6-9 দিয়ে শুরু হওয়া একটি বৈধ 10 সংখ্যার ভারতীয় ফোন নম্বর লিখুন';

  @override
  String get errInvalidPhone10Digit => 'একটি বৈধ 10 সংখ্যার ফোন নম্বর লিখুন';

  @override
  String get errEnterCompleteOtp => 'অনুগ্রহ করে সম্পূর্ণ OTP লিখুন';

  @override
  String get errEnterEmail => 'অনুগ্রহ করে আপনার ইমেইল লিখুন';

  @override
  String get errInvalidEmail => 'অনুগ্রহ করে একটি বৈধ ইমেইল ঠিকানা লিখুন';

  @override
  String get errFillAllFields => 'অনুগ্রহ করে সব ঘর পূরণ করুন';

  @override
  String get errPasswordMin => 'পাসওয়ার্ড অন্তত ৬ অক্ষরের হতে হবে';

  @override
  String get errTooManyAttempts =>
      'অনেক বেশি চেষ্টা। অনুগ্রহ করে কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  @override
  String errCreateProfile(String error) {
    return 'প্রোফাইল তৈরি করা যায়নি: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google সাইন-ইন ব্যর্থ: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'লগইন ব্যর্থ: $error';
  }

  @override
  String errGeneric(String error) {
    return 'ত্রুটি: $error';
  }

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get add => 'যোগ করুন';

  @override
  String get cancel => 'বাতিল';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get update => 'আপডেট করুন';

  @override
  String get back => 'পিছনে';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get next => 'পরবর্তী';

  @override
  String get edit => 'সম্পাদনা';

  @override
  String get deleteLabel => 'মুছুন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get yes => 'হ্যাঁ';

  @override
  String get no => 'না';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get somethingWentWrong => 'কিছু ভুল হয়েছে';

  @override
  String get userNotLoggedIn => 'ব্যবহারকারী লগইন করেননি';

  @override
  String get unknown => 'অজানা';

  @override
  String get typesOfConnections => 'সংযোগের ধরন';

  @override
  String get connectionQuestion => 'Blindly-তে আপনি কী ধরনের সংযোগ খুঁজছেন?';

  @override
  String get connectionSubtitle =>
      'ডেট ও রোমান্স, নতুন বন্ধু, নাকি শুধুই ব্যবসা? আপনি যেকোনো সময় এটি বদলাতে পারেন।';

  @override
  String get modeDateSubtitle =>
      'সম্পর্ক, হালকা কিছু, বা তার মাঝামাঝি কিছু খুঁজুন';

  @override
  String get modeBffSubtitle => 'নতুন বন্ধু বানান এবং আপনার কমিউনিটি খুঁজুন';

  @override
  String get modeEventsSubtitle =>
      'আকর্ষণীয় ইভেন্ট খুঁজুন, টিকিট বুক করুন, আরও অনেক কিছু';

  @override
  String continueWithMode(String mode) {
    return '$mode নিয়ে চালিয়ে যান';
  }

  @override
  String get multiDeviceTitle => 'একাধিক ডিভাইসে লগইন';

  @override
  String get multiDeviceBody =>
      'আপনার অ্যাকাউন্ট অন্য ডিভাইসে সক্রিয়। নিরাপত্তার জন্য শুধু একটি সেশন অনুমোদিত।';

  @override
  String get signedOutOtherDevices => 'অন্য ডিভাইস থেকে সাইন আউট করা হয়েছে!';

  @override
  String get signOutOtherDevices => 'অন্য ডিভাইস সাইন আউট করুন';

  @override
  String get logOutThisDevice => 'এই ডিভাইস থেকে লগ আউট করুন';

  @override
  String get swipeRightHint => 'আরও জানতে ডানদিকে সোয়াইপ করুন!';

  @override
  String get locationRequiredTitle => 'লোকেশন প্রয়োজন';

  @override
  String get locationRequiredBody =>
      'আপনার আশেপাশের দারুণ মানুষদের খুঁজে পেতে আমাদের আপনার লোকেশন দরকার।\n\nঅনুগ্রহ করে \"সেটিংস\"-এ ট্যাপ করে লোকেশন অনুমতি চালু করুন, তারপর \"আবার চেষ্টা করুন\" চাপুন।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get notifyMeSnack => 'নতুন মানুষ যোগ দিলে আমরা আপনাকে জানাব!';

  @override
  String get nearby => 'কাছাকাছি';

  @override
  String heightCm(String value) {
    return '$value সেমি';
  }

  @override
  String get completeYourProfile => 'আপনার প্রোফাইল সম্পূর্ণ করুন';

  @override
  String get completeYourProfileBody =>
      'আপনি কিছু ধাপ এড়িয়ে গেছেন। অ্যাপের পূর্ণ সুবিধা পেতে সেগুলি সম্পূর্ণ করুন।';

  @override
  String get stepNotAvailable => 'এই ধাপটি এখনও উপলব্ধ নয়।';

  @override
  String get profileNotFound => 'প্রোফাইল পাওয়া যায়নি';

  @override
  String get profileUnavailable => 'প্রোফাইল পাওয়া যায়নি বা আর উপলব্ধ নেই।';

  @override
  String get profileLoadFailed =>
      'প্রোফাইল লোড করা যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String get alreadyLikedProfile => 'আপনি ইতিমধ্যে এই প্রোফাইল লাইক করেছেন।';

  @override
  String get personAlreadyLikedYou => 'এই ব্যক্তি ইতিমধ্যে আপনাকে লাইক করেছেন।';

  @override
  String get youAreMatched => 'আপনাদের ম্যাচ হয়েছে।';

  @override
  String get alreadyChatting => 'আপনি ইতিমধ্যে চ্যাট শুরু করেছেন।';

  @override
  String get profileAlreadySkipped =>
      'প্রোফাইল ইতিমধ্যে এড়িয়ে যাওয়া হয়েছে।';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get profilePreview => 'প্রোফাইল প্রিভিউ';

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get voiceIntro => 'ভয়েস পরিচিতি';

  @override
  String get bioTitle => 'বায়ো';

  @override
  String get askAboutMyBio => 'আমার বায়ো নিয়ে জিজ্ঞেস করুন!';

  @override
  String get kudos => 'প্রশংসা';

  @override
  String get aPrompt => 'একটি প্রশ্ন';

  @override
  String get profileVerified => 'প্রোফাইল যাচাইকৃত';

  @override
  String get photoVerified => 'ছবি যাচাইকৃত';

  @override
  String get notVerified => 'যাচাই করা হয়নি';

  @override
  String milesAway(String distance) {
    return '$distance মাইল দূরে';
  }

  @override
  String trustScore(String score) {
    return 'ট্রাস্ট স্কোর: $score%';
  }

  @override
  String get seeHowYouMatch => 'দেখুন আপনারা দুজন কতটা মেলেন';

  @override
  String get aboutMe => 'আমার সম্পর্কে';

  @override
  String get imLookingFor => 'আমি খুঁজছি';

  @override
  String get quickestWayToHeart => 'আমার হৃদয়ে পৌঁছানোর সবচেয়ে সহজ উপায়';

  @override
  String get myInterests => 'আমার আগ্রহ';

  @override
  String get myLifestyle => 'আমার জীবনযাত্রা';

  @override
  String smokesLabel(String value) {
    return 'ধূমপান: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'মদ্যপান: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'ব্যায়াম: $value';
  }

  @override
  String get myCauses => 'আমার কারণ ও কমিউনিটি';

  @override
  String get languagesTitle => 'ভাষা';

  @override
  String get myLocation => 'আমার লোকেশন';

  @override
  String get myTopArtist => 'Spotify-তে আমার প্রিয় শিল্পী';

  @override
  String get editProfile => 'প্রোফাইল সম্পাদনা';

  @override
  String get youLikedThem => 'আপনি তাদের লাইক করেছেন!';

  @override
  String get undoNotForMe => '\'আমার জন্য নয়\' ফিরিয়ে নিন';

  @override
  String get notForMe => 'আমার জন্য নয়';

  @override
  String get block => 'ব্লক করুন';

  @override
  String get report => 'রিপোর্ট করুন';

  @override
  String get outOfSwipesToday => 'আজকের সোয়াইপ\nশেষ';

  @override
  String get moreSwipesIn => 'আরও সোয়াইপ আসবে';

  @override
  String get hoursLabel => 'ঘণ্টা';

  @override
  String get minutesLabel => 'মিনিট';

  @override
  String get secondsLabel => 'সেকেন্ড';

  @override
  String get sendAndSeeLikes => 'যত খুশি লাইক\nপাঠান এবং দেখুন';

  @override
  String get sendUnlimitedSwipes => 'সীমাহীন সোয়াইপ পাঠান';

  @override
  String get advancedSearchFilter => 'অ্যাডভান্সড সার্চ ফিল্টার';

  @override
  String get seeEveryoneWhoLikes => 'যারা আপনাকে পছন্দ করে সবাইকে দেখুন';

  @override
  String get setMoreDatingPrefs => 'আরও ডেটিং পছন্দ সেট করুন';

  @override
  String monthsPlan(String count) {
    return '$count মাস';
  }

  @override
  String get mostPopular => 'সবচেয়ে জনপ্রিয়';

  @override
  String get bestValue => 'সেরা মূল্য';

  @override
  String getWithPlan(String plan, String price) {
    return '$plan নিন $price-এ';
  }

  @override
  String offerEndsIn(String time) {
    return 'অফার শেষ হবে $time-এ';
  }

  @override
  String get chats => 'চ্যাট';

  @override
  String get conversations => 'কথোপকথন';

  @override
  String get recentMatches => 'সাম্প্রতিক ম্যাচ';

  @override
  String get readyToMakeFirstMove => 'প্রথম পদক্ষেপ নিতে\nপ্রস্তুত?';

  @override
  String get tapToContinueChatting => 'চ্যাট চালিয়ে যেতে ট্যাপ করুন';

  @override
  String get unknownUser => 'অজানা ব্যবহারকারী';

  @override
  String get newMatchesAppearHere => 'আপনার নতুন ম্যাচ এখানে দেখা যাবে।';

  @override
  String get endToEndEncrypted => 'এন্ড-টু-এন্ড এনক্রিপ্টেড';

  @override
  String get e2eBanner =>
      'বার্তা ও কল এন্ড-টু-এন্ড এনক্রিপ্টেড। এই চ্যাটের বাইরে কেউ, এমনকি Blindly-ও, সেগুলি পড়তে বা শুনতে পারে না। ';

  @override
  String get encryptedMessage => 'এনক্রিপ্টেড বার্তা';

  @override
  String get encryptionKeyNotLoaded =>
      'এনক্রিপশন কী লোড হয়নি। অনুগ্রহ করে অপেক্ষা করুন।';

  @override
  String get messageViolatesGuidelines =>
      'এই বার্তাটি আমাদের কমিউনিটি নির্দেশিকা লঙ্ঘন করতে পারে, তাই পাঠানো হয়নি।';

  @override
  String get imageMessage => ' ছবি বার্তা';

  @override
  String get voiceMessage => ' ভয়েস বার্তা';

  @override
  String nSelected(String count) {
    return '$count নির্বাচিত';
  }

  @override
  String get editedSuffix => '(সম্পাদিত)';

  @override
  String get editingMessage => 'বার্তা সম্পাদনা করা হচ্ছে';

  @override
  String get onlyTextEditable => 'শুধু টেক্সট বার্তা সম্পাদনা করা যায়';

  @override
  String get messageCopied => 'বার্তা কপি হয়েছে';

  @override
  String get archiveChat => 'চ্যাট আর্কাইভ করুন';

  @override
  String get clearChat => 'চ্যাট মুছুন';

  @override
  String get blockUser => 'ব্যবহারকারীকে ব্লক করুন';

  @override
  String get muteNotifications => 'নোটিফিকেশন মিউট করুন';

  @override
  String get reportAndSpam => 'রিপোর্ট ও স্প্যাম';

  @override
  String get deleteForMe => 'আমার জন্য মুছুন';

  @override
  String get deleteForEveryone => 'সবার জন্য মুছুন';

  @override
  String get showTranslation => 'অনুবাদ দেখান';

  @override
  String get showOriginal => 'মূলটি দেখান';

  @override
  String get takePhoto => 'ছবি তুলুন';

  @override
  String get chooseFromGallery => 'গ্যালারি থেকে বাছুন';

  @override
  String get attachmentComingSoon => 'অ্যাটাচমেন্ট পিকার শীঘ্রই আসছে';

  @override
  String get imageTooLarge => 'ছবি খুব বড় (সর্বোচ্চ 5MB)';

  @override
  String get micPermissionDenied => 'মাইক্রোফোন অনুমতি দেওয়া হয়নি';

  @override
  String get recordingEmpty => 'রেকর্ডিং ফাইল খালি';

  @override
  String get recordingNotFound => 'রেকর্ডিং ফাইল পাওয়া যায়নি';

  @override
  String get failedToPlayVoice => 'ভয়েস বার্তা চালানো যায়নি';

  @override
  String get failedToLoad => 'লোড করা যায়নি';

  @override
  String get errorLoadingGif => 'GIF লোড করতে সমস্যা';

  @override
  String get errorLoadingSticker => 'স্টিকার লোড করতে সমস্যা';

  @override
  String get networkErrorRetry =>
      'নেটওয়ার্ক সমস্যা। আপনার ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get serverSideError =>
      'আমাদের দিকে কিছু সমস্যা হয়েছে। আরেকবার চেষ্টা করুন।';

  @override
  String get pleaseLoginFirst => 'অনুগ্রহ করে আগে লগইন করুন';

  @override
  String get icebreakers => 'আইসব্রেকার';

  @override
  String get iceBreaker => 'আইসব্রেকার';

  @override
  String get couldntLoadIcebreakers => 'আইসব্রেকার লোড করা যায়নি';

  @override
  String get aiAnalyzingProfiles => 'AI আপনার প্রোফাইল বিশ্লেষণ করছে...';

  @override
  String get generate => 'তৈরি করুন';

  @override
  String get regenerate => 'আবার তৈরি করুন';

  @override
  String get categoryAll => 'সব';

  @override
  String get categoryDeep => 'গভীর';

  @override
  String get categoryPlayful => 'খেলাচ্ছলে';

  @override
  String get categoryQuirky => 'অদ্ভুত';

  @override
  String get categoryPersonalized => 'ব্যক্তিগতকৃত';

  @override
  String get categoryQuestion => 'প্রশ্ন';

  @override
  String get categoryObservation => 'পর্যবেক্ষণ';

  @override
  String get categoryFunFact => 'মজার তথ্য';

  @override
  String get categoryHypothesis => 'অনুমান';

  @override
  String get categoryOpeningMove => 'প্রথম পদক্ষেপ';

  @override
  String get superpowerPrompt =>
      'যদি আপনি যেকোনো একটি সুপারপাওয়ার পেতেন, সেটি কী হত?';

  @override
  String get chooseAnOption => 'একটি বিকল্প বাছুন';

  @override
  String get invalidMatchData => 'ম্যাচ ডেটা সঠিক নয়। আবার চেষ্টা করুন।';

  @override
  String get moreOpeningMoves => 'আরও প্রথম পদক্ষেপ';

  @override
  String get onlineNow => 'এখন অনলাইন';

  @override
  String get pleaseEnterMessage => 'অনুগ্রহ করে একটি বার্তা লিখুন';

  @override
  String sendPersonMessage(String name) {
    return '$name-কে বার্তা পাঠান';
  }

  @override
  String get sendMessage => 'বার্তা পাঠান';

  @override
  String get matchHasExpired => 'এই ম্যাচের মেয়াদ শেষ।';

  @override
  String get typeOpeningMove => 'আপনার প্রথম বার্তা লিখুন...';

  @override
  String get use => 'ব্যবহার করুন';

  @override
  String get expiringSoon => 'শীঘ্রই মেয়াদ শেষ';

  @override
  String get matchExpiredTitle => 'ম্যাচের মেয়াদ শেষ';

  @override
  String dontLetThemGetAway(String name) {
    return '$name-কে\nহারিয়ে ফেলবেন না!';
  }

  @override
  String get limitedTimeBody =>
      'পদক্ষেপ নিতে আপনার হাতে অল্প সময় আছে। ম্যাচটি চিরতরে হারিয়ে যাওয়ার আগে একটি বার্তা পাঠান।';

  @override
  String get letThemGo => 'যেতে দিন';

  @override
  String messagePerson(String name) {
    return '$name-কে বার্তা দিন';
  }

  @override
  String get gifs => 'GIF';

  @override
  String get stickers => 'স্টিকার';

  @override
  String get searchGiphy => 'GIPHY-তে খুঁজুন';

  @override
  String get themOnly => 'শুধু তাদের';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get icebreakerSmile => 'সম্প্রতি কোন ছোট বিষয় আপনাকে হাসিয়েছে?';

  @override
  String get icebreakerTwoTruths => 'দুটি সত্যি আর একটি মিথ্যে: শুরু করা যাক!';

  @override
  String get icebreakerInteresting =>
      'সম্প্রতি শেখা সবচেয়ে আকর্ষণীয় জিনিস কী?';

  @override
  String get openingMoveCushions => 'আমি আর আমার বানানো কুশন।\nকেমন লাগল?';

  @override
  String get openingMove90s =>
      'বাজি ধরে বলছি, আমার 90s লুক আপনি হারাতে পারবেন না';

  @override
  String get openingMovePetName => 'আমার পোষ্যের নাম বলতে পারেন?';

  @override
  String get viewProfile => 'প্রোফাইল দেখুন';

  @override
  String get likedYou => 'আপনাকে লাইক করেছে';

  @override
  String get matchLabel => 'ম্যাচ';

  @override
  String get passLabel => 'পাস';

  @override
  String get failedToLoadLikes => 'লাইক লোড করা যায়নি';

  @override
  String get noLikesYet => 'এখনও কোনো লাইক নেই, তবে\n';

  @override
  String get buzzOff => 'হতাশ হবেন না!';

  @override
  String get keepSwipingBody =>
      'আপনার সঙ্গী খুঁজতে সোয়াইপ করতে থাকুন।\nশীঘ্রই কেউ না কেউ আপনাকে পছন্দ করবে!';

  @override
  String get keepSwiping => 'সোয়াইপ করতে থাকুন';

  @override
  String get startSwiping => 'সোয়াইপ শুরু করুন';

  @override
  String get improveProfile => 'প্রোফাইল উন্নত করুন';

  @override
  String get viewMoreLikes => 'আরও লাইক দেখুন';

  @override
  String get seeWhosInterested => 'কারা আগ্রহী দেখুন';

  @override
  String matchInstantly(String count) {
    return 'অপেক্ষা ছাড়াই সঙ্গে সঙ্গে ম্যাচ করুন। আপনার $count+ লাইক অপেক্ষা করছে';
  }

  @override
  String get superLiked => 'সুপার লাইক';

  @override
  String get itsAMatch => 'ম্যাচ হয়েছে!';

  @override
  String youAndThemLiked(String name) {
    return 'আপনি এবং $name একে অপরকে পছন্দ করেছেন।';
  }

  @override
  String get sendAMessage => 'বার্তা পাঠান';

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get loginToViewNotifications => 'নোটিফিকেশন দেখতে লগইন করুন।';

  @override
  String get noNotificationsYet => 'আপনার এখনও কোনো নোটিফিকেশন নেই।';

  @override
  String get discover => 'আবিষ্কার';

  @override
  String get reachedEndOfLine => 'আপনি একদম\nশেষে পৌঁছে গেছেন!';

  @override
  String get checkBackSoon =>
      'আরও মানুষের জন্য শীঘ্রই ফিরে আসুন বা আরও প্রোফাইল দেখতে ফিল্টার বদলান।';

  @override
  String get seeMorePeople => 'আরও মানুষ দেখুন';

  @override
  String get topPicksForYou => 'আপনার জন্য সেরা';

  @override
  String get sharedInterests => 'অভিন্ন আগ্রহ';

  @override
  String get newFaces => 'নতুন মুখ';

  @override
  String get recentlyActive => 'সম্প্রতি সক্রিয়';

  @override
  String get seeAll => 'সব দেখুন';

  @override
  String kmAway(String distance) {
    return '$distance কিমি দূরে';
  }

  @override
  String get letsDiscover => 'চলুন খুঁজি!';

  @override
  String get viewedAllProfiles =>
      'আপনার বর্তমান পছন্দের সাথে মেলে এমন সব প্রোফাইল আপনি দেখে ফেলেছেন। অনুসন্ধান বাড়ান বা নতুন মানুষের জন্য শীঘ্রই ফিরে আসুন।';

  @override
  String get adjustYourFilters => 'আপনার ফিল্টার বদলান';

  @override
  String get notifyMeNewPeople => 'নতুন মানুষ সম্পর্কে জানান';

  @override
  String youAndPerson(String name) {
    return 'আপনি এবং $name';
  }

  @override
  String get workingOutCommon => 'আপনাদের মধ্যে কী মিল আছে দেখছি…';

  @override
  String get whyTitle => 'কেন';

  @override
  String get breakdownTitle => 'বিশ্লেষণ';

  @override
  String get goesBothWays => 'এটা কি দুদিক থেকেই?';

  @override
  String eachFitsOther(String band) {
    return 'আপনারা দুজনেই একে অপরের খোঁজের সাথে মেলেন: $band।';
  }

  @override
  String get sectionConnections => 'সংযোগ';

  @override
  String get typeOfConnection => 'সংযোগের ধরন';

  @override
  String get dateMode => 'ডেট মোড';

  @override
  String get travel => 'ভ্রমণ';

  @override
  String get sectionAccountSettings => 'অ্যাকাউন্ট সেটিংস';

  @override
  String get profileAndVerification => 'প্রোফাইল ও যাচাই';

  @override
  String get contactAndLoginInfo => 'যোগাযোগ ও লগইন তথ্য';

  @override
  String get subscriptionManagement => 'সাবস্ক্রিপশন ব্যবস্থাপনা';

  @override
  String get sectionAppPreference => 'অ্যাপ পছন্দ';

  @override
  String get notificationsSetting => 'নোটিফিকেশন সেটিং';

  @override
  String get privacyControls => 'গোপনীয়তা নিয়ন্ত্রণ';

  @override
  String get sectionSecurityPrivacy => 'নিরাপত্তা ও গোপনীয়তা';

  @override
  String get accountManagement => 'অ্যাকাউন্ট ব্যবস্থাপনা';

  @override
  String get blockedAccounts => 'ব্লক করা অ্যাকাউন্ট';

  @override
  String get locationService => 'লোকেশন সেবা';

  @override
  String get sectionSupportLegal => 'সহায়তা ও আইনি';

  @override
  String get helpCenter => 'সহায়তা কেন্দ্র';

  @override
  String get privacyPolicyTitle => 'গোপনীয়তা নীতি';

  @override
  String get termsAndConditions => 'শর্তাবলী';

  @override
  String get about => 'সম্পর্কে';

  @override
  String get logout => 'লগ আউট';

  @override
  String get deleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get vEnglish => 'ইংরেজি';

  @override
  String get vHindi => 'হিন্দি';

  @override
  String get vTamil => 'তামিল';

  @override
  String get vTelugu => 'তেলুগু';

  @override
  String get vKannada => 'কন্নড়';

  @override
  String get vMalayalam => 'মালয়ালম';

  @override
  String get vMarathi => 'মারাঠি';

  @override
  String get vBengali => 'বাংলা';

  @override
  String get vGujarati => 'গুজরাটি';

  @override
  String get vPunjabi => 'পাঞ্জাবি';

  @override
  String get vOdia => 'ওড়িয়া';

  @override
  String get vSpanish => 'স্প্যানিশ';

  @override
  String get vFrench => 'ফরাসি';

  @override
  String get vGerman => 'জার্মান';

  @override
  String get vItalian => 'ইতালীয়';

  @override
  String get vPortuguese => 'পর্তুগিজ';

  @override
  String get vRussian => 'রুশ';

  @override
  String get vJapanese => 'জাপানি';

  @override
  String get vKorean => 'কোরিয়ান';

  @override
  String get vChinese => 'চীনা';

  @override
  String get vArabic => 'আরবি';

  @override
  String get vTurkish => 'তুর্কি';

  @override
  String get vOthers => 'অন্যান্য';

  @override
  String get vOther => 'অন্য';

  @override
  String get vHindu => 'হিন্দু';

  @override
  String get vChristian => 'খ্রিস্টান';

  @override
  String get vMuslim => 'মুসলিম';

  @override
  String get vSikh => 'শিখ';

  @override
  String get vJain => 'জৈন';

  @override
  String get vBuddhist => 'বৌদ্ধ';

  @override
  String get vAtheist => 'নাস্তিক';

  @override
  String get vAgnostic => 'অজ্ঞেয়বাদী';

  @override
  String get vSpiritual => 'আধ্যাত্মিক';

  @override
  String get vCatholic => 'ক্যাথলিক';

  @override
  String get vLatterDaySaint => 'লেটার ডে সেইন্ট';

  @override
  String get vZoroastrian => 'জরথুস্ট্রীয়';

  @override
  String get vJewish => 'ইহুদি';

  @override
  String get vMormon => 'মরমন';

  @override
  String get vMonogamy => 'একনিষ্ঠ সম্পর্ক';

  @override
  String get vPolyamory => 'বহুপ্রেম';

  @override
  String get vOpenRelationship => 'ওপেন সম্পর্ক';

  @override
  String get vNonMonogamy => 'অ-একনিষ্ঠ';

  @override
  String get vOpenToExploring => 'অনুসন্ধানে আগ্রহী';

  @override
  String get vShortTerm => 'স্বল্পমেয়াদি';

  @override
  String get vLongTerm => 'দীর্ঘমেয়াদি';

  @override
  String get vStraight => 'স্ট্রেট';

  @override
  String get vGay => 'গে';

  @override
  String get vLesbian => 'লেসবিয়ান';

  @override
  String get vBisexual => 'বাইসেক্সুয়াল';

  @override
  String get vAsexual => 'অ্যাসেক্সুয়াল';

  @override
  String get vDemisexual => 'ডেমিসেক্সুয়াল';

  @override
  String get vPansexual => 'প্যানসেক্সুয়াল';

  @override
  String get vQueer => 'কুইয়ার';

  @override
  String get vQuestioning => 'অনিশ্চিত';

  @override
  String get vWomen => 'নারী';

  @override
  String get vMen => 'পুরুষ';

  @override
  String get vEveryone => 'সবাই';

  @override
  String get vMale => 'পুরুষ';

  @override
  String get vFemale => 'নারী';

  @override
  String get vFunCasualDates => 'মজার, হালকা ডেট';

  @override
  String get vLifePartner => 'জীবনসঙ্গী';

  @override
  String get vLongTermRelationship => 'দীর্ঘমেয়াদি সম্পর্ক';

  @override
  String get vShortTermRelationship => 'স্বল্পমেয়াদি সম্পর্ক';

  @override
  String get vStillFiguringOut => 'এখনও ভাবছি';

  @override
  String get vLongOpenToShort => 'দীর্ঘমেয়াদি, স্বল্পমেয়াদিতেও রাজি';

  @override
  String get vShortOpenToLong => 'স্বল্পমেয়াদি, দীর্ঘমেয়াদিতেও রাজি';

  @override
  String get vCasualDating => 'হালকা ডেটিং';

  @override
  String get vNewFriends => 'নতুন বন্ধু';

  @override
  String get vCloseFriends => 'ঘনিষ্ঠ বন্ধু';

  @override
  String get vActivityPartners => 'অ্যাক্টিভিটি সঙ্গী';

  @override
  String get vProfessionalNetworking => 'পেশাগত নেটওয়ার্কিং';

  @override
  String get vWorkoutBuddy => 'ওয়ার্কআউট সঙ্গী';

  @override
  String get vTravelBuddies => 'ভ্রমণসঙ্গী';

  @override
  String get vYesIDrink => 'হ্যাঁ, আমি পান করি';

  @override
  String get vOccasionally => 'মাঝে মাঝে';

  @override
  String get vSometimes => 'কখনো কখনো';

  @override
  String get vNeverDrink => 'কখনো পান করি না';

  @override
  String get vRegularly => 'নিয়মিত';

  @override
  String get vImSober => 'আমি মদ্যপান করি না';

  @override
  String get vSocially => 'সামাজিকভাবে';

  @override
  String get vNever => 'কখনো না';

  @override
  String get vSocialSmoker => 'সামাজিকভাবে ধূমপায়ী';

  @override
  String get vSmokerWhenDrinking => 'মদ্যপানের সময় ধূমপান';

  @override
  String get vNonSmoker => 'ধূমপান করি না';

  @override
  String get vSmoker => 'ধূমপায়ী';

  @override
  String get vTryingToQuit => 'ছাড়ার চেষ্টা করছি';

  @override
  String get vDaily => 'প্রতিদিন';

  @override
  String get vWeekly => 'সাপ্তাহিক';

  @override
  String get vHighSchool => 'হাই স্কুল';

  @override
  String get vGradeSchool => 'প্রাথমিক স্কুল';

  @override
  String get vDiploma => 'ডিপ্লোমা';

  @override
  String get vUnderGraduate => 'স্নাতক';

  @override
  String get vPostGraduate => 'স্নাতকোত্তর';

  @override
  String get vDoctorate => 'ডক্টরেট';

  @override
  String get vCommunist => 'কমিউনিস্ট';

  @override
  String get vSocialist => 'সমাজতন্ত্রী';

  @override
  String get vApolitical => 'অরাজনৈতিক';

  @override
  String get vModerate => 'মধ্যপন্থী';

  @override
  String get vNotInterested => 'আগ্রহী নই';

  @override
  String get vHaveKids => 'সন্তান আছে';

  @override
  String get vDontHaveKids => 'সন্তান নেই';

  @override
  String get vDontWantKids => 'সন্তান চাই না';

  @override
  String get vWantKids => 'সন্তান চাই';

  @override
  String get vOpenToKids => 'সন্তানে আপত্তি নেই';

  @override
  String get vNotSure => 'নিশ্চিত নই';

  @override
  String get vPreferNotToSay => 'বলতে চাই না';

  @override
  String get vAries => 'মেষ';

  @override
  String get vTaurus => 'বৃষ';

  @override
  String get vGemini => 'মিথুন';

  @override
  String get vCancer => 'কর্কট';

  @override
  String get vLeo => 'সিংহ';

  @override
  String get vVirgo => 'কন্যা';

  @override
  String get vLibra => 'তুলা';

  @override
  String get vScorpio => 'বৃশ্চিক';

  @override
  String get vSagittarius => 'ধনু';

  @override
  String get vCapricorn => 'মকর';

  @override
  String get vAquarius => 'কুম্ভ';

  @override
  String get vPisces => 'মীন';

  @override
  String get vHumanRights => 'মানবাধিকার';

  @override
  String get vDisabilityRights => 'প্রতিবন্ধী অধিকার';

  @override
  String get vFeminism => 'নারীবাদ';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'পরিবেশবাদ';

  @override
  String get vLgbtqRights => 'LGBTQ অধিকার';

  @override
  String get vImmigrantRights => 'অভিবাসী অধিকার';

  @override
  String get vEndReligiousHate => 'ধর্মীয় বিদ্বেষের অবসান';

  @override
  String get vIndigenousRights => 'আদিবাসী অধিকার';

  @override
  String get vNeuroDiversity => 'নিউরো বৈচিত্র্য';

  @override
  String get vVoterRights => 'ভোটার অধিকার';

  @override
  String get vReproductiveRights => 'প্রজনন অধিকার';

  @override
  String get vAmbition => 'উচ্চাকাঙ্ক্ষা';

  @override
  String get vConfidence => 'আত্মবিশ্বাস';

  @override
  String get vEmpathy => 'সহমর্মিতা';

  @override
  String get vHumor => 'রসবোধ';

  @override
  String get vKindness => 'দয়া';

  @override
  String get vOpenness => 'খোলামেলা মন';

  @override
  String get vOptimism => 'আশাবাদ';

  @override
  String get vSassiness => 'চটপটে ভাব';

  @override
  String get vPlayfulness => 'খেলাচ্ছলে ভাব';

  @override
  String get vLeadership => 'নেতৃত্ব';

  @override
  String get vHumility => 'বিনয়';

  @override
  String get vLoyalty => 'আনুগত্য';

  @override
  String get vSarcasm => 'শ্লেষ';

  @override
  String get vGratitude => 'কৃতজ্ঞতা';

  @override
  String get vCuriosity => 'কৌতূহল';

  @override
  String get vEmotionalIntelligence => 'আবেগীয় বুদ্ধিমত্তা';

  @override
  String get datingPreference => 'ডেটিং পছন্দ';

  @override
  String get bffPreference => 'BFF পছন্দ';

  @override
  String get whoWouldYouDate => 'আপনি কার সাথে ডেট করতে চান?';

  @override
  String get ageRange => 'বয়সের পরিসর?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max বছর';
  }

  @override
  String get howFarAway => 'তারা কত দূরে?';

  @override
  String kilometersAway(String distance) {
    return '$distance কিলোমিটার দূরে';
  }

  @override
  String get yourInterests => 'আপনার আগ্রহ?';

  @override
  String get errorLoadingInterests => 'আগ্রহ লোড করা যায়নি';

  @override
  String get whichLanguages => 'আপনি কোন ভাষা জানেন?';

  @override
  String get selectLanguages => 'ভাষা বাছুন';

  @override
  String get religionQuestion => 'ধর্ম';

  @override
  String get selectReligion => 'ধর্ম বাছুন';

  @override
  String get relationshipTypeQuestion => 'সম্পর্কের ধরন?';

  @override
  String get relationshipTypeTitle => 'সম্পর্কের ধরন';

  @override
  String get selectType => 'ধরন বাছুন';

  @override
  String get sexualOrientationQuestion => 'যৌন প্রবণতা?';

  @override
  String get sexualOrientationTitle => 'যৌন প্রবণতা';

  @override
  String get selectOrientation => 'প্রবণতা বাছুন';

  @override
  String get datingIntentionQuestion => 'ডেটিংয়ের উদ্দেশ্য?';

  @override
  String get datingIntentionTitle => 'ডেটিংয়ের উদ্দেশ্য';

  @override
  String get selectIntention => 'উদ্দেশ্য বাছুন';

  @override
  String get filtersCleared => 'ফিল্টার মুছে ফেলা হয়েছে!';

  @override
  String get clearFilters => 'ফিল্টার মুছুন';

  @override
  String get filterByInterests => 'আপনার আগ্রহ দিয়ে ফিল্টার করুন';

  @override
  String get showMe => 'আমাকে দেখান';

  @override
  String errUpdateFailed(String error) {
    return 'আপডেট করা যায়নি: $error';
  }

  @override
  String get religionViewTitle => 'ধর্মীয় দৃষ্টিভঙ্গি';

  @override
  String get sensitiveInfoNote =>
      'এটি স্পর্শকাতর তথ্য যা আপনার প্রোফাইলে দেখা যাবে। এটি সম্পূর্ণ ঐচ্ছিক।';

  @override
  String get zodiacSignTitle => 'রাশি';

  @override
  String get doYouDrink => 'আপনি কি মদ্যপান করেন?';

  @override
  String get doYouSmoke => 'আপনি কি ধূমপান করেন?';

  @override
  String get doYouWorkout => 'আপনি কি ব্যায়াম করেন?';

  @override
  String get educationLevelTitle => 'শিক্ষার স্তর';

  @override
  String get politicalViewTitle => 'রাজনৈতিক দৃষ্টিভঙ্গি';

  @override
  String get doYouHaveKids => 'আপনার কি সন্তান আছে?';

  @override
  String get kidsPlanQuestion => 'সন্তান নিয়ে আপনার পরিকল্পনা কী?';

  @override
  String get pickYourPronoun => 'আপনার সর্বনাম বাছুন';

  @override
  String get pronounsBody =>
      'আপনার সর্বনাম কী? ৩টি বাছুন, যেকোনো সময় সরাতে পারবেন।';

  @override
  String get showPronounOnProfile => 'আমার প্রোফাইলে সর্বনাম দেখান';

  @override
  String get causesTitle => 'কারণ ও কমিউনিটি';

  @override
  String get selectUpTo3Causes => 'আপনার হৃদয়ের কাছের সর্বোচ্চ ৩টি বাছুন।';

  @override
  String get maxThreeOptions => 'সর্বোচ্চ ৩টি বিকল্প বাছতে পারবেন';

  @override
  String get personQualities => 'ব্যক্তির গুণাবলী';

  @override
  String get chooseThreeQualities =>
      'সম্পর্ককে আরও দৃঢ় করবে এমন ৩টি গুণ বাছুন।';

  @override
  String get maxThreeQualities => 'সর্বোচ্চ ৩টি গুণ বাছতে পারবেন।';

  @override
  String get howTallAreYou => 'আপনার উচ্চতা কত?';

  @override
  String get showsOnProfile => 'এটি আপনার প্রোফাইলে দেখা যাবে';

  @override
  String get yourHeight => 'আপনার উচ্চতা';

  @override
  String get professionTitle => 'পেশা';

  @override
  String get showProfessionOnProfile => 'আপনার প্রোফাইলে পেশা দেখান';

  @override
  String get titleLabel => 'পদবি';

  @override
  String get companyIndustry => 'কোম্পানি (শিল্প)';

  @override
  String get educatedAt => 'শিক্ষাপ্রতিষ্ঠান';

  @override
  String get showInstitutionOnProfile => 'আপনার প্রোফাইলে প্রতিষ্ঠান দেখান';

  @override
  String get institutionLabel => 'প্রতিষ্ঠান';

  @override
  String get graduationYear => 'স্নাতকের বছর';

  @override
  String get enterInstitution => 'অনুগ্রহ করে আপনার প্রতিষ্ঠানের নাম লিখুন।';

  @override
  String get maxThreeLanguages => 'সর্বোচ্চ ৩টি ভাষা বাছতে পারবেন';

  @override
  String get whatLookingFor => 'আপনি কী খুঁজছেন?';

  @override
  String maxThreeForMode(String mode) {
    return 'বর্তমান মোডের ($mode) জন্য সর্বোচ্চ ৩টি বিকল্প বাছতে পারবেন।';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'পছন্দ সংরক্ষণে সমস্যা: $error';
  }

  @override
  String get languagesIKnow => 'আমি যে ভাষা জানি';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ করুন';

  @override
  String get searchLanguages => 'ভাষা খুঁজুন';

  @override
  String get suggested => 'প্রস্তাবিত';

  @override
  String get allLanguages => 'সব ভাষা';

  @override
  String get errorLoadingProfile => 'প্রোফাইল লোড করা যায়নি';

  @override
  String percentTrust(String percent) {
    return '$percent% ট্রাস্ট';
  }

  @override
  String get profileCompleted => 'প্রোফাইল সম্পূর্ণ';

  @override
  String get completeProfile => 'প্রোফাইল সম্পূর্ণ করুন';

  @override
  String get higherScoreHelps =>
      'বেশি স্কোর আপনাকে আরও\nপ্রকৃত ম্যাচ পেতে সাহায্য করে';

  @override
  String get noBioYet => 'এখনও কোনো বায়ো যোগ করা হয়নি।';

  @override
  String get askMe => 'আমাকে জিজ্ঞেস করুন';

  @override
  String get activeLabel => 'সক্রিয়';

  @override
  String get addReligion => 'ধর্ম যোগ করুন';

  @override
  String get addZodiac => 'রাশি যোগ করুন';

  @override
  String get premium => 'প্রিমিয়াম';

  @override
  String get getNoticedSooner => 'দ্রুত নজরে আসুন এবং\n৩ গুণ বেশি ডেটে যান';

  @override
  String get upgrade => 'আপগ্রেড করুন';

  @override
  String get spotlight => 'স্পটলাইট';

  @override
  String get standOut => 'আলাদা হয়ে উঠুন';

  @override
  String get superSwipe => 'সুপার সোয়াইপ';

  @override
  String get getNoticed => 'নজরে আসুন';

  @override
  String get scoreBreakdown => 'স্কোরের বিশ্লেষণ';

  @override
  String get profilePhotoVerified => 'প্রোফাইল ছবি যাচাইকৃত';

  @override
  String get completedLabel => 'সম্পন্ন';

  @override
  String get profileDetails => 'প্রোফাইল বিবরণ';

  @override
  String get incompleteLabel => 'অসম্পূর্ণ';

  @override
  String get connectSocialAccounts => 'সোশ্যাল অ্যাকাউন্ট যুক্ত করুন';

  @override
  String get waysToImprove => 'উন্নতির উপায়';

  @override
  String get verifyYourPhotos => 'আপনার ছবি যাচাই করুন';

  @override
  String get proveYoureReal => 'অন্যদের কাছে প্রমাণ করুন আপনি আসল';

  @override
  String get addPromptsInterests => 'প্রম্পট, আগ্রহ ও অন্যান্য তথ্য যোগ করুন';

  @override
  String get verificationDataSecure =>
      'আপনার যাচাইকরণের তথ্য নিরাপদে রাখা হয় এবং পাবলিক প্রোফাইলে শেয়ার করা হয় না। ';

  @override
  String get learnMore => 'আরও জানুন';

  @override
  String get improveYourProfile => 'আপনার প্রোফাইল উন্নত করুন';

  @override
  String errorSavingHometown(String error) {
    return 'নিজ শহর সংরক্ষণে সমস্যা: $error';
  }

  @override
  String get searchCity => 'শহর খুঁজুন';

  @override
  String get aboutYou => 'আপনার সম্পর্কে';

  @override
  String get bioPrompt =>
      'লজ্জা পাবেন না! ছোট্ট একটা বায়োতে নিজের ব্যক্তিত্ব তুলে ধরার এটাই সুযোগ।';

  @override
  String get textHereHint => 'এখানে লিখুন.....';

  @override
  String failedToSaveBio(String error) {
    return 'বায়ো সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get selectYourInterests => 'আপনার আগ্রহ বাছুন';

  @override
  String get atLeast5Interests =>
      'অন্তত ৫টি আগ্রহ বাছুন। এতে আপনার মতো মানুষ খুঁজে পেতে সুবিধা হয়';

  @override
  String get searchForInterest => 'আগ্রহ খুঁজুন';

  @override
  String get noInterestsFound => 'কোনো আগ্রহ পাওয়া যায়নি';

  @override
  String get failedLoadInterests => 'আগ্রহ লোড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get maxTenInterests => 'সর্বোচ্চ ১০টি আগ্রহ বাছতে পারবেন';

  @override
  String get minFiveInterests => 'অনুগ্রহ করে অন্তত ৫টি আগ্রহ বাছুন';

  @override
  String errorSavingInterests(String error) {
    return 'আগ্রহ সংরক্ষণে সমস্যা: $error';
  }

  @override
  String get lifeStyle => 'জীবনযাত্রা';

  @override
  String get lifestylePrompt =>
      'আপনার অভ্যাস সম্পর্কে বলুন। যা আপনার সাথে মেলে তা বাছুন।';

  @override
  String get noLifestyleOptions => 'কোনো লাইফস্টাইল বিকল্প নেই';

  @override
  String get failedLoadLifestyle =>
      'লাইফস্টাইল বিকল্প লোড করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String get selectEachCategory =>
      'প্রতিটি বিভাগের জন্য একটি বিকল্প বাছুন, বা এড়াতে সব মুছে দিন।';

  @override
  String get findYourCity => 'আপনার বর্তমান শহর খুঁজুন';

  @override
  String errorSavingLocation(String error) {
    return 'লোকেশন সংরক্ষণে সমস্যা: $error';
  }

  @override
  String get permissionRequired => 'অনুমতি প্রয়োজন';

  @override
  String get permissionRequiredBody =>
      'অ্যাপ ঠিকমতো চলতে এই অনুমতি দরকার। সেটিংসে এটি চালু করুন।';

  @override
  String get cameraAccess => 'ক্যামেরা অ্যাক্সেস';

  @override
  String get photoLibrary => 'ফটো লাইব্রেরি';

  @override
  String get locationAccess => 'লোকেশন অ্যাক্সেস';

  @override
  String get notificationAccess => 'নোটিফিকেশন অ্যাক্সেস';

  @override
  String get microphoneAccess => 'মাইক্রোফোন অ্যাক্সেস';

  @override
  String get unknownAccess => 'অজানা অ্যাক্সেস';

  @override
  String get cameraReason => 'প্রোফাইল ছবি তুলতে ও পরিচয় যাচাই করতে।';

  @override
  String get photoReason => 'আপনার গ্যালারি থেকে ছবি আপলোড করতে।';

  @override
  String get locationReason => 'কাছাকাছি ম্যাচ দেখাতে।';

  @override
  String get notificationReason => 'নতুন ম্যাচ ও বার্তার খবর দিতে।';

  @override
  String get microphoneReason => 'ভয়েস ও ভিডিও যোগাযোগের জন্য।';

  @override
  String get appPermissions => 'অ্যাপ অনুমতি';

  @override
  String get chooseYourPrompt => 'আপনার প্রম্পট বাছুন';

  @override
  String get selectUpTo3Prompts =>
      'আপনার ব্যক্তিত্ব তুলে ধরতে সর্বোচ্চ ৩টি প্রম্পট বাছুন।';

  @override
  String get maxThreePrompts => 'সর্বোচ্চ ৩টি প্রম্পট বাছতে পারবেন।';

  @override
  String get areYouSure => 'আপনি কি নিশ্চিত?';

  @override
  String get removeThisPrompt => 'এই প্রম্পটটি সরাতে চান?';

  @override
  String get selectThreePrompts => 'চালিয়ে যেতে ৩টি প্রম্পট বাছুন।';

  @override
  String get selectOnePrompt => 'অন্তত ১টি প্রম্পট বাছুন।';

  @override
  String selectNMorePrompts(String count) {
    return 'চালিয়ে যেতে আরও $countটি প্রম্পট বাছুন';
  }

  @override
  String get noPromptsForCategory => 'এই বিভাগের জন্য কোনো প্রম্পট নেই।';

  @override
  String get typeYourAnswer => 'আপনার উত্তর লিখুন...';

  @override
  String get addPrompt => 'প্রম্পট যোগ করুন';

  @override
  String failedToLoadPrompts(String error) {
    return 'প্রম্পট লোড করা যায়নি: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'প্রম্পট সংরক্ষণে সমস্যা: $error';
  }

  @override
  String get communityGuidelines => 'কমিউনিটি নির্দেশিকা';

  @override
  String get agreeAndContinue => 'সম্মত ও চালিয়ে যান';

  @override
  String get termsByContinuePrefix => 'চালিয়ে গিয়ে, আপনি আমাদের ';

  @override
  String get guidelinesIntro =>
      'আমাদের কমিউনিটিতে স্বাগতম! সবার জন্য নিরাপদ ও ইতিবাচক অভিজ্ঞতা নিশ্চিত করতে এই সহজ নির্দেশিকা মেনে চলুন।';

  @override
  String get beKindTitle => 'সদয় ও শ্রদ্ধাশীল হোন';

  @override
  String get beKindBody =>
      'আপনি যেমন ব্যবহার আশা করেন, অন্যদের সাথেও তেমন করুন। আমরা সবাই মিলে একটি সুন্দর পরিবেশ গড়ি।';

  @override
  String get stayAuthenticTitle => 'সত্যিকার থাকুন';

  @override
  String get stayAuthenticBody =>
      'আপনার প্রোফাইল ও কথোপকথনে সৎ থাকুন। আমরা সত্যতা ও প্রকৃত সম্পর্ককে মূল্য দিই।';

  @override
  String get prioritizeSafetyTitle => 'নিরাপত্তাকে অগ্রাধিকার দিন';

  @override
  String get prioritizeSafetyBody =>
      'স্পর্শকাতর ও ব্যক্তিগত তথ্য শেয়ার করবেন না। নিজেকে ও কমিউনিটির অন্যদের সুরক্ষিত রাখুন।';

  @override
  String get noHateTitle => 'বিদ্বেষমূলক কথা নয়';

  @override
  String get noHateBody =>
      'হয়রানি, উৎপীড়ন ও বেআইনি বিষয়বস্তু এখানে সহ্য করা হয় না। কমিউনিটি নিরাপদ রাখতে সাহায্য করুন।';

  @override
  String get helpKeepSafeTitle => 'আমাদের নিরাপদ রাখতে সাহায্য করুন';

  @override
  String get helpKeepSafeBody =>
      'আমাদের নির্দেশিকা লঙ্ঘন করে এমন কিছু দেখলে রিপোর্ট করুন। আপনার সাহায্য অমূল্য।';

  @override
  String get genuineIntentTitle => 'সৎ উদ্দেশ্যে ডেট করুন';

  @override
  String get genuineIntentBody =>
      'আমরা প্রকৃত সম্পর্কের জন্য। ভুয়া পরিচয় বা জবরদস্তি অনুমোদিত নয়। প্রতারণা, ছদ্মবেশ, বা ব্যক্তিগত/আর্থিক লাভের জন্য কোনো কারসাজি অনুমোদিত নয়।';

  @override
  String get adultsOnlyTitle => 'শুধু প্রাপ্তবয়স্কদের জন্য';

  @override
  String get adultsOnlyBody =>
      'Blindly ব্যবহার করতে আপনার বয়স ১৮ বা তার বেশি হতে হবে। একা বা পোশাকহীন নাবালকের ছবি অনুমোদিত নয় — আপনার ছোটবেলার ছবিও নয়, সেগুলি যত মিষ্টিই হোক।';

  @override
  String get letsIntroduceYou => 'চলুন আপনার পরিচয় করাই!';

  @override
  String get needNameForProfile => 'প্রোফাইল তৈরি করতে আপনার নাম দরকার';

  @override
  String get nameLabel => 'নাম';

  @override
  String get enterYourName => 'আপনার নাম লিখুন';

  @override
  String get needDobForProfile => 'প্রোফাইল তৈরি করতে আপনার জন্মতারিখ দরকার';

  @override
  String get dateOfBirth => 'জন্মতারিখ';

  @override
  String get birthdayNote =>
      'আপনার জন্মতারিখ থেকে বয়স হিসাব করে প্রোফাইলে দেখানো হবে। আপনার পুরো নাম প্রকাশ্য হবে না';

  @override
  String failedToSaveData(String error) {
    return 'ডেটা সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String get whatsYourGender => 'আপনার লিঙ্গ কী?';

  @override
  String get genderHelpsMatches =>
      'এটি আপনাকে প্রাসঙ্গিক প্রোফাইল দেখাতে ও ম্যাচ খুঁজতে সাহায্য করে';

  @override
  String get vNonBinary => 'নন-বাইনারি';

  @override
  String get vPreferNot => 'বলতে চাই না';

  @override
  String failedToSaveGender(String error) {
    return 'লিঙ্গ সংরক্ষণ করা যায়নি: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'আপনার প্রোফাইলে ছবি আপলোড করতে $permission অনুমতি দিন।';
  }

  @override
  String get gallery => 'গ্যালারি';

  @override
  String get camera => 'ক্যামেরা';

  @override
  String get photoNotAccepted => 'ছবি গ্রহণ করা হয়নি';

  @override
  String get couldNotVerifyPhoto => 'আমরা আপনার ছবি যাচাই করতে পারিনি কারণ:';

  @override
  String get tryDifferentPhoto => 'অনুগ্রহ করে অন্য একটি ছবি আপলোড করুন।';

  @override
  String get addPhotos => 'ছবি যোগ করুন';

  @override
  String get addAtLeast2Photos =>
      'ম্যাচ পেতে অন্তত ২টি ছবি যোগ করুন! প্রথমটি প্রধান ছবি';

  @override
  String get tapPhotoToEdit =>
      'যোগ করা ছবিতে ট্যাপ করে সম্পাদনা বা মুছে ফেলুন।';

  @override
  String get addOneMorePhoto => 'অনুগ্রহ করে আরও একটি ছবি যোগ করুন';

  @override
  String get addMorePhotos => 'আরও ছবি যোগ করুন';

  @override
  String get mainPhotoBadge => 'প্রধান';

  @override
  String get editPhoto => 'ছবি সম্পাদনা';

  @override
  String get removePhoto => 'ছবি সরান';

  @override
  String get realConnectionsStartHere => 'প্রকৃত সম্পর্ক এখান থেকেই শুরু!';

  @override
  String get createAnAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get iHaveAnAccount => 'আমার অ্যাকাউন্ট আছে';

  @override
  String get agreeToOurTerms => 'আপনি আমাদের শর্তাবলীতে সম্মত';

  @override
  String get findPeopleNearYou => 'আশেপাশের মানুষ খুঁজুন';

  @override
  String get locationAccessBody =>
      'আপনার এলাকার সম্ভাব্য ম্যাচ দেখাতে আমাদের আপনার\nলোকেশন জানা দরকার। সত্যতা ও নিরাপত্তার জন্য আপনার সাধারণ\nঅবস্থান যাচাই করতেও এটি সাহায্য করে। চিন্তা করবেন না,\nআপনার সঠিক অবস্থান কখনও শেয়ার করা হয় না';

  @override
  String get allowLocationAccess => 'লোকেশন অ্যাক্সেস দিন';

  @override
  String get events => 'ইভেন্ট';

  @override
  String get booked => 'বুক করা';

  @override
  String get upcoming => 'আসন্ন';

  @override
  String get noEventsFound => 'কোনো ইভেন্ট পাওয়া যায়নি';

  @override
  String get noEventsNearby =>
      'এখন আশেপাশে কোনো ইভেন্ট নেই। পরে দেখুন বা লোকেশন বদলান।';

  @override
  String get refreshEvents => 'ইভেন্ট রিফ্রেশ করুন';

  @override
  String get bookedEvents => 'বুক করা ইভেন্ট';

  @override
  String get ticketsAndReservations => 'আপনার টিকিট ও রিজার্ভেশন';

  @override
  String get upcomingEvents => 'আসন্ন ইভেন্ট';

  @override
  String get eventsYouAreInterested => 'আপনার আগ্রহের ইভেন্ট';

  @override
  String get incomingVideoCall => 'আসন্ন ভিডিও কল';

  @override
  String get incomingVoiceCall => 'আসন্ন ভয়েস কল';

  @override
  String get ringing => 'রিং হচ্ছে...';

  @override
  String get speaker => 'স্পিকার';

  @override
  String get mute => 'মিউট';

  @override
  String get unmute => 'আনমিউট';

  @override
  String get videoOff => 'ভিডিও বন্ধ';

  @override
  String get video => 'ভিডিও';

  @override
  String get decline => 'প্রত্যাখ্যান';

  @override
  String get flip => 'ক্যামেরা বদলান';

  @override
  String get callEnded => 'কল শেষ';

  @override
  String get howWasCallQuality => 'কলের মান কেমন ছিল?';

  @override
  String get switchToVideoCall => 'ভিডিও কলে যাবেন?';

  @override
  String get otherWantsVideoOn => 'অন্য ব্যবহারকারী ভিডিও চালু করতে চান।';

  @override
  String get switchToVoiceCall => 'ভয়েস কলে যাবেন?';

  @override
  String get otherWantsVideoOff => 'অন্য ব্যবহারকারী ভিডিও বন্ধ করতে চান।';

  @override
  String get reject => 'প্রত্যাখ্যান';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get incomingVideoCallTitle => 'আসন্ন ভিডিও কল';

  @override
  String get incomingVoiceCallTitle => 'আসন্ন ভয়েস কল';

  @override
  String get errorTitle => 'ত্রুটি';

  @override
  String get successTitle => 'সফল';

  @override
  String get great => 'দারুণ!';

  @override
  String get peoples => 'মানুষ';

  @override
  String get chatTab => 'চ্যাট';

  @override
  String get editProfileTitle => 'প্রোফাইল সম্পাদনা';

  @override
  String percentComplete(String percent) {
    return '$percent% সম্পূর্ণ';
  }

  @override
  String get profileStrength => 'প্রোফাইলের শক্তি';

  @override
  String get photosAndVideos => 'ছবি ও ভিডিও';

  @override
  String get pickSomeTrueYou => 'যেগুলি আপনার আসল রূপ দেখায় সেগুলি বাছুন।';

  @override
  String get holdDragReorder => 'ক্রম বদলাতে মিডিয়া চেপে টানুন';

  @override
  String get bestPhoto => 'সেরা ছবি';

  @override
  String get aboutYouSection => 'আপনার সম্পর্কে';

  @override
  String get aboutYouHint => 'আপনার সম্পর্কে...';

  @override
  String get writeFunIntro => 'একটি মজার পরিচিতি লিখুন।';

  @override
  String get letPeopleKnowDate => 'আপনার সাথে ডেট করা কেমন, তা জানান।';

  @override
  String get addAPrompt => 'একটি প্রম্পট যোগ করুন';

  @override
  String get prompts => 'প্রম্পট';

  @override
  String get prompt => 'প্রম্পট';

  @override
  String get addVoiceIntro => 'ভয়েস পরিচিতি যোগ করুন';

  @override
  String get letPeopleHearVoice => 'মানুষকে আপনার কণ্ঠ শোনান।';

  @override
  String get reRecordIntro => 'পরিচিতি আবার রেকর্ড করুন';

  @override
  String get deleteVoiceIntro => 'ভয়েস পরিচিতি মুছবেন?';

  @override
  String get removeVoiceIntroBody =>
      'এটি আপনার প্রোফাইল থেকে ভয়েস পরিচিতি সরিয়ে দেবে।';

  @override
  String get interests => 'আগ্রহ';

  @override
  String get addFavoriteInterests => 'আপনার প্রিয় আগ্রহ যোগ করুন';

  @override
  String get getSpecificThingsYouLove =>
      'যা ভালোবাসেন সে সম্পর্কে নির্দিষ্ট করে বলুন।';

  @override
  String get lifestyle => 'জীবনযাত্রা';

  @override
  String get addLifestylePrefs => 'আপনার লাইফস্টাইল পছন্দ যোগ করুন';

  @override
  String get habitsAndPrefs => 'আপনার অভ্যাস ও পছন্দ।';

  @override
  String get iAmLookingFor => 'আমি খুঁজছি';

  @override
  String get addWhatLookingFor => 'আপনি কী খুঁজছেন তা যোগ করুন';

  @override
  String get letOthersKnowWant => 'আপনি কী চান তা অন্যদের জানান';

  @override
  String get qualitiesIValue => 'আমি যে গুণ মূল্য দিই';

  @override
  String get addQualitiesYouValue => 'আপনি যে গুণ মূল্য দেন তা যোগ করুন';

  @override
  String get chooseThreeQualitiesValue =>
      'একজনের মধ্যে আপনি যে ৩টি গুণ মূল্য দেন তা বাছুন';

  @override
  String get myCausesSection => 'আমার কারণ ও কমিউনিটি';

  @override
  String get addYourCauses => 'আপনার কারণ ও কমিউনিটি যোগ করুন';

  @override
  String get addUpTo3Causes =>
      'আপনার হৃদয়ের কাছের সর্বোচ্চ ৩টি কারণ যোগ করুন।';

  @override
  String get addLanguagesYouKnow => 'আপনি যে ভাষা জানেন তা যোগ করুন';

  @override
  String get moreAboutYou => 'আপনার সম্পর্কে আরও';

  @override
  String get heightLabel => 'উচ্চতা';

  @override
  String get genderLabel => 'লিঙ্গ';

  @override
  String get pronounsLabel => 'সর্বনাম';

  @override
  String get pickYourPronouns => 'আপনার সর্বনাম বাছুন';

  @override
  String get addYourPronouns => 'আপনার সর্বনাম যোগ করুন';

  @override
  String get workLabel => 'কাজ';

  @override
  String get educationLevelLabel => 'শিক্ষার স্তর';

  @override
  String get hometownLabel => 'নিজ শহর';

  @override
  String get locationLabel => 'লোকেশন';

  @override
  String get exerciseLabel => 'ব্যায়াম';

  @override
  String get drinkingLabel => 'মদ্যপান';

  @override
  String get smokingLabel => 'ধূমপান';

  @override
  String get kidsLabel => 'সন্তান';

  @override
  String get kidsPreferenceLabel => 'সন্তান বিষয়ক পছন্দ';

  @override
  String get politicsLabel => 'রাজনীতি';

  @override
  String get zodiacLabel => 'রাশি';

  @override
  String get educatedAtLabel => 'শিক্ষাপ্রতিষ্ঠান';

  @override
  String get connectedAccounts => 'যুক্ত অ্যাকাউন্ট';

  @override
  String get connectMySpotify => 'আমার Spotify যুক্ত করুন';

  @override
  String get showFavoriteMusic => 'আপনার প্রিয় গান দেখান';

  @override
  String get spotifyNote =>
      'আপনার প্রিয় Spotify শিল্পীদের প্রোফাইলে দেখান এবং Blindly-কে অন্যদের সাথে মিল তুলে ধরতে দিন।';

  @override
  String get verification => 'যাচাইকরণ';

  @override
  String get verified => 'যাচাইকৃত';

  @override
  String get invalidLocation => 'অবৈধ লোকেশন';

  @override
  String get locationFound => 'লোকেশন পাওয়া গেছে';

  @override
  String get alreadyVerified => 'আপনি ইতিমধ্যে যাচাইকৃত';

  @override
  String get verificationSuccessful => 'যাচাইকরণ সফল';

  @override
  String get documentNotVerified => 'নথি যাচাই করা যায়নি।';

  @override
  String get verificationFailed => 'যাচাইকরণ ব্যর্থ';

  @override
  String get veriffReason =>
      'আমরা আপনার ID যাচাই করতে পারিনি। Veriff এই কারণ জানিয়েছে:';

  @override
  String get tryClearerImage => 'পরিষ্কার ছবি দিয়ে আবার চেষ্টা করুন।';

  @override
  String get veriffWaiting => 'Veriff শেষ। আপডেটের অপেক্ষা...';

  @override
  String get verificationSubmitted =>
      'যাচাইকরণ জমা হয়েছে! আপনার ID পর্যালোচনা হচ্ছে...';

  @override
  String get verifyYourProfile => 'আপনার প্রোফাইল যাচাই করুন';

  @override
  String get youAreVerified => 'আপনি যাচাইকৃত!';

  @override
  String get quickCheckSafe => 'আপনার নিরাপত্তার জন্য একটি দ্রুত যাচাই';

  @override
  String get identityConfirmed => 'আপনার পরিচয় নিশ্চিত হয়েছে।';

  @override
  String get veriffExplainer =>
      'আপনার পরিচয় নিশ্চিত করতে আমরা নিরাপদ নথি স্ক্যানের জন্য Veriff ব্যবহার করি।';

  @override
  String get verifyingResults => 'ফলাফল যাচাই হচ্ছে...';

  @override
  String get verificationComplete => 'যাচাইকরণ সম্পূর্ণ';

  @override
  String get tapToScanDocument => 'নথি স্ক্যান করতে ট্যাপ করুন';

  @override
  String get prepareIdCard => 'আপনার আসল ID কার্ড প্রস্তুত রাখুন';

  @override
  String get ensureGoodLighting => 'ভালো আলো নিশ্চিত করুন';

  @override
  String get readyForSelfie => 'একটি দ্রুত সেলফির জন্য প্রস্তুত থাকুন';

  @override
  String get processing => 'প্রক্রিয়াকরণ হচ্ছে...';

  @override
  String get startVerification => 'যাচাইকরণ শুরু করুন';

  @override
  String get poweredByVeriff => 'Veriff দ্বারা পরিচালিত';

  @override
  String get alignWithCamera => 'ক্যামেরার সাথে নিজেকে সঠিকভাবে রাখুন';

  @override
  String get cameraPermissionRequired =>
      'যাচাইকরণের জন্য ক্যামেরা অনুমতি প্রয়োজন।';

  @override
  String get noCameraFound => 'ডিভাইসে কোনো ক্যামেরা পাওয়া যায়নি।';

  @override
  String get reviewingYourPhotos => 'আমরা আপনার ছবি পর্যালোচনা করছি';

  @override
  String get verificationInProgress =>
      'আপনার প্রোফাইল যাচাই চলছে। সাধারণত কয়েক সেকেন্ড লাগে।';

  @override
  String get verifiedSuccessfully => 'সফলভাবে যাচাইকৃত!';

  @override
  String get profileVerificationDone => 'প্রোফাইল যাচাইকরণ সফলভাবে সম্পন্ন';

  @override
  String get gotIt => 'বুঝেছি';

  @override
  String get copyThisPose => 'এই ভঙ্গি নকল করুন';

  @override
  String get selfieVerification => 'সেলফি যাচাইকরণ';

  @override
  String get proveRealDeal => 'প্রমাণ করুন আপনি\nআসল';

  @override
  String get quickHelpsSafe =>
      'এই দ্রুত যাচাই আমাদের কমিউনিটিকে নিরাপদ ও প্রকৃত রাখে';

  @override
  String get getVerifiedBadge => 'যাচাইকৃত ব্যাজ পান';

  @override
  String get buildTrustBody => 'অন্যদের আস্থা অর্জন করুন এবং দেখান আপনি আসল।';

  @override
  String get keepCommunitySafe => 'কমিউনিটি নিরাপদ রাখুন';

  @override
  String get weedOutFakes => 'ভুয়া প্রোফাইল ও বট সরাতে সাহায্য করুন।';

  @override
  String get copySimplePose => 'একটি সহজ ভঙ্গি নকল করুন';

  @override
  String get quickSelfieConfirm =>
      'পরিচয় নিশ্চিত করতে একটি দ্রুত সেলফি তুলবেন';

  @override
  String get selfieNotOnProfile =>
      'দ্রষ্টব্য: আপনার সেলফি শুধু যাচাইয়ের জন্য, প্রোফাইলে দেখা যাবে না';

  @override
  String get getVerified => 'যাচাই করান';

  @override
  String get voiceIntroTooShort => 'ভয়েস পরিচিতি অন্তত ১ সেকেন্ড হতে হবে';

  @override
  String get recordVoiceIntroFirst =>
      'অনুগ্রহ করে একটি ভয়েস পরিচিতি রেকর্ড করুন';

  @override
  String get recordingBetween1And30 =>
      'রেকর্ডিং ১ থেকে ৩০ সেকেন্ডের মধ্যে হতে হবে';

  @override
  String get recordShortIntro => 'একটি ছোট পরিচিতি রেকর্ড করুন';

  @override
  String get personalityShine =>
      'আপনার ব্যক্তিত্ব ফুটে উঠুক। ৩০ সেকেন্ডের ছোট পরিচিতি রেকর্ড করুন।';

  @override
  String get recordAgain => 'আবার রেকর্ড করুন';

  @override
  String get voicePromptsHelp =>
      'ভয়েস প্রম্পট আপনাকে আলাদা করে ও গভীর সম্পর্ক গড়ে। আপনি আসলে কে তা জানান';

  @override
  String get threeXMatches => 'ভয়েস রেকর্ডে ৩ গুণ বেশি ম্যাচ';

  @override
  String get startConversationNaturally => 'স্বাভাবিকভাবে কথা শুরু করুন';

  @override
  String get showYourPersonality => 'আপনার ব্যক্তিত্ব দেখান';

  @override
  String get saveAndContinue => 'সংরক্ষণ ও চালিয়ে যান';

  @override
  String failedUploadVoice(String error) {
    return 'ভয়েস পরিচিতি আপলোড করা যায়নি: $error';
  }

  @override
  String get failedToStartRecording => 'রেকর্ডিং শুরু করা যায়নি';

  @override
  String get failedToStopRecording => 'রেকর্ডিং থামানো যায়নি';

  @override
  String get failedToPlayAudio => 'অডিও চালানো যায়নি';

  @override
  String get navLikes => 'লাইক';

  @override
  String get photoReasonNoFace =>
      'কোনো স্পষ্ট মুখ পাওয়া যায়নি। মুখ দেখা যায় এমন ছবি দিন।';

  @override
  String get photoReasonGroupPhoto =>
      'এই ছবিতে একাধিক ব্যক্তি আছেন। একার ছবি দিন।';

  @override
  String get photoReasonFaceTooSmall =>
      'এই ছবিতে আপনার মুখ খুব ছোট। কাছে থেকে তুলুন বা ক্রপ করুন।';

  @override
  String get photoReasonUnsafe => 'এই ছবি আমাদের নির্দেশিকা মেনে চলে না।';

  @override
  String get photoReasonBadImage =>
      'ফাইলটি পড়া যায়নি। JPG বা PNG দিয়ে চেষ্টা করুন।';

  @override
  String get photoReasonTooLarge => 'ছবিটি খুব বড়। ছোট ছবি দিন।';

  @override
  String get photoReasonUnavailable => 'এই মুহূর্তে ছবিটি যাচাই করা যায়নি।';

  @override
  String get photoTryAgainLater => 'কানেকশন পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get photoLoadFailed => 'আপনার ছবি লোড করা যায়নি।';

  @override
  String get photoSaveFailed => 'ছবি সেভ করা যায়নি। আবার চেষ্টা করুন।';

  @override
  String photosNotAdded(int count) {
    return '$countটি ছবি যোগ করা যায়নি:';
  }

  @override
  String get photosExpired =>
      'কিছু ছবির মেয়াদ শেষ হয়ে যাওয়ায় সরিয়ে ফেলা হয়েছে। অনুগ্রহ করে আবার যোগ করুন।';
}
