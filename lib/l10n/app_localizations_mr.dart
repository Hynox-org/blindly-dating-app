// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get appLanguageTitle => 'अ‍ॅपची भाषा';

  @override
  String get systemDefault => 'सिस्टम डीफॉल्ट';

  @override
  String get authTitlePhone => 'तुमचा नंबर सांगा';

  @override
  String get authTitleVerifyNumber => 'तुमचा नंबर सत्यापित करा';

  @override
  String get authTitleEmail => 'ईमेलने लॉगिन करा';

  @override
  String get authTitleVerifyEmail => 'तुमचा ईमेल सत्यापित करा';

  @override
  String get authTitleApple => 'Apple ने लॉगिन करा';

  @override
  String get loginTagline => 'एका सुंदर आयुष्यात लॉगिन करा';

  @override
  String get continueWithGoogle => 'Google ने पुढे जा';

  @override
  String get continueLabel => 'पुढे जा';

  @override
  String get termsSignupPrefix => 'साइन अप करून, तुम्ही आमच्या ';

  @override
  String get termsContinuePrefix => 'पुढे जाऊन, तुम्ही आमच्या ';

  @override
  String get termsWord => 'अटींना';

  @override
  String get termsBridge =>
      ' सहमती देता. आम्ही तुमचा डेटा कसा वापरतो हे पहा आमच्या ';

  @override
  String get privacyPolicyWord => 'गोपनीयता धोरणात';

  @override
  String get termsSuffix => '.';

  @override
  String get phoneRationale =>
      'Blindly वर प्रत्येकजण खरा आहे याची खात्री करण्यासाठीच आम्ही फोन नंबर वापरतो';

  @override
  String get countryLabel => 'देश';

  @override
  String get phoneNumberLabel => 'फोन नंबर';

  @override
  String get phoneHint => 'उदा. 9876543210';

  @override
  String otpSentPhone(String phone) {
    return '$phone वर पाठवलेला कोड टाका. ';
  }

  @override
  String get changeNumber => 'नंबर बदला';

  @override
  String otpSentEmail(String email) {
    return '$email वर ईमेलने पाठवलेला कोड टाका. ';
  }

  @override
  String get changeEmail => 'ईमेल बदला';

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String codeArrivesIn(int seconds) {
    return 'कोड $seconds सेकंदात येईल';
  }

  @override
  String get otpSentSuccess => 'OTP पाठवला आहे';

  @override
  String get loginDetailsSubtitle => 'कृपया खाली तुमचे लॉगिन तपशील टाका';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get errEnterPhone => 'कृपया तुमचा फोन नंबर टाका';

  @override
  String get errPhoneDigitsOnly => 'फोन नंबरमध्ये फक्त अंक असावेत';

  @override
  String get errInvalidPhone => 'कृपया वैध फोन नंबर टाका';

  @override
  String get errInvalidPhoneIndia =>
      'कृपया 6-9 ने सुरू होणारा वैध 10 अंकी भारतीय फोन नंबर टाका';

  @override
  String get errInvalidPhone10Digit => 'कृपया वैध 10 अंकी फोन नंबर टाका';

  @override
  String get errEnterCompleteOtp => 'कृपया संपूर्ण OTP टाका';

  @override
  String get errEnterEmail => 'कृपया तुमचा ईमेल टाका';

  @override
  String get errInvalidEmail => 'कृपया वैध ईमेल पत्ता टाका';

  @override
  String get errFillAllFields => 'कृपया सर्व फील्ड भरा';

  @override
  String get errPasswordMin => 'पासवर्ड किमान 6 अक्षरांचा असावा';

  @override
  String get errTooManyAttempts =>
      'खूप जास्त प्रयत्न. कृपया थोड्या वेळाने पुन्हा प्रयत्न करा.';

  @override
  String errCreateProfile(String error) {
    return 'प्रोफाइल तयार करता आले नाही: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google साइन-इन अयशस्वी: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'लॉगिन अयशस्वी: $error';
  }

  @override
  String errGeneric(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get save => 'जतन करा';

  @override
  String get skip => 'वगळा';

  @override
  String get add => 'जोडा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get update => 'अपडेट करा';

  @override
  String get back => 'मागे';

  @override
  String get done => 'पूर्ण';

  @override
  String get next => 'पुढील';

  @override
  String get edit => 'संपादित करा';

  @override
  String get deleteLabel => 'हटवा';

  @override
  String get close => 'बंद करा';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String get loading => 'लोड होत आहे...';

  @override
  String get somethingWentWrong => 'काहीतरी चूक झाली';

  @override
  String get userNotLoggedIn => 'वापरकर्ता लॉग इन नाही';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get typesOfConnections => 'कनेक्शनचे प्रकार';

  @override
  String get connectionQuestion =>
      'तुम्ही Blindly वर कोणत्या प्रकारचे कनेक्शन शोधत आहात?';

  @override
  String get connectionSubtitle =>
      'डेट आणि रोमान्स, नवीन मित्र, की फक्त व्यवसाय? तुम्ही हे कधीही बदलू शकता.';

  @override
  String get modeDateSubtitle => 'नाते, काहीतरी सहज, किंवा मधले काहीही शोधा';

  @override
  String get modeBffSubtitle => 'नवीन मित्र बनवा आणि तुमचा समुदाय शोधा';

  @override
  String get modeEventsSubtitle =>
      'रोमांचक इव्हेंट शोधा, तिकीट बुक करा, आणि बरेच काही';

  @override
  String continueWithMode(String mode) {
    return '$mode सह पुढे जा';
  }

  @override
  String get multiDeviceTitle => 'अनेक डिव्हाइसवर लॉगिन';

  @override
  String get multiDeviceBody =>
      'तुमचे खाते दुसऱ्या डिव्हाइसवर सक्रिय आहे. सुरक्षेसाठी फक्त एकच सेशन परवानगी आहे.';

  @override
  String get signedOutOtherDevices => 'इतर डिव्हाइसवरून साइन आउट केले!';

  @override
  String get signOutOtherDevices => 'इतर डिव्हाइस साइन आउट करा';

  @override
  String get logOutThisDevice => 'या डिव्हाइसवरून लॉग आउट करा';

  @override
  String get swipeRightHint => 'अधिक जाणून घेण्यासाठी उजवीकडे स्वाइप करा!';

  @override
  String get locationRequiredTitle => 'स्थान आवश्यक';

  @override
  String get locationRequiredBody =>
      'तुमच्या जवळील उत्तम लोक शोधण्यासाठी आम्हाला तुमचे स्थान हवे आहे.\n\nकृपया \"सेटिंग्ज\" वर टॅप करून स्थान परवानगी चालू करा, नंतर \"पुन्हा प्रयत्न करा\" दाबा.';

  @override
  String get settingsTitle => 'सेटिंग्ज';

  @override
  String get notifyMeSnack => 'नवीन लोक सामील झाल्यावर आम्ही तुम्हाला कळवू!';

  @override
  String get nearby => 'जवळपास';

  @override
  String heightCm(String value) {
    return '$value सेमी';
  }

  @override
  String get completeYourProfile => 'तुमची प्रोफाइल पूर्ण करा';

  @override
  String get completeYourProfileBody =>
      'तुम्ही काही पायऱ्या वगळल्या. अ‍ॅपचा पूर्ण फायदा घेण्यासाठी त्या पूर्ण करा.';

  @override
  String get stepNotAvailable => 'ही पायरी अद्याप उपलब्ध नाही.';

  @override
  String get profileNotFound => 'प्रोफाइल सापडली नाही';

  @override
  String get profileUnavailable =>
      'प्रोफाइल सापडली नाही किंवा आता उपलब्ध नाही.';

  @override
  String get profileLoadFailed =>
      'प्रोफाइल लोड होऊ शकली नाही. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get alreadyLikedProfile => 'तुम्ही ही प्रोफाइल आधीच लाईक केली आहे.';

  @override
  String get personAlreadyLikedYou =>
      'या व्यक्तीने तुम्हाला आधीच लाईक केले आहे.';

  @override
  String get youAreMatched => 'तुमचे मॅच झाले आहे.';

  @override
  String get alreadyChatting => 'तुम्ही आधीच गप्पा सुरू केल्या आहेत.';

  @override
  String get profileAlreadySkipped => 'प्रोफाइल आधीच वगळली आहे.';

  @override
  String get goBack => 'मागे जा';

  @override
  String get profilePreview => 'प्रोफाइल पूर्वावलोकन';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get voiceIntro => 'व्हॉइस परिचय';

  @override
  String get bioTitle => 'बायो';

  @override
  String get askAboutMyBio => 'माझ्या बायोबद्दल विचारा!';

  @override
  String get kudos => 'कौतुक';

  @override
  String get aPrompt => 'एक प्रश्न';

  @override
  String get profileVerified => 'प्रोफाइल सत्यापित';

  @override
  String get photoVerified => 'फोटो सत्यापित';

  @override
  String get notVerified => 'सत्यापित नाही';

  @override
  String milesAway(String distance) {
    return '$distance मैल दूर';
  }

  @override
  String trustScore(String score) {
    return 'विश्वास स्कोअर: $score%';
  }

  @override
  String get seeHowYouMatch => 'तुम्ही दोघे कसे जुळता ते पहा';

  @override
  String get aboutMe => 'माझ्याबद्दल';

  @override
  String get imLookingFor => 'मी शोधत आहे';

  @override
  String get quickestWayToHeart =>
      'माझ्या हृदयापर्यंत पोहोचण्याचा सर्वात सोपा मार्ग';

  @override
  String get myInterests => 'माझ्या आवडी';

  @override
  String get myLifestyle => 'माझी जीवनशैली';

  @override
  String smokesLabel(String value) {
    return 'धूम्रपान: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'मद्यपान: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'व्यायाम: $value';
  }

  @override
  String get myCauses => 'माझी कारणे आणि समुदाय';

  @override
  String get languagesTitle => 'भाषा';

  @override
  String get myLocation => 'माझे स्थान';

  @override
  String get myTopArtist => 'Spotify वरील माझा आवडता कलाकार';

  @override
  String get editProfile => 'प्रोफाइल संपादित करा';

  @override
  String get youLikedThem => 'तुम्ही त्यांना लाईक केले!';

  @override
  String get undoNotForMe => '\'माझ्यासाठी नाही\' मागे घ्या';

  @override
  String get notForMe => 'माझ्यासाठी नाही';

  @override
  String get block => 'ब्लॉक करा';

  @override
  String get report => 'तक्रार करा';

  @override
  String get outOfSwipesToday => 'आजचे स्वाइप\nसंपले';

  @override
  String get moreSwipesIn => 'आणखी स्वाइप यामध्ये';

  @override
  String get hoursLabel => 'तास';

  @override
  String get minutesLabel => 'मिनिटे';

  @override
  String get secondsLabel => 'सेकंद';

  @override
  String get sendAndSeeLikes => 'हवे तितके लाईक\nपाठवा आणि पहा';

  @override
  String get sendUnlimitedSwipes => 'अमर्यादित स्वाइप पाठवा';

  @override
  String get advancedSearchFilter => 'प्रगत शोध फिल्टर';

  @override
  String get seeEveryoneWhoLikes => 'तुम्हाला आवडणाऱ्या सर्वांना पहा';

  @override
  String get setMoreDatingPrefs => 'अधिक डेटिंग प्राधान्ये सेट करा';

  @override
  String monthsPlan(String count) {
    return '$count महिने';
  }

  @override
  String get mostPopular => 'सर्वाधिक लोकप्रिय';

  @override
  String get bestValue => 'सर्वोत्तम मूल्य';

  @override
  String getWithPlan(String plan, String price) {
    return '$plan मिळवा $price मध्ये';
  }

  @override
  String offerEndsIn(String time) {
    return 'ऑफर संपण्यास $time';
  }

  @override
  String get chats => 'चॅट';

  @override
  String get conversations => 'संभाषणे';

  @override
  String get recentMatches => 'अलीकडील मॅच';

  @override
  String get readyToMakeFirstMove => 'पहिले पाऊल उचलायला\nतयार?';

  @override
  String get tapToContinueChatting => 'गप्पा सुरू ठेवण्यासाठी टॅप करा';

  @override
  String get unknownUser => 'अज्ञात वापरकर्ता';

  @override
  String get newMatchesAppearHere => 'तुमचे नवीन मॅच येथे दिसतील.';

  @override
  String get endToEndEncrypted => 'एंड-टू-एंड एन्क्रिप्टेड';

  @override
  String get e2eBanner =>
      'संदेश आणि कॉल एंड-टू-एंड एन्क्रिप्टेड आहेत. या चॅटच्या बाहेर कोणीही, अगदी Blindly सुद्धा, ते वाचू किंवा ऐकू शकत नाही. ';

  @override
  String get encryptedMessage => 'एन्क्रिप्टेड संदेश';

  @override
  String get encryptionKeyNotLoaded =>
      'एन्क्रिप्शन की लोड झाली नाही. कृपया थांबा.';

  @override
  String get messageViolatesGuidelines =>
      'हा संदेश आमच्या समुदाय मार्गदर्शक तत्त्वांचे उल्लंघन करू शकतो, म्हणून पाठवला गेला नाही.';

  @override
  String get imageMessage => ' प्रतिमा संदेश';

  @override
  String get voiceMessage => ' व्हॉइस संदेश';

  @override
  String nSelected(String count) {
    return '$count निवडले';
  }

  @override
  String get editedSuffix => '(संपादित)';

  @override
  String get editingMessage => 'संदेश संपादित होत आहे';

  @override
  String get onlyTextEditable => 'फक्त मजकूर संदेश संपादित करता येतात';

  @override
  String get messageCopied => 'संदेश कॉपी झाला';

  @override
  String get archiveChat => 'चॅट संग्रहित करा';

  @override
  String get clearChat => 'चॅट साफ करा';

  @override
  String get blockUser => 'वापरकर्त्याला ब्लॉक करा';

  @override
  String get muteNotifications => 'सूचना म्यूट करा';

  @override
  String get reportAndSpam => 'तक्रार आणि स्पॅम';

  @override
  String get deleteForMe => 'माझ्यासाठी हटवा';

  @override
  String get deleteForEveryone => 'सर्वांसाठी हटवा';

  @override
  String get showTranslation => 'भाषांतर दाखवा';

  @override
  String get showOriginal => 'मूळ दाखवा';

  @override
  String get takePhoto => 'फोटो घ्या';

  @override
  String get chooseFromGallery => 'गॅलरीमधून निवडा';

  @override
  String get attachmentComingSoon => 'अटॅचमेंट पिकर लवकरच येत आहे';

  @override
  String get imageTooLarge => 'प्रतिमा खूप मोठी आहे (कमाल 5MB)';

  @override
  String get micPermissionDenied => 'मायक्रोफोन परवानगी नाकारली';

  @override
  String get recordingEmpty => 'रेकॉर्डिंग फाइल रिकामी आहे';

  @override
  String get recordingNotFound => 'रेकॉर्डिंग फाइल सापडली नाही';

  @override
  String get failedToPlayVoice => 'व्हॉइस संदेश वाजवता आला नाही';

  @override
  String get failedToLoad => 'लोड होऊ शकले नाही';

  @override
  String get errorLoadingGif => 'GIF लोड करताना त्रुटी';

  @override
  String get errorLoadingSticker => 'स्टिकर लोड करताना त्रुटी';

  @override
  String get networkErrorRetry =>
      'नेटवर्क त्रुटी. कृपया तुमचे इंटरनेट कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get serverSideError =>
      'आमच्याकडून काहीतरी चूक झाली. पुन्हा एकदा प्रयत्न करा.';

  @override
  String get pleaseLoginFirst => 'कृपया आधी लॉगिन करा';

  @override
  String get icebreakers => 'आइसब्रेकर';

  @override
  String get iceBreaker => 'आइसब्रेकर';

  @override
  String get couldntLoadIcebreakers => 'आइसब्रेकर लोड होऊ शकले नाहीत';

  @override
  String get aiAnalyzingProfiles => 'AI तुमच्या प्रोफाइल तपासत आहे...';

  @override
  String get generate => 'तयार करा';

  @override
  String get regenerate => 'पुन्हा तयार करा';

  @override
  String get categoryAll => 'सर्व';

  @override
  String get categoryDeep => 'सखोल';

  @override
  String get categoryPlayful => 'खेळकर';

  @override
  String get categoryQuirky => 'वेगळे';

  @override
  String get categoryPersonalized => 'वैयक्तिक';

  @override
  String get categoryQuestion => 'प्रश्न';

  @override
  String get categoryObservation => 'निरीक्षण';

  @override
  String get categoryFunFact => 'मजेदार तथ्य';

  @override
  String get categoryHypothesis => 'गृहीतक';

  @override
  String get categoryOpeningMove => 'पहिली चाल';

  @override
  String get superpowerPrompt =>
      'तुम्हाला कोणतीही एक महाशक्ती मिळाली, तर ती कोणती असेल?';

  @override
  String get chooseAnOption => 'एक पर्याय निवडा';

  @override
  String get invalidMatchData => 'मॅच डेटा अवैध आहे. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get moreOpeningMoves => 'आणखी पहिल्या चाली';

  @override
  String get onlineNow => 'आता ऑनलाइन';

  @override
  String get pleaseEnterMessage => 'कृपया संदेश लिहा';

  @override
  String sendPersonMessage(String name) {
    return '$name ला संदेश पाठवा';
  }

  @override
  String get sendMessage => 'संदेश पाठवा';

  @override
  String get matchHasExpired => 'या मॅचची मुदत संपली आहे.';

  @override
  String get typeOpeningMove => 'तुमचा पहिला संदेश लिहा...';

  @override
  String get use => 'वापरा';

  @override
  String get expiringSoon => 'लवकरच मुदत संपणार';

  @override
  String get matchExpiredTitle => 'मॅचची मुदत संपली';

  @override
  String dontLetThemGetAway(String name) {
    return '$name ला\nजाऊ देऊ नका!';
  }

  @override
  String get limitedTimeBody =>
      'पाऊल उचलण्यासाठी तुमच्याकडे कमी वेळ आहे. मॅच कायमचा नाहीसा होण्याआधी संदेश पाठवा.';

  @override
  String get letThemGo => 'जाऊ द्या';

  @override
  String messagePerson(String name) {
    return '$name ला संदेश पाठवा';
  }

  @override
  String get gifs => 'GIF';

  @override
  String get stickers => 'स्टिकर';

  @override
  String get searchGiphy => 'GIPHY मध्ये शोधा';

  @override
  String get themOnly => 'फक्त त्यांच्यासाठी';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String get icebreakerSmile =>
      'अलीकडे कोणत्या छोट्या गोष्टीने तुम्हाला हसवले?';

  @override
  String get icebreakerTwoTruths => 'दोन सत्ये आणि एक खोटे: सुरू करूया!';

  @override
  String get icebreakerInteresting =>
      'अलीकडे तुम्ही शिकलेली सर्वात रोचक गोष्ट कोणती?';

  @override
  String get openingMoveCushions => 'मी आणि मी बनवलेले कुशन.\nकसे वाटले?';

  @override
  String get openingMove90s => 'पैज लावा, माझा 90s लूक तुम्ही हरवू शकणार नाही';

  @override
  String get openingMovePetName => 'माझ्या पाळीव प्राण्याचे नाव ओळखा?';

  @override
  String get viewProfile => 'प्रोफाइल पहा';

  @override
  String get likedYou => 'तुम्हाला आवडले';

  @override
  String get matchLabel => 'मॅच';

  @override
  String get passLabel => 'पास';

  @override
  String get failedToLoadLikes => 'लाईक लोड होऊ शकले नाहीत';

  @override
  String get noLikesYet => 'अजून लाईक नाहीत, पण\n';

  @override
  String get buzzOff => 'निराश होऊ नका!';

  @override
  String get keepSwipingBody =>
      'तुमचा जोडीदार शोधण्यासाठी स्वाइप करत रहा.\nलवकरच कोणीतरी तुम्हाला नक्की आवडेल!';

  @override
  String get keepSwiping => 'स्वाइप करत रहा';

  @override
  String get startSwiping => 'स्वाइप सुरू करा';

  @override
  String get improveProfile => 'प्रोफाइल सुधारा';

  @override
  String get viewMoreLikes => 'आणखी लाईक पहा';

  @override
  String get seeWhosInterested => 'कोणाला रस आहे ते पहा';

  @override
  String matchInstantly(String count) {
    return 'वाट न पाहता लगेच मॅच करा. तुमच्यासाठी $count+ लाईक वाट पाहत आहेत';
  }

  @override
  String get superLiked => 'सुपर लाईक';

  @override
  String get itsAMatch => 'मॅच झाला!';

  @override
  String youAndThemLiked(String name) {
    return 'तुम्ही आणि $name एकमेकांना आवडलात.';
  }

  @override
  String get sendAMessage => 'संदेश पाठवा';

  @override
  String get notifications => 'सूचना';

  @override
  String get loginToViewNotifications => 'सूचना पाहण्यासाठी लॉगिन करा.';

  @override
  String get noNotificationsYet => 'तुमच्याकडे अजून सूचना नाहीत.';

  @override
  String get discover => 'शोधा';

  @override
  String get reachedEndOfLine => 'तुम्ही शेवटपर्यंत\nपोहोचलात!';

  @override
  String get checkBackSoon =>
      'अधिक लोकांसाठी लवकरच परत या किंवा अधिक प्रोफाइल पाहण्यासाठी फिल्टर बदला.';

  @override
  String get seeMorePeople => 'आणखी लोक पहा';

  @override
  String get topPicksForYou => 'तुमच्यासाठी सर्वोत्तम';

  @override
  String get sharedInterests => 'समान आवडी';

  @override
  String get newFaces => 'नवीन चेहरे';

  @override
  String get recentlyActive => 'अलीकडे सक्रिय';

  @override
  String get seeAll => 'सर्व पहा';

  @override
  String kmAway(String distance) {
    return '$distance किमी दूर';
  }

  @override
  String get letsDiscover => 'चला शोधूया!';

  @override
  String get viewedAllProfiles =>
      'तुमच्या सध्याच्या पसंतीशी जुळणाऱ्या सर्व प्रोफाइल तुम्ही पाहिल्या आहेत. शोध वाढवा किंवा नवीन लोकांसाठी लवकरच परत या.';

  @override
  String get adjustYourFilters => 'तुमचे फिल्टर बदला';

  @override
  String get notifyMeNewPeople => 'नवीन लोकांबद्दल मला कळवा';

  @override
  String youAndPerson(String name) {
    return 'तुम्ही आणि $name';
  }

  @override
  String get workingOutCommon => 'तुमच्यात काय समान आहे ते पाहत आहोत…';

  @override
  String get whyTitle => 'का';

  @override
  String get breakdownTitle => 'तपशील';

  @override
  String get goesBothWays => 'हे दोन्ही बाजूंनी आहे का?';

  @override
  String eachFitsOther(String band) {
    return 'तुम्ही दोघे एकमेकांच्या अपेक्षांना पूर्ण करता: $band.';
  }

  @override
  String get sectionConnections => 'कनेक्शन';

  @override
  String get typeOfConnection => 'कनेक्शनचा प्रकार';

  @override
  String get dateMode => 'डेट मोड';

  @override
  String get travel => 'प्रवास';

  @override
  String get sectionAccountSettings => 'खाते सेटिंग्ज';

  @override
  String get profileAndVerification => 'प्रोफाइल आणि सत्यापन';

  @override
  String get contactAndLoginInfo => 'संपर्क आणि लॉगिन माहिती';

  @override
  String get subscriptionManagement => 'सदस्यता व्यवस्थापन';

  @override
  String get sectionAppPreference => 'अ‍ॅप प्राधान्य';

  @override
  String get notificationsSetting => 'सूचना सेटिंग';

  @override
  String get privacyControls => 'गोपनीयता नियंत्रणे';

  @override
  String get sectionSecurityPrivacy => 'सुरक्षा आणि गोपनीयता';

  @override
  String get accountManagement => 'खाते व्यवस्थापन';

  @override
  String get blockedAccounts => 'ब्लॉक केलेली खाती';

  @override
  String get locationService => 'स्थान सेवा';

  @override
  String get sectionSupportLegal => 'सहाय्य आणि कायदेशीर';

  @override
  String get helpCenter => 'मदत केंद्र';

  @override
  String get privacyPolicyTitle => 'गोपनीयता धोरण';

  @override
  String get termsAndConditions => 'अटी व शर्ती';

  @override
  String get about => 'विषयी';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get deleteAccount => 'खाते हटवा';

  @override
  String get vEnglish => 'इंग्रजी';

  @override
  String get vHindi => 'हिंदी';

  @override
  String get vTamil => 'तमिळ';

  @override
  String get vTelugu => 'तेलुगू';

  @override
  String get vKannada => 'कन्नड';

  @override
  String get vMalayalam => 'मल्याळम';

  @override
  String get vMarathi => 'मराठी';

  @override
  String get vBengali => 'बंगाली';

  @override
  String get vGujarati => 'गुजराती';

  @override
  String get vPunjabi => 'पंजाबी';

  @override
  String get vOdia => 'ओडिया';

  @override
  String get vSpanish => 'स्पॅनिश';

  @override
  String get vFrench => 'फ्रेंच';

  @override
  String get vGerman => 'जर्मन';

  @override
  String get vItalian => 'इटालियन';

  @override
  String get vPortuguese => 'पोर्तुगीज';

  @override
  String get vRussian => 'रशियन';

  @override
  String get vJapanese => 'जपानी';

  @override
  String get vKorean => 'कोरियन';

  @override
  String get vChinese => 'चिनी';

  @override
  String get vArabic => 'अरबी';

  @override
  String get vTurkish => 'तुर्की';

  @override
  String get vOthers => 'इतर';

  @override
  String get vOther => 'इतर';

  @override
  String get vHindu => 'हिंदू';

  @override
  String get vChristian => 'ख्रिश्चन';

  @override
  String get vMuslim => 'मुस्लिम';

  @override
  String get vSikh => 'शीख';

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
  String get vCatholic => 'कॅथलिक';

  @override
  String get vLatterDaySaint => 'लॅटर डे सेंट';

  @override
  String get vZoroastrian => 'पारशी';

  @override
  String get vJewish => 'ज्यू';

  @override
  String get vMormon => 'मॉर्मन';

  @override
  String get vMonogamy => 'एकनिष्ठ नाते';

  @override
  String get vPolyamory => 'बहुप्रेम';

  @override
  String get vOpenRelationship => 'खुले नाते';

  @override
  String get vNonMonogamy => 'अ-एकनिष्ठ';

  @override
  String get vOpenToExploring => 'शोधण्यास तयार';

  @override
  String get vShortTerm => 'अल्पकालीन';

  @override
  String get vLongTerm => 'दीर्घकालीन';

  @override
  String get vStraight => 'स्ट्रेट';

  @override
  String get vGay => 'गे';

  @override
  String get vLesbian => 'लेस्बियन';

  @override
  String get vBisexual => 'बायसेक्शुअल';

  @override
  String get vAsexual => 'असेक्शुअल';

  @override
  String get vDemisexual => 'डेमिसेक्शुअल';

  @override
  String get vPansexual => 'पॅनसेक्शुअल';

  @override
  String get vQueer => 'क्वीअर';

  @override
  String get vQuestioning => 'अनिश्चित';

  @override
  String get vWomen => 'महिला';

  @override
  String get vMen => 'पुरुष';

  @override
  String get vEveryone => 'सर्व';

  @override
  String get vMale => 'पुरुष';

  @override
  String get vFemale => 'स्त्री';

  @override
  String get vFunCasualDates => 'मजेदार, सहज डेट';

  @override
  String get vLifePartner => 'जीवनसाथी';

  @override
  String get vLongTermRelationship => 'दीर्घकालीन नाते';

  @override
  String get vShortTermRelationship => 'अल्पकालीन नाते';

  @override
  String get vStillFiguringOut => 'अजून ठरवले नाही';

  @override
  String get vLongOpenToShort => 'दीर्घकालीन, अल्पकालीनही चालेल';

  @override
  String get vShortOpenToLong => 'अल्पकालीन, दीर्घकालीनही चालेल';

  @override
  String get vCasualDating => 'सहज डेटिंग';

  @override
  String get vNewFriends => 'नवीन मित्र';

  @override
  String get vCloseFriends => 'जवळचे मित्र';

  @override
  String get vActivityPartners => 'उपक्रम सोबती';

  @override
  String get vProfessionalNetworking => 'व्यावसायिक नेटवर्किंग';

  @override
  String get vWorkoutBuddy => 'व्यायाम सोबती';

  @override
  String get vTravelBuddies => 'प्रवासी सोबती';

  @override
  String get vYesIDrink => 'होय, मी पितो/पिते';

  @override
  String get vOccasionally => 'कधीतरी';

  @override
  String get vSometimes => 'कधी कधी';

  @override
  String get vNeverDrink => 'कधीच पित नाही';

  @override
  String get vRegularly => 'नियमितपणे';

  @override
  String get vImSober => 'मी मद्यपान करत नाही';

  @override
  String get vSocially => 'सामाजिक प्रसंगी';

  @override
  String get vNever => 'कधीच नाही';

  @override
  String get vSocialSmoker => 'सामाजिक प्रसंगी धूम्रपान';

  @override
  String get vSmokerWhenDrinking => 'मद्यपान करताना धूम्रपान';

  @override
  String get vNonSmoker => 'धूम्रपान करत नाही';

  @override
  String get vSmoker => 'धूम्रपान करतो/करते';

  @override
  String get vTryingToQuit => 'सोडण्याचा प्रयत्न करत आहे';

  @override
  String get vDaily => 'दररोज';

  @override
  String get vWeekly => 'दर आठवड्याला';

  @override
  String get vHighSchool => 'हायस्कूल';

  @override
  String get vGradeSchool => 'प्राथमिक शाळा';

  @override
  String get vDiploma => 'डिप्लोमा';

  @override
  String get vUnderGraduate => 'पदवीधर';

  @override
  String get vPostGraduate => 'पदव्युत्तर';

  @override
  String get vDoctorate => 'डॉक्टरेट';

  @override
  String get vCommunist => 'साम्यवादी';

  @override
  String get vSocialist => 'समाजवादी';

  @override
  String get vApolitical => 'राजकारणापासून दूर';

  @override
  String get vModerate => 'मध्यममार्गी';

  @override
  String get vNotInterested => 'रस नाही';

  @override
  String get vHaveKids => 'मुले आहेत';

  @override
  String get vDontHaveKids => 'मुले नाहीत';

  @override
  String get vDontWantKids => 'मुले नको आहेत';

  @override
  String get vWantKids => 'मुले हवी आहेत';

  @override
  String get vOpenToKids => 'मुलांसाठी तयार';

  @override
  String get vNotSure => 'नक्की नाही';

  @override
  String get vPreferNotToSay => 'सांगू इच्छित नाही';

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
  String get vLibra => 'तूळ';

  @override
  String get vScorpio => 'वृश्चिक';

  @override
  String get vSagittarius => 'धनु';

  @override
  String get vCapricorn => 'मकर';

  @override
  String get vAquarius => 'कुंभ';

  @override
  String get vPisces => 'मीन';

  @override
  String get vHumanRights => 'मानवी हक्क';

  @override
  String get vDisabilityRights => 'दिव्यांग हक्क';

  @override
  String get vFeminism => 'स्त्रीवाद';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'पर्यावरणवाद';

  @override
  String get vLgbtqRights => 'LGBTQ हक्क';

  @override
  String get vImmigrantRights => 'स्थलांतरित हक्क';

  @override
  String get vEndReligiousHate => 'धार्मिक द्वेष संपवा';

  @override
  String get vIndigenousRights => 'आदिवासी हक्क';

  @override
  String get vNeuroDiversity => 'न्यूरो विविधता';

  @override
  String get vVoterRights => 'मतदार हक्क';

  @override
  String get vReproductiveRights => 'प्रजनन हक्क';

  @override
  String get vAmbition => 'महत्त्वाकांक्षा';

  @override
  String get vConfidence => 'आत्मविश्वास';

  @override
  String get vEmpathy => 'सहानुभूती';

  @override
  String get vHumor => 'विनोदबुद्धी';

  @override
  String get vKindness => 'दयाळूपणा';

  @override
  String get vOpenness => 'मोकळेपणा';

  @override
  String get vOptimism => 'आशावाद';

  @override
  String get vSassiness => 'तडफदारपणा';

  @override
  String get vPlayfulness => 'खेळकरपणा';

  @override
  String get vLeadership => 'नेतृत्व';

  @override
  String get vHumility => 'नम्रता';

  @override
  String get vLoyalty => 'निष्ठा';

  @override
  String get vSarcasm => 'उपरोध';

  @override
  String get vGratitude => 'कृतज्ञता';

  @override
  String get vCuriosity => 'जिज्ञासा';

  @override
  String get vEmotionalIntelligence => 'भावनिक बुद्धिमत्ता';

  @override
  String get datingPreference => 'डेटिंग प्राधान्य';

  @override
  String get bffPreference => 'BFF प्राधान्य';

  @override
  String get whoWouldYouDate => 'तुम्ही कोणासोबत डेट करू इच्छिता?';

  @override
  String get ageRange => 'वयोमर्यादा?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max वर्षे';
  }

  @override
  String get howFarAway => 'ते किती दूर आहेत?';

  @override
  String kilometersAway(String distance) {
    return '$distance किलोमीटर दूर';
  }

  @override
  String get yourInterests => 'तुमच्या आवडी?';

  @override
  String get errorLoadingInterests => 'आवडी लोड होऊ शकल्या नाहीत';

  @override
  String get whichLanguages => 'तुम्हाला कोणत्या भाषा येतात?';

  @override
  String get selectLanguages => 'भाषा निवडा';

  @override
  String get religionQuestion => 'धर्म';

  @override
  String get selectReligion => 'धर्म निवडा';

  @override
  String get relationshipTypeQuestion => 'नात्याचा प्रकार?';

  @override
  String get relationshipTypeTitle => 'नात्याचा प्रकार';

  @override
  String get selectType => 'प्रकार निवडा';

  @override
  String get sexualOrientationQuestion => 'लैंगिक कल?';

  @override
  String get sexualOrientationTitle => 'लैंगिक कल';

  @override
  String get selectOrientation => 'कल निवडा';

  @override
  String get datingIntentionQuestion => 'डेटिंगचा हेतू?';

  @override
  String get datingIntentionTitle => 'डेटिंगचा हेतू';

  @override
  String get selectIntention => 'हेतू निवडा';

  @override
  String get filtersCleared => 'फिल्टर काढले गेले!';

  @override
  String get clearFilters => 'फिल्टर काढा';

  @override
  String get filterByInterests => 'तुमच्या आवडींनुसार फिल्टर करा';

  @override
  String get showMe => 'मला दाखवा';

  @override
  String errUpdateFailed(String error) {
    return 'अपडेट होऊ शकले नाही: $error';
  }

  @override
  String get religionViewTitle => 'धार्मिक दृष्टिकोन';

  @override
  String get sensitiveInfoNote =>
      'ही संवेदनशील माहिती तुमच्या प्रोफाइलवर दिसेल. ही पूर्णपणे ऐच्छिक आहे.';

  @override
  String get zodiacSignTitle => 'राशी';

  @override
  String get doYouDrink => 'तुम्ही मद्यपान करता का?';

  @override
  String get doYouSmoke => 'तुम्ही धूम्रपान करता का?';

  @override
  String get doYouWorkout => 'तुम्ही व्यायाम करता का?';

  @override
  String get educationLevelTitle => 'शिक्षण पातळी';

  @override
  String get politicalViewTitle => 'राजकीय दृष्टिकोन';

  @override
  String get doYouHaveKids => 'तुम्हाला मुले आहेत का?';

  @override
  String get kidsPlanQuestion => 'मुलांबाबत तुमची योजना काय आहे?';

  @override
  String get pickYourPronoun => 'तुमचे सर्वनाम निवडा';

  @override
  String get pronounsBody => 'तुमची सर्वनामे कोणती? ३ निवडा, कधीही काढू शकता.';

  @override
  String get showPronounOnProfile => 'माझ्या प्रोफाइलवर सर्वनाम दाखवा';

  @override
  String get causesTitle => 'कारणे आणि समुदाय';

  @override
  String get selectUpTo3Causes =>
      'तुमच्या मनाजवळचे जास्तीत जास्त ३ पर्याय निवडा.';

  @override
  String get maxThreeOptions => 'जास्तीत जास्त ३ पर्याय निवडू शकता';

  @override
  String get personQualities => 'व्यक्तीचे गुण';

  @override
  String get chooseThreeQualities => 'नाते अधिक घट्ट करणारे ३ गुण निवडा.';

  @override
  String get maxThreeQualities => 'जास्तीत जास्त ३ गुणच निवडू शकता.';

  @override
  String get howTallAreYou => 'तुमची उंची किती आहे?';

  @override
  String get showsOnProfile => 'हे तुमच्या प्रोफाइलवर दिसेल';

  @override
  String get yourHeight => 'तुमची उंची';

  @override
  String get professionTitle => 'व्यवसाय';

  @override
  String get showProfessionOnProfile => 'तुमच्या प्रोफाइलवर व्यवसाय दाखवा';

  @override
  String get titleLabel => 'पद';

  @override
  String get companyIndustry => 'कंपनी (उद्योग)';

  @override
  String get educatedAt => 'शिक्षण संस्था';

  @override
  String get showInstitutionOnProfile => 'तुमच्या प्रोफाइलवर संस्था दाखवा';

  @override
  String get institutionLabel => 'संस्था';

  @override
  String get graduationYear => 'पदवी वर्ष';

  @override
  String get enterInstitution => 'कृपया तुमच्या संस्थेचे नाव टाका.';

  @override
  String get maxThreeLanguages => 'जास्तीत जास्त ३ भाषा निवडू शकता';

  @override
  String get whatLookingFor => 'तुम्ही काय शोधत आहात?';

  @override
  String maxThreeForMode(String mode) {
    return 'सध्याच्या मोडसाठी ($mode) जास्तीत जास्त ३ पर्याय निवडू शकता.';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'प्राधान्ये जतन करताना त्रुटी: $error';
  }

  @override
  String get languagesIKnow => 'मला येणाऱ्या भाषा';

  @override
  String get saveChanges => 'बदल जतन करा';

  @override
  String get searchLanguages => 'भाषा शोधा';

  @override
  String get suggested => 'सुचवलेले';

  @override
  String get allLanguages => 'सर्व भाषा';

  @override
  String get errorLoadingProfile => 'प्रोफाइल लोड होऊ शकली नाही';

  @override
  String percentTrust(String percent) {
    return '$percent% विश्वास';
  }

  @override
  String get profileCompleted => 'प्रोफाइल पूर्ण';

  @override
  String get completeProfile => 'प्रोफाइल पूर्ण करा';

  @override
  String get higherScoreHelps =>
      'जास्त स्कोअरमुळे तुम्हाला अधिक\nखरे मॅच मिळतात';

  @override
  String get noBioYet => 'अजून बायो जोडलेला नाही.';

  @override
  String get askMe => 'मला विचारा';

  @override
  String get activeLabel => 'सक्रिय';

  @override
  String get addReligion => 'धर्म जोडा';

  @override
  String get addZodiac => 'राशी जोडा';

  @override
  String get premium => 'प्रीमियम';

  @override
  String get getNoticedSooner => 'लवकर लक्षात या आणि\n३ पट जास्त डेटवर जा';

  @override
  String get upgrade => 'अपग्रेड करा';

  @override
  String get spotlight => 'स्पॉटलाइट';

  @override
  String get standOut => 'वेगळे दिसा';

  @override
  String get superSwipe => 'सुपर स्वाइप';

  @override
  String get getNoticed => 'लक्षात या';

  @override
  String get scoreBreakdown => 'स्कोअरचा तपशील';

  @override
  String get profilePhotoVerified => 'प्रोफाइल फोटो सत्यापित';

  @override
  String get completedLabel => 'पूर्ण';

  @override
  String get profileDetails => 'प्रोफाइल तपशील';

  @override
  String get incompleteLabel => 'अपूर्ण';

  @override
  String get connectSocialAccounts => 'सोशल खाती जोडा';

  @override
  String get waysToImprove => 'सुधारण्याचे मार्ग';

  @override
  String get verifyYourPhotos => 'तुमचे फोटो सत्यापित करा';

  @override
  String get proveYoureReal => 'तुम्ही खरे आहात हे इतरांना दाखवा';

  @override
  String get addPromptsInterests => 'प्रॉम्प्ट, आवडी आणि इतर तपशील जोडा';

  @override
  String get verificationDataSecure =>
      'तुमचा सत्यापन डेटा सुरक्षित ठेवला जातो आणि सार्वजनिक प्रोफाइलवर सामायिक केला जात नाही. ';

  @override
  String get learnMore => 'अधिक जाणून घ्या';

  @override
  String get improveYourProfile => 'तुमची प्रोफाइल सुधारा';

  @override
  String errorSavingHometown(String error) {
    return 'मूळ गाव जतन करताना त्रुटी: $error';
  }

  @override
  String get searchCity => 'शहर शोधा';

  @override
  String get aboutYou => 'तुमच्याबद्दल';

  @override
  String get bioPrompt =>
      'लाजू नका! छोट्या बायोमध्ये तुमचे व्यक्तिमत्त्व दाखवण्याची हीच संधी आहे.';

  @override
  String get textHereHint => 'इथे लिहा.....';

  @override
  String failedToSaveBio(String error) {
    return 'बायो जतन होऊ शकला नाही: $error';
  }

  @override
  String get selectYourInterests => 'तुमच्या आवडी निवडा';

  @override
  String get atLeast5Interests =>
      'किमान ५ आवडी निवडा. यामुळे तुमच्यासारखे लोक शोधणे सोपे होते';

  @override
  String get searchForInterest => 'आवड शोधा';

  @override
  String get noInterestsFound => 'कोणतीही आवड सापडली नाही';

  @override
  String get failedLoadInterests =>
      'आवडी लोड होऊ शकल्या नाहीत. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get maxTenInterests => 'जास्तीत जास्त १० आवडी निवडू शकता';

  @override
  String get minFiveInterests => 'कृपया किमान ५ आवडी निवडा';

  @override
  String errorSavingInterests(String error) {
    return 'आवडी जतन करताना त्रुटी: $error';
  }

  @override
  String get lifeStyle => 'जीवनशैली';

  @override
  String get lifestylePrompt =>
      'तुमच्या सवयींबद्दल सांगा. तुम्हाला जे जुळते ते निवडा.';

  @override
  String get noLifestyleOptions => 'जीवनशैली पर्याय उपलब्ध नाहीत';

  @override
  String get failedLoadLifestyle =>
      'जीवनशैली पर्याय लोड होऊ शकले नाहीत. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get selectEachCategory =>
      'प्रत्येक श्रेणीसाठी एक पर्याय निवडा, किंवा वगळण्यासाठी सर्व काढा.';

  @override
  String get findYourCity => 'तुमचे सध्याचे शहर शोधा';

  @override
  String errorSavingLocation(String error) {
    return 'स्थान जतन करताना त्रुटी: $error';
  }

  @override
  String get permissionRequired => 'परवानगी आवश्यक';

  @override
  String get permissionRequiredBody =>
      'अ‍ॅप योग्यरित्या चालण्यासाठी ही परवानगी आवश्यक आहे. कृपया सेटिंग्जमध्ये ती चालू करा.';

  @override
  String get cameraAccess => 'कॅमेरा प्रवेश';

  @override
  String get photoLibrary => 'फोटो लायब्ररी';

  @override
  String get locationAccess => 'स्थान प्रवेश';

  @override
  String get notificationAccess => 'सूचना प्रवेश';

  @override
  String get microphoneAccess => 'मायक्रोफोन प्रवेश';

  @override
  String get unknownAccess => 'अज्ञात प्रवेश';

  @override
  String get cameraReason =>
      'प्रोफाइल फोटो घेण्यासाठी आणि ओळख सत्यापित करण्यासाठी.';

  @override
  String get photoReason => 'तुमच्या गॅलरीमधून फोटो अपलोड करण्यासाठी.';

  @override
  String get locationReason => 'जवळपासचे मॅच दाखवण्यासाठी.';

  @override
  String get notificationReason => 'नवीन मॅच आणि संदेशांची माहिती देण्यासाठी.';

  @override
  String get microphoneReason => 'व्हॉइस आणि व्हिडिओ संवादासाठी.';

  @override
  String get appPermissions => 'अ‍ॅप परवानग्या';

  @override
  String get chooseYourPrompt => 'तुमचा प्रॉम्प्ट निवडा';

  @override
  String get selectUpTo3Prompts =>
      'तुमचे व्यक्तिमत्त्व दाखवण्यासाठी ३ पर्यंत प्रॉम्प्ट निवडा.';

  @override
  String get maxThreePrompts => 'जास्तीत जास्त ३ प्रॉम्प्टच निवडू शकता.';

  @override
  String get areYouSure => 'तुम्हाला खात्री आहे का?';

  @override
  String get removeThisPrompt => 'हा प्रॉम्प्ट काढायचा आहे का?';

  @override
  String get selectThreePrompts => 'पुढे जाण्यासाठी ३ प्रॉम्प्ट निवडा.';

  @override
  String get selectOnePrompt => 'किमान १ प्रॉम्प्ट निवडा.';

  @override
  String selectNMorePrompts(String count) {
    return 'पुढे जाण्यासाठी आणखी $count प्रॉम्प्ट निवडा';
  }

  @override
  String get noPromptsForCategory => 'या श्रेणीसाठी प्रॉम्प्ट उपलब्ध नाहीत.';

  @override
  String get typeYourAnswer => 'तुमचे उत्तर लिहा...';

  @override
  String get addPrompt => 'प्रॉम्प्ट जोडा';

  @override
  String failedToLoadPrompts(String error) {
    return 'प्रॉम्प्ट लोड होऊ शकले नाहीत: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'प्रॉम्प्ट जतन करताना त्रुटी: $error';
  }

  @override
  String get communityGuidelines => 'समुदाय मार्गदर्शक तत्त्वे';

  @override
  String get agreeAndContinue => 'सहमत आणि पुढे जा';

  @override
  String get termsByContinuePrefix => 'पुढे जाऊन, तुम्ही आमच्या ';

  @override
  String get guidelinesIntro =>
      'आमच्या समुदायात स्वागत आहे! सर्वांसाठी सुरक्षित आणि सकारात्मक अनुभवासाठी ही सोपी मार्गदर्शक तत्त्वे पाळा.';

  @override
  String get beKindTitle => 'दयाळू आणि आदरपूर्ण रहा';

  @override
  String get beKindBody =>
      'तुम्हाला जसे वागवले जावे असे वाटते तसेच इतरांशी वागा. आपण सर्व मिळून स्वागतशील वातावरण तयार करतो.';

  @override
  String get stayAuthenticTitle => 'खरे रहा';

  @override
  String get stayAuthenticBody =>
      'तुमच्या प्रोफाइलमध्ये आणि संवादात खरे रहा. आम्ही सत्यता आणि खऱ्या नात्यांना महत्त्व देतो.';

  @override
  String get prioritizeSafetyTitle => 'सुरक्षेला प्राधान्य द्या';

  @override
  String get prioritizeSafetyBody =>
      'संवेदनशील आणि वैयक्तिक माहिती सामायिक करू नका. स्वतःचे आणि समुदायातील इतरांचे रक्षण करा.';

  @override
  String get noHateTitle => 'द्वेषपूर्ण बोलणे नाही';

  @override
  String get noHateBody =>
      'छळ, दादागिरी आणि बेकायदेशीर मजकूर येथे खपवून घेतला जात नाही. समुदाय सुरक्षित ठेवण्यास मदत करा.';

  @override
  String get helpKeepSafeTitle => 'आम्हाला सुरक्षित ठेवण्यास मदत करा';

  @override
  String get helpKeepSafeBody =>
      'आमच्या मार्गदर्शक तत्त्वांचे उल्लंघन दिसल्यास कृपया तक्रार करा. तुमची मदत अमूल्य आहे.';

  @override
  String get genuineIntentTitle => 'प्रामाणिक हेतूने डेट करा';

  @override
  String get genuineIntentBody =>
      'आम्ही खऱ्या नात्यांसाठी आहोत. बनावट ओळख किंवा जबरदस्ती चालणार नाही. फसवणूक, तोतयागिरी, किंवा वैयक्तिक/आर्थिक फायद्यासाठी कोणतीही हातचलाखी चालणार नाही.';

  @override
  String get adultsOnlyTitle => 'फक्त प्रौढांसाठी';

  @override
  String get adultsOnlyBody =>
      'Blindly वापरण्यासाठी तुमचे वय १८ किंवा त्याहून अधिक असावे. एकट्या किंवा कपड्यांशिवाय असलेल्या अल्पवयीनांचे फोटो चालणार नाहीत — तुमच्या लहानपणीचे फोटोसुद्धा, ते कितीही गोंडस असले तरी.';

  @override
  String get letsIntroduceYou => 'चला तुमची ओळख करून देऊया!';

  @override
  String get needNameForProfile => 'प्रोफाइल तयार करण्यासाठी तुमचे नाव हवे';

  @override
  String get nameLabel => 'नाव';

  @override
  String get enterYourName => 'तुमचे नाव टाका';

  @override
  String get needDobForProfile =>
      'प्रोफाइल तयार करण्यासाठी तुमची जन्मतारीख हवी';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get birthdayNote =>
      'तुमच्या जन्मतारखेवरून वय काढून ते प्रोफाइलवर दाखवले जाईल. तुमचे पूर्ण नाव सार्वजनिक होणार नाही';

  @override
  String failedToSaveData(String error) {
    return 'डेटा जतन होऊ शकला नाही: $error';
  }

  @override
  String get whatsYourGender => 'तुमचे लिंग काय आहे?';

  @override
  String get genderHelpsMatches =>
      'यामुळे तुम्हाला योग्य प्रोफाइल दाखवणे आणि मॅच शोधणे सोपे होते';

  @override
  String get vNonBinary => 'नॉन-बायनरी';

  @override
  String get vPreferNot => 'सांगू इच्छित नाही';

  @override
  String failedToSaveGender(String error) {
    return 'लिंग जतन होऊ शकले नाही: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'तुमच्या प्रोफाइलसाठी फोटो अपलोड करण्यास $permission परवानगी द्या.';
  }

  @override
  String get gallery => 'गॅलरी';

  @override
  String get camera => 'कॅमेरा';

  @override
  String get photoNotAccepted => 'फोटो स्वीकारला नाही';

  @override
  String get couldNotVerifyPhoto =>
      'आम्ही तुमचा फोटो सत्यापित करू शकलो नाही कारण:';

  @override
  String get tryDifferentPhoto => 'कृपया दुसरा फोटो अपलोड करा.';

  @override
  String get addPhotos => 'फोटो जोडा';

  @override
  String get addAtLeast2Photos =>
      'मॅच मिळवण्यासाठी किमान २ फोटो जोडा! पहिला फोटो मुख्य असेल';

  @override
  String get tapPhotoToEdit =>
      'जोडलेल्या फोटोवर टॅप करून संपादित करा किंवा काढा.';

  @override
  String get addOneMorePhoto => 'कृपया आणखी एक फोटो जोडा';

  @override
  String get addMorePhotos => 'आणखी फोटो जोडा';

  @override
  String get mainPhotoBadge => 'मुख्य';

  @override
  String get editPhoto => 'फोटो संपादित करा';

  @override
  String get removePhoto => 'फोटो काढा';

  @override
  String get realConnectionsStartHere => 'खरी नाती इथूनच सुरू होतात!';

  @override
  String get createAnAccount => 'खाते तयार करा';

  @override
  String get iHaveAnAccount => 'माझे खाते आहे';

  @override
  String get agreeToOurTerms => 'तुम्ही आमच्या अटींना सहमती देता';

  @override
  String get findPeopleNearYou => 'जवळपासचे लोक शोधा';

  @override
  String get locationAccessBody =>
      'तुमच्या भागातील संभाव्य मॅच दाखवण्यासाठी आम्हाला तुमचे\nस्थान माहीत असणे आवश्यक आहे. सत्यता आणि सुरक्षेसाठी तुमचे\nसाधारण स्थान पडताळण्यासही याचा उपयोग होतो. काळजी करू नका,\nतुमचे नेमके स्थान कधीही सामायिक केले जात नाही';

  @override
  String get allowLocationAccess => 'स्थान प्रवेश द्या';

  @override
  String get events => 'इव्हेंट';

  @override
  String get booked => 'बुक केलेले';

  @override
  String get upcoming => 'आगामी';

  @override
  String get noEventsFound => 'कोणतेही इव्हेंट सापडले नाहीत';

  @override
  String get noEventsNearby =>
      'सध्या जवळपास कोणतेही इव्हेंट नाहीत. नंतर पहा किंवा स्थान बदला.';

  @override
  String get refreshEvents => 'इव्हेंट रिफ्रेश करा';

  @override
  String get bookedEvents => 'बुक केलेले इव्हेंट';

  @override
  String get ticketsAndReservations => 'तुमची तिकिटे आणि आरक्षणे';

  @override
  String get upcomingEvents => 'आगामी इव्हेंट';

  @override
  String get eventsYouAreInterested => 'तुम्हाला रस असलेले इव्हेंट';

  @override
  String get incomingVideoCall => 'येणारा व्हिडिओ कॉल';

  @override
  String get incomingVoiceCall => 'येणारा व्हॉइस कॉल';

  @override
  String get ringing => 'रिंग वाजत आहे...';

  @override
  String get speaker => 'स्पीकर';

  @override
  String get mute => 'म्यूट';

  @override
  String get unmute => 'अनम्यूट';

  @override
  String get videoOff => 'व्हिडिओ बंद';

  @override
  String get video => 'व्हिडिओ';

  @override
  String get decline => 'नाकारा';

  @override
  String get flip => 'कॅमेरा बदला';

  @override
  String get callEnded => 'कॉल संपला';

  @override
  String get howWasCallQuality => 'कॉलची गुणवत्ता कशी होती?';

  @override
  String get switchToVideoCall => 'व्हिडिओ कॉलवर जायचे?';

  @override
  String get otherWantsVideoOn => 'दुसऱ्या व्यक्तीला व्हिडिओ चालू करायचा आहे.';

  @override
  String get switchToVoiceCall => 'व्हॉइस कॉलवर जायचे?';

  @override
  String get otherWantsVideoOff => 'दुसऱ्या व्यक्तीला व्हिडिओ बंद करायचा आहे.';

  @override
  String get reject => 'नकार';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get incomingVideoCallTitle => 'येणारा व्हिडिओ कॉल';

  @override
  String get incomingVoiceCallTitle => 'येणारा व्हॉइस कॉल';

  @override
  String get errorTitle => 'त्रुटी';

  @override
  String get successTitle => 'यशस्वी';

  @override
  String get great => 'छान!';

  @override
  String get peoples => 'लोक';

  @override
  String get chatTab => 'चॅट';

  @override
  String get editProfileTitle => 'प्रोफाइल संपादित करा';

  @override
  String percentComplete(String percent) {
    return '$percent% पूर्ण';
  }

  @override
  String get profileStrength => 'प्रोफाइलची ताकद';

  @override
  String get photosAndVideos => 'फोटो आणि व्हिडिओ';

  @override
  String get pickSomeTrueYou => 'तुमचे खरे रूप दाखवणारे निवडा.';

  @override
  String get holdDragReorder => 'क्रम बदलण्यासाठी मीडिया दाबून ओढा';

  @override
  String get bestPhoto => 'सर्वोत्तम फोटो';

  @override
  String get aboutYouSection => 'तुमच्याबद्दल';

  @override
  String get aboutYouHint => 'तुमच्याबद्दल...';

  @override
  String get writeFunIntro => 'एक मजेदार परिचय लिहा.';

  @override
  String get letPeopleKnowDate => 'तुमच्यासोबत डेट करणे कसे असते ते सांगा.';

  @override
  String get addAPrompt => 'एक प्रॉम्प्ट जोडा';

  @override
  String get prompts => 'प्रॉम्प्ट';

  @override
  String get prompt => 'प्रॉम्प्ट';

  @override
  String get addVoiceIntro => 'व्हॉइस परिचय जोडा';

  @override
  String get letPeopleHearVoice => 'लोकांना तुमचा आवाज ऐकवा.';

  @override
  String get reRecordIntro => 'परिचय पुन्हा रेकॉर्ड करा';

  @override
  String get deleteVoiceIntro => 'व्हॉइस परिचय हटवायचा?';

  @override
  String get removeVoiceIntroBody =>
      'यामुळे तुमच्या प्रोफाइलमधून व्हॉइस परिचय काढला जाईल.';

  @override
  String get interests => 'आवडी';

  @override
  String get addFavoriteInterests => 'तुमच्या आवडत्या आवडी जोडा';

  @override
  String get getSpecificThingsYouLove =>
      'तुम्हाला जे आवडते त्याबद्दल नेमके सांगा.';

  @override
  String get lifestyle => 'जीवनशैली';

  @override
  String get addLifestylePrefs => 'तुमची जीवनशैली प्राधान्ये जोडा';

  @override
  String get habitsAndPrefs => 'तुमच्या सवयी आणि प्राधान्ये.';

  @override
  String get iAmLookingFor => 'मी शोधत आहे';

  @override
  String get addWhatLookingFor => 'तुम्ही काय शोधत आहात ते जोडा';

  @override
  String get letOthersKnowWant => 'तुम्हाला काय हवे आहे ते इतरांना कळवा';

  @override
  String get qualitiesIValue => 'मला महत्त्वाचे वाटणारे गुण';

  @override
  String get addQualitiesYouValue => 'तुम्हाला महत्त्वाचे वाटणारे गुण जोडा';

  @override
  String get chooseThreeQualitiesValue =>
      'एखाद्यात तुम्हाला आवडणारे ३ पर्यंत गुण निवडा';

  @override
  String get myCausesSection => 'माझी कारणे आणि समुदाय';

  @override
  String get addYourCauses => 'तुमची कारणे आणि समुदाय जोडा';

  @override
  String get addUpTo3Causes => 'तुमच्या मनाजवळची ३ पर्यंत कारणे जोडा.';

  @override
  String get addLanguagesYouKnow => 'तुम्हाला येणाऱ्या भाषा जोडा';

  @override
  String get moreAboutYou => 'तुमच्याबद्दल आणखी';

  @override
  String get heightLabel => 'उंची';

  @override
  String get genderLabel => 'लिंग';

  @override
  String get pronounsLabel => 'सर्वनामे';

  @override
  String get pickYourPronouns => 'तुमची सर्वनामे निवडा';

  @override
  String get addYourPronouns => 'तुमची सर्वनामे जोडा';

  @override
  String get workLabel => 'काम';

  @override
  String get educationLevelLabel => 'शिक्षण पातळी';

  @override
  String get hometownLabel => 'मूळ गाव';

  @override
  String get locationLabel => 'स्थान';

  @override
  String get exerciseLabel => 'व्यायाम';

  @override
  String get drinkingLabel => 'मद्यपान';

  @override
  String get smokingLabel => 'धूम्रपान';

  @override
  String get kidsLabel => 'मुले';

  @override
  String get kidsPreferenceLabel => 'मुलांबाबत प्राधान्य';

  @override
  String get politicsLabel => 'राजकारण';

  @override
  String get zodiacLabel => 'राशी';

  @override
  String get educatedAtLabel => 'शिक्षण संस्था';

  @override
  String get connectedAccounts => 'जोडलेली खाती';

  @override
  String get connectMySpotify => 'माझे Spotify जोडा';

  @override
  String get showFavoriteMusic => 'तुमचे आवडते संगीत दाखवा';

  @override
  String get spotifyNote =>
      'तुमचे आवडते Spotify कलाकार प्रोफाइलवर दाखवा आणि Blindly ला इतरांशी असलेले साम्य दाखवू द्या.';

  @override
  String get verification => 'सत्यापन';

  @override
  String get verified => 'सत्यापित';

  @override
  String get invalidLocation => 'अवैध स्थान';

  @override
  String get locationFound => 'स्थान सापडले';

  @override
  String get alreadyVerified => 'तुम्ही आधीच सत्यापित आहात';

  @override
  String get verificationSuccessful => 'सत्यापन यशस्वी';

  @override
  String get documentNotVerified => 'कागदपत्र सत्यापित होऊ शकले नाही.';

  @override
  String get verificationFailed => 'सत्यापन अयशस्वी';

  @override
  String get veriffReason =>
      'आम्ही तुमचे ID सत्यापित करू शकलो नाही. Veriff ने हे कारण दिले:';

  @override
  String get tryClearerImage => 'स्पष्ट प्रतिमेसह पुन्हा प्रयत्न करा.';

  @override
  String get veriffWaiting => 'Veriff पूर्ण झाले. अपडेटची वाट पाहत आहोत...';

  @override
  String get verificationSubmitted =>
      'सत्यापन सादर केले! तुमचे ID तपासले जात आहे...';

  @override
  String get verifyYourProfile => 'तुमची प्रोफाइल सत्यापित करा';

  @override
  String get youAreVerified => 'तुम्ही सत्यापित आहात!';

  @override
  String get quickCheckSafe => 'तुमच्या सुरक्षेसाठी एक झटपट तपासणी';

  @override
  String get identityConfirmed => 'तुमची ओळख निश्चित झाली आहे.';

  @override
  String get veriffExplainer =>
      'तुमची ओळख निश्चित करण्यासाठी आम्ही सुरक्षित कागदपत्र स्कॅनिंगसाठी Veriff वापरतो.';

  @override
  String get verifyingResults => 'निकाल तपासले जात आहेत...';

  @override
  String get verificationComplete => 'सत्यापन पूर्ण';

  @override
  String get tapToScanDocument => 'कागदपत्र स्कॅन करण्यासाठी टॅप करा';

  @override
  String get prepareIdCard => 'तुमचे प्रत्यक्ष ID कार्ड तयार ठेवा';

  @override
  String get ensureGoodLighting => 'चांगला प्रकाश असल्याची खात्री करा';

  @override
  String get readyForSelfie => 'एका झटपट सेल्फीसाठी तयार रहा';

  @override
  String get processing => 'प्रक्रिया सुरू आहे...';

  @override
  String get startVerification => 'सत्यापन सुरू करा';

  @override
  String get poweredByVeriff => 'Veriff द्वारे संचालित';

  @override
  String get alignWithCamera => 'कॅमेऱ्यासमोर स्वतःला योग्य ठेवा';

  @override
  String get cameraPermissionRequired =>
      'सत्यापनासाठी कॅमेरा परवानगी आवश्यक आहे.';

  @override
  String get noCameraFound => 'डिव्हाइसवर कॅमेरा सापडला नाही.';

  @override
  String get reviewingYourPhotos => 'आम्ही तुमचे फोटो तपासत आहोत';

  @override
  String get verificationInProgress =>
      'तुमच्या प्रोफाइलचे सत्यापन सुरू आहे. यास सहसा काही सेकंद लागतात.';

  @override
  String get verifiedSuccessfully => 'यशस्वीरित्या सत्यापित!';

  @override
  String get profileVerificationDone =>
      'प्रोफाइल सत्यापन यशस्वीरित्या पूर्ण झाले';

  @override
  String get gotIt => 'समजले';

  @override
  String get copyThisPose => 'ही पोझ करा';

  @override
  String get selfieVerification => 'सेल्फी सत्यापन';

  @override
  String get proveRealDeal => 'तुम्ही खरे आहात\nहे सिद्ध करा';

  @override
  String get quickHelpsSafe =>
      'ही झटपट तपासणी आमचा समुदाय सुरक्षित आणि खरा ठेवते';

  @override
  String get getVerifiedBadge => 'सत्यापित बॅज मिळवा';

  @override
  String get buildTrustBody =>
      'इतरांचा विश्वास मिळवा आणि तुम्ही खरे आहात हे दाखवा.';

  @override
  String get keepCommunitySafe => 'समुदाय सुरक्षित ठेवा';

  @override
  String get weedOutFakes => 'बनावट प्रोफाइल आणि बॉट्स हटवण्यास मदत करा.';

  @override
  String get copySimplePose => 'एक सोपी पोझ करा';

  @override
  String get quickSelfieConfirm =>
      'तुमची ओळख निश्चित करण्यासाठी झटपट सेल्फी घ्याल';

  @override
  String get selfieNotOnProfile =>
      'टीप: तुमची सेल्फी फक्त सत्यापनासाठी आहे, प्रोफाइलवर दिसणार नाही';

  @override
  String get getVerified => 'सत्यापित व्हा';

  @override
  String get voiceIntroTooShort => 'व्हॉइस परिचय किमान १ सेकंदाचा असावा';

  @override
  String get recordVoiceIntroFirst => 'कृपया व्हॉइस परिचय रेकॉर्ड करा';

  @override
  String get recordingBetween1And30 =>
      'रेकॉर्डिंग १ ते ३० सेकंदांदरम्यान असावे';

  @override
  String get recordShortIntro => 'एक छोटा परिचय रेकॉर्ड करा';

  @override
  String get personalityShine =>
      'तुमचे व्यक्तिमत्त्व झळकू द्या. ३० सेकंदांचा छोटा परिचय रेकॉर्ड करा.';

  @override
  String get recordAgain => 'पुन्हा रेकॉर्ड करा';

  @override
  String get voicePromptsHelp =>
      'व्हॉइस प्रॉम्प्टमुळे तुम्ही वेगळे दिसता आणि खोल नाती जुळतात. तुम्ही खरोखर कोण आहात ते सांगा';

  @override
  String get threeXMatches => 'व्हॉइस रेकॉर्डने ३ पट जास्त मॅच';

  @override
  String get startConversationNaturally => 'संवाद सहजपणे सुरू करा';

  @override
  String get showYourPersonality => 'तुमचे व्यक्तिमत्त्व दाखवा';

  @override
  String get saveAndContinue => 'जतन करा आणि पुढे जा';

  @override
  String failedUploadVoice(String error) {
    return 'व्हॉइस परिचय अपलोड होऊ शकला नाही: $error';
  }

  @override
  String get failedToStartRecording => 'रेकॉर्डिंग सुरू होऊ शकले नाही';

  @override
  String get failedToStopRecording => 'रेकॉर्डिंग थांबवता आले नाही';

  @override
  String get failedToPlayAudio => 'ऑडिओ वाजवता आला नाही';

  @override
  String get navLikes => 'लाईक';

  @override
  String get photoReasonNoFace =>
      'स्पष्ट चेहरा आढळला नाही. चेहरा दिसेल असा फोटो वापरा.';

  @override
  String get photoReasonGroupPhoto =>
      'या फोटोमध्ये एकापेक्षा जास्त व्यक्ती आहेत. एकट्याचा फोटो वापरा.';

  @override
  String get photoReasonFaceTooSmall =>
      'या फोटोमध्ये तुमचा चेहरा फार लहान आहे. जवळून घ्या किंवा क्रॉप करा.';

  @override
  String get photoReasonUnsafe =>
      'हा फोटो आमच्या मार्गदर्शक तत्त्वांनुसार नाही.';

  @override
  String get photoReasonBadImage =>
      'ही फाईल वाचता आली नाही. JPG किंवा PNG वापरा.';

  @override
  String get photoReasonTooLarge => 'हा फोटो फार मोठा आहे. लहान फोटो वापरा.';

  @override
  String get photoReasonUnavailable => 'आत्ता हा फोटो तपासता आला नाही.';

  @override
  String get photoTryAgainLater => 'कृपया कनेक्शन तपासून पुन्हा प्रयत्न करा.';

  @override
  String get photoLoadFailed => 'तुमचे फोटो लोड करता आले नाहीत.';

  @override
  String get photoSaveFailed =>
      'फोटो सेव्ह करता आले नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String photosNotAdded(int count) {
    return '$count फोटो जोडता आले नाहीत:';
  }

  @override
  String get photosExpired =>
      'काही फोटोंची मुदत संपल्याने ते काढले गेले. कृपया ते पुन्हा जोडा.';

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
