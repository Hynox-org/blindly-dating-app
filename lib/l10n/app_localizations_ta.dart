// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get settingsLanguage => 'மொழி';

  @override
  String get appLanguageTitle => 'ஆப்ஸ் மொழி';

  @override
  String get systemDefault => 'சாதன இயல்புநிலை';

  @override
  String get authTitlePhone => 'உங்கள் எண்ணைச் சொல்லுங்கள்';

  @override
  String get authTitleVerifyNumber => 'உங்கள் எண்ணைச் சரிபார்க்கவும்';

  @override
  String get authTitleEmail => 'மின்னஞ்சல் மூலம் உள்நுழைக';

  @override
  String get authTitleVerifyEmail => 'உங்கள் மின்னஞ்சலைச் சரிபார்க்கவும்';

  @override
  String get authTitleApple => 'Apple மூலம் உள்நுழைக';

  @override
  String get loginTagline => 'அழகான வாழ்க்கைக்குள் நுழையுங்கள்';

  @override
  String get continueWithGoogle => 'Google மூலம் தொடரவும்';

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String get termsSignupPrefix => 'பதிவு செய்வதன் மூலம், நீங்கள் எங்கள் ';

  @override
  String get termsContinuePrefix => 'தொடர்வதன் மூலம், நீங்கள் எங்கள் ';

  @override
  String get termsWord => 'விதிமுறைகளை';

  @override
  String get termsBridge =>
      ' ஏற்கிறீர்கள். உங்கள் தரவை நாங்கள் எவ்வாறு பயன்படுத்துகிறோம் என்பதை எங்கள் ';

  @override
  String get privacyPolicyWord => 'தனியுரிமைக் கொள்கையில்';

  @override
  String get termsSuffix => ' பார்க்கவும்.';

  @override
  String get phoneRationale =>
      'Blindly-இல் உள்ள அனைவரும் உண்மையானவர்கள் என்பதை உறுதிசெய்யவே தொலைபேசி எண்ணைப் பயன்படுத்துகிறோம்';

  @override
  String get countryLabel => 'நாடு';

  @override
  String get phoneNumberLabel => 'தொலைபேசி எண்';

  @override
  String get phoneHint => 'எ.கா. 9876543210';

  @override
  String otpSentPhone(String phone) {
    return '$phone க்கு நாங்கள் அனுப்பிய குறியீட்டை உள்ளிடவும். ';
  }

  @override
  String get changeNumber => 'எண்ணை மாற்று';

  @override
  String otpSentEmail(String email) {
    return '$email க்கு மின்னஞ்சலில் அனுப்பிய குறியீட்டை உள்ளிடவும். ';
  }

  @override
  String get changeEmail => 'மின்னஞ்சலை மாற்று';

  @override
  String get resendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String codeArrivesIn(int seconds) {
    return 'குறியீடு $seconds வினாடிகளில் வரும்';
  }

  @override
  String get otpSentSuccess => 'OTP அனுப்பப்பட்டது';

  @override
  String get loginDetailsSubtitle =>
      'உங்கள் உள்நுழைவு விவரங்களை கீழே உள்ளிடவும்';

  @override
  String get emailLabel => 'மின்னஞ்சல்';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'கடவுச்சொல்';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';

  @override
  String get errEnterPhone => 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get errPhoneDigitsOnly =>
      'தொலைபேசி எண்ணில் இலக்கங்கள் மட்டுமே இருக்க வேண்டும்';

  @override
  String get errInvalidPhone => 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get errInvalidPhoneIndia =>
      '6-9 இல் தொடங்கும் சரியான 10 இலக்க இந்திய தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get errInvalidPhone10Digit =>
      'சரியான 10 இலக்க தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get errEnterCompleteOtp => 'முழு OTP ஐ உள்ளிடவும்';

  @override
  String get errEnterEmail => 'உங்கள் மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get errInvalidEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get errFillAllFields => 'அனைத்து புலங்களையும் நிரப்பவும்';

  @override
  String get errPasswordMin =>
      'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get errTooManyAttempts =>
      'அதிக முயற்சிகள். சிறிது நேரம் கழித்து மீண்டும் முயலவும்.';

  @override
  String errCreateProfile(String error) {
    return 'சுயவிவரத்தை உருவாக்க முடியவில்லை: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google உள்நுழைவு தோல்வி: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'உள்நுழைவு தோல்வி: $error';
  }

  @override
  String errGeneric(String error) {
    return 'பிழை: $error';
  }

  @override
  String get save => 'சேமி';

  @override
  String get skip => 'தவிர்';

  @override
  String get add => 'சேர்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get retry => 'மீண்டும் முயற்சி';

  @override
  String get update => 'புதுப்பி';

  @override
  String get back => 'பின்';

  @override
  String get done => 'முடிந்தது';

  @override
  String get next => 'அடுத்து';

  @override
  String get edit => 'திருத்து';

  @override
  String get deleteLabel => 'நீக்கு';

  @override
  String get close => 'மூடு';

  @override
  String get yes => 'ஆம்';

  @override
  String get no => 'இல்லை';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get somethingWentWrong => 'ஏதோ தவறு நடந்தது';

  @override
  String get userNotLoggedIn => 'பயனர் உள்நுழையவில்லை';

  @override
  String get unknown => 'தெரியவில்லை';

  @override
  String get typesOfConnections => 'தொடர்பு வகைகள்';

  @override
  String get connectionQuestion =>
      'Blindly-இல் எந்த வகையான தொடர்பைத் தேடுகிறீர்கள்?';

  @override
  String get connectionSubtitle =>
      'டேட்டிங் மற்றும் காதல், புதிய நண்பர்கள், அல்லது வணிகம் மட்டுமா? இதை எப்போது வேண்டுமானாலும் மாற்றலாம்.';

  @override
  String get modeDateSubtitle =>
      'உறவு, சாதாரண நட்பு, அல்லது இடைப்பட்ட எதையும் கண்டறியுங்கள்';

  @override
  String get modeBffSubtitle =>
      'புதிய நண்பர்களை உருவாக்கி உங்கள் சமூகத்தைக் கண்டறியுங்கள்';

  @override
  String get modeEventsSubtitle =>
      'சுவாரஸ்யமான நிகழ்வுகளைக் கண்டறியுங்கள், டிக்கெட் பதிவு செய்யுங்கள், மேலும் பல';

  @override
  String continueWithMode(String mode) {
    return '$mode உடன் தொடரவும்';
  }

  @override
  String get multiDeviceTitle => 'பல சாதன உள்நுழைவு';

  @override
  String get multiDeviceBody =>
      'உங்கள் கணக்கு மற்றொரு சாதனத்தில் இயங்குகிறது. பாதுகாப்பிற்காக ஒரு அமர்வு மட்டுமே அனுமதிக்கப்படுகிறது.';

  @override
  String get signedOutOtherDevices =>
      'மற்ற சாதனங்களிலிருந்து வெளியேற்றப்பட்டது!';

  @override
  String get signOutOtherDevices => 'மற்ற சாதனங்களை வெளியேற்று';

  @override
  String get logOutThisDevice => 'இந்தச் சாதனத்திலிருந்து வெளியேறு';

  @override
  String get swipeRightHint => 'மேலும் அறிய வலதுபுறம் ஸ்வைப் செய்யுங்கள்!';

  @override
  String get locationRequiredTitle => 'இருப்பிடம் தேவை';

  @override
  String get locationRequiredBody =>
      'உங்கள் அருகில் உள்ள சிறந்தவர்களைக் கண்டறிய உங்கள் இருப்பிடம் தேவை.\n\n\"அமைப்புகள்\" ஐத் தட்டி இருப்பிட அனுமதியை இயக்கவும், பின்னர் \"மீண்டும் முயற்சி\" அழுத்தவும்.';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get notifyMeSnack =>
      'புதியவர்கள் இணையும்போது உங்களுக்குத் தெரிவிப்போம்!';

  @override
  String get nearby => 'அருகில்';

  @override
  String heightCm(String value) {
    return '$value செ.மீ';
  }

  @override
  String get completeYourProfile => 'உங்கள் சுயவிவரத்தை நிறைவு செய்யுங்கள்';

  @override
  String get completeYourProfileBody =>
      'சில படிகளைத் தவிர்த்துவிட்டீர்கள். ஆப்ஸை முழுமையாகப் பயன்படுத்த அவற்றை நிறைவு செய்யுங்கள்.';

  @override
  String get stepNotAvailable => 'இந்தப் படி இன்னும் கிடைக்கவில்லை.';

  @override
  String get profileNotFound => 'சுயவிவரம் கிடைக்கவில்லை';

  @override
  String get profileUnavailable =>
      'சுயவிவரம் கிடைக்கவில்லை அல்லது இனி கிடைக்காது.';

  @override
  String get profileLoadFailed =>
      'சுயவிவரத்தை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get alreadyLikedProfile =>
      'இந்தச் சுயவிவரத்தை ஏற்கனவே விரும்பியுள்ளீர்கள்.';

  @override
  String get personAlreadyLikedYou => 'இவர் ஏற்கனவே உங்களை விரும்பியுள்ளார்.';

  @override
  String get youAreMatched => 'நீங்கள் இணைக்கப்பட்டுள்ளீர்கள்.';

  @override
  String get alreadyChatting =>
      'நீங்கள் ஏற்கனவே உரையாடலைத் தொடங்கிவிட்டீர்கள்.';

  @override
  String get profileAlreadySkipped => 'சுயவிவரம் ஏற்கனவே தவிர்க்கப்பட்டது.';

  @override
  String get goBack => 'பின் செல்';

  @override
  String get profilePreview => 'சுயவிவர முன்னோட்டம்';

  @override
  String get profileTitle => 'சுயவிவரம்';

  @override
  String get voiceIntro => 'குரல் அறிமுகம்';

  @override
  String get bioTitle => 'சுயவிவரக் குறிப்பு';

  @override
  String get askAboutMyBio => 'என் சுயவிவரக் குறிப்பைப் பற்றிக் கேளுங்கள்!';

  @override
  String get kudos => 'பாராட்டு';

  @override
  String get aPrompt => 'ஒரு கேள்வி';

  @override
  String get profileVerified => 'சுயவிவரம் சரிபார்க்கப்பட்டது';

  @override
  String get photoVerified => 'புகைப்படம் சரிபார்க்கப்பட்டது';

  @override
  String get notVerified => 'சரிபார்க்கப்படவில்லை';

  @override
  String milesAway(String distance) {
    return '$distance மைல் தொலைவில்';
  }

  @override
  String trustScore(String score) {
    return 'நம்பிக்கை மதிப்பெண்: $score%';
  }

  @override
  String get seeHowYouMatch =>
      'நீங்கள் இருவரும் எப்படிப் பொருந்துகிறீர்கள் என்று பாருங்கள்';

  @override
  String get aboutMe => 'என்னைப் பற்றி';

  @override
  String get imLookingFor => 'நான் தேடுவது';

  @override
  String get quickestWayToHeart => 'என் இதயத்தை வெல்லும் எளிதான வழி';

  @override
  String get myInterests => 'என் ஆர்வங்கள்';

  @override
  String get myLifestyle => 'என் வாழ்க்கை முறை';

  @override
  String smokesLabel(String value) {
    return 'புகைப்பழக்கம்: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'மது: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'உடற்பயிற்சி: $value';
  }

  @override
  String get myCauses => 'என் நோக்கங்களும் சமூகங்களும்';

  @override
  String get languagesTitle => 'மொழிகள்';

  @override
  String get myLocation => 'என் இருப்பிடம்';

  @override
  String get myTopArtist => 'Spotify-இல் என் விருப்பக் கலைஞர்';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get youLikedThem => 'நீங்கள் அவரை விரும்பினீர்கள்!';

  @override
  String get undoNotForMe => '\'எனக்கானது அல்ல\' ஐ மாற்று';

  @override
  String get notForMe => 'எனக்கானது அல்ல';

  @override
  String get block => 'தடு';

  @override
  String get report => 'புகாரளி';

  @override
  String get outOfSwipesToday => 'இன்றைய ஸ்வைப்கள்\nமுடிந்துவிட்டன';

  @override
  String get moreSwipesIn => 'மேலும் ஸ்வைப்கள் இதற்குள்';

  @override
  String get hoursLabel => 'மணி';

  @override
  String get minutesLabel => 'நிமிடம்';

  @override
  String get secondsLabel => 'வினாடி';

  @override
  String get sendAndSeeLikes =>
      'நீங்கள் விரும்பும் அளவு\nலைக்குகளை அனுப்பி பாருங்கள்';

  @override
  String get sendUnlimitedSwipes => 'வரம்பற்ற ஸ்வைப்களை அனுப்புங்கள்';

  @override
  String get advancedSearchFilter => 'மேம்பட்ட தேடல் வடிகட்டி';

  @override
  String get seeEveryoneWhoLikes => 'உங்களை விரும்பும் அனைவரையும் பாருங்கள்';

  @override
  String get setMoreDatingPrefs => 'மேலும் டேட்டிங் விருப்பங்களை அமைக்கவும்';

  @override
  String monthsPlan(String count) {
    return '$count மாதங்கள்';
  }

  @override
  String get mostPopular => 'மிகவும் பிரபலமானது';

  @override
  String get bestValue => 'சிறந்த மதிப்பு';

  @override
  String getWithPlan(String plan, String price) {
    return '$plan ஐ $price க்கு பெறுங்கள்';
  }

  @override
  String offerEndsIn(String time) {
    return 'சலுகை முடிய $time';
  }

  @override
  String get chats => 'அரட்டைகள்';

  @override
  String get conversations => 'உரையாடல்கள்';

  @override
  String get recentMatches => 'சமீபத்திய பொருத்தங்கள்';

  @override
  String get readyToMakeFirstMove => 'முதல் அடி எடுத்து வைக்கத்\nதயாரா?';

  @override
  String get tapToContinueChatting => 'உரையாடலைத் தொடர தட்டவும்';

  @override
  String get unknownUser => 'தெரியாத பயனர்';

  @override
  String get newMatchesAppearHere =>
      'உங்கள் புதிய பொருத்தங்கள் இங்கே தோன்றும்.';

  @override
  String get endToEndEncrypted => 'முழுமையாக மறையாக்கம் செய்யப்பட்டது';

  @override
  String get e2eBanner =>
      'செய்திகளும் அழைப்புகளும் முழுமையாக மறையாக்கம் செய்யப்பட்டுள்ளன. இந்த உரையாடலுக்கு வெளியே யாரும், Blindly கூட, அவற்றைப் படிக்கவோ கேட்கவோ முடியாது. ';

  @override
  String get encryptedMessage => 'மறையாக்கப்பட்ட செய்தி';

  @override
  String get encryptionKeyNotLoaded =>
      'மறையாக்கச் சாவி ஏற்றப்படவில்லை. காத்திருக்கவும்.';

  @override
  String get messageViolatesGuidelines =>
      'இந்தச் செய்தி எங்கள் சமூக வழிகாட்டுதல்களை மீறக்கூடும், அதனால் அனுப்பப்படவில்லை.';

  @override
  String get imageMessage => ' படச் செய்தி';

  @override
  String get voiceMessage => ' குரல் செய்தி';

  @override
  String nSelected(String count) {
    return '$count தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get editedSuffix => '(திருத்தப்பட்டது)';

  @override
  String get editingMessage => 'செய்தி திருத்தப்படுகிறது';

  @override
  String get onlyTextEditable => 'உரைச் செய்திகளை மட்டுமே திருத்த முடியும்';

  @override
  String get messageCopied => 'செய்தி நகலெடுக்கப்பட்டது';

  @override
  String get archiveChat => 'உரையாடலைக் காப்பகப்படுத்து';

  @override
  String get clearChat => 'உரையாடலை அழி';

  @override
  String get blockUser => 'பயனரைத் தடு';

  @override
  String get muteNotifications => 'அறிவிப்புகளை முடக்கு';

  @override
  String get reportAndSpam => 'புகாரளித்து ஸ்பேம் எனக் குறி';

  @override
  String get deleteForMe => 'எனக்காக நீக்கு';

  @override
  String get deleteForEveryone => 'அனைவருக்கும் நீக்கு';

  @override
  String get showTranslation => 'மொழிபெயர்ப்பைக் காட்டு';

  @override
  String get showOriginal => 'மூலத்தைக் காட்டு';

  @override
  String get takePhoto => 'புகைப்படம் எடு';

  @override
  String get chooseFromGallery => 'கேலரியிலிருந்து தேர்வுசெய்';

  @override
  String get attachmentComingSoon => 'இணைப்புத் தேர்வி விரைவில்';

  @override
  String get imageTooLarge => 'படம் மிகப் பெரியது (அதிகபட்சம் 5MB)';

  @override
  String get micPermissionDenied => 'ஒலிவாங்கி அனுமதி மறுக்கப்பட்டது';

  @override
  String get recordingEmpty => 'பதிவு கோப்பு காலியாக உள்ளது';

  @override
  String get recordingNotFound => 'பதிவு கோப்பு கிடைக்கவில்லை';

  @override
  String get failedToPlayVoice => 'குரல் செய்தியை இயக்க முடியவில்லை';

  @override
  String get failedToLoad => 'ஏற்ற முடியவில்லை';

  @override
  String get errorLoadingGif => 'GIF ஏற்றுவதில் பிழை';

  @override
  String get errorLoadingSticker => 'ஸ்டிக்கர் ஏற்றுவதில் பிழை';

  @override
  String get networkErrorRetry =>
      'பிணையப் பிழை. உங்கள் இணைய இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get serverSideError =>
      'எங்கள் பக்கம் ஏதோ தவறு. மீண்டும் ஒருமுறை முயற்சிக்கவும்.';

  @override
  String get pleaseLoginFirst => 'முதலில் உள்நுழையவும்';

  @override
  String get icebreakers => 'உரையாடல் தொடக்கிகள்';

  @override
  String get iceBreaker => 'உரையாடல் தொடக்கி';

  @override
  String get couldntLoadIcebreakers => 'உரையாடல் தொடக்கிகளை ஏற்ற முடியவில்லை';

  @override
  String get aiAnalyzingProfiles => 'AI உங்கள் சுயவிவரங்களை ஆய்வு செய்கிறது...';

  @override
  String get generate => 'உருவாக்கு';

  @override
  String get regenerate => 'மீண்டும் உருவாக்கு';

  @override
  String get categoryAll => 'அனைத்தும்';

  @override
  String get categoryDeep => 'ஆழமான';

  @override
  String get categoryPlayful => 'விளையாட்டான';

  @override
  String get categoryQuirky => 'வித்தியாசமான';

  @override
  String get categoryPersonalized => 'தனிப்பயனாக்கப்பட்ட';

  @override
  String get categoryQuestion => 'கேள்வி';

  @override
  String get categoryObservation => 'கவனிப்பு';

  @override
  String get categoryFunFact => 'சுவாரஸ்யத் தகவல்';

  @override
  String get categoryHypothesis => 'ஊகம்';

  @override
  String get categoryOpeningMove => 'தொடக்க நகர்வு';

  @override
  String get superpowerPrompt =>
      'உங்களுக்கு ஏதேனும் ஒரு அதிசய சக்தி கிடைத்தால், அது என்னவாக இருக்கும்?';

  @override
  String get chooseAnOption => 'ஒரு விருப்பத்தைத் தேர்வுசெய்';

  @override
  String get invalidMatchData =>
      'பொருத்தத் தரவு தவறானது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get moreOpeningMoves => 'மேலும் தொடக்க நகர்வுகள்';

  @override
  String get onlineNow => 'இப்போது ஆன்லைனில்';

  @override
  String get pleaseEnterMessage => 'ஒரு செய்தியை உள்ளிடவும்';

  @override
  String sendPersonMessage(String name) {
    return '$name க்கு செய்தி அனுப்பு';
  }

  @override
  String get sendMessage => 'செய்தி அனுப்பு';

  @override
  String get matchHasExpired => 'இந்தப் பொருத்தம் காலாவதியாகிவிட்டது.';

  @override
  String get typeOpeningMove => 'உங்கள் தொடக்கச் செய்தியை எழுதுங்கள்...';

  @override
  String get use => 'பயன்படுத்து';

  @override
  String get expiringSoon => 'விரைவில் காலாவதியாகும்';

  @override
  String get matchExpiredTitle => 'பொருத்தம் காலாவதி';

  @override
  String dontLetThemGetAway(String name) {
    return '$name ஐ\nதவறவிடாதீர்கள்!';
  }

  @override
  String get limitedTimeBody =>
      'நடவடிக்கை எடுக்க உங்களுக்குக் குறைந்த நேரமே உள்ளது. பொருத்தம் நிரந்தரமாக மறையும் முன் ஒரு செய்தி அனுப்புங்கள்.';

  @override
  String get letThemGo => 'விட்டுவிடுங்கள்';

  @override
  String messagePerson(String name) {
    return '$name க்கு செய்தி அனுப்பு';
  }

  @override
  String get gifs => 'GIF';

  @override
  String get stickers => 'ஸ்டிக்கர்கள்';

  @override
  String get searchGiphy => 'GIPHY இல் தேடு';

  @override
  String get themOnly => 'அவர் மட்டும்';

  @override
  String get tryAgain => 'மீண்டும் முயற்சி';

  @override
  String get icebreakerSmile =>
      'சமீபத்தில் எந்தச் சிறிய விஷயம் உங்களைப் புன்னகைக்க வைத்தது?';

  @override
  String get icebreakerTwoTruths => 'இரண்டு உண்மைகள், ஒரு பொய்: தொடங்கலாம்!';

  @override
  String get icebreakerInteresting =>
      'சமீபத்தில் நீங்கள் கற்ற மிகச் சுவாரஸ்யமான விஷயம் என்ன?';

  @override
  String get openingMoveCushions =>
      'நானும் நான் செய்த மெத்தைகளும்.\nஎப்படி இருக்கு?';

  @override
  String get openingMove90s => 'என் 90s தோற்றத்தை உங்களால் வெல்ல முடியாது';

  @override
  String get openingMovePetName =>
      'என் செல்லப்பிராணியின் பெயரை யூகிக்கிறீர்களா?';

  @override
  String get viewProfile => 'சுயவிவரத்தைப் பார்';

  @override
  String get likedYou => 'உங்களை விரும்பியவர்கள்';

  @override
  String get matchLabel => 'பொருத்தம்';

  @override
  String get passLabel => 'தவிர்';

  @override
  String get failedToLoadLikes => 'விருப்பங்களை ஏற்ற முடியவில்லை';

  @override
  String get noLikesYet => 'இன்னும் விருப்பங்கள் இல்லை, ஆனால்\n';

  @override
  String get buzzOff => 'கவலைப்பட வேண்டாம்!';

  @override
  String get keepSwipingBody =>
      'உங்கள் துணையைக் கண்டறிய ஸ்வைப் செய்யுங்கள்.\nவிரைவில் யாராவது உங்களை விரும்புவார்கள்!';

  @override
  String get keepSwiping => 'ஸ்வைப் செய்யுங்கள்';

  @override
  String get startSwiping => 'ஸ்வைப் செய்யத் தொடங்கு';

  @override
  String get improveProfile => 'சுயவிவரத்தை மேம்படுத்து';

  @override
  String get viewMoreLikes => 'மேலும் விருப்பங்களைப் பார்';

  @override
  String get seeWhosInterested => 'யாருக்கு ஆர்வம் என்று பாருங்கள்';

  @override
  String matchInstantly(String count) {
    return 'காத்திருக்காமல் உடனே பொருந்துங்கள். உங்களுக்கு $count+ விருப்பங்கள் காத்திருக்கின்றன';
  }

  @override
  String get superLiked => 'சூப்பர் லைக்';

  @override
  String get itsAMatch => 'பொருத்தம் கிடைத்தது!';

  @override
  String youAndThemLiked(String name) {
    return 'நீங்களும் $name ம் ஒருவரையொருவர் விரும்பினீர்கள்.';
  }

  @override
  String get sendAMessage => 'செய்தி அனுப்பு';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get loginToViewNotifications => 'அறிவிப்புகளைப் பார்க்க உள்நுழையவும்.';

  @override
  String get noNotificationsYet => 'உங்களுக்கு இன்னும் அறிவிப்புகள் இல்லை.';

  @override
  String get discover => 'கண்டறி';

  @override
  String get reachedEndOfLine => 'நீங்கள் இறுதிவரை\nவந்துவிட்டீர்கள்!';

  @override
  String get checkBackSoon =>
      'மேலும் நபர்களுக்கு விரைவில் திரும்பி வாருங்கள் அல்லது கூடுதல் சுயவிவரங்களைப் பார்க்க வடிகட்டிகளை மாற்றுங்கள்.';

  @override
  String get seeMorePeople => 'மேலும் நபர்களைப் பார்';

  @override
  String get topPicksForYou => 'உங்களுக்கான சிறந்தவை';

  @override
  String get sharedInterests => 'பொதுவான ஆர்வங்கள்';

  @override
  String get newFaces => 'புதிய முகங்கள்';

  @override
  String get recentlyActive => 'சமீபத்தில் செயலில்';

  @override
  String get seeAll => 'அனைத்தையும் பார்';

  @override
  String kmAway(String distance) {
    return '$distance கி.மீ தொலைவில்';
  }

  @override
  String get letsDiscover => 'கண்டறியலாம்!';

  @override
  String get viewedAllProfiles =>
      'உங்கள் தற்போதைய விருப்பத்திற்குப் பொருந்தும் அனைத்துச் சுயவிவரங்களையும் பார்த்துவிட்டீர்கள். தேடலை விரிவாக்குங்கள் அல்லது புதியவர்களுக்கு விரைவில் திரும்பி வாருங்கள்.';

  @override
  String get adjustYourFilters => 'உங்கள் வடிகட்டிகளை மாற்று';

  @override
  String get notifyMeNewPeople => 'புதியவர்களைப் பற்றி எனக்குத் தெரிவி';

  @override
  String youAndPerson(String name) {
    return 'நீங்களும் $name ம்';
  }

  @override
  String get workingOutCommon =>
      'உங்கள் இருவருக்கும் என்ன பொதுவானது என்று பார்க்கிறோம்…';

  @override
  String get whyTitle => 'ஏன்';

  @override
  String get breakdownTitle => 'விவரம்';

  @override
  String get goesBothWays => 'இது இருபுறமும் பொருந்துகிறதா?';

  @override
  String eachFitsOther(String band) {
    return 'நீங்கள் ஒருவருக்கொருவர் தேடுவதற்குப் பொருந்துகிறீர்கள்: $band.';
  }

  @override
  String get sectionConnections => 'தொடர்புகள்';

  @override
  String get typeOfConnection => 'தொடர்பு வகை';

  @override
  String get dateMode => 'டேட் பயன்முறை';

  @override
  String get travel => 'பயணம்';

  @override
  String get sectionAccountSettings => 'கணக்கு அமைப்புகள்';

  @override
  String get profileAndVerification => 'சுயவிவரம் & சரிபார்ப்பு';

  @override
  String get contactAndLoginInfo => 'தொடர்பு & உள்நுழைவுத் தகவல்';

  @override
  String get subscriptionManagement => 'சந்தா மேலாண்மை';

  @override
  String get sectionAppPreference => 'ஆப்ஸ் விருப்பம்';

  @override
  String get notificationsSetting => 'அறிவிப்பு அமைப்பு';

  @override
  String get privacyControls => 'தனியுரிமைக் கட்டுப்பாடுகள்';

  @override
  String get sectionSecurityPrivacy => 'பாதுகாப்பு & தனியுரிமை';

  @override
  String get accountManagement => 'கணக்கு மேலாண்மை';

  @override
  String get blockedAccounts => 'தடுக்கப்பட்ட கணக்குகள்';

  @override
  String get locationService => 'இருப்பிடச் சேவை';

  @override
  String get sectionSupportLegal => 'ஆதரவு & சட்டம்';

  @override
  String get helpCenter => 'உதவி மையம்';

  @override
  String get privacyPolicyTitle => 'தனியுரிமைக் கொள்கை';

  @override
  String get termsAndConditions => 'விதிமுறைகள் & நிபந்தனைகள்';

  @override
  String get about => 'பற்றி';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String get vEnglish => 'ஆங்கிலம்';

  @override
  String get vHindi => 'இந்தி';

  @override
  String get vTamil => 'தமிழ்';

  @override
  String get vTelugu => 'தெலுங்கு';

  @override
  String get vKannada => 'கன்னடம்';

  @override
  String get vMalayalam => 'மலையாளம்';

  @override
  String get vMarathi => 'மராத்தி';

  @override
  String get vBengali => 'வங்காளம்';

  @override
  String get vGujarati => 'குஜராத்தி';

  @override
  String get vPunjabi => 'பஞ்சாபி';

  @override
  String get vOdia => 'ஒடியா';

  @override
  String get vSpanish => 'ஸ்பானிஷ்';

  @override
  String get vFrench => 'பிரெஞ்சு';

  @override
  String get vGerman => 'ஜெர்மன்';

  @override
  String get vItalian => 'இத்தாலியன்';

  @override
  String get vPortuguese => 'போர்ச்சுகீஸ்';

  @override
  String get vRussian => 'ரஷ்யன்';

  @override
  String get vJapanese => 'ஜப்பானியம்';

  @override
  String get vKorean => 'கொரியன்';

  @override
  String get vChinese => 'சீனம்';

  @override
  String get vArabic => 'அரபு';

  @override
  String get vTurkish => 'துருக்கி';

  @override
  String get vOthers => 'மற்றவை';

  @override
  String get vOther => 'மற்றது';

  @override
  String get vHindu => 'இந்து';

  @override
  String get vChristian => 'கிறிஸ்தவர்';

  @override
  String get vMuslim => 'முஸ்லிம்';

  @override
  String get vSikh => 'சீக்கியர்';

  @override
  String get vJain => 'சமணர்';

  @override
  String get vBuddhist => 'பௌத்தர்';

  @override
  String get vAtheist => 'நாத்திகர்';

  @override
  String get vAgnostic => 'அஞ்ஞானவாதி';

  @override
  String get vSpiritual => 'ஆன்மீகம்';

  @override
  String get vCatholic => 'கத்தோலிக்கர்';

  @override
  String get vLatterDaySaint => 'லேட்டர் டே சேயின்ட்';

  @override
  String get vZoroastrian => 'ஜோராஸ்திரியர்';

  @override
  String get vJewish => 'யூதர்';

  @override
  String get vMormon => 'மார்மன்';

  @override
  String get vMonogamy => 'ஒருதார உறவு';

  @override
  String get vPolyamory => 'பலதரப்பு உறவு';

  @override
  String get vOpenRelationship => 'திறந்த உறவு';

  @override
  String get vNonMonogamy => 'ஒருதாரம் அல்லாத';

  @override
  String get vOpenToExploring => 'ஆராயத் தயார்';

  @override
  String get vShortTerm => 'குறுகிய கால';

  @override
  String get vLongTerm => 'நீண்ட கால';

  @override
  String get vStraight => 'ஸ்ட்ரெயிட்';

  @override
  String get vGay => 'கே';

  @override
  String get vLesbian => 'லெஸ்பியன்';

  @override
  String get vBisexual => 'இருபால் ஈர்ப்பு';

  @override
  String get vAsexual => 'பாலீர்ப்பற்ற';

  @override
  String get vDemisexual => 'டெமிசெக்ஸுவல்';

  @override
  String get vPansexual => 'பான்செக்ஸுவல்';

  @override
  String get vQueer => 'க்வியர்';

  @override
  String get vQuestioning => 'தெளிவில்லாத';

  @override
  String get vWomen => 'பெண்கள்';

  @override
  String get vMen => 'ஆண்கள்';

  @override
  String get vEveryone => 'அனைவரும்';

  @override
  String get vMale => 'ஆண்';

  @override
  String get vFemale => 'பெண்';

  @override
  String get vFunCasualDates => 'சுவாரஸ்யமான, சாதாரண டேட்';

  @override
  String get vLifePartner => 'வாழ்க்கைத் துணை';

  @override
  String get vLongTermRelationship => 'நீண்ட கால உறவு';

  @override
  String get vShortTermRelationship => 'குறுகிய கால உறவு';

  @override
  String get vStillFiguringOut => 'இன்னும் யோசித்து வருகிறேன்';

  @override
  String get vLongOpenToShort => 'நீண்ட கால, குறுகிய காலமும் சரி';

  @override
  String get vShortOpenToLong => 'குறுகிய கால, நீண்ட காலமும் சரி';

  @override
  String get vCasualDating => 'சாதாரண டேட்டிங்';

  @override
  String get vNewFriends => 'புதிய நண்பர்கள்';

  @override
  String get vCloseFriends => 'நெருங்கிய நண்பர்கள்';

  @override
  String get vActivityPartners => 'செயல்பாட்டுத் துணை';

  @override
  String get vProfessionalNetworking => 'தொழில்முறை தொடர்பு';

  @override
  String get vWorkoutBuddy => 'உடற்பயிற்சித் துணை';

  @override
  String get vTravelBuddies => 'பயணத் தோழர்கள்';

  @override
  String get vYesIDrink => 'ஆம், நான் குடிப்பேன்';

  @override
  String get vOccasionally => 'எப்போதாவது';

  @override
  String get vSometimes => 'சில சமயம்';

  @override
  String get vNeverDrink => 'ஒருபோதும் குடிப்பதில்லை';

  @override
  String get vRegularly => 'தொடர்ந்து';

  @override
  String get vImSober => 'நான் மது அருந்துவதில்லை';

  @override
  String get vSocially => 'சமூகச் சூழலில்';

  @override
  String get vNever => 'ஒருபோதும் இல்லை';

  @override
  String get vSocialSmoker => 'சமூகச் சூழலில் புகைப்பவர்';

  @override
  String get vSmokerWhenDrinking => 'மது அருந்தும்போது புகைப்பவர்';

  @override
  String get vNonSmoker => 'புகைப்பிடிக்காதவர்';

  @override
  String get vSmoker => 'புகைப்பிடிப்பவர்';

  @override
  String get vTryingToQuit => 'விட முயற்சிக்கிறேன்';

  @override
  String get vDaily => 'தினமும்';

  @override
  String get vWeekly => 'வாரந்தோறும்';

  @override
  String get vHighSchool => 'உயர்நிலைப் பள்ளி';

  @override
  String get vGradeSchool => 'தொடக்கப் பள்ளி';

  @override
  String get vDiploma => 'டிப்ளோமா';

  @override
  String get vUnderGraduate => 'இளங்கலை';

  @override
  String get vPostGraduate => 'முதுகலை';

  @override
  String get vDoctorate => 'முனைவர் பட்டம்';

  @override
  String get vCommunist => 'கம்யூனிஸ்ட்';

  @override
  String get vSocialist => 'சோஷலிஸ்ட்';

  @override
  String get vApolitical => 'அரசியல் சாராத';

  @override
  String get vModerate => 'மிதவாத';

  @override
  String get vNotInterested => 'ஆர்வம் இல்லை';

  @override
  String get vHaveKids => 'குழந்தைகள் உள்ளனர்';

  @override
  String get vDontHaveKids => 'குழந்தைகள் இல்லை';

  @override
  String get vDontWantKids => 'குழந்தைகள் வேண்டாம்';

  @override
  String get vWantKids => 'குழந்தைகள் வேண்டும்';

  @override
  String get vOpenToKids => 'குழந்தைகளுக்குத் தயார்';

  @override
  String get vNotSure => 'உறுதியாகத் தெரியவில்லை';

  @override
  String get vPreferNotToSay => 'சொல்ல விரும்பவில்லை';

  @override
  String get vAries => 'மேஷம்';

  @override
  String get vTaurus => 'ரிஷபம்';

  @override
  String get vGemini => 'மிதுனம்';

  @override
  String get vCancer => 'கடகம்';

  @override
  String get vLeo => 'சிம்மம்';

  @override
  String get vVirgo => 'கன்னி';

  @override
  String get vLibra => 'துலாம்';

  @override
  String get vScorpio => 'விருச்சிகம்';

  @override
  String get vSagittarius => 'தனுசு';

  @override
  String get vCapricorn => 'மகரம்';

  @override
  String get vAquarius => 'கும்பம்';

  @override
  String get vPisces => 'மீனம்';

  @override
  String get vHumanRights => 'மனித உரிமைகள்';

  @override
  String get vDisabilityRights => 'மாற்றுத்திறனாளிகள் உரிமைகள்';

  @override
  String get vFeminism => 'பெண்ணியம்';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'சுற்றுச்சூழல் பாதுகாப்பு';

  @override
  String get vLgbtqRights => 'LGBTQ உரிமைகள்';

  @override
  String get vImmigrantRights => 'புலம்பெயர்ந்தோர் உரிமைகள்';

  @override
  String get vEndReligiousHate => 'மத வெறுப்பை முடிவுக்குக் கொண்டுவா';

  @override
  String get vIndigenousRights => 'பழங்குடியினர் உரிமைகள்';

  @override
  String get vNeuroDiversity => 'நரம்பியல் பன்முகத்தன்மை';

  @override
  String get vVoterRights => 'வாக்காளர் உரிமைகள்';

  @override
  String get vReproductiveRights => 'இனப்பெருக்க உரிமைகள்';

  @override
  String get vAmbition => 'லட்சியம்';

  @override
  String get vConfidence => 'தன்னம்பிக்கை';

  @override
  String get vEmpathy => 'பரிவு';

  @override
  String get vHumor => 'நகைச்சுவை';

  @override
  String get vKindness => 'கருணை';

  @override
  String get vOpenness => 'திறந்த மனப்பான்மை';

  @override
  String get vOptimism => 'நம்பிக்கை';

  @override
  String get vSassiness => 'துடுக்குத்தனம்';

  @override
  String get vPlayfulness => 'விளையாட்டுத்தனம்';

  @override
  String get vLeadership => 'தலைமைத்துவம்';

  @override
  String get vHumility => 'பணிவு';

  @override
  String get vLoyalty => 'விசுவாசம்';

  @override
  String get vSarcasm => 'கிண்டல்';

  @override
  String get vGratitude => 'நன்றியுணர்வு';

  @override
  String get vCuriosity => 'ஆர்வம்';

  @override
  String get vEmotionalIntelligence => 'உணர்ச்சி நுண்ணறிவு';

  @override
  String get datingPreference => 'டேட்டிங் விருப்பம்';

  @override
  String get bffPreference => 'BFF விருப்பம்';

  @override
  String get whoWouldYouDate => 'யாருடன் டேட் செய்ய விரும்புகிறீர்கள்?';

  @override
  String get ageRange => 'வயது வரம்பு?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max வயது';
  }

  @override
  String get howFarAway => 'அவர்கள் எவ்வளவு தூரத்தில் உள்ளனர்?';

  @override
  String kilometersAway(String distance) {
    return '$distance கிலோமீட்டர் தொலைவில்';
  }

  @override
  String get yourInterests => 'உங்கள் ஆர்வங்கள்?';

  @override
  String get errorLoadingInterests => 'ஆர்வங்களை ஏற்ற முடியவில்லை';

  @override
  String get whichLanguages => 'நீங்கள் எந்த மொழிகளை அறிவீர்கள்?';

  @override
  String get selectLanguages => 'மொழிகளைத் தேர்வுசெய்';

  @override
  String get religionQuestion => 'மதம்';

  @override
  String get selectReligion => 'மதத்தைத் தேர்வுசெய்';

  @override
  String get relationshipTypeQuestion => 'உறவின் வகை?';

  @override
  String get relationshipTypeTitle => 'உறவின் வகை';

  @override
  String get selectType => 'வகையைத் தேர்வுசெய்';

  @override
  String get sexualOrientationQuestion => 'பாலியல் நாட்டம்?';

  @override
  String get sexualOrientationTitle => 'பாலியல் நாட்டம்';

  @override
  String get selectOrientation => 'நாட்டத்தைத் தேர்வுசெய்';

  @override
  String get datingIntentionQuestion => 'டேட்டிங் நோக்கம்?';

  @override
  String get datingIntentionTitle => 'டேட்டிங் நோக்கம்';

  @override
  String get selectIntention => 'நோக்கத்தைத் தேர்வுசெய்';

  @override
  String get filtersCleared => 'வடிகட்டிகள் அழிக்கப்பட்டன!';

  @override
  String get clearFilters => 'வடிகட்டிகளை அழி';

  @override
  String get filterByInterests => 'உங்கள் ஆர்வங்களால் வடிகட்டு';

  @override
  String get showMe => 'எனக்குக் காட்டு';

  @override
  String errUpdateFailed(String error) {
    return 'புதுப்பிக்க முடியவில்லை: $error';
  }

  @override
  String get religionViewTitle => 'மதப் பார்வை';

  @override
  String get sensitiveInfoNote =>
      'இது உங்கள் சுயவிவரத்தில் தோன்றும் முக்கியமான தகவல். இது முற்றிலும் விருப்பத்தேர்வு.';

  @override
  String get zodiacSignTitle => 'ராசி';

  @override
  String get doYouDrink => 'நீங்கள் மது அருந்துவீர்களா?';

  @override
  String get doYouSmoke => 'நீங்கள் புகைப்பிடிப்பீர்களா?';

  @override
  String get doYouWorkout => 'நீங்கள் உடற்பயிற்சி செய்வீர்களா?';

  @override
  String get educationLevelTitle => 'கல்வி நிலை';

  @override
  String get politicalViewTitle => 'அரசியல் நோக்கு';

  @override
  String get doYouHaveKids => 'உங்களுக்குக் குழந்தைகள் உள்ளனரா?';

  @override
  String get kidsPlanQuestion => 'குழந்தைகள் குறித்த உங்கள் திட்டம் என்ன?';

  @override
  String get pickYourPronoun => 'உங்கள் பெயர்ச்சொல்லைத் தேர்வுசெய்';

  @override
  String get pronounsBody =>
      'உங்கள் பெயர்ச்சொற்கள் என்ன? 3 ஐத் தேர்வுசெய்யுங்கள், எப்போது வேண்டுமானாலும் நீக்கலாம்.';

  @override
  String get showPronounOnProfile => 'என் சுயவிவரத்தில் பெயர்ச்சொல்லைக் காட்டு';

  @override
  String get causesTitle => 'நோக்கங்கள் & சமூகங்கள்';

  @override
  String get selectUpTo3Causes =>
      'உங்கள் மனதுக்கு நெருக்கமான 3 வரை தேர்வுசெய்யுங்கள்.';

  @override
  String get maxThreeOptions => 'அதிகபட்சம் 3 விருப்பங்களைத் தேர்வுசெய்யலாம்';

  @override
  String get personQualities => 'நபரின் பண்புகள்';

  @override
  String get chooseThreeQualities =>
      'தொடர்பை மேலும் வலுப்படுத்தும் 3 பண்புகளைத் தேர்வுசெய்யுங்கள்.';

  @override
  String get maxThreeQualities =>
      'அதிகபட்சம் 3 பண்புகளை மட்டுமே தேர்வுசெய்யலாம்.';

  @override
  String get howTallAreYou => 'உங்கள் உயரம் என்ன?';

  @override
  String get showsOnProfile => 'இது உங்கள் சுயவிவரத்தில் தோன்றும்';

  @override
  String get yourHeight => 'உங்கள் உயரம்';

  @override
  String get professionTitle => 'தொழில்';

  @override
  String get showProfessionOnProfile => 'உங்கள் சுயவிவரத்தில் தொழிலைக் காட்டு';

  @override
  String get titleLabel => 'பதவி';

  @override
  String get companyIndustry => 'நிறுவனம் (துறை)';

  @override
  String get educatedAt => 'கல்வி பயின்ற இடம்';

  @override
  String get showInstitutionOnProfile =>
      'உங்கள் சுயவிவரத்தில் நிறுவனத்தைக் காட்டு';

  @override
  String get institutionLabel => 'நிறுவனம்';

  @override
  String get graduationYear => 'பட்டப்படிப்பு ஆண்டு';

  @override
  String get enterInstitution => 'உங்கள் நிறுவனத்தின் பெயரை உள்ளிடவும்.';

  @override
  String get maxThreeLanguages => 'அதிகபட்சம் 3 மொழிகளைத் தேர்வுசெய்யலாம்';

  @override
  String get whatLookingFor => 'நீங்கள் எதைத் தேடுகிறீர்கள்?';

  @override
  String maxThreeForMode(String mode) {
    return 'தற்போதைய முறைக்கு ($mode) அதிகபட்சம் 3 விருப்பங்களைத் தேர்வுசெய்யலாம்.';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'விருப்பங்களைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get languagesIKnow => 'எனக்குத் தெரிந்த மொழிகள்';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get searchLanguages => 'மொழிகளைத் தேடு';

  @override
  String get suggested => 'பரிந்துரைக்கப்பட்டவை';

  @override
  String get allLanguages => 'அனைத்து மொழிகளும்';

  @override
  String get errorLoadingProfile => 'சுயவிவரத்தை ஏற்ற முடியவில்லை';

  @override
  String percentTrust(String percent) {
    return '$percent% நம்பிக்கை';
  }

  @override
  String get profileCompleted => 'சுயவிவரம் நிறைவு';

  @override
  String get completeProfile => 'சுயவிவரத்தை நிறைவு செய்';

  @override
  String get higherScoreHelps =>
      'அதிக மதிப்பெண் மேலும் உண்மையான\nபொருத்தங்களைப் பெற உதவும்';

  @override
  String get noBioYet => 'இன்னும் சுயவிவரக் குறிப்பு இல்லை.';

  @override
  String get askMe => 'என்னிடம் கேளுங்கள்';

  @override
  String get activeLabel => 'செயலில்';

  @override
  String get addReligion => 'மதத்தைச் சேர்';

  @override
  String get addZodiac => 'ராசியைச் சேர்';

  @override
  String get premium => 'பிரீமியம்';

  @override
  String get getNoticedSooner =>
      'விரைவில் கவனிக்கப்படுங்கள்,\n3 மடங்கு அதிக டேட்டுகளுக்குச் செல்லுங்கள்';

  @override
  String get upgrade => 'மேம்படுத்து';

  @override
  String get spotlight => 'ஸ்பாட்லைட்';

  @override
  String get standOut => 'தனித்து நில்';

  @override
  String get superSwipe => 'சூப்பர் ஸ்வைப்';

  @override
  String get getNoticed => 'கவனிக்கப்படுங்கள்';

  @override
  String get scoreBreakdown => 'மதிப்பெண் விவரம்';

  @override
  String get profilePhotoVerified => 'சுயவிவரப் புகைப்படம் சரிபார்க்கப்பட்டது';

  @override
  String get completedLabel => 'நிறைவு';

  @override
  String get profileDetails => 'சுயவிவர விவரங்கள்';

  @override
  String get incompleteLabel => 'முழுமையடையவில்லை';

  @override
  String get connectSocialAccounts => 'சமூக கணக்குகளை இணை';

  @override
  String get waysToImprove => 'மேம்படுத்தும் வழிகள்';

  @override
  String get verifyYourPhotos => 'உங்கள் புகைப்படங்களைச் சரிபார்';

  @override
  String get proveYoureReal =>
      'நீங்கள் உண்மையானவர் என்பதை மற்றவர்களுக்கு நிரூபியுங்கள்';

  @override
  String get addPromptsInterests =>
      'கேள்விகள், ஆர்வங்கள் மற்றும் பிற விவரங்களைச் சேர்';

  @override
  String get verificationDataSecure =>
      'உங்கள் சரிபார்ப்புத் தரவு பாதுகாப்பாக வைக்கப்படுகிறது, பொது சுயவிவரத்தில் பகிரப்படுவதில்லை. ';

  @override
  String get learnMore => 'மேலும் அறிக';

  @override
  String get improveYourProfile => 'உங்கள் சுயவிவரத்தை மேம்படுத்து';

  @override
  String errorSavingHometown(String error) {
    return 'சொந்த ஊரைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get searchCity => 'நகரத்தைத் தேடு';

  @override
  String get aboutYou => 'உங்களைப் பற்றி';

  @override
  String get bioPrompt =>
      'கூச்சப்பட வேண்டாம்! ஒரு சிறு குறிப்பில் உங்கள் ஆளுமையைப் பகிர இதுவே வாய்ப்பு.';

  @override
  String get textHereHint => 'இங்கே எழுதுங்கள்.....';

  @override
  String failedToSaveBio(String error) {
    return 'குறிப்பைச் சேமிக்க முடியவில்லை: $error';
  }

  @override
  String get selectYourInterests => 'உங்கள் ஆர்வங்களைத் தேர்வுசெய்';

  @override
  String get atLeast5Interests =>
      'குறைந்தது 5 ஆர்வங்களைத் தேர்வுசெய்யுங்கள். இது உங்களுக்கானவர்களைக் கண்டறிய உதவும்';

  @override
  String get searchForInterest => 'ஆர்வத்தைத் தேடு';

  @override
  String get noInterestsFound => 'ஆர்வங்கள் எதுவும் இல்லை';

  @override
  String get failedLoadInterests =>
      'ஆர்வங்களை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get maxTenInterests => 'அதிகபட்சம் 10 ஆர்வங்களைத் தேர்வுசெய்யலாம்';

  @override
  String get minFiveInterests => 'குறைந்தது 5 ஆர்வங்களைத் தேர்வுசெய்யவும்';

  @override
  String errorSavingInterests(String error) {
    return 'ஆர்வங்களைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get lifeStyle => 'வாழ்க்கை முறை';

  @override
  String get lifestylePrompt =>
      'உங்கள் பழக்கங்களைப் பற்றிச் சொல்லுங்கள். உங்களுக்குப் பொருத்தமானதைத் தேர்வுசெய்யுங்கள்.';

  @override
  String get noLifestyleOptions => 'வாழ்க்கை முறை விருப்பங்கள் இல்லை';

  @override
  String get failedLoadLifestyle =>
      'வாழ்க்கை முறை விருப்பங்களை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get selectEachCategory =>
      'ஒவ்வொரு பிரிவுக்கும் ஒரு விருப்பத்தைத் தேர்வுசெய்யுங்கள், அல்லது தவிர்க்க அனைத்தையும் அழிக்கவும்.';

  @override
  String get findYourCity => 'உங்கள் தற்போதைய நகரத்தைக் கண்டறியுங்கள்';

  @override
  String errorSavingLocation(String error) {
    return 'இருப்பிடத்தைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get permissionRequired => 'அனுமதி தேவை';

  @override
  String get permissionRequiredBody =>
      'ஆப்ஸ் சரியாக இயங்க இந்த அனுமதி தேவை. அமைப்புகளில் இதை இயக்கவும்.';

  @override
  String get cameraAccess => 'கேமரா அணுகல்';

  @override
  String get photoLibrary => 'புகைப்பட நூலகம்';

  @override
  String get locationAccess => 'இருப்பிட அணுகல்';

  @override
  String get notificationAccess => 'அறிவிப்பு அணுகல்';

  @override
  String get microphoneAccess => 'ஒலிவாங்கி அணுகல்';

  @override
  String get unknownAccess => 'தெரியாத அணுகல்';

  @override
  String get cameraReason =>
      'சுயவிவரப் புகைப்படங்கள் எடுக்கவும் அடையாளத்தைச் சரிபார்க்கவும்.';

  @override
  String get photoReason => 'உங்கள் கேலரியிலிருந்து புகைப்படங்களை பதிவேற்ற.';

  @override
  String get locationReason => 'அருகிலுள்ள பொருத்தங்களைக் காட்ட.';

  @override
  String get notificationReason =>
      'புதிய பொருத்தங்கள் மற்றும் செய்திகளைத் தெரிவிக்க.';

  @override
  String get microphoneReason => 'குரல் மற்றும் காணொலி உரையாடலுக்கு.';

  @override
  String get appPermissions => 'ஆப்ஸ் அனுமதிகள்';

  @override
  String get chooseYourPrompt => 'உங்கள் கேள்வியைத் தேர்வுசெய்';

  @override
  String get selectUpTo3Prompts =>
      'உங்கள் ஆளுமையைக் காட்ட 3 கேள்விகள் வரை தேர்வுசெய்யுங்கள்.';

  @override
  String get maxThreePrompts =>
      'அதிகபட்சம் 3 கேள்விகளை மட்டுமே தேர்வுசெய்யலாம்.';

  @override
  String get areYouSure => 'நிச்சயமாகவா?';

  @override
  String get removeThisPrompt => 'இந்தக் கேள்வியை நீக்க வேண்டுமா?';

  @override
  String get selectThreePrompts => 'தொடர 3 கேள்விகளைத் தேர்வுசெய்யுங்கள்.';

  @override
  String get selectOnePrompt => 'குறைந்தது 1 கேள்வியைத் தேர்வுசெய்யுங்கள்.';

  @override
  String selectNMorePrompts(String count) {
    return 'தொடர மேலும் $count கேள்விகளைத் தேர்வுசெய்யுங்கள்';
  }

  @override
  String get noPromptsForCategory => 'இந்தப் பிரிவுக்கு கேள்விகள் இல்லை.';

  @override
  String get typeYourAnswer => 'உங்கள் பதிலை எழுதுங்கள்...';

  @override
  String get addPrompt => 'கேள்வியைச் சேர்';

  @override
  String failedToLoadPrompts(String error) {
    return 'கேள்விகளை ஏற்ற முடியவில்லை: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'கேள்விகளைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get communityGuidelines => 'சமூக வழிகாட்டுதல்கள்';

  @override
  String get agreeAndContinue => 'ஏற்று தொடரவும்';

  @override
  String get termsByContinuePrefix => 'தொடர்வதன் மூலம், நீங்கள் எங்கள் ';

  @override
  String get guidelinesIntro =>
      'எங்கள் சமூகத்திற்கு வரவேற்கிறோம்! அனைவருக்கும் பாதுகாப்பான, நேர்மறையான அனுபவத்திற்காக இந்த எளிய வழிகாட்டுதல்களைப் பின்பற்றுங்கள்.';

  @override
  String get beKindTitle => 'கருணையுடனும் மரியாதையுடனும் இருங்கள்';

  @override
  String get beKindBody =>
      'நீங்கள் எப்படி நடத்தப்பட விரும்புகிறீர்களோ அப்படியே மற்றவர்களை நடத்துங்கள். வரவேற்கும் சூழலை நாம் அனைவரும் சேர்ந்தே உருவாக்குகிறோம்.';

  @override
  String get stayAuthenticTitle => 'உண்மையாக இருங்கள்';

  @override
  String get stayAuthenticBody =>
      'உங்கள் சுயவிவரத்திலும் உரையாடலிலும் உண்மையாக இருங்கள். உண்மைத்தன்மையையும் நிஜமான தொடர்புகளையும் நாங்கள் மதிக்கிறோம்.';

  @override
  String get prioritizeSafetyTitle => 'பாதுகாப்புக்கு முன்னுரிமை';

  @override
  String get prioritizeSafetyBody =>
      'முக்கியமான, தனிப்பட்ட தகவல்களைப் பகிர வேண்டாம். உங்களையும் சமூகத்தில் உள்ள மற்றவர்களையும் பாதுகாக்கவும்.';

  @override
  String get noHateTitle => 'வெறுப்புப் பேச்சு கூடாது';

  @override
  String get noHateBody =>
      'தொல்லை, மிரட்டல், சட்டவிரோத உள்ளடக்கம் இங்கு அனுமதிக்கப்படாது. சமூகத்தைப் பாதுகாக்க உதவுங்கள்.';

  @override
  String get helpKeepSafeTitle => 'எங்களைப் பாதுகாக்க உதவுங்கள்';

  @override
  String get helpKeepSafeBody =>
      'எங்கள் வழிகாட்டுதலை மீறும் ஒன்றைக் கண்டால் புகாரளியுங்கள். உங்கள் உதவி விலைமதிப்பற்றது.';

  @override
  String get genuineIntentTitle => 'உண்மையான நோக்கத்துடன் டேட் செய்யுங்கள்';

  @override
  String get genuineIntentBody =>
      'நாங்கள் நிஜமான தொடர்புகளுக்காகவே இருக்கிறோம். போலி அடையாளம் அல்லது கட்டாயம் அனுமதிக்கப்படாது. மோசடி, ஆள்மாறாட்டம், தனிப்பட்ட அல்லது நிதி ஆதாயத்திற்கான எந்தக் கையாளுதலும் அனுமதிக்கப்படாது.';

  @override
  String get adultsOnlyTitle => 'பெரியவர்களுக்கு மட்டும்';

  @override
  String get adultsOnlyBody =>
      'Blindly பயன்படுத்த உங்கள் வயது 18 அல்லது அதற்கு மேல் இருக்க வேண்டும். தனியாக இருக்கும் அல்லது ஆடையின்றி உள்ள சிறார்களின் புகைப்படங்கள் அனுமதிக்கப்படாது — உங்கள் சிறுவயதுப் படங்களும் அடக்கம், அவை எவ்வளவு அழகாக இருந்தாலும்.';

  @override
  String get letsIntroduceYou => 'உங்களை அறிமுகப்படுத்துவோம்!';

  @override
  String get needNameForProfile => 'உங்கள் சுயவிவரத்தை உருவாக்க பெயர் தேவை';

  @override
  String get nameLabel => 'பெயர்';

  @override
  String get enterYourName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get needDobForProfile =>
      'உங்கள் சுயவிவரத்தை உருவாக்க பிறந்த தேதி தேவை';

  @override
  String get dateOfBirth => 'பிறந்த தேதி';

  @override
  String get birthdayNote =>
      'உங்கள் பிறந்த தேதியிலிருந்து வயது கணக்கிடப்பட்டு சுயவிவரத்தில் காட்டப்படும். உங்கள் முழுப் பெயர் பொதுவில் தெரியாது';

  @override
  String failedToSaveData(String error) {
    return 'தரவைச் சேமிக்க முடியவில்லை: $error';
  }

  @override
  String get whatsYourGender => 'உங்கள் பாலினம் என்ன?';

  @override
  String get genderHelpsMatches =>
      'இது உங்களுக்குப் பொருத்தமான சுயவிவரங்களைக் காட்டவும் பொருத்தங்களைக் கண்டறியவும் உதவும்';

  @override
  String get vNonBinary => 'நான்-பைனரி';

  @override
  String get vPreferNot => 'சொல்ல விரும்பவில்லை';

  @override
  String failedToSaveGender(String error) {
    return 'பாலினத்தைச் சேமிக்க முடியவில்லை: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'உங்கள் சுயவிவரத்திற்குப் புகைப்படங்களைப் பதிவேற்ற $permission அனுமதி வழங்கவும்.';
  }

  @override
  String get gallery => 'கேலரி';

  @override
  String get camera => 'கேமரா';

  @override
  String get photoNotAccepted => 'புகைப்படம் ஏற்கப்படவில்லை';

  @override
  String get couldNotVerifyPhoto =>
      'உங்கள் புகைப்படத்தைச் சரிபார்க்க முடியவில்லை, ஏனெனில்:';

  @override
  String get tryDifferentPhoto =>
      'வேறு புகைப்படத்தைப் பதிவேற்ற முயற்சிக்கவும்.';

  @override
  String get addPhotos => 'புகைப்படங்களைச் சேர்';

  @override
  String get addAtLeast2Photos =>
      'பொருத்தங்கள் கிடைக்க குறைந்தது 2 புகைப்படங்களைச் சேர்க்கவும்! முதலாவது முதன்மைப் படம்';

  @override
  String get tapPhotoToEdit =>
      'சேர்த்த புகைப்படத்தைத் தட்டி திருத்தவும் அல்லது நீக்கவும்.';

  @override
  String get addOneMorePhoto => 'மேலும் ஒரு புகைப்படத்தைச் சேர்க்கவும்';

  @override
  String get addMorePhotos => 'மேலும் புகைப்படங்களைச் சேர்';

  @override
  String get mainPhotoBadge => 'முதன்மை';

  @override
  String get editPhoto => 'புகைப்படத்தைத் திருத்து';

  @override
  String get removePhoto => 'புகைப்படத்தை நீக்கு';

  @override
  String get realConnectionsStartHere =>
      'நிஜமான தொடர்புகள் இங்கிருந்தே தொடங்குகின்றன!';

  @override
  String get createAnAccount => 'கணக்கை உருவாக்கு';

  @override
  String get iHaveAnAccount => 'என்னிடம் கணக்கு உள்ளது';

  @override
  String get agreeToOurTerms => 'நீங்கள் எங்கள் விதிமுறைகளை ஏற்கிறீர்கள்';

  @override
  String get findPeopleNearYou => 'அருகில் உள்ளவர்களைக் கண்டறியுங்கள்';

  @override
  String get locationAccessBody =>
      'உங்கள் பகுதியில் உள்ள சாத்தியமான பொருத்தங்களைக் காட்ட\nஉங்கள் இருப்பிடம் தேவை. உண்மைத்தன்மை மற்றும் பாதுகாப்பிற்காக\nஉங்கள் பொதுவான இடத்தையும் இது சரிபார்க்கிறது. கவலை வேண்டாம்,\nஉங்கள் சரியான இருப்பிடம் ஒருபோதும் பகிரப்படாது';

  @override
  String get allowLocationAccess => 'இருப்பிட அணுகலை அனுமதி';

  @override
  String get events => 'நிகழ்வுகள்';

  @override
  String get booked => 'பதிவு செய்யப்பட்டவை';

  @override
  String get upcoming => 'வரவிருப்பவை';

  @override
  String get noEventsFound => 'நிகழ்வுகள் எதுவும் இல்லை';

  @override
  String get noEventsNearby =>
      'தற்போது அருகில் நிகழ்வுகள் எதுவும் இல்லை. பின்னர் பாருங்கள் அல்லது இருப்பிடத்தை மாற்றுங்கள்.';

  @override
  String get refreshEvents => 'நிகழ்வுகளைப் புதுப்பி';

  @override
  String get bookedEvents => 'பதிவு செய்யப்பட்ட நிகழ்வுகள்';

  @override
  String get ticketsAndReservations => 'உங்கள் டிக்கெட்டுகளும் முன்பதிவுகளும்';

  @override
  String get upcomingEvents => 'வரவிருக்கும் நிகழ்வுகள்';

  @override
  String get eventsYouAreInterested => 'நீங்கள் ஆர்வம் காட்டிய நிகழ்வுகள்';

  @override
  String get incomingVideoCall => 'உள்வரும் காணொலி அழைப்பு';

  @override
  String get incomingVoiceCall => 'உள்வரும் குரல் அழைப்பு';

  @override
  String get ringing => 'ஒலிக்கிறது...';

  @override
  String get speaker => 'ஒலிபெருக்கி';

  @override
  String get mute => 'முடக்கு';

  @override
  String get unmute => 'ஒலி இயக்கு';

  @override
  String get videoOff => 'காணொலி அணை';

  @override
  String get video => 'காணொலி';

  @override
  String get decline => 'நிராகரி';

  @override
  String get flip => 'கேமராவை மாற்று';

  @override
  String get callEnded => 'அழைப்பு முடிந்தது';

  @override
  String get howWasCallQuality => 'அழைப்பின் தரம் எப்படி இருந்தது?';

  @override
  String get switchToVideoCall => 'காணொலி அழைப்புக்கு மாறவா?';

  @override
  String get otherWantsVideoOn => 'மற்றவர் காணொலியை இயக்க விரும்புகிறார்.';

  @override
  String get switchToVoiceCall => 'குரல் அழைப்புக்கு மாறவா?';

  @override
  String get otherWantsVideoOff => 'மற்றவர் காணொலியை அணைக்க விரும்புகிறார்.';

  @override
  String get reject => 'நிராகரி';

  @override
  String get accept => 'ஏற்று';

  @override
  String get incomingVideoCallTitle => 'உள்வரும் காணொலி அழைப்பு';

  @override
  String get incomingVoiceCallTitle => 'உள்வரும் குரல் அழைப்பு';

  @override
  String get errorTitle => 'பிழை';

  @override
  String get successTitle => 'வெற்றி';

  @override
  String get great => 'நன்று!';

  @override
  String get peoples => 'நபர்கள்';

  @override
  String get chatTab => 'அரட்டை';

  @override
  String get editProfileTitle => 'சுயவிவரத்தைத் திருத்து';

  @override
  String percentComplete(String percent) {
    return '$percent% நிறைவு';
  }

  @override
  String get profileStrength => 'சுயவிவர வலிமை';

  @override
  String get photosAndVideos => 'புகைப்படங்களும் காணொலிகளும்';

  @override
  String get pickSomeTrueYou =>
      'உங்கள் உண்மையான தன்மையைக் காட்டுபவற்றைத் தேர்வுசெய்யுங்கள்.';

  @override
  String get holdDragReorder => 'வரிசையை மாற்ற ஊடகத்தை அழுத்தி இழுக்கவும்';

  @override
  String get bestPhoto => 'சிறந்த புகைப்படம்';

  @override
  String get aboutYouSection => 'உங்களைப் பற்றி';

  @override
  String get aboutYouHint => 'உங்களைப் பற்றி...';

  @override
  String get writeFunIntro => 'ஒரு சுவாரஸ்யமான அறிமுகம் எழுதுங்கள்.';

  @override
  String get letPeopleKnowDate =>
      'உங்களுடன் டேட் செய்வது எப்படி இருக்கும் என்பதைச் சொல்லுங்கள்.';

  @override
  String get addAPrompt => 'ஒரு கேள்வியைச் சேர்';

  @override
  String get prompts => 'கேள்விகள்';

  @override
  String get prompt => 'கேள்வி';

  @override
  String get addVoiceIntro => 'குரல் அறிமுகத்தைச் சேர்';

  @override
  String get letPeopleHearVoice => 'உங்கள் குரலை மற்றவர்கள் கேட்கட்டும்.';

  @override
  String get reRecordIntro => 'அறிமுகத்தை மீண்டும் பதிவுசெய்';

  @override
  String get deleteVoiceIntro => 'குரல் அறிமுகத்தை நீக்கவா?';

  @override
  String get removeVoiceIntroBody =>
      'இது உங்கள் சுயவிவரத்திலிருந்து குரல் அறிமுகத்தை நீக்கும்.';

  @override
  String get interests => 'ஆர்வங்கள்';

  @override
  String get addFavoriteInterests => 'உங்கள் விருப்ப ஆர்வங்களைச் சேர்';

  @override
  String get getSpecificThingsYouLove =>
      'நீங்கள் விரும்புவதைப் பற்றித் தெளிவாகச் சொல்லுங்கள்.';

  @override
  String get lifestyle => 'வாழ்க்கை முறை';

  @override
  String get addLifestylePrefs => 'உங்கள் வாழ்க்கை முறை விருப்பங்களைச் சேர்';

  @override
  String get habitsAndPrefs => 'உங்கள் பழக்கங்களும் விருப்பங்களும்.';

  @override
  String get iAmLookingFor => 'நான் தேடுவது';

  @override
  String get addWhatLookingFor => 'நீங்கள் தேடுவதைச் சேர்க்கவும்';

  @override
  String get letOthersKnowWant =>
      'நீங்கள் எதைத் தேடுகிறீர்கள் என்பதை மற்றவர்களுக்குத் தெரியப்படுத்துங்கள்';

  @override
  String get qualitiesIValue => 'நான் மதிக்கும் பண்புகள்';

  @override
  String get addQualitiesYouValue => 'நீங்கள் மதிக்கும் பண்புகளைச் சேர்';

  @override
  String get chooseThreeQualitiesValue =>
      'ஒருவரிடம் நீங்கள் மதிக்கும் 3 பண்புகள் வரை தேர்வுசெய்யுங்கள்';

  @override
  String get myCausesSection => 'என் நோக்கங்களும் சமூகங்களும்';

  @override
  String get addYourCauses => 'உங்கள் நோக்கங்களையும் சமூகங்களையும் சேர்';

  @override
  String get addUpTo3Causes =>
      'உங்கள் மனதுக்கு நெருக்கமான 3 நோக்கங்கள் வரை சேர்க்கவும்.';

  @override
  String get addLanguagesYouKnow => 'உங்களுக்குத் தெரிந்த மொழிகளைச் சேர்';

  @override
  String get moreAboutYou => 'உங்களைப் பற்றி மேலும்';

  @override
  String get heightLabel => 'உயரம்';

  @override
  String get genderLabel => 'பாலினம்';

  @override
  String get pronounsLabel => 'பெயர்ச்சொற்கள்';

  @override
  String get pickYourPronouns => 'உங்கள் பெயர்ச்சொற்களைத் தேர்வுசெய்';

  @override
  String get addYourPronouns => 'உங்கள் பெயர்ச்சொற்களைச் சேர்';

  @override
  String get workLabel => 'வேலை';

  @override
  String get educationLevelLabel => 'கல்வி நிலை';

  @override
  String get hometownLabel => 'சொந்த ஊர்';

  @override
  String get locationLabel => 'இருப்பிடம்';

  @override
  String get exerciseLabel => 'உடற்பயிற்சி';

  @override
  String get drinkingLabel => 'மது';

  @override
  String get smokingLabel => 'புகைப்பழக்கம்';

  @override
  String get kidsLabel => 'குழந்தைகள்';

  @override
  String get kidsPreferenceLabel => 'குழந்தைகள் குறித்த விருப்பம்';

  @override
  String get politicsLabel => 'அரசியல்';

  @override
  String get zodiacLabel => 'ராசி';

  @override
  String get educatedAtLabel => 'கல்வி பயின்ற இடம்';

  @override
  String get connectedAccounts => 'இணைக்கப்பட்ட கணக்குகள்';

  @override
  String get connectMySpotify => 'என் Spotify ஐ இணை';

  @override
  String get showFavoriteMusic => 'உங்கள் விருப்ப இசையைக் காட்டு';

  @override
  String get spotifyNote =>
      'உங்கள் விருப்ப Spotify கலைஞர்களை சுயவிவரத்தில் காட்டி, மற்றவர்களுடன் பொதுவானதை Blindly முன்னிலைப்படுத்த அனுமதியுங்கள்.';

  @override
  String get verification => 'சரிபார்ப்பு';

  @override
  String get verified => 'சரிபார்க்கப்பட்டது';

  @override
  String get invalidLocation => 'தவறான இருப்பிடம்';

  @override
  String get locationFound => 'இருப்பிடம் கண்டறியப்பட்டது';

  @override
  String get alreadyVerified => 'நீங்கள் ஏற்கனவே சரிபார்க்கப்பட்டுள்ளீர்கள்';

  @override
  String get verificationSuccessful => 'சரிபார்ப்பு வெற்றி';

  @override
  String get documentNotVerified => 'ஆவணத்தைச் சரிபார்க்க முடியவில்லை.';

  @override
  String get verificationFailed => 'சரிபார்ப்பு தோல்வி';

  @override
  String get veriffReason =>
      'உங்கள் அடையாளத்தைச் சரிபார்க்க முடியவில்லை. Veriff கூறிய காரணம்:';

  @override
  String get tryClearerImage => 'தெளிவான படத்துடன் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get veriffWaiting =>
      'Veriff முடிந்தது. புதுப்பிப்புக்காகக் காத்திருக்கிறோம்...';

  @override
  String get verificationSubmitted =>
      'சரிபார்ப்பு சமர்ப்பிக்கப்பட்டது! உங்கள் அடையாளம் பரிசீலிக்கப்படுகிறது...';

  @override
  String get verifyYourProfile => 'உங்கள் சுயவிவரத்தைச் சரிபார்';

  @override
  String get youAreVerified => 'நீங்கள் சரிபார்க்கப்பட்டீர்கள்!';

  @override
  String get quickCheckSafe => 'உங்கள் பாதுகாப்பிற்கான ஒரு விரைவான சோதனை';

  @override
  String get identityConfirmed => 'உங்கள் அடையாளம் உறுதிசெய்யப்பட்டது.';

  @override
  String get veriffExplainer =>
      'உங்கள் அடையாளத்தை உறுதிசெய்ய, பாதுகாப்பான ஆவண ஸ்கேனிங்கிற்கு Veriff ஐப் பயன்படுத்துகிறோம்.';

  @override
  String get verifyingResults => 'முடிவுகள் சரிபார்க்கப்படுகின்றன...';

  @override
  String get verificationComplete => 'சரிபார்ப்பு நிறைவு';

  @override
  String get tapToScanDocument => 'ஆவணத்தை ஸ்கேன் செய்யத் தட்டவும்';

  @override
  String get prepareIdCard => 'உங்கள் அடையாள அட்டையைத் தயாராக வைத்திருங்கள்';

  @override
  String get ensureGoodLighting => 'நல்ல வெளிச்சம் இருப்பதை உறுதிசெய்யுங்கள்';

  @override
  String get readyForSelfie => 'விரைவான செல்ஃபிக்குத் தயாராக இருங்கள்';

  @override
  String get processing => 'செயலாக்கப்படுகிறது...';

  @override
  String get startVerification => 'சரிபார்ப்பைத் தொடங்கு';

  @override
  String get poweredByVeriff => 'Veriff வழங்குகிறது';

  @override
  String get alignWithCamera => 'கேமராவுடன் உங்களை சரியாக நிறுத்துங்கள்';

  @override
  String get cameraPermissionRequired => 'சரிபார்ப்பிற்கு கேமரா அனுமதி தேவை.';

  @override
  String get noCameraFound => 'சாதனத்தில் கேமரா இல்லை.';

  @override
  String get reviewingYourPhotos => 'உங்கள் புகைப்படங்களைப் பரிசீலிக்கிறோம்';

  @override
  String get verificationInProgress =>
      'உங்கள் சுயவிவரச் சரிபார்ப்பு நடைபெறுகிறது. இது சில வினாடிகள் ஆகும்.';

  @override
  String get verifiedSuccessfully => 'வெற்றிகரமாகச் சரிபார்க்கப்பட்டது!';

  @override
  String get profileVerificationDone =>
      'சுயவிவரச் சரிபார்ப்பு வெற்றிகரமாக முடிந்தது';

  @override
  String get gotIt => 'புரிந்தது';

  @override
  String get copyThisPose => 'இந்த நிலையைப் பின்பற்றுங்கள்';

  @override
  String get selfieVerification => 'செல்ஃபி சரிபார்ப்பு';

  @override
  String get proveRealDeal => 'நீங்கள் உண்மையானவர்\nஎன்பதை நிரூபியுங்கள்';

  @override
  String get quickHelpsSafe =>
      'இந்த விரைவான சோதனை எங்கள் சமூகத்தைப் பாதுகாப்பாகவும் உண்மையாகவும் வைத்திருக்கிறது';

  @override
  String get getVerifiedBadge => 'சரிபார்க்கப்பட்ட பேட்ஜ் பெறுங்கள்';

  @override
  String get buildTrustBody =>
      'மற்றவர்களின் நம்பிக்கையைப் பெறுங்கள், நீங்கள் உண்மையானவர் என்பதைக் காட்டுங்கள்.';

  @override
  String get keepCommunitySafe => 'சமூகத்தைப் பாதுகாப்பாக வையுங்கள்';

  @override
  String get weedOutFakes =>
      'போலி சுயவிவரங்களையும் பாட்களையும் நீக்க உதவுங்கள்.';

  @override
  String get copySimplePose => 'ஓர் எளிய நிலையைப் பின்பற்றுங்கள்';

  @override
  String get quickSelfieConfirm =>
      'உங்கள் அடையாளத்தை உறுதிசெய்ய ஒரு விரைவான செல்ஃபி எடுப்பீர்கள்';

  @override
  String get selfieNotOnProfile =>
      'குறிப்பு: உங்கள் செல்ஃபி சரிபார்ப்புக்கு மட்டுமே, சுயவிவரத்தில் தோன்றாது';

  @override
  String get getVerified => 'சரிபார்க்கப்படுங்கள்';

  @override
  String get voiceIntroTooShort =>
      'குரல் அறிமுகம் குறைந்தது 1 வினாடி இருக்க வேண்டும்';

  @override
  String get recordVoiceIntroFirst => 'ஒரு குரல் அறிமுகத்தைப் பதிவுசெய்யவும்';

  @override
  String get recordingBetween1And30 =>
      'பதிவு 1 முதல் 30 வினாடிகளுக்குள் இருக்க வேண்டும்';

  @override
  String get recordShortIntro => 'ஒரு சிறு அறிமுகத்தைப் பதிவுசெய்';

  @override
  String get personalityShine =>
      'உங்கள் ஆளுமை பிரகாசிக்கட்டும். 30 வினாடி சிறு அறிமுகத்தைப் பதிவுசெய்யுங்கள்.';

  @override
  String get recordAgain => 'மீண்டும் பதிவுசெய்';

  @override
  String get voicePromptsHelp =>
      'குரல் அறிமுகம் உங்களைத் தனித்துக் காட்டி ஆழமான தொடர்புகளை உருவாக்கும். நீங்கள் யார் என்பதைப் பகிருங்கள்';

  @override
  String get threeXMatches => 'குரல் பதிவால் 3 மடங்கு அதிக பொருத்தங்கள்';

  @override
  String get startConversationNaturally => 'உரையாடலை இயல்பாகத் தொடங்குங்கள்';

  @override
  String get showYourPersonality => 'உங்கள் ஆளுமையைக் காட்டுங்கள்';

  @override
  String get saveAndContinue => 'சேமித்துத் தொடரவும்';

  @override
  String failedUploadVoice(String error) {
    return 'குரல் அறிமுகத்தைப் பதிவேற்ற முடியவில்லை: $error';
  }

  @override
  String get failedToStartRecording => 'பதிவைத் தொடங்க முடியவில்லை';

  @override
  String get failedToStopRecording => 'பதிவை நிறுத்த முடியவில்லை';

  @override
  String get failedToPlayAudio => 'ஒலியை இயக்க முடியவில்லை';

  @override
  String get navLikes => 'லைக்ஸ்';

  @override
  String get photoReasonNoFace =>
      'தெளிவான முகம் கிடைக்கவில்லை. முகம் தெரியும் படத்தைப் பயன்படுத்தவும்.';

  @override
  String get photoReasonGroupPhoto =>
      'இந்தப் படத்தில் ஒருவருக்கு மேல் உள்ளனர். தனிப் படத்தைப் பயன்படுத்தவும்.';

  @override
  String get photoReasonFaceTooSmall =>
      'இந்தப் படத்தில் உங்கள் முகம் மிகச் சிறியதாக உள்ளது. அருகில் எடுக்கவும்.';

  @override
  String get photoReasonUnsafe =>
      'இந்தப் படம் எங்கள் விதிமுறைகளுக்கு உட்படவில்லை.';

  @override
  String get photoReasonBadImage =>
      'இந்தக் கோப்பைப் படிக்க முடியவில்லை. JPG அல்லது PNG முயற்சிக்கவும்.';

  @override
  String get photoReasonTooLarge =>
      'இந்தப் படம் மிகப் பெரியது. சிறிய படத்தை முயற்சிக்கவும்.';

  @override
  String get photoReasonUnavailable =>
      'தற்போது இந்தப் படத்தைச் சரிபார்க்க முடியவில்லை.';

  @override
  String get photoTryAgainLater =>
      'இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get photoLoadFailed => 'உங்கள் படங்களை ஏற்ற முடியவில்லை.';

  @override
  String get photoSaveFailed =>
      'படங்களைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String photosNotAdded(int count) {
    return '$count படங்களைச் சேர்க்க முடியவில்லை:';
  }

  @override
  String get photosExpired =>
      'சில படங்களின் கால அவகாசம் முடிந்ததால் நீக்கப்பட்டன. மீண்டும் சேர்க்கவும்.';

  @override
  String get spotlightHeadline => 'Be the first card they see';

  @override
  String get spotlightExplainer =>
      'For as long as your spotlight runs, you sit at the top of the deck for everyone in your district — even people whose filters you don\'t match.';

  @override
  String spotlightDistrictLine(String district) {
    return 'Your district: $district';
  }

  @override
  String get spotlightDistrictUnknown => 'Working out where you are…';

  @override
  String get spotlightChooseDuration => 'Choose how long';

  @override
  String spotlightMinutes(String count) {
    return '$count minutes';
  }

  @override
  String get spotlightOneHour => '1 hour';

  @override
  String spotlightPrice(String amount) {
    return '₹$amount';
  }

  @override
  String get spotlightBuy => 'Purchase';

  @override
  String get spotlightExtend => 'Extend spotlight';

  @override
  String spotlightLiveIn(String district) {
    return 'Live in $district';
  }

  @override
  String spotlightTimeLeft(String time) {
    return '$time left';
  }

  @override
  String get spotlightSuccess => 'You\'re in the spotlight';

  @override
  String get spotlightNoDistrict =>
      'We couldn\'t work out which district you\'re in. Turn location on and try again.';

  @override
  String get spotlightFailed => 'That didn\'t go through. Please try again.';

  @override
  String get spotlightTestPurchase =>
      'No payment is taken yet. This completes the purchase for testing.';

  @override
  String get spotlightRuleFilters =>
      'Filters are ignored — age, distance, interests, everything except who they asked to see.';

  @override
  String get spotlightRuleAudience =>
      'Only people in the same district as you.';

  @override
  String get spotlightRuleSkipped =>
      'People who already swiped you, matched you or blocked you will not see you again.';
}
