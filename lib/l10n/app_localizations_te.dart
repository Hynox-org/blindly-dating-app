// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'package:blindly_dating_app/l10n/app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get settingsLanguage => 'భాష';

  @override
  String get appLanguageTitle => 'యాప్ భాష';

  @override
  String get systemDefault => 'సిస్టమ్ డిఫాల్ట్';

  @override
  String get authTitlePhone => 'మీ నంబర్‌ను తెలియజేయండి';

  @override
  String get authTitleVerifyNumber => 'మీ నంబర్‌ను ధృవీకరించండి';

  @override
  String get authTitleEmail => 'ఇమెయిల్‌తో లాగిన్ చేయండి';

  @override
  String get authTitleVerifyEmail => 'మీ ఇమెయిల్‌ను ధృవీకరించండి';

  @override
  String get authTitleApple => 'Apple తో లాగిన్ చేయండి';

  @override
  String get loginTagline => 'ఒక అందమైన జీవితంలోకి లాగిన్ అవ్వండి';

  @override
  String get continueWithGoogle => 'Google తో కొనసాగండి';

  @override
  String get continueLabel => 'కొనసాగించు';

  @override
  String get termsSignupPrefix => 'సైన్ అప్ చేయడం ద్వారా, మీరు మా ';

  @override
  String get termsContinuePrefix => 'కొనసాగించడం ద్వారా, మీరు మా ';

  @override
  String get termsWord => 'నిబంధనలకు';

  @override
  String get termsBridge =>
      ' అంగీకరిస్తున్నారు. మేము మీ డేటాను ఎలా ఉపయోగిస్తామో మా ';

  @override
  String get privacyPolicyWord => 'గోప్యతా విధానంలో';

  @override
  String get termsSuffix => ' చూడండి.';

  @override
  String get phoneRationale =>
      'Blindly లో ప్రతి ఒక్కరూ నిజమైనవారని నిర్ధారించుకోవడానికే మేము ఫోన్ నంబర్‌లను ఉపయోగిస్తాము';

  @override
  String get countryLabel => 'దేశం';

  @override
  String get phoneNumberLabel => 'ఫోన్ నంబర్';

  @override
  String get phoneHint => 'ఉదా. 9876543210';

  @override
  String otpSentPhone(String phone) {
    return '$phone కి మేము పంపిన కోడ్‌ను నమోదు చేయండి. ';
  }

  @override
  String get changeNumber => 'నంబర్ మార్చు';

  @override
  String otpSentEmail(String email) {
    return '$email కి ఇమెయిల్‌లో పంపిన కోడ్‌ను నమోదు చేయండి. ';
  }

  @override
  String get changeEmail => 'ఇమెయిల్ మార్చు';

  @override
  String get resendCode => 'కోడ్‌ను మళ్లీ పంపండి';

  @override
  String codeArrivesIn(int seconds) {
    return 'కోడ్ $seconds సెకన్లలో వస్తుంది';
  }

  @override
  String get otpSentSuccess => 'OTP పంపబడింది';

  @override
  String get loginDetailsSubtitle =>
      'దయచేసి మీ లాగిన్ వివరాలను క్రింద నమోదు చేయండి';

  @override
  String get emailLabel => 'ఇమెయిల్';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'పాస్‌వర్డ్';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get errEnterPhone => 'దయచేసి మీ ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errPhoneDigitsOnly => 'ఫోన్ నంబర్‌లో అంకెలు మాత్రమే ఉండాలి';

  @override
  String get errInvalidPhone =>
      'దయచేసి చెల్లుబాటు అయ్యే ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errInvalidPhoneIndia =>
      '6-9 తో ప్రారంభమయ్యే చెల్లుబాటు అయ్యే 10 అంకెల భారతీయ ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errInvalidPhone10Digit =>
      'చెల్లుబాటు అయ్యే 10 అంకెల ఫోన్ నంబర్ నమోదు చేయండి';

  @override
  String get errEnterCompleteOtp => 'దయచేసి పూర్తి OTP నమోదు చేయండి';

  @override
  String get errEnterEmail => 'దయచేసి మీ ఇమెయిల్ నమోదు చేయండి';

  @override
  String get errInvalidEmail =>
      'దయచేసి చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామా నమోదు చేయండి';

  @override
  String get errFillAllFields => 'దయచేసి అన్ని ఫీల్డ్‌లను పూరించండి';

  @override
  String get errPasswordMin => 'పాస్‌వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి';

  @override
  String get errTooManyAttempts =>
      'చాలా ప్రయత్నాలు. దయచేసి కొంతసేపటి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String errCreateProfile(String error) {
    return 'ప్రొఫైల్ సృష్టించడం విఫలమైంది: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google సైన్-ఇన్ విఫలమైంది: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'లాగిన్ విఫలమైంది: $error';
  }

  @override
  String errGeneric(String error) {
    return 'లోపం: $error';
  }

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get skip => 'దాటవేయి';

  @override
  String get add => 'జోడించు';

  @override
  String get cancel => 'రద్దు';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get update => 'నవీకరించు';

  @override
  String get back => 'వెనుకకు';

  @override
  String get done => 'పూర్తయింది';

  @override
  String get next => 'తదుపరి';

  @override
  String get edit => 'సవరించు';

  @override
  String get deleteLabel => 'తొలగించు';

  @override
  String get close => 'మూసివేయి';

  @override
  String get yes => 'అవును';

  @override
  String get no => 'కాదు';

  @override
  String get loading => 'లోడ్ అవుతోంది...';

  @override
  String get somethingWentWrong => 'ఏదో తప్పు జరిగింది';

  @override
  String get userNotLoggedIn => 'వినియోగదారు లాగిన్ కాలేదు';

  @override
  String get unknown => 'తెలియదు';

  @override
  String get typesOfConnections => 'కనెక్షన్ రకాలు';

  @override
  String get connectionQuestion =>
      'Blindly లో మీరు ఎలాంటి కనెక్షన్ కోసం చూస్తున్నారు?';

  @override
  String get connectionSubtitle =>
      'డేటింగ్ మరియు ప్రేమ, కొత్త స్నేహితులు, లేదా కేవలం వ్యాపారమా? దీన్ని మీరు ఎప్పుడైనా మార్చుకోవచ్చు.';

  @override
  String get modeDateSubtitle =>
      'సంబంధం, సాధారణ పరిచయం, లేదా మధ్యలో ఏదైనా కనుగొనండి';

  @override
  String get modeBffSubtitle =>
      'కొత్త స్నేహితులను చేసుకోండి మరియు మీ సముదాయాన్ని కనుగొనండి';

  @override
  String get modeEventsSubtitle =>
      'ఆసక్తికరమైన ఈవెంట్‌లను కనుగొనండి, టికెట్లు బుక్ చేయండి, మరిన్ని';

  @override
  String continueWithMode(String mode) {
    return '$mode తో కొనసాగించు';
  }

  @override
  String get multiDeviceTitle => 'బహుళ-పరికర లాగిన్';

  @override
  String get multiDeviceBody =>
      'మీ ఖాతా మరో పరికరంలో యాక్టివ్‌గా ఉంది. భద్రత కోసం ఒక సెషన్ మాత్రమే అనుమతించబడుతుంది.';

  @override
  String get signedOutOtherDevices => 'ఇతర పరికరాల నుండి సైన్ అవుట్ చేయబడింది!';

  @override
  String get signOutOtherDevices => 'ఇతర పరికరాలను సైన్ అవుట్ చేయి';

  @override
  String get logOutThisDevice => 'ఈ పరికరం నుండి లాగ్ అవుట్ చేయి';

  @override
  String get swipeRightHint => 'మరింత తెలుసుకోవడానికి కుడివైపు స్వైప్ చేయండి!';

  @override
  String get locationRequiredTitle => 'లొకేషన్ అవసరం';

  @override
  String get locationRequiredBody =>
      'మీ దగ్గరలోని అద్భుతమైన వ్యక్తులను కనుగొనడానికి మాకు మీ లొకేషన్ కావాలి.\n\nదయచేసి \"సెట్టింగ్‌లు\" నొక్కి లొకేషన్ అనుమతిని ఆన్ చేసి, ఆపై \"మళ్లీ ప్రయత్నించు\" నొక్కండి.';

  @override
  String get settingsTitle => 'సెట్టింగ్‌లు';

  @override
  String get notifyMeSnack => 'కొత్తవారు చేరినప్పుడు మేము మీకు తెలియజేస్తాము!';

  @override
  String get nearby => 'సమీపంలో';

  @override
  String heightCm(String value) {
    return '$value సెం.మీ';
  }

  @override
  String get completeYourProfile => 'మీ ప్రొఫైల్‌ను పూర్తి చేయండి';

  @override
  String get completeYourProfileBody =>
      'మీరు కొన్ని దశలను దాటవేశారు. యాప్‌ను పూర్తిగా వినియోగించుకోవడానికి వాటిని పూర్తి చేయండి.';

  @override
  String get stepNotAvailable => 'ఈ దశ ఇంకా అందుబాటులో లేదు.';

  @override
  String get profileNotFound => 'ప్రొఫైల్ కనుగొనబడలేదు';

  @override
  String get profileUnavailable =>
      'ప్రొఫైల్ కనుగొనబడలేదు లేదా ఇక అందుబాటులో లేదు.';

  @override
  String get profileLoadFailed =>
      'ప్రొఫైల్ లోడ్ కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get alreadyLikedProfile => 'మీరు ఈ ప్రొఫైల్‌ను ఇప్పటికే లైక్ చేశారు.';

  @override
  String get personAlreadyLikedYou =>
      'ఈ వ్యక్తి ఇప్పటికే మిమ్మల్ని లైక్ చేశారు.';

  @override
  String get youAreMatched => 'మీరు మ్యాచ్ అయ్యారు.';

  @override
  String get alreadyChatting => 'మీరు ఇప్పటికే చాట్ ప్రారంభించారు.';

  @override
  String get profileAlreadySkipped => 'ప్రొఫైల్ ఇప్పటికే దాటవేయబడింది.';

  @override
  String get goBack => 'వెనుకకు వెళ్లు';

  @override
  String get profilePreview => 'ప్రొఫైల్ ప్రివ్యూ';

  @override
  String get profileTitle => 'ప్రొఫైల్';

  @override
  String get voiceIntro => 'వాయిస్ పరిచయం';

  @override
  String get bioTitle => 'బయో';

  @override
  String get askAboutMyBio => 'నా బయో గురించి అడగండి!';

  @override
  String get kudos => 'ప్రశంసలు';

  @override
  String get aPrompt => 'ఒక ప్రశ్న';

  @override
  String get profileVerified => 'ప్రొఫైల్ ధృవీకరించబడింది';

  @override
  String get photoVerified => 'ఫోటో ధృవీకరించబడింది';

  @override
  String get notVerified => 'ధృవీకరించబడలేదు';

  @override
  String milesAway(String distance) {
    return '$distance మైళ్ల దూరం';
  }

  @override
  String trustScore(String score) {
    return 'విశ్వాస స్కోరు: $score%';
  }

  @override
  String get seeHowYouMatch => 'మీరిద్దరూ ఎలా సరిపోతారో చూడండి';

  @override
  String get aboutMe => 'నా గురించి';

  @override
  String get imLookingFor => 'నేను వెతుకుతున్నది';

  @override
  String get quickestWayToHeart => 'నా హృదయాన్ని గెలుచుకునే సులభమైన మార్గం';

  @override
  String get myInterests => 'నా ఆసక్తులు';

  @override
  String get myLifestyle => 'నా జీవనశైలి';

  @override
  String smokesLabel(String value) {
    return 'ధూమపానం: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'మద్యం: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'వ్యాయామం: $value';
  }

  @override
  String get myCauses => 'నా కారణాలు మరియు సముదాయాలు';

  @override
  String get languagesTitle => 'భాషలు';

  @override
  String get myLocation => 'నా లొకేషన్';

  @override
  String get myTopArtist => 'Spotify లో నా అభిమాన కళాకారుడు';

  @override
  String get editProfile => 'ప్రొఫైల్ సవరించు';

  @override
  String get youLikedThem => 'మీరు వారిని లైక్ చేశారు!';

  @override
  String get undoNotForMe => '\'నాకు కాదు\' ను రద్దు చేయి';

  @override
  String get notForMe => 'నాకు కాదు';

  @override
  String get block => 'బ్లాక్ చేయి';

  @override
  String get report => 'రిపోర్ట్ చేయి';

  @override
  String get outOfSwipesToday => 'ఈ రోజుకి స్వైప్‌లు\nఅయిపోయాయి';

  @override
  String get moreSwipesIn => 'మరిన్ని స్వైప్‌లు ఇందులో';

  @override
  String get hoursLabel => 'గంటలు';

  @override
  String get minutesLabel => 'నిమిషాలు';

  @override
  String get secondsLabel => 'సెకన్లు';

  @override
  String get sendAndSeeLikes => 'మీకు కావలసినన్ని\nలైక్‌లు పంపి చూడండి';

  @override
  String get sendUnlimitedSwipes => 'అపరిమిత స్వైప్‌లు పంపండి';

  @override
  String get advancedSearchFilter => 'అధునాతన శోధన ఫిల్టర్';

  @override
  String get seeEveryoneWhoLikes => 'మిమ్మల్ని ఇష్టపడే వారందరినీ చూడండి';

  @override
  String get setMoreDatingPrefs => 'మరిన్ని డేటింగ్ ప్రాధాన్యతలు సెట్ చేయండి';

  @override
  String monthsPlan(String count) {
    return '$count నెలలు';
  }

  @override
  String get mostPopular => 'అత్యంత జనాదరణ';

  @override
  String get bestValue => 'అత్యుత్తమ విలువ';

  @override
  String getWithPlan(String plan, String price) {
    return '$plan ను $price కు పొందండి';
  }

  @override
  String offerEndsIn(String time) {
    return 'ఆఫర్ ముగియడానికి $time';
  }

  @override
  String get chats => 'చాట్‌లు';

  @override
  String get conversations => 'సంభాషణలు';

  @override
  String get recentMatches => 'ఇటీవలి మ్యాచ్‌లు';

  @override
  String get readyToMakeFirstMove => 'మొదటి అడుగు వేయడానికి\nసిద్ధమా?';

  @override
  String get tapToContinueChatting => 'చాట్ కొనసాగించడానికి నొక్కండి';

  @override
  String get unknownUser => 'తెలియని వినియోగదారు';

  @override
  String get newMatchesAppearHere => 'మీ కొత్త మ్యాచ్‌లు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get endToEndEncrypted => 'ఎండ్-టు-ఎండ్ ఎన్‌క్రిప్టెడ్';

  @override
  String get e2eBanner =>
      'సందేశాలు మరియు కాల్‌లు ఎండ్-టు-ఎండ్ ఎన్‌క్రిప్ట్ చేయబడ్డాయి. ఈ చాట్ వెలుపల ఎవరూ, Blindly కూడా, వాటిని చదవలేరు లేదా వినలేరు. ';

  @override
  String get encryptedMessage => 'ఎన్‌క్రిప్టెడ్ సందేశం';

  @override
  String get encryptionKeyNotLoaded =>
      'ఎన్‌క్రిప్షన్ కీ లోడ్ కాలేదు. దయచేసి వేచి ఉండండి.';

  @override
  String get messageViolatesGuidelines =>
      'ఈ సందేశం మా కమ్యూనిటీ మార్గదర్శకాలను ఉల్లంఘించవచ్చు, అందుకే పంపబడలేదు.';

  @override
  String get imageMessage => ' చిత్ర సందేశం';

  @override
  String get voiceMessage => ' వాయిస్ సందేశం';

  @override
  String nSelected(String count) {
    return '$count ఎంపిక చేయబడింది';
  }

  @override
  String get editedSuffix => '(సవరించబడింది)';

  @override
  String get editingMessage => 'సందేశం సవరించబడుతోంది';

  @override
  String get onlyTextEditable => 'టెక్స్ట్ సందేశాలను మాత్రమే సవరించగలరు';

  @override
  String get messageCopied => 'సందేశం కాపీ చేయబడింది';

  @override
  String get archiveChat => 'చాట్‌ను ఆర్కైవ్ చేయి';

  @override
  String get clearChat => 'చాట్‌ను క్లియర్ చేయి';

  @override
  String get blockUser => 'వినియోగదారుని బ్లాక్ చేయి';

  @override
  String get muteNotifications => 'నోటిఫికేషన్‌లను మ్యూట్ చేయి';

  @override
  String get reportAndSpam => 'రిపోర్ట్ చేసి స్పామ్‌గా గుర్తించు';

  @override
  String get deleteForMe => 'నా కోసం తొలగించు';

  @override
  String get deleteForEveryone => 'అందరి కోసం తొలగించు';

  @override
  String get showTranslation => 'అనువాదం చూపించు';

  @override
  String get showOriginal => 'అసలుది చూపించు';

  @override
  String get takePhoto => 'ఫోటో తీయి';

  @override
  String get chooseFromGallery => 'గ్యాలరీ నుండి ఎంచుకో';

  @override
  String get attachmentComingSoon => 'అటాచ్‌మెంట్ పికర్ త్వరలో';

  @override
  String get imageTooLarge => 'చిత్రం చాలా పెద్దది (గరిష్టం 5MB)';

  @override
  String get micPermissionDenied => 'మైక్రోఫోన్ అనుమతి నిరాకరించబడింది';

  @override
  String get recordingEmpty => 'రికార్డింగ్ ఫైల్ ఖాళీగా ఉంది';

  @override
  String get recordingNotFound => 'రికార్డింగ్ ఫైల్ కనుగొనబడలేదు';

  @override
  String get failedToPlayVoice => 'వాయిస్ సందేశం ప్లే కాలేదు';

  @override
  String get failedToLoad => 'లోడ్ కాలేదు';

  @override
  String get errorLoadingGif => 'GIF లోడ్ చేయడంలో లోపం';

  @override
  String get errorLoadingSticker => 'స్టిక్కర్ లోడ్ చేయడంలో లోపం';

  @override
  String get networkErrorRetry =>
      'నెట్‌వర్క్ లోపం. మీ ఇంటర్నెట్ కనెక్షన్ తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get serverSideError =>
      'మా వైపు ఏదో పొరపాటు జరిగింది. మరోసారి ప్రయత్నించండి.';

  @override
  String get pleaseLoginFirst => 'ముందుగా లాగిన్ చేయండి';

  @override
  String get icebreakers => 'సంభాషణ ఆరంభాలు';

  @override
  String get iceBreaker => 'సంభాషణ ఆరంభం';

  @override
  String get couldntLoadIcebreakers => 'సంభాషణ ఆరంభాలు లోడ్ కాలేదు';

  @override
  String get aiAnalyzingProfiles => 'AI మీ ప్రొఫైల్‌లను విశ్లేషిస్తోంది...';

  @override
  String get generate => 'సృష్టించు';

  @override
  String get regenerate => 'మళ్లీ సృష్టించు';

  @override
  String get categoryAll => 'అన్నీ';

  @override
  String get categoryDeep => 'లోతైన';

  @override
  String get categoryPlayful => 'సరదా';

  @override
  String get categoryQuirky => 'విచిత్రమైన';

  @override
  String get categoryPersonalized => 'వ్యక్తిగతీకరించిన';

  @override
  String get categoryQuestion => 'ప్రశ్న';

  @override
  String get categoryObservation => 'పరిశీలన';

  @override
  String get categoryFunFact => 'ఆసక్తికర విషయం';

  @override
  String get categoryHypothesis => 'ఊహ';

  @override
  String get categoryOpeningMove => 'మొదటి అడుగు';

  @override
  String get superpowerPrompt => 'మీకు ఏదైనా ఒక మహాశక్తి లభిస్తే, అది ఏమిటి?';

  @override
  String get chooseAnOption => 'ఒక ఎంపికను ఎంచుకోండి';

  @override
  String get invalidMatchData =>
      'మ్యాచ్ డేటా చెల్లదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get moreOpeningMoves => 'మరిన్ని మొదటి అడుగులు';

  @override
  String get onlineNow => 'ఇప్పుడు ఆన్‌లైన్‌లో';

  @override
  String get pleaseEnterMessage => 'దయచేసి సందేశం రాయండి';

  @override
  String sendPersonMessage(String name) {
    return '$name కు సందేశం పంపండి';
  }

  @override
  String get sendMessage => 'సందేశం పంపు';

  @override
  String get matchHasExpired => 'ఈ మ్యాచ్ గడువు ముగిసింది.';

  @override
  String get typeOpeningMove => 'మీ మొదటి సందేశం రాయండి...';

  @override
  String get use => 'వాడు';

  @override
  String get expiringSoon => 'త్వరలో గడువు ముగుస్తుంది';

  @override
  String get matchExpiredTitle => 'మ్యాచ్ గడువు ముగిసింది';

  @override
  String dontLetThemGetAway(String name) {
    return '$name ను\nవదులుకోకండి!';
  }

  @override
  String get limitedTimeBody =>
      'చర్య తీసుకోవడానికి మీకు తక్కువ సమయం మిగిలింది. మ్యాచ్ శాశ్వతంగా అదృశ్యమయ్యే ముందు సందేశం పంపండి.';

  @override
  String get letThemGo => 'వదిలేయండి';

  @override
  String messagePerson(String name) {
    return '$name కు సందేశం పంపు';
  }

  @override
  String get gifs => 'GIF';

  @override
  String get stickers => 'స్టిక్కర్లు';

  @override
  String get searchGiphy => 'GIPHY లో వెతకండి';

  @override
  String get themOnly => 'వారు మాత్రమే';

  @override
  String get tryAgain => 'మళ్లీ ప్రయత్నించు';

  @override
  String get icebreakerSmile => 'ఇటీవల ఏ చిన్న విషయం మిమ్మల్ని నవ్వించింది?';

  @override
  String get icebreakerTwoTruths => 'రెండు నిజాలు, ఒక అబద్ధం: మొదలుపెడదాం!';

  @override
  String get icebreakerInteresting =>
      'ఇటీవల మీరు నేర్చుకున్న అత్యంత ఆసక్తికరమైన విషయం ఏమిటి?';

  @override
  String get openingMoveCushions => 'నేను, నేను చేసిన కుషన్లు.\nఎలా ఉన్నాయి?';

  @override
  String get openingMove90s => 'నా 90s లుక్‌ను మీరు ఓడించలేరు';

  @override
  String get openingMovePetName => 'నా పెంపుడు జంతువు పేరు ఊహించగలరా?';

  @override
  String get viewProfile => 'ప్రొఫైల్ చూడు';

  @override
  String get likedYou => 'మిమ్మల్ని లైక్ చేశారు';

  @override
  String get matchLabel => 'మ్యాచ్';

  @override
  String get passLabel => 'వదిలేయి';

  @override
  String get failedToLoadLikes => 'లైక్‌లు లోడ్ కాలేదు';

  @override
  String get noLikesYet => 'ఇంకా లైక్‌లు లేవు, కానీ\n';

  @override
  String get buzzOff => 'నిరాశ చెందకండి!';

  @override
  String get keepSwipingBody =>
      'మీ జోడీని కనుగొనడానికి స్వైప్ చేస్తూ ఉండండి.\nత్వరలో ఎవరో ఒకరు మిమ్మల్ని ఇష్టపడతారు!';

  @override
  String get keepSwiping => 'స్వైప్ చేస్తూ ఉండండి';

  @override
  String get startSwiping => 'స్వైప్ ప్రారంభించు';

  @override
  String get improveProfile => 'ప్రొఫైల్‌ను మెరుగుపరచు';

  @override
  String get viewMoreLikes => 'మరిన్ని లైక్‌లు చూడు';

  @override
  String get seeWhosInterested => 'ఎవరికి ఆసక్తి ఉందో చూడండి';

  @override
  String matchInstantly(String count) {
    return 'వేచి ఉండకుండా వెంటనే మ్యాచ్ అవ్వండి. మీకు $count+ లైక్‌లు వేచి ఉన్నాయి';
  }

  @override
  String get superLiked => 'సూపర్ లైక్';

  @override
  String get itsAMatch => 'మ్యాచ్ అయ్యింది!';

  @override
  String youAndThemLiked(String name) {
    return 'మీరు మరియు $name ఒకరినొకరు ఇష్టపడ్డారు.';
  }

  @override
  String get sendAMessage => 'సందేశం పంపు';

  @override
  String get notifications => 'నోటిఫికేషన్‌లు';

  @override
  String get loginToViewNotifications =>
      'నోటిఫికేషన్‌లు చూడటానికి లాగిన్ చేయండి.';

  @override
  String get noNotificationsYet => 'మీకు ఇంకా నోటిఫికేషన్‌లు లేవు.';

  @override
  String get discover => 'కనుగొను';

  @override
  String get reachedEndOfLine => 'మీరు చివరికి\nచేరుకున్నారు!';

  @override
  String get checkBackSoon =>
      'మరింత మంది కోసం త్వరలో తిరిగి చూడండి లేదా మరిన్ని ప్రొఫైల్‌ల కోసం ఫిల్టర్‌లను మార్చండి.';

  @override
  String get seeMorePeople => 'మరింత మందిని చూడు';

  @override
  String get topPicksForYou => 'మీ కోసం అత్యుత్తమం';

  @override
  String get sharedInterests => 'ఉమ్మడి ఆసక్తులు';

  @override
  String get newFaces => 'కొత్త ముఖాలు';

  @override
  String get recentlyActive => 'ఇటీవల యాక్టివ్';

  @override
  String get seeAll => 'అన్నీ చూడు';

  @override
  String kmAway(String distance) {
    return '$distance కి.మీ దూరం';
  }

  @override
  String get letsDiscover => 'కనుగొందాం!';

  @override
  String get viewedAllProfiles =>
      'మీ ప్రస్తుత ప్రాధాన్యతకు సరిపోయే అన్ని ప్రొఫైల్‌లను మీరు చూశారు. శోధనను విస్తరించండి లేదా కొత్తవారి కోసం త్వరలో తిరిగి చూడండి.';

  @override
  String get adjustYourFilters => 'మీ ఫిల్టర్‌లను మార్చు';

  @override
  String get notifyMeNewPeople => 'కొత్తవారి గురించి నాకు తెలియజేయి';

  @override
  String youAndPerson(String name) {
    return 'మీరు మరియు $name';
  }

  @override
  String get workingOutCommon => 'మీ ఇద్దరిలో ఏమి ఉమ్మడిగా ఉందో చూస్తున్నాము…';

  @override
  String get whyTitle => 'ఎందుకు';

  @override
  String get breakdownTitle => 'వివరణ';

  @override
  String get goesBothWays => 'ఇది రెండు వైపులా ఉందా?';

  @override
  String eachFitsOther(String band) {
    return 'మీరిద్దరూ ఒకరికొకరు వెతుకుతున్నదానికి సరిపోతారు: $band.';
  }

  @override
  String get sectionConnections => 'కనెక్షన్‌లు';

  @override
  String get typeOfConnection => 'కనెక్షన్ రకం';

  @override
  String get dateMode => 'డేట్ మోడ్';

  @override
  String get travel => 'ప్రయాణం';

  @override
  String get sectionAccountSettings => 'ఖాతా సెట్టింగ్‌లు';

  @override
  String get profileAndVerification => 'ప్రొఫైల్ & ధృవీకరణ';

  @override
  String get contactAndLoginInfo => 'సంప్రదింపు & లాగిన్ సమాచారం';

  @override
  String get subscriptionManagement => 'సబ్‌స్క్రిప్షన్ నిర్వహణ';

  @override
  String get sectionAppPreference => 'యాప్ ప్రాధాన్యత';

  @override
  String get notificationsSetting => 'నోటిఫికేషన్ సెట్టింగ్';

  @override
  String get privacyControls => 'గోప్యతా నియంత్రణలు';

  @override
  String get sectionSecurityPrivacy => 'భద్రత & గోప్యత';

  @override
  String get accountManagement => 'ఖాతా నిర్వహణ';

  @override
  String get blockedAccounts => 'బ్లాక్ చేసిన ఖాతాలు';

  @override
  String get locationService => 'లొకేషన్ సేవ';

  @override
  String get sectionSupportLegal => 'మద్దతు & చట్టపరమైనవి';

  @override
  String get helpCenter => 'సహాయ కేంద్రం';

  @override
  String get privacyPolicyTitle => 'గోప్యతా విధానం';

  @override
  String get termsAndConditions => 'నిబంధనలు & షరతులు';

  @override
  String get about => 'గురించి';

  @override
  String get logout => 'లాగ్ అవుట్';

  @override
  String get deleteAccount => 'ఖాతాను తొలగించు';

  @override
  String get vEnglish => 'ఇంగ్లీష్';

  @override
  String get vHindi => 'హిందీ';

  @override
  String get vTamil => 'తమిళం';

  @override
  String get vTelugu => 'తెలుగు';

  @override
  String get vKannada => 'కన్నడ';

  @override
  String get vMalayalam => 'మలయాళం';

  @override
  String get vMarathi => 'మరాఠీ';

  @override
  String get vBengali => 'బెంగాలీ';

  @override
  String get vGujarati => 'గుజరాతీ';

  @override
  String get vPunjabi => 'పంజాబీ';

  @override
  String get vOdia => 'ఒడియా';

  @override
  String get vSpanish => 'స్పానిష్';

  @override
  String get vFrench => 'ఫ్రెంచ్';

  @override
  String get vGerman => 'జర్మన్';

  @override
  String get vItalian => 'ఇటాలియన్';

  @override
  String get vPortuguese => 'పోర్చుగీస్';

  @override
  String get vRussian => 'రష్యన్';

  @override
  String get vJapanese => 'జపనీస్';

  @override
  String get vKorean => 'కొరియన్';

  @override
  String get vChinese => 'చైనీస్';

  @override
  String get vArabic => 'అరబిక్';

  @override
  String get vTurkish => 'టర్కిష్';

  @override
  String get vOthers => 'ఇతరులు';

  @override
  String get vOther => 'ఇతర';

  @override
  String get vHindu => 'హిందూ';

  @override
  String get vChristian => 'క్రైస్తవ';

  @override
  String get vMuslim => 'ముస్లిం';

  @override
  String get vSikh => 'సిక్కు';

  @override
  String get vJain => 'జైన';

  @override
  String get vBuddhist => 'బౌద్ధ';

  @override
  String get vAtheist => 'నాస్తికుడు';

  @override
  String get vAgnostic => 'అజ్ఞేయవాది';

  @override
  String get vSpiritual => 'ఆధ్యాత్మిక';

  @override
  String get vCatholic => 'కాథలిక్';

  @override
  String get vLatterDaySaint => 'లేటర్ డే సెయింట్';

  @override
  String get vZoroastrian => 'జొరాస్ట్రియన్';

  @override
  String get vJewish => 'యూదు';

  @override
  String get vMormon => 'మార్మన్';

  @override
  String get vMonogamy => 'ఏకపత్నీ సంబంధం';

  @override
  String get vPolyamory => 'బహుళ ప్రేమ సంబంధం';

  @override
  String get vOpenRelationship => 'ఓపెన్ రిలేషన్‌షిప్';

  @override
  String get vNonMonogamy => 'ఏకపత్నీత్వం కానిది';

  @override
  String get vOpenToExploring => 'అన్వేషించడానికి సిద్ధం';

  @override
  String get vShortTerm => 'స్వల్పకాలిక';

  @override
  String get vLongTerm => 'దీర్ఘకాలిక';

  @override
  String get vStraight => 'స్ట్రెయిట్';

  @override
  String get vGay => 'గే';

  @override
  String get vLesbian => 'లెస్బియన్';

  @override
  String get vBisexual => 'బైసెక్సువల్';

  @override
  String get vAsexual => 'అసెక్సువల్';

  @override
  String get vDemisexual => 'డెమిసెక్సువల్';

  @override
  String get vPansexual => 'పాన్‌సెక్సువల్';

  @override
  String get vQueer => 'క్వీర్';

  @override
  String get vQuestioning => 'అనిశ్చితం';

  @override
  String get vWomen => 'మహిళలు';

  @override
  String get vMen => 'పురుషులు';

  @override
  String get vEveryone => 'అందరూ';

  @override
  String get vMale => 'పురుషుడు';

  @override
  String get vFemale => 'స్త్రీ';

  @override
  String get vFunCasualDates => 'సరదా, సాధారణ డేట్‌లు';

  @override
  String get vLifePartner => 'జీవిత భాగస్వామి';

  @override
  String get vLongTermRelationship => 'దీర్ఘకాలిక సంబంధం';

  @override
  String get vShortTermRelationship => 'స్వల్పకాలిక సంబంధం';

  @override
  String get vStillFiguringOut => 'ఇంకా నిర్ణయించుకోలేదు';

  @override
  String get vLongOpenToShort => 'దీర్ఘకాలిక, స్వల్పకాలికానికీ సిద్ధం';

  @override
  String get vShortOpenToLong => 'స్వల్పకాలిక, దీర్ఘకాలికానికీ సిద్ధం';

  @override
  String get vCasualDating => 'సాధారణ డేటింగ్';

  @override
  String get vNewFriends => 'కొత్త స్నేహితులు';

  @override
  String get vCloseFriends => 'సన్నిహిత స్నేహితులు';

  @override
  String get vActivityPartners => 'కార్యకలాప భాగస్వాములు';

  @override
  String get vProfessionalNetworking => 'వృత్తిపరమైన నెట్‌వర్కింగ్';

  @override
  String get vWorkoutBuddy => 'వ్యాయామ భాగస్వామి';

  @override
  String get vTravelBuddies => 'ప్రయాణ మిత్రులు';

  @override
  String get vYesIDrink => 'అవును, నేను తాగుతాను';

  @override
  String get vOccasionally => 'అప్పుడప్పుడు';

  @override
  String get vSometimes => 'కొన్నిసార్లు';

  @override
  String get vNeverDrink => 'ఎప్పుడూ తాగను';

  @override
  String get vRegularly => 'క్రమం తప్పకుండా';

  @override
  String get vImSober => 'నేను మద్యం సేవించను';

  @override
  String get vSocially => 'సామాజిక సందర్భాల్లో';

  @override
  String get vNever => 'ఎప్పుడూ కాదు';

  @override
  String get vSocialSmoker => 'సామాజిక సందర్భాల్లో ధూమపానం';

  @override
  String get vSmokerWhenDrinking => 'మద్యం సేవించేటప్పుడు ధూమపానం';

  @override
  String get vNonSmoker => 'ధూమపానం చేయను';

  @override
  String get vSmoker => 'ధూమపానం చేస్తాను';

  @override
  String get vTryingToQuit => 'మానేయడానికి ప్రయత్నిస్తున్నాను';

  @override
  String get vDaily => 'ప్రతిరోజూ';

  @override
  String get vWeekly => 'వారానికోసారి';

  @override
  String get vHighSchool => 'హైస్కూల్';

  @override
  String get vGradeSchool => 'ప్రాథమిక పాఠశాల';

  @override
  String get vDiploma => 'డిప్లొమా';

  @override
  String get vUnderGraduate => 'అండర్ గ్రాడ్యుయేట్';

  @override
  String get vPostGraduate => 'పోస్ట్ గ్రాడ్యుయేట్';

  @override
  String get vDoctorate => 'డాక్టరేట్';

  @override
  String get vCommunist => 'కమ్యూనిస్ట్';

  @override
  String get vSocialist => 'సోషలిస్ట్';

  @override
  String get vApolitical => 'రాజకీయేతర';

  @override
  String get vModerate => 'మధ్యస్థ';

  @override
  String get vNotInterested => 'ఆసక్తి లేదు';

  @override
  String get vHaveKids => 'పిల్లలు ఉన్నారు';

  @override
  String get vDontHaveKids => 'పిల్లలు లేరు';

  @override
  String get vDontWantKids => 'పిల్లలు వద్దు';

  @override
  String get vWantKids => 'పిల్లలు కావాలి';

  @override
  String get vOpenToKids => 'పిల్లలకు సిద్ధం';

  @override
  String get vNotSure => 'ఖచ్చితంగా తెలియదు';

  @override
  String get vPreferNotToSay => 'చెప్పడం ఇష్టం లేదు';

  @override
  String get vAries => 'మేషం';

  @override
  String get vTaurus => 'వృషభం';

  @override
  String get vGemini => 'మిథునం';

  @override
  String get vCancer => 'కర్కాటకం';

  @override
  String get vLeo => 'సింహం';

  @override
  String get vVirgo => 'కన్య';

  @override
  String get vLibra => 'తుల';

  @override
  String get vScorpio => 'వృశ్చికం';

  @override
  String get vSagittarius => 'ధనుస్సు';

  @override
  String get vCapricorn => 'మకరం';

  @override
  String get vAquarius => 'కుంభం';

  @override
  String get vPisces => 'మీనం';

  @override
  String get vHumanRights => 'మానవ హక్కులు';

  @override
  String get vDisabilityRights => 'వికలాంగుల హక్కులు';

  @override
  String get vFeminism => 'స్త్రీవాదం';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'పర్యావరణవాదం';

  @override
  String get vLgbtqRights => 'LGBTQ హక్కులు';

  @override
  String get vImmigrantRights => 'వలసదారుల హక్కులు';

  @override
  String get vEndReligiousHate => 'మతపరమైన ద్వేషానికి ముగింపు';

  @override
  String get vIndigenousRights => 'ఆదివాసీ హక్కులు';

  @override
  String get vNeuroDiversity => 'న్యూరో వైవిధ్యం';

  @override
  String get vVoterRights => 'ఓటరు హక్కులు';

  @override
  String get vReproductiveRights => 'పునరుత్పత్తి హక్కులు';

  @override
  String get vAmbition => 'ఆశయం';

  @override
  String get vConfidence => 'ఆత్మవిశ్వాసం';

  @override
  String get vEmpathy => 'సానుభూతి';

  @override
  String get vHumor => 'హాస్యం';

  @override
  String get vKindness => 'దయ';

  @override
  String get vOpenness => 'నిష్కపటత్వం';

  @override
  String get vOptimism => 'ఆశావాదం';

  @override
  String get vSassiness => 'చురుకుదనం';

  @override
  String get vPlayfulness => 'సరదా స్వభావం';

  @override
  String get vLeadership => 'నాయకత్వం';

  @override
  String get vHumility => 'వినయం';

  @override
  String get vLoyalty => 'విధేయత';

  @override
  String get vSarcasm => 'వ్యంగ్యం';

  @override
  String get vGratitude => 'కృతజ్ఞత';

  @override
  String get vCuriosity => 'కుతూహలం';

  @override
  String get vEmotionalIntelligence => 'భావోద్వేగ మేధస్సు';

  @override
  String get datingPreference => 'డేటింగ్ ప్రాధాన్యత';

  @override
  String get bffPreference => 'BFF ప్రాధాన్యత';

  @override
  String get whoWouldYouDate => 'మీరు ఎవరితో డేట్ చేయాలనుకుంటున్నారు?';

  @override
  String get ageRange => 'వయస్సు పరిధి?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max సంవత్సరాలు';
  }

  @override
  String get howFarAway => 'వారు ఎంత దూరంలో ఉన్నారు?';

  @override
  String kilometersAway(String distance) {
    return '$distance కిలోమీటర్ల దూరం';
  }

  @override
  String get yourInterests => 'మీ ఆసక్తులు?';

  @override
  String get errorLoadingInterests => 'ఆసక్తులు లోడ్ కాలేదు';

  @override
  String get whichLanguages => 'మీకు ఏ భాషలు తెలుసు?';

  @override
  String get selectLanguages => 'భాషలను ఎంచుకోండి';

  @override
  String get religionQuestion => 'మతం';

  @override
  String get selectReligion => 'మతాన్ని ఎంచుకోండి';

  @override
  String get relationshipTypeQuestion => 'సంబంధం రకం?';

  @override
  String get relationshipTypeTitle => 'సంబంధం రకం';

  @override
  String get selectType => 'రకాన్ని ఎంచుకోండి';

  @override
  String get sexualOrientationQuestion => 'లైంగిక ధోరణి?';

  @override
  String get sexualOrientationTitle => 'లైంగిక ధోరణి';

  @override
  String get selectOrientation => 'ధోరణిని ఎంచుకోండి';

  @override
  String get datingIntentionQuestion => 'డేటింగ్ ఉద్దేశం?';

  @override
  String get datingIntentionTitle => 'డేటింగ్ ఉద్దేశం';

  @override
  String get selectIntention => 'ఉద్దేశాన్ని ఎంచుకోండి';

  @override
  String get filtersCleared => 'ఫిల్టర్‌లు తొలగించబడ్డాయి!';

  @override
  String get clearFilters => 'ఫిల్టర్‌లను తొలగించు';

  @override
  String get filterByInterests => 'మీ ఆసక్తుల ఆధారంగా ఫిల్టర్ చేయండి';

  @override
  String get showMe => 'నాకు చూపించు';

  @override
  String errUpdateFailed(String error) {
    return 'నవీకరణ విఫలమైంది: $error';
  }

  @override
  String get religionViewTitle => 'మత దృక్పథం';

  @override
  String get sensitiveInfoNote =>
      'ఇది మీ ప్రొఫైల్‌లో కనిపించే సున్నితమైన సమాచారం. ఇది పూర్తిగా ఐచ్ఛికం.';

  @override
  String get zodiacSignTitle => 'రాశి';

  @override
  String get doYouDrink => 'మీరు మద్యం సేవిస్తారా?';

  @override
  String get doYouSmoke => 'మీరు ధూమపానం చేస్తారా?';

  @override
  String get doYouWorkout => 'మీరు వ్యాయామం చేస్తారా?';

  @override
  String get educationLevelTitle => 'విద్యా స్థాయి';

  @override
  String get politicalViewTitle => 'రాజకీయ దృక్పథం';

  @override
  String get doYouHaveKids => 'మీకు పిల్లలు ఉన్నారా?';

  @override
  String get kidsPlanQuestion => 'పిల్లల విషయంలో మీ ప్రణాళిక ఏమిటి?';

  @override
  String get pickYourPronoun => 'మీ సర్వనామాన్ని ఎంచుకోండి';

  @override
  String get pronounsBody =>
      'మీ సర్వనామాలు ఏమిటి? 3 ఎంచుకోండి, ఎప్పుడైనా తొలగించవచ్చు.';

  @override
  String get showPronounOnProfile => 'నా ప్రొఫైల్‌లో సర్వనామాన్ని చూపించు';

  @override
  String get causesTitle => 'కారణాలు & సముదాయాలు';

  @override
  String get selectUpTo3Causes => 'మీ మనసుకు దగ్గరైన 3 వరకు ఎంచుకోండి.';

  @override
  String get maxThreeOptions => 'గరిష్టంగా 3 ఎంపికలు ఎంచుకోవచ్చు';

  @override
  String get personQualities => 'వ్యక్తి లక్షణాలు';

  @override
  String get chooseThreeQualities =>
      'అనుబంధాన్ని మరింత బలపరిచే 3 లక్షణాలను ఎంచుకోండి.';

  @override
  String get maxThreeQualities => 'గరిష్టంగా 3 లక్షణాలు మాత్రమే ఎంచుకోవచ్చు.';

  @override
  String get howTallAreYou => 'మీ ఎత్తు ఎంత?';

  @override
  String get showsOnProfile => 'ఇది మీ ప్రొఫైల్‌లో కనిపిస్తుంది';

  @override
  String get yourHeight => 'మీ ఎత్తు';

  @override
  String get professionTitle => 'వృత్తి';

  @override
  String get showProfessionOnProfile => 'మీ ప్రొఫైల్‌లో వృత్తిని చూపించు';

  @override
  String get titleLabel => 'హోదా';

  @override
  String get companyIndustry => 'కంపెనీ (పరిశ్రమ)';

  @override
  String get educatedAt => 'చదివిన సంస్థ';

  @override
  String get showInstitutionOnProfile => 'మీ ప్రొఫైల్‌లో సంస్థను చూపించు';

  @override
  String get institutionLabel => 'సంస్థ';

  @override
  String get graduationYear => 'పట్టభద్రత సంవత్సరం';

  @override
  String get enterInstitution => 'దయచేసి మీ సంస్థ పేరు నమోదు చేయండి.';

  @override
  String get maxThreeLanguages => 'గరిష్టంగా 3 భాషలు ఎంచుకోవచ్చు';

  @override
  String get whatLookingFor => 'మీరు దేని కోసం చూస్తున్నారు?';

  @override
  String maxThreeForMode(String mode) {
    return 'ప్రస్తుత మోడ్ ($mode) కోసం గరిష్టంగా 3 ఎంపికలు ఎంచుకోవచ్చు.';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'ప్రాధాన్యతలను సేవ్ చేయడంలో లోపం: $error';
  }

  @override
  String get languagesIKnow => 'నాకు తెలిసిన భాషలు';

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయి';

  @override
  String get searchLanguages => 'భాషలను వెతకండి';

  @override
  String get suggested => 'సూచించినవి';

  @override
  String get allLanguages => 'అన్ని భాషలు';

  @override
  String get errorLoadingProfile => 'ప్రొఫైల్ లోడ్ కాలేదు';

  @override
  String percentTrust(String percent) {
    return '$percent% విశ్వాసం';
  }

  @override
  String get profileCompleted => 'ప్రొఫైల్ పూర్తయింది';

  @override
  String get completeProfile => 'ప్రొఫైల్ పూర్తి చేయి';

  @override
  String get higherScoreHelps =>
      'ఎక్కువ స్కోరు మరిన్ని నిజమైన\nమ్యాచ్‌లు పొందడంలో సహాయపడుతుంది';

  @override
  String get noBioYet => 'ఇంకా బయో జోడించలేదు.';

  @override
  String get askMe => 'నన్ను అడగండి';

  @override
  String get activeLabel => 'యాక్టివ్';

  @override
  String get addReligion => 'మతాన్ని జోడించు';

  @override
  String get addZodiac => 'రాశిని జోడించు';

  @override
  String get premium => 'ప్రీమియం';

  @override
  String get getNoticedSooner =>
      'త్వరగా గుర్తింపు పొందండి,\n3 రెట్లు ఎక్కువ డేట్‌లకు వెళ్లండి';

  @override
  String get upgrade => 'అప్‌గ్రేడ్ చేయి';

  @override
  String get spotlight => 'స్పాట్‌లైట్';

  @override
  String get standOut => 'ప్రత్యేకంగా నిలవండి';

  @override
  String get superSwipe => 'సూపర్ స్వైప్';

  @override
  String get getNoticed => 'గుర్తింపు పొందండి';

  @override
  String get scoreBreakdown => 'స్కోరు వివరణ';

  @override
  String get profilePhotoVerified => 'ప్రొఫైల్ ఫోటో ధృవీకరించబడింది';

  @override
  String get completedLabel => 'పూర్తయింది';

  @override
  String get profileDetails => 'ప్రొఫైల్ వివరాలు';

  @override
  String get incompleteLabel => 'అసంపూర్ణం';

  @override
  String get connectSocialAccounts => 'సోషల్ ఖాతాలను కనెక్ట్ చేయి';

  @override
  String get waysToImprove => 'మెరుగుపరచే మార్గాలు';

  @override
  String get verifyYourPhotos => 'మీ ఫోటోలను ధృవీకరించండి';

  @override
  String get proveYoureReal => 'మీరు నిజమైన వ్యక్తి అని ఇతరులకు నిరూపించండి';

  @override
  String get addPromptsInterests =>
      'ప్రాంప్ట్‌లు, ఆసక్తులు, ఇతర వివరాలు జోడించండి';

  @override
  String get verificationDataSecure =>
      'మీ ధృవీకరణ డేటా సురక్షితంగా ఉంచబడుతుంది, పబ్లిక్ ప్రొఫైల్‌లో పంచుకోబడదు. ';

  @override
  String get learnMore => 'మరింత తెలుసుకోండి';

  @override
  String get improveYourProfile => 'మీ ప్రొఫైల్‌ను మెరుగుపరచు';

  @override
  String errorSavingHometown(String error) {
    return 'స్వస్థలాన్ని సేవ్ చేయడంలో లోపం: $error';
  }

  @override
  String get searchCity => 'నగరాన్ని వెతకండి';

  @override
  String get aboutYou => 'మీ గురించి';

  @override
  String get bioPrompt =>
      'సిగ్గుపడకండి! చిన్న బయోలో మీ వ్యక్తిత్వాన్ని పంచుకోవడానికి ఇదే అవకాశం.';

  @override
  String get textHereHint => 'ఇక్కడ రాయండి.....';

  @override
  String failedToSaveBio(String error) {
    return 'బయో సేవ్ కాలేదు: $error';
  }

  @override
  String get selectYourInterests => 'మీ ఆసక్తులను ఎంచుకోండి';

  @override
  String get atLeast5Interests =>
      'కనీసం 5 ఆసక్తులు ఎంచుకోండి. ఇది మీకు సరిపోయే వారిని కనుగొనడంలో సహాయపడుతుంది';

  @override
  String get searchForInterest => 'ఆసక్తిని వెతకండి';

  @override
  String get noInterestsFound => 'ఆసక్తులు కనుగొనబడలేదు';

  @override
  String get failedLoadInterests =>
      'ఆసక్తులు లోడ్ కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get maxTenInterests => 'గరిష్టంగా 10 ఆసక్తులు ఎంచుకోవచ్చు';

  @override
  String get minFiveInterests => 'దయచేసి కనీసం 5 ఆసక్తులు ఎంచుకోండి';

  @override
  String errorSavingInterests(String error) {
    return 'ఆసక్తులను సేవ్ చేయడంలో లోపం: $error';
  }

  @override
  String get lifeStyle => 'జీవనశైలి';

  @override
  String get lifestylePrompt =>
      'మీ అలవాట్ల గురించి చెప్పండి. మీకు సరిపోయేది ఎంచుకోండి.';

  @override
  String get noLifestyleOptions => 'జీవనశైలి ఎంపికలు అందుబాటులో లేవు';

  @override
  String get failedLoadLifestyle =>
      'జీవనశైలి ఎంపికలు లోడ్ కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get selectEachCategory =>
      'ప్రతి విభాగానికి ఒక ఎంపిక చేయండి, లేదా దాటవేయడానికి అన్నీ తొలగించండి.';

  @override
  String get findYourCity => 'మీ ప్రస్తుత నగరాన్ని కనుగొనండి';

  @override
  String errorSavingLocation(String error) {
    return 'లొకేషన్ సేవ్ చేయడంలో లోపం: $error';
  }

  @override
  String get permissionRequired => 'అనుమతి అవసరం';

  @override
  String get permissionRequiredBody =>
      'యాప్ సరిగ్గా పనిచేయడానికి ఈ అనుమతి అవసరం. దయచేసి సెట్టింగ్‌లలో దీన్ని ఆన్ చేయండి.';

  @override
  String get cameraAccess => 'కెమెరా యాక్సెస్';

  @override
  String get photoLibrary => 'ఫోటో లైబ్రరీ';

  @override
  String get locationAccess => 'లొకేషన్ యాక్సెస్';

  @override
  String get notificationAccess => 'నోటిఫికేషన్ యాక్సెస్';

  @override
  String get microphoneAccess => 'మైక్రోఫోన్ యాక్సెస్';

  @override
  String get unknownAccess => 'తెలియని యాక్సెస్';

  @override
  String get cameraReason =>
      'ప్రొఫైల్ ఫోటోలు తీయడానికి, గుర్తింపు ధృవీకరించడానికి.';

  @override
  String get photoReason => 'మీ గ్యాలరీ నుండి ఫోటోలు అప్‌లోడ్ చేయడానికి.';

  @override
  String get locationReason => 'సమీపంలోని మ్యాచ్‌లు చూపించడానికి.';

  @override
  String get notificationReason =>
      'కొత్త మ్యాచ్‌లు, సందేశాల గురించి తెలియజేయడానికి.';

  @override
  String get microphoneReason => 'వాయిస్ మరియు వీడియో సంభాషణల కోసం.';

  @override
  String get appPermissions => 'యాప్ అనుమతులు';

  @override
  String get chooseYourPrompt => 'మీ ప్రాంప్ట్‌ను ఎంచుకోండి';

  @override
  String get selectUpTo3Prompts =>
      'మీ వ్యక్తిత్వాన్ని చూపించడానికి 3 ప్రాంప్ట్‌ల వరకు ఎంచుకోండి.';

  @override
  String get maxThreePrompts => 'గరిష్టంగా 3 ప్రాంప్ట్‌లు మాత్రమే ఎంచుకోవచ్చు.';

  @override
  String get areYouSure => 'మీరు ఖచ్చితంగా ఉన్నారా?';

  @override
  String get removeThisPrompt => 'ఈ ప్రాంప్ట్‌ను తొలగించాలా?';

  @override
  String get selectThreePrompts => 'కొనసాగించడానికి 3 ప్రాంప్ట్‌లు ఎంచుకోండి.';

  @override
  String get selectOnePrompt => 'కనీసం 1 ప్రాంప్ట్ ఎంచుకోండి.';

  @override
  String selectNMorePrompts(String count) {
    return 'కొనసాగించడానికి మరో $count ప్రాంప్ట్ ఎంచుకోండి';
  }

  @override
  String get noPromptsForCategory => 'ఈ విభాగానికి ప్రాంప్ట్‌లు లేవు.';

  @override
  String get typeYourAnswer => 'మీ సమాధానం రాయండి...';

  @override
  String get addPrompt => 'ప్రాంప్ట్ జోడించు';

  @override
  String failedToLoadPrompts(String error) {
    return 'ప్రాంప్ట్‌లు లోడ్ కాలేదు: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'ప్రాంప్ట్‌లను సేవ్ చేయడంలో లోపం: $error';
  }

  @override
  String get communityGuidelines => 'కమ్యూనిటీ మార్గదర్శకాలు';

  @override
  String get agreeAndContinue => 'అంగీకరించి కొనసాగించు';

  @override
  String get termsByContinuePrefix => 'కొనసాగించడం ద్వారా, మీరు మా ';

  @override
  String get guidelinesIntro =>
      'మా కమ్యూనిటీకి స్వాగతం! అందరికీ సురక్షితమైన, సానుకూల అనుభవం కోసం ఈ సాధారణ మార్గదర్శకాలను పాటించండి.';

  @override
  String get beKindTitle => 'దయతో, గౌరవంగా ఉండండి';

  @override
  String get beKindBody =>
      'మీరు ఎలా చూడబడాలనుకుంటారో ఇతరులను అలాగే చూడండి. స్వాగతించే వాతావరణాన్ని మనమందరం కలిసి సృష్టిస్తాం.';

  @override
  String get stayAuthenticTitle => 'నిజాయితీగా ఉండండి';

  @override
  String get stayAuthenticBody =>
      'మీ ప్రొఫైల్‌లో, సంభాషణల్లో నిజాయితీగా ఉండండి. మేము నిజాయితీని, నిజమైన అనుబంధాలను గౌరవిస్తాం.';

  @override
  String get prioritizeSafetyTitle => 'భద్రతకు ప్రాధాన్యత';

  @override
  String get prioritizeSafetyBody =>
      'సున్నితమైన, వ్యక్తిగత సమాచారాన్ని పంచుకోవద్దు. మిమ్మల్ని, కమ్యూనిటీలోని ఇతరులను రక్షించుకోండి.';

  @override
  String get noHateTitle => 'ద్వేషపూరిత మాటలు వద్దు';

  @override
  String get noHateBody =>
      'వేధింపులు, బెదిరింపులు, చట్టవిరుద్ధ కంటెంట్ ఇక్కడ సహించబడవు. కమ్యూనిటీని సురక్షితంగా ఉంచడంలో సహాయపడండి.';

  @override
  String get helpKeepSafeTitle => 'మమ్మల్ని సురక్షితంగా ఉంచడంలో సహాయపడండి';

  @override
  String get helpKeepSafeBody =>
      'మా మార్గదర్శకాలను ఉల్లంఘించేది కనిపిస్తే దయచేసి రిపోర్ట్ చేయండి. మీ సహాయం అమూల్యం.';

  @override
  String get genuineIntentTitle => 'నిజమైన ఉద్దేశంతో డేట్ చేయండి';

  @override
  String get genuineIntentBody =>
      'మేము నిజమైన అనుబంధాల కోసమే. నకిలీ గుర్తింపు లేదా బలవంతం అనుమతించబడవు. మోసాలు, ఇతరుల పేరుతో నటించడం, వ్యక్తిగత లేదా ఆర్థిక లాభం కోసం ఎలాంటి తారుమారు అనుమతించబడవు.';

  @override
  String get adultsOnlyTitle => 'పెద్దలకు మాత్రమే';

  @override
  String get adultsOnlyBody =>
      'Blindly ఉపయోగించడానికి మీ వయస్సు 18 లేదా అంతకంటే ఎక్కువ ఉండాలి. ఒంటరిగా ఉన్న లేదా బట్టలు లేని మైనర్ల ఫోటోలు అనుమతించబడవు — మీ చిన్ననాటి ఫోటోలు కూడా, అవి ఎంత ముద్దుగా ఉన్నా.';

  @override
  String get letsIntroduceYou => 'మిమ్మల్ని పరిచయం చేద్దాం!';

  @override
  String get needNameForProfile => 'మీ ప్రొఫైల్ సృష్టించడానికి మీ పేరు కావాలి';

  @override
  String get nameLabel => 'పేరు';

  @override
  String get enterYourName => 'మీ పేరు నమోదు చేయండి';

  @override
  String get needDobForProfile =>
      'మీ ప్రొఫైల్ సృష్టించడానికి పుట్టిన తేదీ కావాలి';

  @override
  String get dateOfBirth => 'పుట్టిన తేదీ';

  @override
  String get birthdayNote =>
      'మీ పుట్టిన తేదీ నుండి వయస్సు లెక్కించి ప్రొఫైల్‌లో చూపబడుతుంది. మీ పూర్తి పేరు బహిరంగం కాదు';

  @override
  String failedToSaveData(String error) {
    return 'డేటా సేవ్ కాలేదు: $error';
  }

  @override
  String get whatsYourGender => 'మీ లింగం ఏమిటి?';

  @override
  String get genderHelpsMatches =>
      'ఇది మీకు సరైన ప్రొఫైల్‌లు చూపించడానికి, మ్యాచ్‌లు కనుగొనడానికి సహాయపడుతుంది';

  @override
  String get vNonBinary => 'నాన్-బైనరీ';

  @override
  String get vPreferNot => 'చెప్పడం ఇష్టం లేదు';

  @override
  String failedToSaveGender(String error) {
    return 'లింగం సేవ్ కాలేదు: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'మీ ప్రొఫైల్ కోసం ఫోటోలు అప్‌లోడ్ చేయడానికి $permission అనుమతి ఇవ్వండి.';
  }

  @override
  String get gallery => 'గ్యాలరీ';

  @override
  String get camera => 'కెమెరా';

  @override
  String get photoNotAccepted => 'ఫోటో ఆమోదించబడలేదు';

  @override
  String get couldNotVerifyPhoto => 'మీ ఫోటోను ధృవీకరించలేకపోయాము ఎందుకంటే:';

  @override
  String get tryDifferentPhoto => 'దయచేసి వేరే ఫోటో అప్‌లోడ్ చేయండి.';

  @override
  String get addPhotos => 'ఫోటోలు జోడించు';

  @override
  String get addAtLeast2Photos =>
      'మ్యాచ్‌లు రావడానికి కనీసం 2 ఫోటోలు జోడించండి! మొదటిది ప్రధాన చిత్రం';

  @override
  String get tapPhotoToEdit =>
      'జోడించిన ఫోటోను నొక్కి సవరించండి లేదా తొలగించండి.';

  @override
  String get addOneMorePhoto => 'దయచేసి మరో ఫోటో జోడించండి';

  @override
  String get addMorePhotos => 'మరిన్ని ఫోటోలు జోడించు';

  @override
  String get mainPhotoBadge => 'ప్రధాన';

  @override
  String get editPhoto => 'ఫోటో సవరించు';

  @override
  String get removePhoto => 'ఫోటో తొలగించు';

  @override
  String get realConnectionsStartHere => 'నిజమైన అనుబంధాలు ఇక్కడే మొదలవుతాయి!';

  @override
  String get createAnAccount => 'ఖాతా సృష్టించు';

  @override
  String get iHaveAnAccount => 'నాకు ఖాతా ఉంది';

  @override
  String get agreeToOurTerms => 'మీరు మా నిబంధనలకు అంగీకరిస్తున్నారు';

  @override
  String get findPeopleNearYou => 'మీ దగ్గరలోని వ్యక్తులను కనుగొనండి';

  @override
  String get locationAccessBody =>
      'మీ ప్రాంతంలోని సాధ్యమైన మ్యాచ్‌లు చూపించడానికి మాకు మీ\nలొకేషన్ తెలియాలి. ప్రామాణికత, భద్రత కోసం మీ సాధారణ ప్రాంతాన్ని\nధృవీకరించడానికీ ఇది ఉపయోగపడుతుంది. చింతించకండి,\nమీ ఖచ్చితమైన లొకేషన్ ఎప్పుడూ పంచుకోబడదు';

  @override
  String get allowLocationAccess => 'లొకేషన్ యాక్సెస్ ఇవ్వండి';

  @override
  String get events => 'ఈవెంట్‌లు';

  @override
  String get booked => 'బుక్ చేసినవి';

  @override
  String get upcoming => 'రాబోయేవి';

  @override
  String get noEventsFound => 'ఈవెంట్‌లు కనుగొనబడలేదు';

  @override
  String get noEventsNearby =>
      'ప్రస్తుతం సమీపంలో ఈవెంట్‌లు లేవు. తర్వాత చూడండి లేదా లొకేషన్ మార్చండి.';

  @override
  String get refreshEvents => 'ఈవెంట్‌లను రిఫ్రెష్ చేయి';

  @override
  String get bookedEvents => 'బుక్ చేసిన ఈవెంట్‌లు';

  @override
  String get ticketsAndReservations => 'మీ టికెట్లు మరియు రిజర్వేషన్లు';

  @override
  String get upcomingEvents => 'రాబోయే ఈవెంట్‌లు';

  @override
  String get eventsYouAreInterested => 'మీకు ఆసక్తి ఉన్న ఈవెంట్‌లు';

  @override
  String get incomingVideoCall => 'ఇన్‌కమింగ్ వీడియో కాల్';

  @override
  String get incomingVoiceCall => 'ఇన్‌కమింగ్ వాయిస్ కాల్';

  @override
  String get ringing => 'రింగ్ అవుతోంది...';

  @override
  String get speaker => 'స్పీకర్';

  @override
  String get mute => 'మ్యూట్';

  @override
  String get unmute => 'అన్‌మ్యూట్';

  @override
  String get videoOff => 'వీడియో ఆఫ్';

  @override
  String get video => 'వీడియో';

  @override
  String get decline => 'తిరస్కరించు';

  @override
  String get flip => 'కెమెరా మార్చు';

  @override
  String get callEnded => 'కాల్ ముగిసింది';

  @override
  String get howWasCallQuality => 'కాల్ నాణ్యత ఎలా ఉంది?';

  @override
  String get switchToVideoCall => 'వీడియో కాల్‌కు మారాలా?';

  @override
  String get otherWantsVideoOn =>
      'అవతలి వ్యక్తి వీడియో ఆన్ చేయాలనుకుంటున్నారు.';

  @override
  String get switchToVoiceCall => 'వాయిస్ కాల్‌కు మారాలా?';

  @override
  String get otherWantsVideoOff =>
      'అవతలి వ్యక్తి వీడియో ఆఫ్ చేయాలనుకుంటున్నారు.';

  @override
  String get reject => 'తిరస్కరించు';

  @override
  String get accept => 'ఆమోదించు';

  @override
  String get incomingVideoCallTitle => 'ఇన్‌కమింగ్ వీడియో కాల్';

  @override
  String get incomingVoiceCallTitle => 'ఇన్‌కమింగ్ వాయిస్ కాల్';

  @override
  String get errorTitle => 'లోపం';

  @override
  String get successTitle => 'విజయవంతం';

  @override
  String get great => 'బాగుంది!';

  @override
  String get peoples => 'వ్యక్తులు';

  @override
  String get chatTab => 'చాట్';

  @override
  String get editProfileTitle => 'ప్రొఫైల్ సవరించు';

  @override
  String percentComplete(String percent) {
    return '$percent% పూర్తి';
  }

  @override
  String get profileStrength => 'ప్రొఫైల్ బలం';

  @override
  String get photosAndVideos => 'ఫోటోలు మరియు వీడియోలు';

  @override
  String get pickSomeTrueYou => 'మీ నిజ స్వరూపాన్ని చూపించేవి ఎంచుకోండి.';

  @override
  String get holdDragReorder => 'క్రమం మార్చడానికి మీడియాను నొక్కి లాగండి';

  @override
  String get bestPhoto => 'ఉత్తమ ఫోటో';

  @override
  String get aboutYouSection => 'మీ గురించి';

  @override
  String get aboutYouHint => 'మీ గురించి...';

  @override
  String get writeFunIntro => 'ఒక సరదా పరిచయం రాయండి.';

  @override
  String get letPeopleKnowDate => 'మీతో డేట్ చేయడం ఎలా ఉంటుందో చెప్పండి.';

  @override
  String get addAPrompt => 'ఒక ప్రాంప్ట్ జోడించు';

  @override
  String get prompts => 'ప్రాంప్ట్‌లు';

  @override
  String get prompt => 'ప్రాంప్ట్';

  @override
  String get addVoiceIntro => 'వాయిస్ పరిచయం జోడించు';

  @override
  String get letPeopleHearVoice => 'మీ గొంతును ఇతరులకు వినిపించండి.';

  @override
  String get reRecordIntro => 'పరిచయాన్ని మళ్లీ రికార్డ్ చేయి';

  @override
  String get deleteVoiceIntro => 'వాయిస్ పరిచయాన్ని తొలగించాలా?';

  @override
  String get removeVoiceIntroBody =>
      'ఇది మీ ప్రొఫైల్ నుండి వాయిస్ పరిచయాన్ని తొలగిస్తుంది.';

  @override
  String get interests => 'ఆసక్తులు';

  @override
  String get addFavoriteInterests => 'మీ ఇష్టమైన ఆసక్తులు జోడించండి';

  @override
  String get getSpecificThingsYouLove =>
      'మీకు ఇష్టమైన వాటి గురించి స్పష్టంగా చెప్పండి.';

  @override
  String get lifestyle => 'జీవనశైలి';

  @override
  String get addLifestylePrefs => 'మీ జీవనశైలి ప్రాధాన్యతలు జోడించండి';

  @override
  String get habitsAndPrefs => 'మీ అలవాట్లు మరియు ప్రాధాన్యతలు.';

  @override
  String get iAmLookingFor => 'నేను వెతుకుతున్నది';

  @override
  String get addWhatLookingFor => 'మీరు వెతుకుతున్నది జోడించండి';

  @override
  String get letOthersKnowWant =>
      'మీరు ఏమి కోరుకుంటున్నారో ఇతరులకు తెలియజేయండి';

  @override
  String get qualitiesIValue => 'నేను విలువిచ్చే లక్షణాలు';

  @override
  String get addQualitiesYouValue => 'మీరు విలువిచ్చే లక్షణాలు జోడించండి';

  @override
  String get chooseThreeQualitiesValue =>
      'ఒక వ్యక్తిలో మీరు విలువిచ్చే 3 లక్షణాల వరకు ఎంచుకోండి';

  @override
  String get myCausesSection => 'నా కారణాలు మరియు సముదాయాలు';

  @override
  String get addYourCauses => 'మీ కారణాలు, సముదాయాలు జోడించండి';

  @override
  String get addUpTo3Causes => 'మీ మనసుకు దగ్గరైన 3 కారణాల వరకు జోడించండి.';

  @override
  String get addLanguagesYouKnow => 'మీకు తెలిసిన భాషలు జోడించండి';

  @override
  String get moreAboutYou => 'మీ గురించి మరింత';

  @override
  String get heightLabel => 'ఎత్తు';

  @override
  String get genderLabel => 'లింగం';

  @override
  String get pronounsLabel => 'సర్వనామాలు';

  @override
  String get pickYourPronouns => 'మీ సర్వనామాలను ఎంచుకోండి';

  @override
  String get addYourPronouns => 'మీ సర్వనామాలు జోడించండి';

  @override
  String get workLabel => 'ఉద్యోగం';

  @override
  String get educationLevelLabel => 'విద్యా స్థాయి';

  @override
  String get hometownLabel => 'స్వస్థలం';

  @override
  String get locationLabel => 'లొకేషన్';

  @override
  String get exerciseLabel => 'వ్యాయామం';

  @override
  String get drinkingLabel => 'మద్యం';

  @override
  String get smokingLabel => 'ధూమపానం';

  @override
  String get kidsLabel => 'పిల్లలు';

  @override
  String get kidsPreferenceLabel => 'పిల్లల ప్రాధాన్యత';

  @override
  String get politicsLabel => 'రాజకీయాలు';

  @override
  String get zodiacLabel => 'రాశి';

  @override
  String get educatedAtLabel => 'చదివిన సంస్థ';

  @override
  String get connectedAccounts => 'కనెక్ట్ చేసిన ఖాతాలు';

  @override
  String get connectMySpotify => 'నా Spotify ను కనెక్ట్ చేయి';

  @override
  String get showFavoriteMusic => 'మీ ఇష్టమైన సంగీతాన్ని చూపించు';

  @override
  String get spotifyNote =>
      'మీ అభిమాన Spotify కళాకారులను ప్రొఫైల్‌లో చూపించి, ఇతరులతో ఉమ్మడి అభిరుచులను Blindly హైలైట్ చేయనివ్వండి.';

  @override
  String get verification => 'ధృవీకరణ';

  @override
  String get verified => 'ధృవీకరించబడింది';

  @override
  String get invalidLocation => 'చెల్లని లొకేషన్';

  @override
  String get locationFound => 'లొకేషన్ కనుగొనబడింది';

  @override
  String get alreadyVerified => 'మీరు ఇప్పటికే ధృవీకరించబడ్డారు';

  @override
  String get verificationSuccessful => 'ధృవీకరణ విజయవంతం';

  @override
  String get documentNotVerified => 'పత్రం ధృవీకరించబడలేదు.';

  @override
  String get verificationFailed => 'ధృవీకరణ విఫలమైంది';

  @override
  String get veriffReason => 'మీ IDని ధృవీకరించలేకపోయాము. Veriff ఇచ్చిన కారణం:';

  @override
  String get tryClearerImage => 'స్పష్టమైన చిత్రంతో మళ్లీ ప్రయత్నించండి.';

  @override
  String get veriffWaiting =>
      'Veriff పూర్తయింది. అప్‌డేట్ కోసం వేచి ఉన్నాము...';

  @override
  String get verificationSubmitted =>
      'ధృవీకరణ సమర్పించబడింది! మీ IDని సమీక్షిస్తున్నాము...';

  @override
  String get verifyYourProfile => 'మీ ప్రొఫైల్‌ను ధృవీకరించండి';

  @override
  String get youAreVerified => 'మీరు ధృవీకరించబడ్డారు!';

  @override
  String get quickCheckSafe => 'మీ భద్రత కోసం ఒక చిన్న తనిఖీ';

  @override
  String get identityConfirmed => 'మీ గుర్తింపు నిర్ధారించబడింది.';

  @override
  String get veriffExplainer =>
      'మీ గుర్తింపును నిర్ధారించడానికి, సురక్షిత పత్ర స్కానింగ్ కోసం Veriff ఉపయోగిస్తాము.';

  @override
  String get verifyingResults => 'ఫలితాలు ధృవీకరించబడుతున్నాయి...';

  @override
  String get verificationComplete => 'ధృవీకరణ పూర్తయింది';

  @override
  String get tapToScanDocument => 'పత్రాన్ని స్కాన్ చేయడానికి నొక్కండి';

  @override
  String get prepareIdCard => 'మీ ఐడీ కార్డును సిద్ధంగా ఉంచండి';

  @override
  String get ensureGoodLighting => 'మంచి వెలుతురు ఉండేలా చూడండి';

  @override
  String get readyForSelfie => 'ఒక త్వరిత సెల్ఫీకి సిద్ధంగా ఉండండి';

  @override
  String get processing => 'ప్రాసెస్ అవుతోంది...';

  @override
  String get startVerification => 'ధృవీకరణ ప్రారంభించు';

  @override
  String get poweredByVeriff => 'Veriff అందిస్తోంది';

  @override
  String get alignWithCamera => 'కెమెరాకు అనుగుణంగా నిలబడండి';

  @override
  String get cameraPermissionRequired => 'ధృవీకరణ కోసం కెమెరా అనుమతి అవసరం.';

  @override
  String get noCameraFound => 'పరికరంలో కెమెరా కనుగొనబడలేదు.';

  @override
  String get reviewingYourPhotos => 'మేము మీ ఫోటోలను సమీక్షిస్తున్నాము';

  @override
  String get verificationInProgress =>
      'మీ ప్రొఫైల్ ధృవీకరణ జరుగుతోంది. ఇది సాధారణంగా కొన్ని సెకన్లు పడుతుంది.';

  @override
  String get verifiedSuccessfully => 'విజయవంతంగా ధృవీకరించబడింది!';

  @override
  String get profileVerificationDone =>
      'ప్రొఫైల్ ధృవీకరణ విజయవంతంగా పూర్తయింది';

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get copyThisPose => 'ఈ భంగిమను అనుకరించండి';

  @override
  String get selfieVerification => 'సెల్ఫీ ధృవీకరణ';

  @override
  String get proveRealDeal => 'మీరు నిజమైనవారని\nనిరూపించండి';

  @override
  String get quickHelpsSafe =>
      'ఈ చిన్న తనిఖీ మా కమ్యూనిటీని సురక్షితంగా, నిజాయితీగా ఉంచుతుంది';

  @override
  String get getVerifiedBadge => 'ధృవీకరించిన బ్యాడ్జ్ పొందండి';

  @override
  String get buildTrustBody =>
      'ఇతరుల విశ్వాసాన్ని పొందండి, మీరు నిజమని చూపించండి.';

  @override
  String get keepCommunitySafe => 'కమ్యూనిటీని సురక్షితంగా ఉంచండి';

  @override
  String get weedOutFakes =>
      'నకిలీ ప్రొఫైల్‌లు, బాట్‌లను తొలగించడంలో సహాయపడండి.';

  @override
  String get copySimplePose => 'ఒక సాధారణ భంగిమను అనుకరించండి';

  @override
  String get quickSelfieConfirm =>
      'మీ గుర్తింపును నిర్ధారించడానికి ఒక త్వరిత సెల్ఫీ తీసుకుంటారు';

  @override
  String get selfieNotOnProfile =>
      'గమనిక: మీ సెల్ఫీ ధృవీకరణ కోసం మాత్రమే, ప్రొఫైల్‌లో కనిపించదు';

  @override
  String get getVerified => 'ధృవీకరించబడండి';

  @override
  String get voiceIntroTooShort => 'వాయిస్ పరిచయం కనీసం 1 సెకను ఉండాలి';

  @override
  String get recordVoiceIntroFirst => 'దయచేసి వాయిస్ పరిచయం రికార్డ్ చేయండి';

  @override
  String get recordingBetween1And30 =>
      'రికార్డింగ్ 1 నుండి 30 సెకన్ల మధ్య ఉండాలి';

  @override
  String get recordShortIntro => 'ఒక చిన్న పరిచయం రికార్డ్ చేయండి';

  @override
  String get personalityShine =>
      'మీ వ్యక్తిత్వం ప్రకాశించనివ్వండి. 30 సెకన్ల చిన్న పరిచయం రికార్డ్ చేయండి.';

  @override
  String get recordAgain => 'మళ్లీ రికార్డ్ చేయి';

  @override
  String get voicePromptsHelp =>
      'వాయిస్ ప్రాంప్ట్‌లు మిమ్మల్ని ప్రత్యేకంగా చూపించి లోతైన అనుబంధాలు ఏర్పరుస్తాయి. మీరు నిజంగా ఎవరో పంచుకోండి';

  @override
  String get threeXMatches => 'వాయిస్ రికార్డ్‌తో 3 రెట్లు ఎక్కువ మ్యాచ్‌లు';

  @override
  String get startConversationNaturally => 'సంభాషణను సహజంగా ప్రారంభించండి';

  @override
  String get showYourPersonality => 'మీ వ్యక్తిత్వాన్ని చూపించండి';

  @override
  String get saveAndContinue => 'సేవ్ చేసి కొనసాగించు';

  @override
  String failedUploadVoice(String error) {
    return 'వాయిస్ పరిచయం అప్‌లోడ్ కాలేదు: $error';
  }

  @override
  String get failedToStartRecording => 'రికార్డింగ్ ప్రారంభం కాలేదు';

  @override
  String get failedToStopRecording => 'రికార్డింగ్ ఆపలేకపోయాము';

  @override
  String get failedToPlayAudio => 'ఆడియో ప్లే కాలేదు';

  @override
  String get navLikes => 'లైక్‌లు';

  @override
  String get photoReasonNoFace =>
      'స్పష్టమైన ముఖం కనబడలేదు. ముఖం కనబడే ఫోటోను వాడండి.';

  @override
  String get photoReasonGroupPhoto =>
      'ఈ ఫోటోలో ఒకరికంటే ఎక్కువ మంది ఉన్నారు. ఒంటరి ఫోటో వాడండి.';

  @override
  String get photoReasonFaceTooSmall =>
      'ఈ ఫోటోలో మీ ముఖం చాలా చిన్నగా ఉంది. దగ్గరగా తీయండి.';

  @override
  String get photoReasonUnsafe => 'ఈ ఫోటో మా మార్గదర్శకాలకు అనుగుణంగా లేదు.';

  @override
  String get photoReasonBadImage =>
      'ఈ ఫైల్‌ను చదవలేకపోయాం. JPG లేదా PNG ప్రయత్నించండి.';

  @override
  String get photoReasonTooLarge => 'ఈ ఫోటో చాలా పెద్దది. చిన్న ఫోటో వాడండి.';

  @override
  String get photoReasonUnavailable => 'ఇప్పుడు ఈ ఫోటోను తనిఖీ చేయలేకపోయాం.';

  @override
  String get photoTryAgainLater => 'కనెక్షన్ చెక్ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get photoLoadFailed => 'మీ ఫోటోలను లోడ్ చేయలేకపోయాం.';

  @override
  String get photoSaveFailed =>
      'ఫోటోలను సేవ్ చేయలేకపోయాం. మళ్లీ ప్రయత్నించండి.';

  @override
  String photosNotAdded(int count) {
    return '$count ఫోటోలను జోడించలేకపోయాం:';
  }

  @override
  String get photosExpired =>
      'కొన్ని ఫోటోల గడువు ముగియడంతో తొలగించబడ్డాయి. దయచేసి మళ్లీ జోడించండి.';
}
