// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'package:blindly_dating_app/l10n/app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get appLanguageTitle => 'ऐप की भाषा';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get authTitlePhone => 'अपना नंबर बताएं';

  @override
  String get authTitleVerifyNumber => 'अपना नंबर सत्यापित करें';

  @override
  String get authTitleEmail => 'ईमेल से लॉगिन करें';

  @override
  String get authTitleVerifyEmail => 'अपना ईमेल सत्यापित करें';

  @override
  String get authTitleApple => 'Apple से लॉगिन करें';

  @override
  String get loginTagline => 'एक प्यारी ज़िंदगी में लॉगिन करें';

  @override
  String get continueWithGoogle => 'Google से जारी रखें';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get termsSignupPrefix => 'साइन अप करके, आप हमारी ';

  @override
  String get termsContinuePrefix => 'जारी रखकर, आप हमारी ';

  @override
  String get termsWord => 'शर्तों';

  @override
  String get termsBridge =>
      ' से सहमत हैं। हम आपका डेटा कैसे उपयोग करते हैं, यह देखें हमारी ';

  @override
  String get privacyPolicyWord => 'गोपनीयता नीति';

  @override
  String get termsSuffix => ' में।';

  @override
  String get phoneRationale =>
      'हम फ़ोन नंबर सिर्फ़ यह पक्का करने के लिए इस्तेमाल करते हैं कि Blindly पर हर कोई असली है';

  @override
  String get countryLabel => 'देश';

  @override
  String get phoneNumberLabel => 'फ़ोन नंबर';

  @override
  String get phoneHint => 'जैसे 9876543210';

  @override
  String otpSentPhone(String phone) {
    return 'हमने $phone पर मैसेज से भेजा कोड डालें। ';
  }

  @override
  String get changeNumber => 'नंबर बदलें';

  @override
  String otpSentEmail(String email) {
    return 'हमने $email पर ईमेल से भेजा कोड डालें। ';
  }

  @override
  String get changeEmail => 'ईमेल बदलें';

  @override
  String get resendCode => 'कोड फिर भेजें';

  @override
  String codeArrivesIn(int seconds) {
    return 'कोड $seconds सेकंड में आ जाना चाहिए';
  }

  @override
  String get otpSentSuccess => 'OTP भेज दिया गया';

  @override
  String get loginDetailsSubtitle => 'कृपया नीचे अपने लॉगिन विवरण डालें';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get errEnterPhone => 'कृपया अपना फ़ोन नंबर डालें';

  @override
  String get errPhoneDigitsOnly => 'फ़ोन नंबर में सिर्फ़ अंक होने चाहिए';

  @override
  String get errInvalidPhone => 'कृपया एक मान्य फ़ोन नंबर डालें';

  @override
  String get errInvalidPhoneIndia =>
      'कृपया 6-9 से शुरू होने वाला मान्य 10-अंकों का भारतीय फ़ोन नंबर डालें';

  @override
  String get errInvalidPhone10Digit =>
      'कृपया मान्य 10-अंकों का फ़ोन नंबर डालें';

  @override
  String get errEnterCompleteOtp => 'कृपया पूरा OTP डालें';

  @override
  String get errEnterEmail => 'कृपया अपना ईमेल डालें';

  @override
  String get errInvalidEmail => 'कृपया एक मान्य ईमेल पता डालें';

  @override
  String get errFillAllFields => 'कृपया सभी फ़ील्ड भरें';

  @override
  String get errPasswordMin => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get errTooManyAttempts =>
      'बहुत ज़्यादा कोशिशें। कृपया कुछ देर बाद दोबारा कोशिश करें।';

  @override
  String errCreateProfile(String error) {
    return 'प्रोफ़ाइल नहीं बन सकी: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google साइन-इन विफल: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'लॉगिन विफल: $error';
  }

  @override
  String errGeneric(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get save => 'सहेजें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get add => 'जोड़ें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get update => 'अपडेट करें';

  @override
  String get back => 'वापस';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'आगे';

  @override
  String get edit => 'संपादित करें';

  @override
  String get deleteLabel => 'हटाएं';

  @override
  String get close => 'बंद करें';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get userNotLoggedIn => 'उपयोगकर्ता लॉग इन नहीं है';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get typesOfConnections => 'कनेक्शन के प्रकार';

  @override
  String get connectionQuestion =>
      'आप Blindly पर किस तरह का कनेक्शन ढूंढ रहे हैं?';

  @override
  String get connectionSubtitle =>
      'डेट और रोमांस, नए दोस्त, या सिर्फ़ बिज़नेस? आप इसे कभी भी बदल सकते हैं।';

  @override
  String get modeDateSubtitle =>
      'रिश्ता, कुछ हल्का-फुल्का, या बीच का कुछ भी ढूंढें';

  @override
  String get modeBffSubtitle => 'नए दोस्त बनाएं और अपना समुदाय खोजें';

  @override
  String get modeEventsSubtitle =>
      'रोमांचक इवेंट खोजें, टिकट बुक करें, और भी बहुत कुछ';

  @override
  String continueWithMode(String mode) {
    return '$mode के साथ जारी रखें';
  }

  @override
  String get multiDeviceTitle => 'एक से ज़्यादा डिवाइस पर लॉगिन';

  @override
  String get multiDeviceBody =>
      'आपका खाता किसी और डिवाइस पर चालू है। सुरक्षा के लिए सिर्फ़ एक सेशन की अनुमति है।';

  @override
  String get signedOutOtherDevices => 'दूसरे डिवाइस से साइन आउट कर दिया!';

  @override
  String get signOutOtherDevices => 'दूसरे डिवाइस साइन आउट करें';

  @override
  String get logOutThisDevice => 'इस डिवाइस से लॉग आउट करें';

  @override
  String get swipeRightHint => 'और जानने के लिए दाईं ओर स्वाइप करें!';

  @override
  String get locationRequiredTitle => 'लोकेशन ज़रूरी है';

  @override
  String get locationRequiredBody =>
      'आपके आस-पास बेहतरीन लोगों को खोजने के लिए हमें आपकी लोकेशन चाहिए।\n\nकृपया \"सेटिंग्स\" पर टैप करके लोकेशन की अनुमति चालू करें, फिर \"फिर कोशिश करें\" दबाएं।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get notifyMeSnack => 'नए लोग जुड़ने पर हम आपको बताएंगे!';

  @override
  String get nearby => 'आस-पास';

  @override
  String heightCm(String value) {
    return '$value सेमी';
  }

  @override
  String get completeYourProfile => 'अपनी प्रोफ़ाइल पूरी करें';

  @override
  String get completeYourProfileBody =>
      'आपने कुछ चरण छोड़ दिए थे। ऐप का पूरा फ़ायदा लेने के लिए उन्हें पूरा करें।';

  @override
  String get stepNotAvailable => 'यह चरण अभी उपलब्ध नहीं है।';

  @override
  String get profileNotFound => 'प्रोफ़ाइल नहीं मिली';

  @override
  String get profileUnavailable => 'प्रोफ़ाइल नहीं मिली या अब उपलब्ध नहीं है।';

  @override
  String get profileLoadFailed =>
      'प्रोफ़ाइल लोड नहीं हो सकी। कृपया फिर कोशिश करें।';

  @override
  String get alreadyLikedProfile =>
      'आप इस प्रोफ़ाइल को पहले ही लाइक कर चुके हैं।';

  @override
  String get personAlreadyLikedYou =>
      'यह व्यक्ति आपको पहले ही लाइक कर चुका है।';

  @override
  String get youAreMatched => 'आपका मैच हो गया।';

  @override
  String get alreadyChatting => 'आपने बातचीत शुरू कर दी है।';

  @override
  String get profileAlreadySkipped => 'प्रोफ़ाइल पहले ही छोड़ी जा चुकी है।';

  @override
  String get goBack => 'वापस जाएं';

  @override
  String get profilePreview => 'प्रोफ़ाइल झलक';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get voiceIntro => 'वॉइस परिचय';

  @override
  String get bioTitle => 'बायो';

  @override
  String get askAboutMyBio => 'मेरे बायो के बारे में पूछें!';

  @override
  String get kudos => 'तारीफ़';

  @override
  String get aPrompt => 'एक सवाल';

  @override
  String get profileVerified => 'प्रोफ़ाइल सत्यापित';

  @override
  String get photoVerified => 'फ़ोटो सत्यापित';

  @override
  String get notVerified => 'सत्यापित नहीं';

  @override
  String milesAway(String distance) {
    return '$distance मील दूर';
  }

  @override
  String trustScore(String score) {
    return 'भरोसा स्कोर: $score%';
  }

  @override
  String get seeHowYouMatch => 'देखें आप दोनों कितने मेल खाते हैं';

  @override
  String get aboutMe => 'मेरे बारे में';

  @override
  String get imLookingFor => 'मैं ढूंढ रहा/रही हूँ';

  @override
  String get quickestWayToHeart => 'मेरे दिल तक पहुँचने का सबसे तेज़ रास्ता है';

  @override
  String get myInterests => 'मेरी रुचियाँ';

  @override
  String get myLifestyle => 'मेरी जीवनशैली';

  @override
  String smokesLabel(String value) {
    return 'धूम्रपान: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'शराब: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'कसरत: $value';
  }

  @override
  String get myCauses => 'मेरे मुद्दे और समुदाय';

  @override
  String get languagesTitle => 'भाषाएँ';

  @override
  String get myLocation => 'मेरी लोकेशन';

  @override
  String get myTopArtist => 'Spotify पर मेरा पसंदीदा कलाकार';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get youLikedThem => 'आपने उन्हें लाइक किया!';

  @override
  String get undoNotForMe => '\'मेरे लिए नहीं\' वापस लें';

  @override
  String get notForMe => 'मेरे लिए नहीं';

  @override
  String get block => 'ब्लॉक करें';

  @override
  String get report => 'रिपोर्ट करें';

  @override
  String get outOfSwipesToday => 'आज के स्वाइप\nखत्म हो गए';

  @override
  String get moreSwipesIn => 'और स्वाइप इतने समय में';

  @override
  String get hoursLabel => 'घंटे';

  @override
  String get minutesLabel => 'मिनट';

  @override
  String get secondsLabel => 'सेकंड';

  @override
  String get sendAndSeeLikes => 'जितने चाहें उतने\nलाइक भेजें और देखें';

  @override
  String get sendUnlimitedSwipes => 'असीमित स्वाइप भेजें';

  @override
  String get advancedSearchFilter => 'एडवांस्ड सर्च फ़िल्टर';

  @override
  String get seeEveryoneWhoLikes => 'देखें कौन-कौन आपको पसंद करता है';

  @override
  String get setMoreDatingPrefs => 'और डेटिंग पसंद सेट करें';

  @override
  String monthsPlan(String count) {
    return '$count महीने';
  }

  @override
  String get mostPopular => 'सबसे लोकप्रिय';

  @override
  String get bestValue => 'सबसे फ़ायदेमंद';

  @override
  String getWithPlan(String plan, String price) {
    return '$plan पाएं $price में';
  }

  @override
  String offerEndsIn(String time) {
    return 'ऑफ़र खत्म होने में $time';
  }

  @override
  String get chats => 'चैट';

  @override
  String get conversations => 'बातचीत';

  @override
  String get recentMatches => 'हाल के मैच';

  @override
  String get readyToMakeFirstMove => 'पहला कदम उठाने\nके लिए तैयार?';

  @override
  String get tapToContinueChatting => 'बातचीत जारी रखने के लिए टैप करें';

  @override
  String get unknownUser => 'अज्ञात उपयोगकर्ता';

  @override
  String get newMatchesAppearHere => 'आपके नए मैच यहाँ दिखेंगे।';

  @override
  String get endToEndEncrypted => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String get e2eBanner =>
      'संदेश और कॉल एंड-टू-एंड एन्क्रिप्टेड हैं। इस चैट के बाहर कोई भी, यहाँ तक कि Blindly भी, उन्हें पढ़ या सुन नहीं सकता। ';

  @override
  String get encryptedMessage => 'एन्क्रिप्टेड संदेश';

  @override
  String get encryptionKeyNotLoaded =>
      'एन्क्रिप्शन कुंजी लोड नहीं हुई। कृपया रुकें।';

  @override
  String get messageViolatesGuidelines =>
      'यह संदेश हमारे समुदाय दिशानिर्देशों का उल्लंघन कर सकता है और भेजा नहीं गया।';

  @override
  String get imageMessage => ' इमेज संदेश';

  @override
  String get voiceMessage => ' वॉइस संदेश';

  @override
  String nSelected(String count) {
    return '$count चुने गए';
  }

  @override
  String get editedSuffix => '(संपादित)';

  @override
  String get editingMessage => 'संदेश संपादित हो रहा है';

  @override
  String get onlyTextEditable => 'सिर्फ़ टेक्स्ट संदेश संपादित हो सकते हैं';

  @override
  String get messageCopied => 'संदेश कॉपी हो गया';

  @override
  String get archiveChat => 'चैट संग्रहित करें';

  @override
  String get clearChat => 'चैट साफ़ करें';

  @override
  String get blockUser => 'उपयोगकर्ता को ब्लॉक करें';

  @override
  String get muteNotifications => 'सूचनाएं म्यूट करें';

  @override
  String get reportAndSpam => 'रिपोर्ट और स्पैम';

  @override
  String get deleteForMe => 'मेरे लिए हटाएं';

  @override
  String get deleteForEveryone => 'सबके लिए हटाएं';

  @override
  String get showTranslation => 'अनुवाद दिखाएं';

  @override
  String get showOriginal => 'मूल दिखाएं';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get chooseFromGallery => 'गैलरी से चुनें';

  @override
  String get attachmentComingSoon => 'अटैचमेंट पिकर जल्द आ रहा है';

  @override
  String get imageTooLarge => 'इमेज बहुत बड़ी है (अधिकतम 5MB)';

  @override
  String get micPermissionDenied => 'माइक्रोफ़ोन की अनुमति नहीं मिली';

  @override
  String get recordingEmpty => 'रिकॉर्डिंग फ़ाइल खाली है';

  @override
  String get recordingNotFound => 'रिकॉर्डिंग फ़ाइल नहीं मिली';

  @override
  String get failedToPlayVoice => 'वॉइस संदेश नहीं चल सका';

  @override
  String get failedToLoad => 'लोड नहीं हो सका';

  @override
  String get errorLoadingGif => 'GIF लोड करने में गड़बड़ी';

  @override
  String get errorLoadingSticker => 'स्टिकर लोड करने में गड़बड़ी';

  @override
  String get networkErrorRetry =>
      'नेटवर्क गड़बड़ी। कृपया अपना इंटरनेट कनेक्शन जांचें और फिर कोशिश करें।';

  @override
  String get serverSideError =>
      'हमारी तरफ़ से कुछ गड़बड़ हुई। एक बार फिर कोशिश करें।';

  @override
  String get pleaseLoginFirst => 'कृपया पहले लॉगिन करें';

  @override
  String get icebreakers => 'आइसब्रेकर';

  @override
  String get iceBreaker => 'आइसब्रेकर';

  @override
  String get couldntLoadIcebreakers => 'आइसब्रेकर लोड नहीं हो सके';

  @override
  String get aiAnalyzingProfiles => 'AI आपकी प्रोफ़ाइलें देख रहा है...';

  @override
  String get generate => 'बनाएं';

  @override
  String get regenerate => 'फिर से बनाएं';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryDeep => 'गहरा';

  @override
  String get categoryPlayful => 'चुलबुला';

  @override
  String get categoryQuirky => 'अनोखा';

  @override
  String get categoryPersonalized => 'आपके हिसाब से';

  @override
  String get categoryQuestion => 'सवाल';

  @override
  String get categoryObservation => 'अवलोकन';

  @override
  String get categoryFunFact => 'मज़ेदार तथ्य';

  @override
  String get categoryHypothesis => 'कल्पना';

  @override
  String get categoryOpeningMove => 'पहला कदम';

  @override
  String get superpowerPrompt =>
      'अगर आपको कोई एक महाशक्ति मिल सकती, तो कौन-सी होती?';

  @override
  String get chooseAnOption => 'एक विकल्प चुनें';

  @override
  String get invalidMatchData => 'मैच डेटा गलत है। कृपया फिर कोशिश करें।';

  @override
  String get moreOpeningMoves => 'और पहले कदम';

  @override
  String get onlineNow => 'अभी ऑनलाइन';

  @override
  String get pleaseEnterMessage => 'कृपया कोई संदेश लिखें';

  @override
  String sendPersonMessage(String name) {
    return '$name को संदेश भेजें';
  }

  @override
  String get sendMessage => 'संदेश भेजें';

  @override
  String get matchHasExpired => 'यह मैच खत्म हो चुका है।';

  @override
  String get typeOpeningMove => 'अपना पहला संदेश लिखें...';

  @override
  String get use => 'इस्तेमाल करें';

  @override
  String get expiringSoon => 'जल्द खत्म हो रहा है';

  @override
  String get matchExpiredTitle => 'मैच खत्म';

  @override
  String dontLetThemGetAway(String name) {
    return '$name को\nजाने मत दीजिए!';
  }

  @override
  String get limitedTimeBody =>
      'आपके पास कदम उठाने के लिए कम समय बचा है। मैच हमेशा के लिए गायब होने से पहले संदेश भेजें।';

  @override
  String get letThemGo => 'जाने दें';

  @override
  String messagePerson(String name) {
    return '$name को संदेश करें';
  }

  @override
  String get gifs => 'GIF';

  @override
  String get stickers => 'स्टिकर';

  @override
  String get searchGiphy => 'GIPHY खोजें';

  @override
  String get themOnly => 'सिर्फ़ उनके लिए';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get icebreakerSmile => 'हाल में किस छोटी सी बात ने आपको मुस्कुराया?';

  @override
  String get icebreakerTwoTruths => 'दो सच और एक झूठ: शुरू करें!';

  @override
  String get icebreakerInteresting => 'हाल में आपने सबसे दिलचस्प क्या सीखा?';

  @override
  String get openingMoveCushions => 'मैं और मेरे बनाए कुशन।\nआपको कैसे लगे?';

  @override
  String get openingMove90s => 'शर्त लगा लें, मेरा 90s लुक कोई नहीं हरा सकता';

  @override
  String get openingMovePetName => 'मेरे पालतू का नाम बताइए?';

  @override
  String get viewProfile => 'प्रोफ़ाइल देखें';

  @override
  String get likedYou => 'आपको पसंद किया';

  @override
  String get matchLabel => 'मैच';

  @override
  String get passLabel => 'छोड़ें';

  @override
  String get failedToLoadLikes => 'लाइक लोड नहीं हो सके';

  @override
  String get noLikesYet => 'अभी कोई लाइक नहीं, पर\n';

  @override
  String get buzzOff => 'निराश मत होइए!';

  @override
  String get keepSwipingBody =>
      'अपना साथी ढूंढने के लिए स्वाइप करते रहें।\nजल्द ही कोई आपको ज़रूर पसंद करेगा!';

  @override
  String get keepSwiping => 'स्वाइप करते रहें';

  @override
  String get startSwiping => 'स्वाइप शुरू करें';

  @override
  String get improveProfile => 'प्रोफ़ाइल बेहतर करें';

  @override
  String get viewMoreLikes => 'और लाइक देखें';

  @override
  String get seeWhosInterested => 'देखें किसे आपमें दिलचस्पी है';

  @override
  String matchInstantly(String count) {
    return 'बिना इंतज़ार तुरंत मैच करें। आपके $count+ लाइक इंतज़ार कर रहे हैं';
  }

  @override
  String get superLiked => 'सुपर लाइक';

  @override
  String get itsAMatch => 'मैच हो गया!';

  @override
  String youAndThemLiked(String name) {
    return 'आपने और $name ने एक-दूसरे को पसंद किया।';
  }

  @override
  String get sendAMessage => 'संदेश भेजें';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get loginToViewNotifications => 'सूचनाएं देखने के लिए लॉगिन करें।';

  @override
  String get noNotificationsYet => 'अभी आपकी कोई सूचना नहीं है।';

  @override
  String get discover => 'खोजें';

  @override
  String get reachedEndOfLine => 'आप आखिर तक\nपहुँच गए!';

  @override
  String get checkBackSoon =>
      'और लोगों के लिए जल्द वापस आएं या ज़्यादा प्रोफ़ाइल देखने के लिए फ़िल्टर बदलें।';

  @override
  String get seeMorePeople => 'और लोग देखें';

  @override
  String get topPicksForYou => 'आपके लिए बेहतरीन';

  @override
  String get sharedInterests => 'साझा रुचियाँ';

  @override
  String get newFaces => 'नए चेहरे';

  @override
  String get recentlyActive => 'हाल में सक्रिय';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String kmAway(String distance) {
    return '$distance किमी दूर';
  }

  @override
  String get letsDiscover => 'चलिए खोजते हैं!';

  @override
  String get viewedAllProfiles =>
      'आपने अपनी मौजूदा पसंद से मेल खाती सभी प्रोफ़ाइल देख ली हैं। खोज बढ़ाएं या नए लोगों के लिए जल्द वापस आएं।';

  @override
  String get adjustYourFilters => 'अपने फ़िल्टर बदलें';

  @override
  String get notifyMeNewPeople => 'नए लोगों के बारे में बताएं';

  @override
  String youAndPerson(String name) {
    return 'आप और $name';
  }

  @override
  String get workingOutCommon => 'देख रहे हैं आप दोनों में क्या समान है…';

  @override
  String get whyTitle => 'क्यों';

  @override
  String get breakdownTitle => 'विवरण';

  @override
  String get goesBothWays => 'क्या यह दोनों तरफ़ से है?';

  @override
  String eachFitsOther(String band) {
    return 'आप दोनों एक-दूसरे की तलाश पर खरे उतरते हैं: $band।';
  }

  @override
  String get sectionConnections => 'कनेक्शन';

  @override
  String get typeOfConnection => 'कनेक्शन का प्रकार';

  @override
  String get dateMode => 'डेट मोड';

  @override
  String get travel => 'यात्रा';

  @override
  String get sectionAccountSettings => 'खाता सेटिंग्स';

  @override
  String get profileAndVerification => 'प्रोफ़ाइल और सत्यापन';

  @override
  String get contactAndLoginInfo => 'संपर्क और लॉगिन जानकारी';

  @override
  String get subscriptionManagement => 'सब्सक्रिप्शन प्रबंधन';

  @override
  String get sectionAppPreference => 'ऐप पसंद';

  @override
  String get notificationsSetting => 'सूचना सेटिंग';

  @override
  String get privacyControls => 'गोपनीयता नियंत्रण';

  @override
  String get sectionSecurityPrivacy => 'सुरक्षा और गोपनीयता';

  @override
  String get accountManagement => 'खाता प्रबंधन';

  @override
  String get blockedAccounts => 'ब्लॉक किए गए खाते';

  @override
  String get locationService => 'लोकेशन सेवा';

  @override
  String get sectionSupportLegal => 'सहायता और कानूनी';

  @override
  String get helpCenter => 'सहायता केंद्र';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get vEnglish => 'अंग्रेज़ी';

  @override
  String get vHindi => 'हिन्दी';

  @override
  String get vTamil => 'तमिल';

  @override
  String get vTelugu => 'तेलुगु';

  @override
  String get vKannada => 'कन्नड़';

  @override
  String get vMalayalam => 'मलयालम';

  @override
  String get vMarathi => 'मराठी';

  @override
  String get vBengali => 'बंगाली';

  @override
  String get vGujarati => 'गुजराती';

  @override
  String get vPunjabi => 'पंजाबी';

  @override
  String get vOdia => 'ओड़िया';

  @override
  String get vSpanish => 'स्पेनिश';

  @override
  String get vFrench => 'फ़्रेंच';

  @override
  String get vGerman => 'जर्मन';

  @override
  String get vItalian => 'इतालवी';

  @override
  String get vPortuguese => 'पुर्तगाली';

  @override
  String get vRussian => 'रूसी';

  @override
  String get vJapanese => 'जापानी';

  @override
  String get vKorean => 'कोरियाई';

  @override
  String get vChinese => 'चीनी';

  @override
  String get vArabic => 'अरबी';

  @override
  String get vTurkish => 'तुर्की';

  @override
  String get vOthers => 'अन्य';

  @override
  String get vOther => 'अन्य';

  @override
  String get vHindu => 'हिन्दू';

  @override
  String get vChristian => 'ईसाई';

  @override
  String get vMuslim => 'मुस्लिम';

  @override
  String get vSikh => 'सिख';

  @override
  String get vJain => 'जैन';

  @override
  String get vBuddhist => 'बौद्ध';

  @override
  String get vAtheist => 'नास्तिक';

  @override
  String get vAgnostic => 'अज्ञेयवादी';

  @override
  String get vSpiritual => 'आध्यात्मिक';

  @override
  String get vCatholic => 'कैथोलिक';

  @override
  String get vLatterDaySaint => 'लैटर डे सेंट';

  @override
  String get vZoroastrian => 'पारसी';

  @override
  String get vJewish => 'यहूदी';

  @override
  String get vMormon => 'मॉर्मन';

  @override
  String get vMonogamy => 'एकनिष्ठ संबंध';

  @override
  String get vPolyamory => 'बहुप्रेम';

  @override
  String get vOpenRelationship => 'खुला रिश्ता';

  @override
  String get vNonMonogamy => 'गैर-एकनिष्ठ';

  @override
  String get vOpenToExploring => 'तलाशने को तैयार';

  @override
  String get vShortTerm => 'अल्पकालिक';

  @override
  String get vLongTerm => 'दीर्घकालिक';

  @override
  String get vStraight => 'स्ट्रेट';

  @override
  String get vGay => 'गे';

  @override
  String get vLesbian => 'लेस्बियन';

  @override
  String get vBisexual => 'बाइसेक्सुअल';

  @override
  String get vAsexual => 'एसेक्सुअल';

  @override
  String get vDemisexual => 'डेमीसेक्सुअल';

  @override
  String get vPansexual => 'पैनसेक्सुअल';

  @override
  String get vQueer => 'क्वीर';

  @override
  String get vQuestioning => 'अनिश्चित';

  @override
  String get vWomen => 'महिलाएं';

  @override
  String get vMen => 'पुरुष';

  @override
  String get vEveryone => 'सभी';

  @override
  String get vMale => 'पुरुष';

  @override
  String get vFemale => 'महिला';

  @override
  String get vFunCasualDates => 'मज़ेदार, हल्की-फुल्की डेट';

  @override
  String get vLifePartner => 'जीवनसाथी';

  @override
  String get vLongTermRelationship => 'दीर्घकालिक रिश्ता';

  @override
  String get vShortTermRelationship => 'अल्पकालिक रिश्ता';

  @override
  String get vStillFiguringOut => 'अभी तय नहीं किया';

  @override
  String get vLongOpenToShort => 'दीर्घकालिक, अल्पकालिक भी चलेगा';

  @override
  String get vShortOpenToLong => 'अल्पकालिक, दीर्घकालिक भी चलेगा';

  @override
  String get vCasualDating => 'हल्की-फुल्की डेटिंग';

  @override
  String get vNewFriends => 'नए दोस्त';

  @override
  String get vCloseFriends => 'करीबी दोस्त';

  @override
  String get vActivityPartners => 'गतिविधि साथी';

  @override
  String get vProfessionalNetworking => 'पेशेवर नेटवर्किंग';

  @override
  String get vWorkoutBuddy => 'कसरत का साथी';

  @override
  String get vTravelBuddies => 'सफ़र के साथी';

  @override
  String get vYesIDrink => 'हाँ, मैं पीता/पीती हूँ';

  @override
  String get vOccasionally => 'कभी-कभार';

  @override
  String get vSometimes => 'कभी-कभी';

  @override
  String get vNeverDrink => 'कभी नहीं पीता/पीती';

  @override
  String get vRegularly => 'नियमित रूप से';

  @override
  String get vImSober => 'मैं शराब नहीं पीता/पीती';

  @override
  String get vSocially => 'सामाजिक मौकों पर';

  @override
  String get vNever => 'कभी नहीं';

  @override
  String get vSocialSmoker => 'सामाजिक मौकों पर धूम्रपान';

  @override
  String get vSmokerWhenDrinking => 'पीते समय धूम्रपान';

  @override
  String get vNonSmoker => 'धूम्रपान नहीं करता/करती';

  @override
  String get vSmoker => 'धूम्रपान करता/करती हूँ';

  @override
  String get vTryingToQuit => 'छोड़ने की कोशिश में';

  @override
  String get vDaily => 'रोज़';

  @override
  String get vWeekly => 'हर हफ़्ते';

  @override
  String get vHighSchool => 'हाई स्कूल';

  @override
  String get vGradeSchool => 'प्राथमिक स्कूल';

  @override
  String get vDiploma => 'डिप्लोमा';

  @override
  String get vUnderGraduate => 'स्नातक';

  @override
  String get vPostGraduate => 'स्नातकोत्तर';

  @override
  String get vDoctorate => 'डॉक्टरेट';

  @override
  String get vCommunist => 'साम्यवादी';

  @override
  String get vSocialist => 'समाजवादी';

  @override
  String get vApolitical => 'राजनीति से दूर';

  @override
  String get vModerate => 'उदारवादी';

  @override
  String get vNotInterested => 'दिलचस्पी नहीं';

  @override
  String get vHaveKids => 'बच्चे हैं';

  @override
  String get vDontHaveKids => 'बच्चे नहीं हैं';

  @override
  String get vDontWantKids => 'बच्चे नहीं चाहिए';

  @override
  String get vWantKids => 'बच्चे चाहिए';

  @override
  String get vOpenToKids => 'बच्चों के लिए तैयार';

  @override
  String get vNotSure => 'पक्का नहीं';

  @override
  String get vPreferNotToSay => 'बताना नहीं चाहूँगा/चाहूँगी';

  @override
  String get vAries => 'मेष';

  @override
  String get vTaurus => 'वृषभ';

  @override
  String get vGemini => 'मिथुन';

  @override
  String get vCancer => 'कर्क';

  @override
  String get vLeo => 'सिंह';

  @override
  String get vVirgo => 'कन्या';

  @override
  String get vLibra => 'तुला';

  @override
  String get vScorpio => 'वृश्चिक';

  @override
  String get vSagittarius => 'धनु';

  @override
  String get vCapricorn => 'मकर';

  @override
  String get vAquarius => 'कुम्भ';

  @override
  String get vPisces => 'मीन';

  @override
  String get vHumanRights => 'मानवाधिकार';

  @override
  String get vDisabilityRights => 'दिव्यांग अधिकार';

  @override
  String get vFeminism => 'नारीवाद';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'पर्यावरणवाद';

  @override
  String get vLgbtqRights => 'LGBTQ अधिकार';

  @override
  String get vImmigrantRights => 'प्रवासी अधिकार';

  @override
  String get vEndReligiousHate => 'धार्मिक नफ़रत का अंत';

  @override
  String get vIndigenousRights => 'आदिवासी अधिकार';

  @override
  String get vNeuroDiversity => 'न्यूरो विविधता';

  @override
  String get vVoterRights => 'मतदाता अधिकार';

  @override
  String get vReproductiveRights => 'प्रजनन अधिकार';

  @override
  String get vAmbition => 'महत्वाकांक्षा';

  @override
  String get vConfidence => 'आत्मविश्वास';

  @override
  String get vEmpathy => 'सहानुभूति';

  @override
  String get vHumor => 'हास्य';

  @override
  String get vKindness => 'दयालुता';

  @override
  String get vOpenness => 'खुलापन';

  @override
  String get vOptimism => 'आशावाद';

  @override
  String get vSassiness => 'बेबाकपन';

  @override
  String get vPlayfulness => 'चुलबुलापन';

  @override
  String get vLeadership => 'नेतृत्व';

  @override
  String get vHumility => 'विनम्रता';

  @override
  String get vLoyalty => 'वफ़ादारी';

  @override
  String get vSarcasm => 'तंज';

  @override
  String get vGratitude => 'कृतज्ञता';

  @override
  String get vCuriosity => 'जिज्ञासा';

  @override
  String get vEmotionalIntelligence => 'भावनात्मक समझ';

  @override
  String get datingPreference => 'डेटिंग पसंद';

  @override
  String get bffPreference => 'BFF पसंद';

  @override
  String get whoWouldYouDate => 'आप किसे डेट करना चाहेंगे?';

  @override
  String get ageRange => 'उम्र सीमा?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max साल';
  }

  @override
  String get howFarAway => 'वे कितनी दूर हैं?';

  @override
  String kilometersAway(String distance) {
    return '$distance किलोमीटर दूर';
  }

  @override
  String get yourInterests => 'आपकी रुचियाँ?';

  @override
  String get errorLoadingInterests => 'रुचियाँ लोड नहीं हो सकीं';

  @override
  String get whichLanguages => 'आप कौन-सी भाषाएँ जानते हैं?';

  @override
  String get selectLanguages => 'भाषाएँ चुनें';

  @override
  String get religionQuestion => 'धर्म';

  @override
  String get selectReligion => 'धर्म चुनें';

  @override
  String get relationshipTypeQuestion => 'रिश्ते का प्रकार?';

  @override
  String get relationshipTypeTitle => 'रिश्ते का प्रकार';

  @override
  String get selectType => 'प्रकार चुनें';

  @override
  String get sexualOrientationQuestion => 'यौन रुझान?';

  @override
  String get sexualOrientationTitle => 'यौन रुझान';

  @override
  String get selectOrientation => 'रुझान चुनें';

  @override
  String get datingIntentionQuestion => 'डेटिंग का इरादा?';

  @override
  String get datingIntentionTitle => 'डेटिंग का इरादा';

  @override
  String get selectIntention => 'इरादा चुनें';

  @override
  String get filtersCleared => 'फ़िल्टर हटा दिए गए!';

  @override
  String get clearFilters => 'फ़िल्टर हटाएं';

  @override
  String get filterByInterests => 'अपनी रुचियों से फ़िल्टर करें';

  @override
  String get showMe => 'मुझे दिखाएं';

  @override
  String errUpdateFailed(String error) {
    return 'अपडेट नहीं हो सका: $error';
  }

  @override
  String get religionViewTitle => 'धार्मिक विचार';

  @override
  String get sensitiveInfoNote =>
      'यह संवेदनशील जानकारी है जो आपकी प्रोफ़ाइल पर दिखेगी। यह पूरी तरह वैकल्पिक है।';

  @override
  String get zodiacSignTitle => 'राशि';

  @override
  String get doYouDrink => 'क्या आप शराब पीते हैं?';

  @override
  String get doYouSmoke => 'क्या आप धूम्रपान करते हैं?';

  @override
  String get doYouWorkout => 'क्या आप कसरत करते हैं?';

  @override
  String get educationLevelTitle => 'शिक्षा स्तर';

  @override
  String get politicalViewTitle => 'राजनीतिक विचार';

  @override
  String get doYouHaveKids => 'क्या आपके बच्चे हैं?';

  @override
  String get kidsPlanQuestion => 'बच्चों को लेकर आपकी क्या योजना है?';

  @override
  String get pickYourPronoun => 'अपना सर्वनाम चुनें';

  @override
  String get pronounsBody =>
      'आपके सर्वनाम क्या हैं? 3 सर्वनाम चुनें, आप इन्हें कभी भी हटा सकते हैं।';

  @override
  String get showPronounOnProfile => 'मेरी प्रोफ़ाइल पर सर्वनाम दिखाएं';

  @override
  String get causesTitle => 'मुद्दे और समुदाय';

  @override
  String get selectUpTo3Causes => 'अपने दिल के करीब 3 विकल्प तक चुनें।';

  @override
  String get maxThreeOptions => 'आप ज़्यादा से ज़्यादा 3 विकल्प चुन सकते हैं';

  @override
  String get personQualities => 'व्यक्ति के गुण';

  @override
  String get chooseThreeQualities =>
      '3 ऐसे गुण चुनें जो रिश्ते को और मज़बूत बनाएं।';

  @override
  String get maxThreeQualities => 'आप सिर्फ़ 3 गुण तक चुन सकते हैं।';

  @override
  String get howTallAreYou => 'आपकी लंबाई कितनी है?';

  @override
  String get showsOnProfile => 'यह आपकी प्रोफ़ाइल पर दिखेगा';

  @override
  String get yourHeight => 'आपकी लंबाई';

  @override
  String get professionTitle => 'पेशा';

  @override
  String get showProfessionOnProfile => 'अपनी प्रोफ़ाइल पर पेशा दिखाएं';

  @override
  String get titleLabel => 'पद';

  @override
  String get companyIndustry => 'कंपनी (उद्योग)';

  @override
  String get educatedAt => 'शिक्षा कहाँ से';

  @override
  String get showInstitutionOnProfile => 'अपनी प्रोफ़ाइल पर संस्थान दिखाएं';

  @override
  String get institutionLabel => 'संस्थान';

  @override
  String get graduationYear => 'स्नातक वर्ष';

  @override
  String get enterInstitution => 'कृपया अपने संस्थान का नाम डालें।';

  @override
  String get maxThreeLanguages => 'आप ज़्यादा से ज़्यादा 3 भाषाएँ चुन सकते हैं';

  @override
  String get whatLookingFor => 'आप क्या ढूंढ रहे हैं?';

  @override
  String maxThreeForMode(String mode) {
    return 'मौजूदा मोड ($mode) के लिए आप 3 विकल्प तक चुन सकते हैं।';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'पसंद सहेजने में गड़बड़ी: $error';
  }

  @override
  String get languagesIKnow => 'मुझे आने वाली भाषाएँ';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get searchLanguages => 'भाषाएँ खोजें';

  @override
  String get suggested => 'सुझाए गए';

  @override
  String get allLanguages => 'सभी भाषाएँ';

  @override
  String get errorLoadingProfile => 'प्रोफ़ाइल लोड नहीं हो सकी';

  @override
  String percentTrust(String percent) {
    return '$percent% भरोसा';
  }

  @override
  String get profileCompleted => 'प्रोफ़ाइल पूरी';

  @override
  String get completeProfile => 'प्रोफ़ाइल पूरी करें';

  @override
  String get higherScoreHelps =>
      'बेहतर स्कोर से आपको ज़्यादा\nसच्चे मैच मिलते हैं';

  @override
  String get noBioYet => 'अभी कोई बायो नहीं जोड़ा।';

  @override
  String get askMe => 'मुझसे पूछें';

  @override
  String get activeLabel => 'सक्रिय';

  @override
  String get addReligion => 'धर्म जोड़ें';

  @override
  String get addZodiac => 'राशि जोड़ें';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get getNoticedSooner =>
      'जल्दी नज़र में आएं और\n3 गुना ज़्यादा डेट पर जाएं';

  @override
  String get upgrade => 'अपग्रेड करें';

  @override
  String get spotlight => 'स्पॉटलाइट';

  @override
  String get standOut => 'अलग दिखें';

  @override
  String get superSwipe => 'सुपर स्वाइप';

  @override
  String get getNoticed => 'नज़र में आएं';

  @override
  String get scoreBreakdown => 'स्कोर का विवरण';

  @override
  String get profilePhotoVerified => 'प्रोफ़ाइल फ़ोटो सत्यापित';

  @override
  String get completedLabel => 'पूरा';

  @override
  String get profileDetails => 'प्रोफ़ाइल विवरण';

  @override
  String get incompleteLabel => 'अधूरा';

  @override
  String get connectSocialAccounts => 'सोशल खाते जोड़ें';

  @override
  String get waysToImprove => 'बेहतर करने के तरीके';

  @override
  String get verifyYourPhotos => 'अपनी फ़ोटो सत्यापित करें';

  @override
  String get proveYoureReal => 'दूसरों को दिखाएं कि आप असली हैं';

  @override
  String get addPromptsInterests => 'प्रॉम्प्ट, रुचियाँ और बाकी जानकारी जोड़ें';

  @override
  String get verificationDataSecure =>
      'आपका सत्यापन डेटा सुरक्षित रखा जाता है और आपकी सार्वजनिक प्रोफ़ाइल पर साझा नहीं होता। ';

  @override
  String get learnMore => 'और जानें';

  @override
  String get improveYourProfile => 'अपनी प्रोफ़ाइल बेहतर करें';

  @override
  String errorSavingHometown(String error) {
    return 'गृहनगर सहेजने में गड़बड़ी: $error';
  }

  @override
  String get searchCity => 'शहर खोजें';

  @override
  String get aboutYou => 'आपके बारे में';

  @override
  String get bioPrompt =>
      'शर्माइए मत! यह मौका है एक छोटे बायो में अपनी शख्सियत दिखाने का।';

  @override
  String get textHereHint => 'यहाँ लिखें.....';

  @override
  String failedToSaveBio(String error) {
    return 'बायो सहेजा नहीं जा सका: $error';
  }

  @override
  String get selectYourInterests => 'अपनी रुचियाँ चुनें';

  @override
  String get atLeast5Interests =>
      'कम से कम 5 रुचियाँ चुनें। इससे हम आपके जैसे लोग ढूंढ पाते हैं';

  @override
  String get searchForInterest => 'रुचि खोजें';

  @override
  String get noInterestsFound => 'कोई रुचि नहीं मिली';

  @override
  String get failedLoadInterests =>
      'रुचियाँ लोड नहीं हो सकीं। कृपया फिर कोशिश करें।';

  @override
  String get maxTenInterests => 'आप ज़्यादा से ज़्यादा 10 रुचियाँ चुन सकते हैं';

  @override
  String get minFiveInterests => 'कृपया कम से कम 5 रुचियाँ चुनें';

  @override
  String errorSavingInterests(String error) {
    return 'रुचियाँ सहेजने में गड़बड़ी: $error';
  }

  @override
  String get lifeStyle => 'जीवनशैली';

  @override
  String get lifestylePrompt =>
      'अपनी आदतों के बारे में बताएं। जो आप पर सबसे सही बैठे, वह चुनें।';

  @override
  String get noLifestyleOptions => 'कोई जीवनशैली विकल्प उपलब्ध नहीं';

  @override
  String get failedLoadLifestyle =>
      'जीवनशैली विकल्प लोड नहीं हो सके। कृपया फिर कोशिश करें।';

  @override
  String get selectEachCategory =>
      'हर श्रेणी के लिए एक विकल्प चुनें, या छोड़ने के लिए सब हटा दें।';

  @override
  String get findYourCity => 'अपना मौजूदा शहर खोजें';

  @override
  String errorSavingLocation(String error) {
    return 'लोकेशन सहेजने में गड़बड़ी: $error';
  }

  @override
  String get permissionRequired => 'अनुमति ज़रूरी है';

  @override
  String get permissionRequiredBody =>
      'ऐप ठीक से चलने के लिए यह अनुमति ज़रूरी है। कृपया इसे सेटिंग्स में चालू करें।';

  @override
  String get cameraAccess => 'कैमरा एक्सेस';

  @override
  String get photoLibrary => 'फ़ोटो लाइब्रेरी';

  @override
  String get locationAccess => 'लोकेशन एक्सेस';

  @override
  String get notificationAccess => 'सूचना एक्सेस';

  @override
  String get microphoneAccess => 'माइक्रोफ़ोन एक्सेस';

  @override
  String get unknownAccess => 'अज्ञात एक्सेस';

  @override
  String get cameraReason =>
      'प्रोफ़ाइल फ़ोटो लेने और पहचान सत्यापित करने के लिए।';

  @override
  String get photoReason => 'आपकी गैलरी से फ़ोटो अपलोड करने के लिए।';

  @override
  String get locationReason => 'आपके आस-पास के मैच दिखाने के लिए।';

  @override
  String get notificationReason => 'नए मैच और संदेशों की जानकारी देने के लिए।';

  @override
  String get microphoneReason => 'वॉइस और वीडियो बातचीत के लिए।';

  @override
  String get appPermissions => 'ऐप अनुमतियाँ';

  @override
  String get chooseYourPrompt => 'अपना प्रॉम्प्ट चुनें';

  @override
  String get selectUpTo3Prompts =>
      'अपनी शख्सियत दिखाने के लिए 3 प्रॉम्प्ट तक चुनें।';

  @override
  String get maxThreePrompts => 'आप सिर्फ़ 3 प्रॉम्प्ट तक चुन सकते हैं।';

  @override
  String get areYouSure => 'क्या आप पक्का चाहते हैं?';

  @override
  String get removeThisPrompt => 'क्या यह प्रॉम्प्ट हटाना है?';

  @override
  String get selectThreePrompts => 'आगे बढ़ने के लिए 3 प्रॉम्प्ट चुनें।';

  @override
  String get selectOnePrompt => 'कम से कम 1 प्रॉम्प्ट चुनें।';

  @override
  String selectNMorePrompts(String count) {
    return 'आगे बढ़ने के लिए $count और प्रॉम्प्ट चुनें';
  }

  @override
  String get noPromptsForCategory => 'इस श्रेणी के लिए कोई प्रॉम्प्ट नहीं है।';

  @override
  String get typeYourAnswer => 'अपना जवाब लिखें...';

  @override
  String get addPrompt => 'प्रॉम्प्ट जोड़ें';

  @override
  String failedToLoadPrompts(String error) {
    return 'प्रॉम्प्ट लोड नहीं हो सके: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'प्रॉम्प्ट सहेजने में गड़बड़ी: $error';
  }

  @override
  String get communityGuidelines => 'समुदाय दिशानिर्देश';

  @override
  String get agreeAndContinue => 'सहमत हूँ और आगे बढ़ें';

  @override
  String get termsByContinuePrefix => 'आगे बढ़कर, आप हमारी ';

  @override
  String get guidelinesIntro =>
      'हमारे समुदाय में आपका स्वागत है! सबके लिए सुरक्षित और अच्छा अनुभव बनाए रखने के लिए कृपया ये सरल दिशानिर्देश मानें।';

  @override
  String get beKindTitle => 'दयालु और सम्मानजनक रहें';

  @override
  String get beKindBody =>
      'दूसरों के साथ वैसा ही व्यवहार करें जैसा आप चाहते हैं। हम सब मिलकर एक अच्छा माहौल बनाते हैं।';

  @override
  String get stayAuthenticTitle => 'असली बने रहें';

  @override
  String get stayAuthenticBody =>
      'अपनी प्रोफ़ाइल और बातचीत में सच्चे रहें। हम सच्चाई और असली रिश्तों को महत्व देते हैं।';

  @override
  String get prioritizeSafetyTitle => 'सुरक्षा को पहले रखें';

  @override
  String get prioritizeSafetyBody =>
      'संवेदनशील और निजी जानकारी साझा न करें। खुद को और समुदाय के दूसरों को सुरक्षित रखें।';

  @override
  String get noHateTitle => 'नफ़रत भरी बातें नहीं';

  @override
  String get noHateBody =>
      'उत्पीड़न, धमकाना और गैर-कानूनी सामग्री यहाँ बर्दाश्त नहीं है। समुदाय को सुरक्षित रखने में मदद करें।';

  @override
  String get helpKeepSafeTitle => 'हमें सुरक्षित रखने में मदद करें';

  @override
  String get helpKeepSafeBody =>
      'अगर आपको हमारे दिशानिर्देशों का उल्लंघन दिखे, तो कृपया रिपोर्ट करें। आपकी मदद बहुत कीमती है।';

  @override
  String get genuineIntentTitle => 'सच्ची नीयत से डेट करें';

  @override
  String get genuineIntentBody =>
      'हम असली रिश्तों के लिए हैं। फ़र्ज़ी पहचान या दबाव की अनुमति नहीं है। ठगी, किसी और का रूप धरना, या निजी/आर्थिक फ़ायदे के लिए किसी भी तरह की चालबाज़ी मना है।';

  @override
  String get adultsOnlyTitle => 'सिर्फ़ वयस्कों के लिए';

  @override
  String get adultsOnlyBody =>
      'Blindly इस्तेमाल करने के लिए आपकी उम्र 18 साल या उससे ज़्यादा होनी चाहिए। इसका मतलब यह भी है कि अकेले या बिना कपड़ों वाले नाबालिगों की तस्वीरें मना हैं, आपके बचपन की तस्वीरें भी — चाहे वे कितनी ही प्यारी क्यों न हों।';

  @override
  String get letsIntroduceYou => 'चलिए आपका परिचय कराएं!';

  @override
  String get needNameForProfile => 'प्रोफ़ाइल बनाने के लिए हमें आपका नाम चाहिए';

  @override
  String get nameLabel => 'नाम';

  @override
  String get enterYourName => 'अपना नाम डालें';

  @override
  String get needDobForProfile =>
      'प्रोफ़ाइल बनाने के लिए हमें आपकी जन्मतिथि चाहिए';

  @override
  String get dateOfBirth => 'जन्मतिथि';

  @override
  String get birthdayNote =>
      'आपकी जन्मतिथि से उम्र निकाली जाती है और वह प्रोफ़ाइल पर दिखेगी। आपका पूरा नाम सार्वजनिक नहीं होगा';

  @override
  String failedToSaveData(String error) {
    return 'डेटा सहेजा नहीं जा सका: $error';
  }

  @override
  String get whatsYourGender => 'आपका लिंग क्या है?';

  @override
  String get genderHelpsMatches =>
      'इससे हम आपको सही प्रोफ़ाइल दिखा पाते हैं और मैच ढूंढ पाते हैं';

  @override
  String get vNonBinary => 'नॉन-बाइनरी';

  @override
  String get vPreferNot => 'बताना नहीं चाहूँगा';

  @override
  String failedToSaveGender(String error) {
    return 'लिंग सहेजा नहीं जा सका: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'अपनी प्रोफ़ाइल के लिए फ़ोटो अपलोड करने हेतु $permission की अनुमति दें।';
  }

  @override
  String get gallery => 'गैलरी';

  @override
  String get camera => 'कैमरा';

  @override
  String get photoNotAccepted => 'फ़ोटो स्वीकार नहीं हुई';

  @override
  String get couldNotVerifyPhoto =>
      'हम आपकी फ़ोटो सत्यापित नहीं कर सके क्योंकि:';

  @override
  String get tryDifferentPhoto => 'कृपया कोई दूसरी फ़ोटो अपलोड करें।';

  @override
  String get addPhotos => 'फ़ोटो जोड़ें';

  @override
  String get addAtLeast2Photos =>
      'मैच पाने के लिए कम से कम 2 फ़ोटो जोड़ें! पहली फ़ोटो मुख्य होगी';

  @override
  String get tapPhotoToEdit => 'जोड़ी गई फ़ोटो पर टैप करके उसे बदलें या हटाएं।';

  @override
  String get addOneMorePhoto => 'कृपया एक और फ़ोटो जोड़ें';

  @override
  String get addMorePhotos => 'और फ़ोटो जोड़ें';

  @override
  String get mainPhotoBadge => 'मुख्य';

  @override
  String get editPhoto => 'फ़ोटो संपादित करें';

  @override
  String get removePhoto => 'फ़ोटो हटाएं';

  @override
  String get realConnectionsStartHere => 'सच्चे रिश्ते यहीं से शुरू होते हैं!';

  @override
  String get createAnAccount => 'खाता बनाएं';

  @override
  String get iHaveAnAccount => 'मेरा खाता है';

  @override
  String get agreeToOurTerms => 'आप हमारी शर्तों से सहमत हैं';

  @override
  String get findPeopleNearYou => 'अपने आस-पास लोग खोजें';

  @override
  String get locationAccessBody =>
      'आपके इलाके के संभावित मैच दिखाने के लिए हमें आपकी\nलोकेशन जाननी होगी। इससे प्रामाणिकता और सुरक्षा के लिए\nआपका सामान्य इलाका भी सत्यापित होता है। चिंता न करें,\nआपकी सटीक लोकेशन कभी साझा नहीं होती';

  @override
  String get allowLocationAccess => 'लोकेशन एक्सेस दें';

  @override
  String get events => 'इवेंट';

  @override
  String get booked => 'बुक किए गए';

  @override
  String get upcoming => 'आने वाले';

  @override
  String get noEventsFound => 'कोई इवेंट नहीं मिला';

  @override
  String get noEventsNearby =>
      'अभी आस-पास कोई इवेंट नहीं है। बाद में देखें या अपनी लोकेशन बदलें।';

  @override
  String get refreshEvents => 'इवेंट रिफ़्रेश करें';

  @override
  String get bookedEvents => 'बुक किए गए इवेंट';

  @override
  String get ticketsAndReservations => 'आपके टिकट और बुकिंग';

  @override
  String get upcomingEvents => 'आने वाले इवेंट';

  @override
  String get eventsYouAreInterested => 'जिन इवेंट में आपकी दिलचस्पी है';

  @override
  String get incomingVideoCall => 'आने वाली वीडियो कॉल';

  @override
  String get incomingVoiceCall => 'आने वाली वॉइस कॉल';

  @override
  String get ringing => 'घंटी बज रही है...';

  @override
  String get speaker => 'स्पीकर';

  @override
  String get mute => 'म्यूट';

  @override
  String get unmute => 'अनम्यूट';

  @override
  String get videoOff => 'वीडियो बंद';

  @override
  String get video => 'वीडियो';

  @override
  String get decline => 'अस्वीकार करें';

  @override
  String get flip => 'कैमरा बदलें';

  @override
  String get callEnded => 'कॉल खत्म';

  @override
  String get howWasCallQuality => 'कॉल की क्वालिटी कैसी थी?';

  @override
  String get switchToVideoCall => 'वीडियो कॉल पर जाएं?';

  @override
  String get otherWantsVideoOn => 'दूसरा व्यक्ति वीडियो चालू करना चाहता है।';

  @override
  String get switchToVoiceCall => 'वॉइस कॉल पर जाएं?';

  @override
  String get otherWantsVideoOff => 'दूसरा व्यक्ति वीडियो बंद करना चाहता है।';

  @override
  String get reject => 'अस्वीकार';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get incomingVideoCallTitle => 'आने वाली वीडियो कॉल';

  @override
  String get incomingVoiceCallTitle => 'आने वाली वॉइस कॉल';

  @override
  String get errorTitle => 'गड़बड़ी';

  @override
  String get successTitle => 'हो गया';

  @override
  String get great => 'बढ़िया!';

  @override
  String get peoples => 'लोग';

  @override
  String get chatTab => 'चैट';

  @override
  String get editProfileTitle => 'प्रोफ़ाइल संपादित करें';

  @override
  String percentComplete(String percent) {
    return '$percent% पूरा';
  }

  @override
  String get profileStrength => 'प्रोफ़ाइल की मज़बूती';

  @override
  String get photosAndVideos => 'फ़ोटो और वीडियो';

  @override
  String get pickSomeTrueYou => 'वो चुनें जो आपका असली रूप दिखाएं।';

  @override
  String get holdDragReorder => 'क्रम बदलने के लिए मीडिया दबाकर खींचें';

  @override
  String get bestPhoto => 'सबसे अच्छी फ़ोटो';

  @override
  String get aboutYouSection => 'आपके बारे में';

  @override
  String get aboutYouHint => 'आपके बारे में...';

  @override
  String get writeFunIntro => 'एक मज़ेदार परिचय लिखें।';

  @override
  String get letPeopleKnowDate =>
      'लोगों को बताएं कि आपके साथ डेट करना कैसा है।';

  @override
  String get addAPrompt => 'एक प्रॉम्प्ट जोड़ें';

  @override
  String get prompts => 'प्रॉम्प्ट';

  @override
  String get prompt => 'प्रॉम्प्ट';

  @override
  String get addVoiceIntro => 'वॉइस परिचय जोड़ें';

  @override
  String get letPeopleHearVoice => 'लोगों को अपनी आवाज़ सुनाएं।';

  @override
  String get reRecordIntro => 'परिचय फिर रिकॉर्ड करें';

  @override
  String get deleteVoiceIntro => 'वॉइस परिचय हटाएं?';

  @override
  String get removeVoiceIntroBody =>
      'इससे आपकी प्रोफ़ाइल से वॉइस परिचय हट जाएगा।';

  @override
  String get interests => 'रुचियाँ';

  @override
  String get addFavoriteInterests => 'अपनी पसंदीदा रुचियाँ जोड़ें';

  @override
  String get getSpecificThingsYouLove =>
      'जो आपको पसंद है उसके बारे में खास बताएं।';

  @override
  String get lifestyle => 'जीवनशैली';

  @override
  String get addLifestylePrefs => 'अपनी जीवनशैली पसंद जोड़ें';

  @override
  String get habitsAndPrefs => 'आपकी आदतें और पसंद।';

  @override
  String get iAmLookingFor => 'मैं ढूंढ रहा/रही हूँ';

  @override
  String get addWhatLookingFor => 'बताएं आप क्या ढूंढ रहे हैं';

  @override
  String get letOthersKnowWant => 'दूसरों को बताएं कि आप क्या पाना चाहते हैं';

  @override
  String get qualitiesIValue => 'मुझे पसंद गुण';

  @override
  String get addQualitiesYouValue => 'अपने पसंदीदा गुण जोड़ें';

  @override
  String get chooseThreeQualitiesValue =>
      'किसी में जो 3 गुण आपको पसंद हैं वे चुनें';

  @override
  String get myCausesSection => 'मेरे मुद्दे और समुदाय';

  @override
  String get addYourCauses => 'अपने मुद्दे और समुदाय जोड़ें';

  @override
  String get addUpTo3Causes => 'अपने दिल के करीब 3 मुद्दे तक जोड़ें।';

  @override
  String get addLanguagesYouKnow => 'आपको आने वाली भाषाएँ जोड़ें';

  @override
  String get moreAboutYou => 'आपके बारे में और';

  @override
  String get heightLabel => 'लंबाई';

  @override
  String get genderLabel => 'लिंग';

  @override
  String get pronounsLabel => 'सर्वनाम';

  @override
  String get pickYourPronouns => 'अपने सर्वनाम चुनें';

  @override
  String get addYourPronouns => 'अपने सर्वनाम जोड़ें';

  @override
  String get workLabel => 'काम';

  @override
  String get educationLevelLabel => 'शिक्षा स्तर';

  @override
  String get hometownLabel => 'गृहनगर';

  @override
  String get locationLabel => 'लोकेशन';

  @override
  String get exerciseLabel => 'कसरत';

  @override
  String get drinkingLabel => 'शराब';

  @override
  String get smokingLabel => 'धूम्रपान';

  @override
  String get kidsLabel => 'बच्चे';

  @override
  String get kidsPreferenceLabel => 'बच्चों को लेकर पसंद';

  @override
  String get politicsLabel => 'राजनीति';

  @override
  String get zodiacLabel => 'राशि';

  @override
  String get educatedAtLabel => 'शिक्षा कहाँ से';

  @override
  String get connectedAccounts => 'जुड़े हुए खाते';

  @override
  String get connectMySpotify => 'मेरा Spotify जोड़ें';

  @override
  String get showFavoriteMusic => 'अपना पसंदीदा संगीत दिखाएं';

  @override
  String get spotifyNote =>
      'अपने पसंदीदा Spotify कलाकार प्रोफ़ाइल पर दिखाएं और Blindly को दूसरों से मिलती-जुलती पसंद उजागर करने दें।';

  @override
  String get verification => 'सत्यापन';

  @override
  String get verified => 'सत्यापित';

  @override
  String get invalidLocation => 'गलत लोकेशन';

  @override
  String get locationFound => 'लोकेशन मिल गई';

  @override
  String get alreadyVerified => 'आप पहले ही सत्यापित हो चुके हैं';

  @override
  String get verificationSuccessful => 'सत्यापन सफल';

  @override
  String get documentNotVerified => 'दस्तावेज़ सत्यापित नहीं हो सका।';

  @override
  String get verificationFailed => 'सत्यापन विफल';

  @override
  String get veriffReason =>
      'हम आपकी ID सत्यापित नहीं कर सके। Veriff ने यह कारण बताया:';

  @override
  String get tryClearerImage => 'कृपया साफ़ तस्वीर के साथ फिर कोशिश करें।';

  @override
  String get veriffWaiting => 'Veriff पूरा हुआ। अपडेट का इंतज़ार है...';

  @override
  String get verificationSubmitted =>
      'सत्यापन भेज दिया गया! आपकी ID जाँची जा रही है...';

  @override
  String get verifyYourProfile => 'अपनी प्रोफ़ाइल सत्यापित करें';

  @override
  String get youAreVerified => 'आप सत्यापित हैं!';

  @override
  String get quickCheckSafe => 'आपकी सुरक्षा के लिए एक छोटी जाँच';

  @override
  String get identityConfirmed => 'आपकी पहचान की पुष्टि हो गई है।';

  @override
  String get veriffExplainer =>
      'आपकी पहचान की पुष्टि के लिए हम सुरक्षित दस्तावेज़ स्कैनिंग हेतु Veriff इस्तेमाल करते हैं।';

  @override
  String get verifyingResults => 'नतीजे जाँचे जा रहे हैं...';

  @override
  String get verificationComplete => 'सत्यापन पूरा';

  @override
  String get tapToScanDocument => 'दस्तावेज़ स्कैन करने के लिए टैप करें';

  @override
  String get prepareIdCard => 'अपना असली ID कार्ड तैयार रखें';

  @override
  String get ensureGoodLighting => 'अच्छी रोशनी रखें';

  @override
  String get readyForSelfie => 'एक झटपट सेल्फ़ी के लिए तैयार रहें';

  @override
  String get processing => 'प्रोसेस हो रहा है...';

  @override
  String get startVerification => 'सत्यापन शुरू करें';

  @override
  String get poweredByVeriff => 'Veriff द्वारा संचालित';

  @override
  String get alignWithCamera => 'खुद को कैमरे के सामने सही जगह रखें';

  @override
  String get cameraPermissionRequired =>
      'सत्यापन के लिए कैमरे की अनुमति ज़रूरी है।';

  @override
  String get noCameraFound => 'डिवाइस में कोई कैमरा नहीं मिला।';

  @override
  String get reviewingYourPhotos => 'हम आपकी फ़ोटो जाँच रहे हैं';

  @override
  String get verificationInProgress =>
      'आपकी प्रोफ़ाइल का सत्यापन चल रहा है। इसमें आमतौर पर कुछ सेकंड लगते हैं।';

  @override
  String get verifiedSuccessfully => 'सफलतापूर्वक सत्यापित!';

  @override
  String get profileVerificationDone =>
      'प्रोफ़ाइल सत्यापन सफलतापूर्वक पूरा हुआ';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get copyThisPose => 'यह पोज़ दोहराएं';

  @override
  String get selfieVerification => 'सेल्फ़ी सत्यापन';

  @override
  String get proveRealDeal => 'साबित करें कि\nआप असली हैं';

  @override
  String get quickHelpsSafe =>
      'यह छोटी सी जाँच हमारे समुदाय को सुरक्षित और असली बनाए रखती है';

  @override
  String get getVerifiedBadge => 'सत्यापित बैज पाएं';

  @override
  String get buildTrustBody =>
      'दूसरों का भरोसा जीतें और दिखाएं कि आप असली हैं।';

  @override
  String get keepCommunitySafe => 'समुदाय को सुरक्षित रखें';

  @override
  String get weedOutFakes => 'नकली प्रोफ़ाइल और बॉट हटाने में हमारी मदद करें।';

  @override
  String get copySimplePose => 'एक आसान पोज़ दोहराएं';

  @override
  String get quickSelfieConfirm =>
      'अपनी पहचान की पुष्टि के लिए एक झटपट सेल्फ़ी लेंगे';

  @override
  String get selfieNotOnProfile =>
      'ध्यान दें: आपकी सेल्फ़ी सिर्फ़ सत्यापन के लिए है और प्रोफ़ाइल पर नहीं दिखेगी';

  @override
  String get getVerified => 'सत्यापित हों';

  @override
  String get voiceIntroTooShort => 'वॉइस परिचय कम से कम 1 सेकंड का होना चाहिए';

  @override
  String get recordVoiceIntroFirst => 'कृपया एक वॉइस परिचय रिकॉर्ड करें';

  @override
  String get recordingBetween1And30 =>
      'रिकॉर्डिंग 1 से 30 सेकंड के बीच होनी चाहिए';

  @override
  String get recordShortIntro => 'एक छोटा परिचय रिकॉर्ड करें';

  @override
  String get personalityShine =>
      'अपनी शख्सियत को चमकने दें। 30 सेकंड का छोटा परिचय रिकॉर्ड करें।';

  @override
  String get recordAgain => 'फिर रिकॉर्ड करें';

  @override
  String get voicePromptsHelp =>
      'वॉइस प्रॉम्प्ट से आप अलग दिखते हैं और गहरे रिश्ते बनते हैं। बताएं आप असल में कौन हैं';

  @override
  String get threeXMatches => 'वॉइस रिकॉर्ड से 3 गुना ज़्यादा मैच';

  @override
  String get startConversationNaturally => 'बातचीत सहज तरीके से शुरू करें';

  @override
  String get showYourPersonality => 'अपनी शख्सियत दिखाएं';

  @override
  String get saveAndContinue => 'सहेजें और आगे बढ़ें';

  @override
  String failedUploadVoice(String error) {
    return 'वॉइस परिचय अपलोड नहीं हो सका: $error';
  }

  @override
  String get failedToStartRecording => 'रिकॉर्डिंग शुरू नहीं हो सकी';

  @override
  String get failedToStopRecording => 'रिकॉर्डिंग रोकी नहीं जा सकी';

  @override
  String get failedToPlayAudio => 'ऑडियो नहीं चल सका';

  @override
  String get navLikes => 'लाइक';

  @override
  String get photoReasonNoFace =>
      'हमें स्पष्ट चेहरा नहीं मिला। ऐसी फोटो लगाएं जिसमें आपका चेहरा दिखे।';

  @override
  String get photoReasonGroupPhoto =>
      'इस फोटो में एक से ज़्यादा लोग हैं। अकेले की फोटो लगाएं।';

  @override
  String get photoReasonFaceTooSmall =>
      'इस फोटो में आपका चेहरा बहुत छोटा है। पास से लें या क्रॉप करें।';

  @override
  String get photoReasonUnsafe =>
      'यह फोटो हमारे दिशानिर्देशों के अनुरूप नहीं है।';

  @override
  String get photoReasonBadImage =>
      'यह फ़ाइल पढ़ी नहीं जा सकी। JPG या PNG आज़माएं।';

  @override
  String get photoReasonTooLarge => 'यह फोटो बहुत बड़ी है। छोटी फोटो आज़माएं।';

  @override
  String get photoReasonUnavailable => 'अभी यह फोटो जाँची नहीं जा सकी।';

  @override
  String get photoTryAgainLater =>
      'कृपया अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get photoLoadFailed => 'आपकी फोटो लोड नहीं हो सकीं।';

  @override
  String get photoSaveFailed => 'फोटो सेव नहीं हो सकीं। फिर से कोशिश करें।';

  @override
  String photosNotAdded(int count) {
    return '$count फोटो जोड़ी नहीं जा सकीं:';
  }

  @override
  String get photosExpired =>
      'कुछ फोटो की समय-सीमा समाप्त हो गई और वे हटा दी गईं। कृपया उन्हें फिर से जोड़ें।';
}
