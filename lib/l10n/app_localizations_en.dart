// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsLanguage => 'Language';

  @override
  String get appLanguageTitle => 'App language';

  @override
  String get systemDefault => 'System default';

  @override
  String get authTitlePhone => 'Can I get your number?';

  @override
  String get authTitleVerifyNumber => 'Verify your number';

  @override
  String get authTitleEmail => 'Login with Email';

  @override
  String get authTitleVerifyEmail => 'Verify your email';

  @override
  String get authTitleApple => 'Login with Apple';

  @override
  String get loginTagline => 'Login to a Lovely life';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueLabel => 'Continue';

  @override
  String get termsSignupPrefix => 'By signing up, you agree to our ';

  @override
  String get termsContinuePrefix => 'By continuing, you agree to our ';

  @override
  String get termsWord => 'terms';

  @override
  String get termsBridge => '. See how we use your data in our ';

  @override
  String get privacyPolicyWord => 'privacy policy';

  @override
  String get termsSuffix => '.';

  @override
  String get phoneRationale =>
      'We only use phone numbers to make sure everyone on Blindly is real';

  @override
  String get countryLabel => 'Country';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneHint => 'e.g. 9876543210';

  @override
  String otpSentPhone(String phone) {
    return 'Enter the code we\'ve sent by text to $phone. ';
  }

  @override
  String get changeNumber => 'Change number';

  @override
  String otpSentEmail(String email) {
    return 'Enter the code we\'ve sent by email to\n$email. ';
  }

  @override
  String get changeEmail => 'Change email';

  @override
  String get resendCode => 'Resend code';

  @override
  String codeArrivesIn(int seconds) {
    return 'The code should arrive within ${seconds}s';
  }

  @override
  String get otpSentSuccess => 'OTP sent successfully';

  @override
  String get loginDetailsSubtitle => 'Please enter your login details below';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Abcd@gmail.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'abc@123';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get errEnterPhone => 'Please enter your phone number';

  @override
  String get errPhoneDigitsOnly => 'Phone number must contain only digits';

  @override
  String get errInvalidPhone => 'Please enter a valid phone number';

  @override
  String get errInvalidPhoneIndia =>
      'Please enter a valid 10-digit Indian phone number starting with 6-9';

  @override
  String get errInvalidPhone10Digit =>
      'Please enter a valid 10-digit phone number';

  @override
  String get errEnterCompleteOtp => 'Please enter complete OTP';

  @override
  String get errEnterEmail => 'Please enter your email';

  @override
  String get errInvalidEmail => 'Please enter a valid email address';

  @override
  String get errFillAllFields => 'Please fill all fields';

  @override
  String get errPasswordMin => 'Password must be at least 6 characters';

  @override
  String get errTooManyAttempts =>
      'Too many attempts. Please wait a while before trying again.';

  @override
  String errCreateProfile(String error) {
    return 'Failed to create profile: $error';
  }

  @override
  String errGoogleSignIn(String error) {
    return 'Google Sign-In failed: $error';
  }

  @override
  String errLoginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String errGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get save => 'Save';

  @override
  String get skip => 'Skip';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get update => 'Update';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get edit => 'Edit';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get unknown => 'Unknown';

  @override
  String get typesOfConnections => 'Types of Connections';

  @override
  String get connectionQuestion =>
      'What type of connection are you looking for on Blindly?';

  @override
  String get connectionSubtitle =>
      'Dates and romances, new friends, or strictly business? You can change this any time.';

  @override
  String get modeDateSubtitle =>
      'Find a relationship, something casual, or anything in-between';

  @override
  String get modeBffSubtitle => 'Make new friends and find your community';

  @override
  String get modeEventsSubtitle =>
      'Find exciting events, book tickets, and more';

  @override
  String continueWithMode(String mode) {
    return 'Continue with $mode';
  }

  @override
  String get multiDeviceTitle => 'Multi-Device Login';

  @override
  String get multiDeviceBody =>
      'Your account is active on another device. For security, only one session is allowed.';

  @override
  String get signedOutOtherDevices => 'Signed out other devices!';

  @override
  String get signOutOtherDevices => 'Sign Out Other Devices';

  @override
  String get logOutThisDevice => 'Log Out This Device';

  @override
  String get swipeRightHint => 'Swipe right to know more!';

  @override
  String get locationRequiredTitle => 'Location Required';

  @override
  String get locationRequiredBody =>
      'We need your location to find amazing people near you.\n\nPlease tap \"Settings\" to enable location permissions, then hit \"Retry\".';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get notifyMeSnack => 'We\'ll notify you when new people join!';

  @override
  String get nearby => 'Nearby';

  @override
  String heightCm(String value) {
    return '$value cm';
  }

  @override
  String get completeYourProfile => 'Complete your profile';

  @override
  String get completeYourProfileBody =>
      'You skipped some steps. Complete them to get the most out of the app.';

  @override
  String get stepNotAvailable => 'This step is not yet available.';

  @override
  String get profileNotFound => 'Profile not found';

  @override
  String get profileUnavailable => 'Profile not found or no longer available.';

  @override
  String get profileLoadFailed => 'Failed to load profile. Please try again.';

  @override
  String get alreadyLikedProfile => 'You already liked this profile.';

  @override
  String get personAlreadyLikedYou => 'This person already liked you.';

  @override
  String get youAreMatched => 'You are matched.';

  @override
  String get alreadyChatting => 'You already started chatting.';

  @override
  String get profileAlreadySkipped => 'Profile already skipped.';

  @override
  String get goBack => 'Go Back';

  @override
  String get profilePreview => 'Profile Preview';

  @override
  String get profileTitle => 'Profile';

  @override
  String get voiceIntro => 'Voice Intro';

  @override
  String get bioTitle => 'Bio';

  @override
  String get askAboutMyBio => 'Ask me about my bio!';

  @override
  String get kudos => 'Kudos';

  @override
  String get aPrompt => 'A prompt';

  @override
  String get profileVerified => 'Profile Verified';

  @override
  String get photoVerified => 'Photo Verified';

  @override
  String get notVerified => 'Not Verified';

  @override
  String milesAway(String distance) {
    return '$distance miles away';
  }

  @override
  String trustScore(String score) {
    return 'Trust Score: $score%';
  }

  @override
  String get seeHowYouMatch => 'See how you two match';

  @override
  String get aboutMe => 'About Me';

  @override
  String get imLookingFor => 'I\'m looking for';

  @override
  String get quickestWayToHeart => 'The quickest way to my heart is';

  @override
  String get myInterests => 'My Interests';

  @override
  String get myLifestyle => 'My Lifestyle';

  @override
  String smokesLabel(String value) {
    return 'Smokes: $value';
  }

  @override
  String drinksLabel(String value) {
    return 'Drinks: $value';
  }

  @override
  String worksOutLabel(String value) {
    return 'Works out: $value';
  }

  @override
  String get myCauses => 'My causes and communities';

  @override
  String get languagesTitle => 'Languages';

  @override
  String get myLocation => 'My location';

  @override
  String get myTopArtist => 'My top artist on spotify';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get youLikedThem => 'You liked them!';

  @override
  String get undoNotForMe => 'Undo \'Not for me\'';

  @override
  String get notForMe => 'Not for me';

  @override
  String get block => 'Block';

  @override
  String get report => 'Report';

  @override
  String get outOfSwipesToday => 'Out of swipes for\ntoday';

  @override
  String get moreSwipesIn => 'More swipes in';

  @override
  String get hoursLabel => 'Hours';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get secondsLabel => 'Seconds';

  @override
  String get sendAndSeeLikes => 'Sent and see all\nthe likes you want';

  @override
  String get sendUnlimitedSwipes => 'Send unlimited swipes';

  @override
  String get advancedSearchFilter => 'Advanced search filter';

  @override
  String get seeEveryoneWhoLikes => 'See everyone who like you';

  @override
  String get setMoreDatingPrefs => 'Set more dating preference';

  @override
  String monthsPlan(String count) {
    return '$count months';
  }

  @override
  String get mostPopular => 'most popular';

  @override
  String get bestValue => 'best value';

  @override
  String getWithPlan(String plan, String price) {
    return 'Get with $plan for $price';
  }

  @override
  String offerEndsIn(String time) {
    return 'Offers ends in $time';
  }

  @override
  String get chats => 'Chats';

  @override
  String get conversations => 'Conversations';

  @override
  String get recentMatches => 'Recent matches';

  @override
  String get readyToMakeFirstMove => 'Ready to make the first\nmove?';

  @override
  String get tapToContinueChatting => 'Tap to continue chatting';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get newMatchesAppearHere => 'Your new matches will appear here.';

  @override
  String get endToEndEncrypted => 'End-to-end encrypted';

  @override
  String get e2eBanner =>
      'Messages and calls are end-to-end encrypted. No one outside of this chat, not even Blindly, can read or listen to them. ';

  @override
  String get encryptedMessage => 'Encrypted message';

  @override
  String get encryptionKeyNotLoaded =>
      'Encryption key not loaded. Please wait.';

  @override
  String get messageViolatesGuidelines =>
      'This message may violate our community guidelines and wasn\'t sent.';

  @override
  String get imageMessage => ' Image message';

  @override
  String get voiceMessage => ' Voice message';

  @override
  String nSelected(String count) {
    return '$count selected';
  }

  @override
  String get editedSuffix => '(Edited)';

  @override
  String get editingMessage => 'Editing message';

  @override
  String get onlyTextEditable => 'Only text messages can be edited';

  @override
  String get messageCopied => 'Message copied';

  @override
  String get archiveChat => 'Archive Chat';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get blockUser => 'Block User';

  @override
  String get muteNotifications => 'Mute Notifications';

  @override
  String get reportAndSpam => 'Report and Spam';

  @override
  String get deleteForMe => 'Delete for me';

  @override
  String get deleteForEveryone => 'Delete for everyone';

  @override
  String get showTranslation => 'Show translation';

  @override
  String get showOriginal => 'Show original';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get attachmentComingSoon => 'Attachment picker coming soon';

  @override
  String get imageTooLarge => 'Image too large (max 5MB)';

  @override
  String get micPermissionDenied => 'Microphone permission denied';

  @override
  String get recordingEmpty => 'Recording file is empty';

  @override
  String get recordingNotFound => 'Recording file not found';

  @override
  String get failedToPlayVoice => 'Failed to play voice message';

  @override
  String get failedToLoad => 'Failed to load';

  @override
  String get errorLoadingGif => 'Error loading GIF';

  @override
  String get errorLoadingSticker => 'Error loading Sticker';

  @override
  String get networkErrorRetry =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get serverSideError =>
      'Something went wrong on our side. Give it another go.';

  @override
  String get pleaseLoginFirst => 'Please login first';

  @override
  String get icebreakers => 'Icebreakers';

  @override
  String get iceBreaker => 'Ice Breaker';

  @override
  String get couldntLoadIcebreakers => 'Couldn\'t load icebreakers';

  @override
  String get aiAnalyzingProfiles => 'AI is analyzing your profiles...';

  @override
  String get generate => 'Generate';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryDeep => 'Deep';

  @override
  String get categoryPlayful => 'Playful';

  @override
  String get categoryQuirky => 'Quirky';

  @override
  String get categoryPersonalized => 'Personalized';

  @override
  String get categoryQuestion => 'Question';

  @override
  String get categoryObservation => 'Observation';

  @override
  String get categoryFunFact => 'Fun Fact';

  @override
  String get categoryHypothesis => 'Hypothesis';

  @override
  String get categoryOpeningMove => 'Opening Move';

  @override
  String get superpowerPrompt =>
      'If you could have any superpower, what would it be?';

  @override
  String get chooseAnOption => 'Choose an option';

  @override
  String get invalidMatchData => 'Invalid match data. Please try again.';

  @override
  String get moreOpeningMoves => 'More opening moves';

  @override
  String get onlineNow => 'Online now';

  @override
  String get pleaseEnterMessage => 'Please enter a message';

  @override
  String sendPersonMessage(String name) {
    return 'Send $name a message';
  }

  @override
  String get sendMessage => 'Send message';

  @override
  String get matchHasExpired => 'This match has expired.';

  @override
  String get typeOpeningMove => 'Type your opening move...';

  @override
  String get use => 'Use';

  @override
  String get expiringSoon => 'Expiring Soon';

  @override
  String get matchExpiredTitle => 'Match Expired';

  @override
  String dontLetThemGetAway(String name) {
    return 'Don\'t Let $name\nGet Away!';
  }

  @override
  String get limitedTimeBody =>
      'You have limited time left to make a move. Send a message before the match disappears forever.';

  @override
  String get letThemGo => 'Let them go';

  @override
  String messagePerson(String name) {
    return 'Message $name';
  }

  @override
  String get gifs => 'GIFs';

  @override
  String get stickers => 'Stickers';

  @override
  String get searchGiphy => 'Search GIPHY';

  @override
  String get themOnly => 'Them only';

  @override
  String get tryAgain => 'Try again';

  @override
  String get icebreakerSmile =>
      'What\'s a small thing that made you smile recently?';

  @override
  String get icebreakerTwoTruths => 'Two truths and a lie: Let\'s go!';

  @override
  String get icebreakerInteresting =>
      'What\'s the most interesting thing you\'ve learned lately?';

  @override
  String get openingMoveCushions =>
      'Me and the cushions I made.\nWhat do you think?';

  @override
  String get openingMove90s => 'I bet you can\'t beat my 90s look';

  @override
  String get openingMovePetName => 'Guess my pet\'s name?';

  @override
  String get viewProfile => 'View Profile';

  @override
  String get likedYou => 'Liked You';

  @override
  String get matchLabel => 'Match';

  @override
  String get passLabel => 'Pass';

  @override
  String get failedToLoadLikes => 'Failed to load likes';

  @override
  String get noLikesYet => 'No likes yet, but don\'t\n';

  @override
  String get buzzOff => 'buzz off!';

  @override
  String get keepSwipingBody =>
      'Keep swiping to find your honey.\nSomeone is bound to like you soon!';

  @override
  String get keepSwiping => 'Keep swiping';

  @override
  String get startSwiping => 'Start Swiping';

  @override
  String get improveProfile => 'Improve Profile';

  @override
  String get viewMoreLikes => 'View more likes';

  @override
  String get seeWhosInterested => 'See Who\'s Interested';

  @override
  String matchInstantly(String count) {
    return 'Match instantly without the wait. You have $count+ likes waiting you';
  }

  @override
  String get superLiked => 'Super Liked';

  @override
  String get itsAMatch => 'It\'s a Match!';

  @override
  String youAndThemLiked(String name) {
    return 'You and $name liked each other.';
  }

  @override
  String get sendAMessage => 'Send a message';

  @override
  String get notifications => 'Notifications';

  @override
  String get loginToViewNotifications => 'Please log in to view notifications.';

  @override
  String get noNotificationsYet => 'You have no notifications yet.';

  @override
  String get discover => 'Discover';

  @override
  String get reachedEndOfLine => 'You\'ve reached the end\nof the line!';

  @override
  String get checkBackSoon =>
      'Check back soon for more people or try adjusting your filters to see more profiles.';

  @override
  String get seeMorePeople => 'See More Peoples';

  @override
  String get topPicksForYou => 'Top Picks For You';

  @override
  String get sharedInterests => 'Shared Interests';

  @override
  String get newFaces => 'New Faces';

  @override
  String get recentlyActive => 'Recently Active';

  @override
  String get seeAll => 'See all';

  @override
  String kmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get letsDiscover => 'Lets Discover!';

  @override
  String get viewedAllProfiles =>
      'You\'re viewed all the profiles matching your current preference. Expand your search or check back soon for new peoples.';

  @override
  String get adjustYourFilters => 'Adjust Your Filters';

  @override
  String get notifyMeNewPeople => 'Notify Me About New People';

  @override
  String youAndPerson(String name) {
    return 'You and $name';
  }

  @override
  String get workingOutCommon => 'Working out what you have in common…';

  @override
  String get whyTitle => 'Why';

  @override
  String get breakdownTitle => 'Breakdown';

  @override
  String get goesBothWays => 'Does it go both ways?';

  @override
  String eachFitsOther(String band) {
    return 'You each fit what the other is looking for: $band.';
  }

  @override
  String get sectionConnections => 'Connections';

  @override
  String get typeOfConnection => 'Type of connection';

  @override
  String get dateMode => 'Date mode';

  @override
  String get travel => 'Travel';

  @override
  String get sectionAccountSettings => 'Account Settings';

  @override
  String get profileAndVerification => 'Profile & Verification';

  @override
  String get contactAndLoginInfo => 'Contact & Login info';

  @override
  String get subscriptionManagement => 'Subscription Management';

  @override
  String get sectionAppPreference => 'App Preference';

  @override
  String get notificationsSetting => 'Notifications setting';

  @override
  String get privacyControls => 'Privacy controls';

  @override
  String get sectionSecurityPrivacy => 'Security & Privacy';

  @override
  String get accountManagement => 'Account Management';

  @override
  String get blockedAccounts => 'Blocked accounts';

  @override
  String get locationService => 'Location service';

  @override
  String get sectionSupportLegal => 'Support & Legal';

  @override
  String get helpCenter => 'Help center';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get vEnglish => 'English';

  @override
  String get vHindi => 'Hindi';

  @override
  String get vTamil => 'Tamil';

  @override
  String get vTelugu => 'Telugu';

  @override
  String get vKannada => 'Kannada';

  @override
  String get vMalayalam => 'Malayalam';

  @override
  String get vMarathi => 'Marathi';

  @override
  String get vBengali => 'Bengali';

  @override
  String get vGujarati => 'Gujarati';

  @override
  String get vPunjabi => 'Punjabi';

  @override
  String get vOdia => 'Odia';

  @override
  String get vSpanish => 'Spanish';

  @override
  String get vFrench => 'French';

  @override
  String get vGerman => 'German';

  @override
  String get vItalian => 'Italian';

  @override
  String get vPortuguese => 'Portuguese';

  @override
  String get vRussian => 'Russian';

  @override
  String get vJapanese => 'Japanese';

  @override
  String get vKorean => 'Korean';

  @override
  String get vChinese => 'Chinese';

  @override
  String get vArabic => 'Arabic';

  @override
  String get vTurkish => 'Turkish';

  @override
  String get vOthers => 'Others';

  @override
  String get vOther => 'Other';

  @override
  String get vHindu => 'Hindu';

  @override
  String get vChristian => 'Christian';

  @override
  String get vMuslim => 'Muslim';

  @override
  String get vSikh => 'Sikh';

  @override
  String get vJain => 'Jain';

  @override
  String get vBuddhist => 'Buddhist';

  @override
  String get vAtheist => 'Atheist';

  @override
  String get vAgnostic => 'Agnostic';

  @override
  String get vSpiritual => 'Spiritual';

  @override
  String get vCatholic => 'Catholic';

  @override
  String get vLatterDaySaint => 'Latter day saint';

  @override
  String get vZoroastrian => 'Zoroastrian';

  @override
  String get vJewish => 'Jewish';

  @override
  String get vMormon => 'Mormon';

  @override
  String get vMonogamy => 'Monogamy';

  @override
  String get vPolyamory => 'Polyamory';

  @override
  String get vOpenRelationship => 'Open relationship';

  @override
  String get vNonMonogamy => 'Non-monogamy';

  @override
  String get vOpenToExploring => 'Open to exploring';

  @override
  String get vShortTerm => 'Short Term';

  @override
  String get vLongTerm => 'Long Term';

  @override
  String get vStraight => 'Straight';

  @override
  String get vGay => 'Gay';

  @override
  String get vLesbian => 'Lesbian';

  @override
  String get vBisexual => 'Bisexual';

  @override
  String get vAsexual => 'Asexual';

  @override
  String get vDemisexual => 'Demisexual';

  @override
  String get vPansexual => 'Pansexual';

  @override
  String get vQueer => 'Queer';

  @override
  String get vQuestioning => 'Questioning';

  @override
  String get vWomen => 'Women';

  @override
  String get vMen => 'Men';

  @override
  String get vEveryone => 'Everyone';

  @override
  String get vMale => 'Male';

  @override
  String get vFemale => 'Female';

  @override
  String get vFunCasualDates => 'Fun, causal dates';

  @override
  String get vLifePartner => 'Life partner';

  @override
  String get vLongTermRelationship => 'Long-term relationship';

  @override
  String get vShortTermRelationship => 'Short-term relationship';

  @override
  String get vStillFiguringOut => 'Still figuring it out';

  @override
  String get vLongOpenToShort => 'Long-term, open to short';

  @override
  String get vShortOpenToLong => 'Short-term, open to long';

  @override
  String get vCasualDating => 'Casual dating';

  @override
  String get vNewFriends => 'New friends';

  @override
  String get vCloseFriends => 'Close friends';

  @override
  String get vActivityPartners => 'Activity partners';

  @override
  String get vProfessionalNetworking => 'Professional networking';

  @override
  String get vWorkoutBuddy => 'Workout buddy';

  @override
  String get vTravelBuddies => 'Travel buddies';

  @override
  String get vYesIDrink => 'Yes, i drink';

  @override
  String get vOccasionally => 'Occasionally';

  @override
  String get vSometimes => 'Sometimes';

  @override
  String get vNeverDrink => 'Never drink';

  @override
  String get vRegularly => 'Regularly';

  @override
  String get vImSober => 'I\'m Sober';

  @override
  String get vSocially => 'Socially';

  @override
  String get vNever => 'Never';

  @override
  String get vSocialSmoker => 'Social smoker';

  @override
  String get vSmokerWhenDrinking => 'Smoker when drinking';

  @override
  String get vNonSmoker => 'Non-smoker';

  @override
  String get vSmoker => 'Smoker';

  @override
  String get vTryingToQuit => 'Trying to quit';

  @override
  String get vDaily => 'Daily';

  @override
  String get vWeekly => 'Weekly';

  @override
  String get vHighSchool => 'High school';

  @override
  String get vGradeSchool => 'Grade School';

  @override
  String get vDiploma => 'Diploma';

  @override
  String get vUnderGraduate => 'Under Graduate';

  @override
  String get vPostGraduate => 'Post Graduate';

  @override
  String get vDoctorate => 'Doctorate';

  @override
  String get vCommunist => 'Communist';

  @override
  String get vSocialist => 'Socialist';

  @override
  String get vApolitical => 'Apolitical';

  @override
  String get vModerate => 'Moderate';

  @override
  String get vNotInterested => 'Not Interested';

  @override
  String get vHaveKids => 'Have kids';

  @override
  String get vDontHaveKids => 'Don\'t have kids';

  @override
  String get vDontWantKids => 'Don\'t want kids';

  @override
  String get vWantKids => 'Want Kids';

  @override
  String get vOpenToKids => 'Open to kids';

  @override
  String get vNotSure => 'Not Sure';

  @override
  String get vPreferNotToSay => 'Prefer not to say';

  @override
  String get vAries => 'Aries';

  @override
  String get vTaurus => 'Taurus';

  @override
  String get vGemini => 'Gemini';

  @override
  String get vCancer => 'Cancer';

  @override
  String get vLeo => 'Leo';

  @override
  String get vVirgo => 'Virgo';

  @override
  String get vLibra => 'Libra';

  @override
  String get vScorpio => 'Scorpio';

  @override
  String get vSagittarius => 'Sagittarius';

  @override
  String get vCapricorn => 'Capricorn';

  @override
  String get vAquarius => 'Aquarius';

  @override
  String get vPisces => 'Pisces';

  @override
  String get vHumanRights => 'Human Rights';

  @override
  String get vDisabilityRights => 'Disability Rights';

  @override
  String get vFeminism => 'Feminism';

  @override
  String get vBlackLivesMatter => 'Black Lives Matter';

  @override
  String get vEnvironmentalism => 'Environmentalism';

  @override
  String get vLgbtqRights => 'LGBTQ Rights';

  @override
  String get vImmigrantRights => 'Immigrant Rights';

  @override
  String get vEndReligiousHate => 'End Religious Hate';

  @override
  String get vIndigenousRights => 'Indigenous Rights';

  @override
  String get vNeuroDiversity => 'Neuro diversity';

  @override
  String get vVoterRights => 'Voter Rights';

  @override
  String get vReproductiveRights => 'Reproductive Rights';

  @override
  String get vAmbition => 'Ambition';

  @override
  String get vConfidence => 'Confidence';

  @override
  String get vEmpathy => 'Empathy';

  @override
  String get vHumor => 'Humor';

  @override
  String get vKindness => 'Kindness';

  @override
  String get vOpenness => 'Openness';

  @override
  String get vOptimism => 'Optimism';

  @override
  String get vSassiness => 'Sassiness';

  @override
  String get vPlayfulness => 'Playfulness';

  @override
  String get vLeadership => 'Leadership';

  @override
  String get vHumility => 'Humility';

  @override
  String get vLoyalty => 'Loyalty';

  @override
  String get vSarcasm => 'Sarcasm';

  @override
  String get vGratitude => 'Gratitude';

  @override
  String get vCuriosity => 'Curiosity';

  @override
  String get vEmotionalIntelligence => 'Emotional Intelligence';

  @override
  String get datingPreference => 'Dating Preference';

  @override
  String get bffPreference => 'BFF Preference';

  @override
  String get whoWouldYouDate => 'Who would you like to date?';

  @override
  String get ageRange => 'Age range?';

  @override
  String yearsOldRange(String min, String max) {
    return '$min - $max years old';
  }

  @override
  String get howFarAway => 'How far away they are?';

  @override
  String kilometersAway(String distance) {
    return '$distance kilometers away';
  }

  @override
  String get yourInterests => 'Your interests?';

  @override
  String get errorLoadingInterests => 'Error loading interests';

  @override
  String get whichLanguages => 'Which language do you know?';

  @override
  String get selectLanguages => 'Select languages';

  @override
  String get religionQuestion => 'Religion';

  @override
  String get selectReligion => 'Select religion';

  @override
  String get relationshipTypeQuestion => 'Relationship type?';

  @override
  String get relationshipTypeTitle => 'Relationship Type';

  @override
  String get selectType => 'Select type';

  @override
  String get sexualOrientationQuestion => 'Sexual orientation?';

  @override
  String get sexualOrientationTitle => 'Sexual Orientation';

  @override
  String get selectOrientation => 'Select orientation';

  @override
  String get datingIntentionQuestion => 'Dating intention?';

  @override
  String get datingIntentionTitle => 'Dating Intention';

  @override
  String get selectIntention => 'Select intention';

  @override
  String get filtersCleared => 'Filters cleared successfully!';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get filterByInterests => 'Filter by your interests';

  @override
  String get showMe => 'Show me';

  @override
  String errUpdateFailed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get religionViewTitle => 'Religion View';

  @override
  String get sensitiveInfoNote =>
      'This is sensitive information that\'ll be on your profile. It\'s Totally optional.';

  @override
  String get zodiacSignTitle => 'Zodiac Sign';

  @override
  String get doYouDrink => 'Do you drink?';

  @override
  String get doYouSmoke => 'Do you smoke?';

  @override
  String get doYouWorkout => 'Do you have workout?';

  @override
  String get educationLevelTitle => 'Education Level';

  @override
  String get politicalViewTitle => 'Political View';

  @override
  String get doYouHaveKids => 'Do you have kids?';

  @override
  String get kidsPlanQuestion => 'What are your plan for children\'s?';

  @override
  String get pickYourPronoun => 'Pick Your Pronoun';

  @override
  String get pronounsBody =>
      'What are your Pronouns? Pick 3 Pronouns you can remove this at anytime.';

  @override
  String get showPronounOnProfile => 'Show your pronoun on my profile';

  @override
  String get causesTitle => 'Causes & Communities';

  @override
  String get selectUpTo3Causes =>
      'Select up to 3 options close to your hearts.';

  @override
  String get maxThreeOptions => 'You can select up to 3 options';

  @override
  String get personQualities => 'Person Qualities';

  @override
  String get chooseThreeQualities =>
      'Choose 3 qualities that would make a connection that much stronger.';

  @override
  String get maxThreeQualities => 'You can select up to 3 qualities only.';

  @override
  String get howTallAreYou => 'How tall are you?';

  @override
  String get showsOnProfile => 'This will show on your profile';

  @override
  String get yourHeight => 'Your Height';

  @override
  String get professionTitle => 'Profession';

  @override
  String get showProfessionOnProfile => 'Show your profession on your profile';

  @override
  String get titleLabel => 'Title';

  @override
  String get companyIndustry => 'Company (Industry)';

  @override
  String get educatedAt => 'Educated at';

  @override
  String get showInstitutionOnProfile =>
      'Show your institution on your profile';

  @override
  String get institutionLabel => 'Institution';

  @override
  String get graduationYear => 'Graduation Year';

  @override
  String get enterInstitution => 'Please enter your institution name.';

  @override
  String get maxThreeLanguages => 'You can select up to 3 languages';

  @override
  String get whatLookingFor => 'What are you looking for?';

  @override
  String maxThreeForMode(String mode) {
    return 'You can select up to 3 options for the current mode ($mode).';
  }

  @override
  String errorSavingPreferences(String error) {
    return 'Error saving preferences: $error';
  }

  @override
  String get languagesIKnow => 'Languages I know';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get searchLanguages => 'Search languages';

  @override
  String get suggested => 'Suggested';

  @override
  String get allLanguages => 'All languages';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String percentTrust(String percent) {
    return '$percent% Trust';
  }

  @override
  String get profileCompleted => 'Profile Completed';

  @override
  String get completeProfile => 'Complete profile';

  @override
  String get higherScoreHelps =>
      'A higher score helps you get more\nauthentic matches';

  @override
  String get noBioYet => 'No bio added yet.';

  @override
  String get askMe => 'Ask me';

  @override
  String get activeLabel => 'Active';

  @override
  String get addReligion => 'Add Religion';

  @override
  String get addZodiac => 'Add Zodiac';

  @override
  String get premium => 'PREMIUM';

  @override
  String get getNoticedSooner =>
      'Get noticed sooner and\ngo on 3x as many dates';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get spotlight => 'Spot light';

  @override
  String get standOut => 'Stand out';

  @override
  String get superSwipe => 'Super swipe';

  @override
  String get getNoticed => 'Get noticed';

  @override
  String get scoreBreakdown => 'Score breakdown';

  @override
  String get profilePhotoVerified => 'Profile photo verified';

  @override
  String get completedLabel => 'Completed';

  @override
  String get profileDetails => 'Profile details';

  @override
  String get incompleteLabel => 'Incomplete';

  @override
  String get connectSocialAccounts => 'Connect social accounts';

  @override
  String get waysToImprove => 'Ways to improve';

  @override
  String get verifyYourPhotos => 'Verify your photos';

  @override
  String get proveYoureReal => 'Prove you\'re real to other members';

  @override
  String get addPromptsInterests => 'Add prompts, interests and other details';

  @override
  String get verificationDataSecure =>
      'You\'re verification data is handled secured and is not shared on your public profile. ';

  @override
  String get learnMore => 'Learn more';

  @override
  String get improveYourProfile => 'Improve your Profile';

  @override
  String errorSavingHometown(String error) {
    return 'Error saving hometown: $error';
  }

  @override
  String get searchCity => 'Search city';

  @override
  String get aboutYou => 'About You';

  @override
  String get bioPrompt =>
      'Don\'t be shy! This is your chance to share your personality with a short bio.';

  @override
  String get textHereHint => 'Text Here.....';

  @override
  String failedToSaveBio(String error) {
    return 'Failed to save bio: $error';
  }

  @override
  String get selectYourInterests => 'Select Your Interests';

  @override
  String get atLeast5Interests =>
      'Please select at least 5 interest. This helps us find your peoples';

  @override
  String get searchForInterest => 'Search for interest';

  @override
  String get noInterestsFound => 'No interests found';

  @override
  String get failedLoadInterests =>
      'Failed to load interests. Please try again.';

  @override
  String get maxTenInterests => 'You can select up to 10 interests';

  @override
  String get minFiveInterests => 'Please select at least 5 interests';

  @override
  String errorSavingInterests(String error) {
    return 'Error saving interests: $error';
  }

  @override
  String get lifeStyle => 'Life Style';

  @override
  String get lifestylePrompt =>
      'Tell us more about your habits. Pick what fits you best.';

  @override
  String get noLifestyleOptions => 'No lifestyle options available';

  @override
  String get failedLoadLifestyle =>
      'Failed to load lifestyle options. Please try again.';

  @override
  String get selectEachCategory =>
      'Please select an option for each category, or clear all to skip.';

  @override
  String get findYourCity => 'Find your current city';

  @override
  String errorSavingLocation(String error) {
    return 'Error saving location: $error';
  }

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredBody =>
      'This permission is required for the app to function correctly. Please enable it in settings.';

  @override
  String get cameraAccess => 'Camera Access';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get locationAccess => 'Location Access';

  @override
  String get notificationAccess => 'Notification Access';

  @override
  String get microphoneAccess => 'Microphone Access';

  @override
  String get unknownAccess => 'Unknown Access';

  @override
  String get cameraReason => 'To take profile photos and verify identity.';

  @override
  String get photoReason => 'To upload photos from your gallery.';

  @override
  String get locationReason => 'To show you matches nearby.';

  @override
  String get notificationReason => 'To alert you of new matches and messages.';

  @override
  String get microphoneReason => 'For voice and video interactions.';

  @override
  String get appPermissions => 'App Permissions';

  @override
  String get chooseYourPrompt => 'Choose Your Prompt';

  @override
  String get selectUpTo3Prompts =>
      'Select up to 3 prompt to showing up your personality.';

  @override
  String get maxThreePrompts => 'You can only select up to 3 prompts.';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get removeThisPrompt => 'Want to remove this prompt?';

  @override
  String get selectThreePrompts => 'Please select 3 prompts to continue.';

  @override
  String get selectOnePrompt => 'Please select at least 1 prompt.';

  @override
  String selectNMorePrompts(String count) {
    return 'Please select $count prompt to continue';
  }

  @override
  String get noPromptsForCategory => 'No prompts available for this category.';

  @override
  String get typeYourAnswer => 'Type your answer...';

  @override
  String get addPrompt => 'Add Prompt';

  @override
  String failedToLoadPrompts(String error) {
    return 'Failed to load prompts: $error';
  }

  @override
  String errorSavingPrompts(String error) {
    return 'Error saving prompts: $error';
  }

  @override
  String get communityGuidelines => 'Community guidelines';

  @override
  String get agreeAndContinue => 'Agree & Continue';

  @override
  String get termsByContinuePrefix => 'By Continue, you agree to our ';

  @override
  String get guidelinesIntro =>
      'Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.';

  @override
  String get beKindTitle => 'Be kind and respectful';

  @override
  String get beKindBody =>
      'Treat others as you would like to be treated. We\'re all in together to create welcoming environment.';

  @override
  String get stayAuthenticTitle => 'Stay authentic';

  @override
  String get stayAuthenticBody =>
      'Be genuine in your profile and interactions. We value authenticity and real connections.';

  @override
  String get prioritizeSafetyTitle => 'Prioritize safety';

  @override
  String get prioritizeSafetyBody =>
      'Do not share sensitive and personal information. Protect your self and others in the community.';

  @override
  String get noHateTitle => 'No hate speech';

  @override
  String get noHateBody =>
      'Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.';

  @override
  String get helpKeepSafeTitle => 'Help keep us safe';

  @override
  String get helpKeepSafeBody =>
      'If you see something that violate our guideline. Please report it. Your help is invaluable.';

  @override
  String get genuineIntentTitle => 'Date with genuine intentions';

  @override
  String get genuineIntentBody =>
      'We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.';

  @override
  String get adultsOnlyTitle => 'Adults only';

  @override
  String get adultsOnlyBody =>
      'You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.';

  @override
  String get letsIntroduceYou => 'Let\'s introduce you!';

  @override
  String get needNameForProfile => 'We need your Name to create your profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get enterYourName => 'Enter Your Name';

  @override
  String get needDobForProfile => 'We need your DOB to create your profile';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get birthdayNote =>
      'Your birthday is used to calculate your age and will be shown on your profile. Your full name will not be public';

  @override
  String failedToSaveData(String error) {
    return 'Failed to save data: $error';
  }

  @override
  String get whatsYourGender => 'What\'s your Gender?';

  @override
  String get genderHelpsMatches =>
      'This help us show you relevant profiles and find your matches';

  @override
  String get vNonBinary => 'Non-Binary';

  @override
  String get vPreferNot => 'Prefer Not';

  @override
  String failedToSaveGender(String error) {
    return 'Failed to save gender: $error';
  }

  @override
  String grantPermissionPhotos(String permission) {
    return 'Please grant $permission permission to upload photos for your profile.';
  }

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get photoNotAccepted => 'Photo Not Accepted';

  @override
  String get couldNotVerifyPhoto => 'We could not verify your photo because:';

  @override
  String get tryDifferentPhoto => 'Please try uploading a different photo.';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get addAtLeast2Photos =>
      'Add at least 2 photos to get your matches! First one is main picture';

  @override
  String get tapPhotoToEdit => 'Tap on an added photo to edit or remove it.';

  @override
  String get addOneMorePhoto => 'Please add one more photo';

  @override
  String get addMorePhotos => 'Add more photos';

  @override
  String get mainPhotoBadge => 'MAIN';

  @override
  String get editPhoto => 'Edit Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get realConnectionsStartHere => 'Real connections start here!';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get iHaveAnAccount => 'I have an account';

  @override
  String get agreeToOurTerms => 'you agree to our terms';

  @override
  String get findPeopleNearYou => 'Find People Near You';

  @override
  String get locationAccessBody =>
      'To show you potential matches in your area. We need to\nknow your location. This also help us verify your\ngeneral location for authenticity and safety. Don\'t\nworry, your exact location is never shared';

  @override
  String get allowLocationAccess => 'Allow location access';

  @override
  String get events => 'Events';

  @override
  String get booked => 'Booked';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noEventsFound => 'No Events Found';

  @override
  String get noEventsNearby =>
      'There are no events happening nearby at the moment. Check back later or adjust your location.';

  @override
  String get refreshEvents => 'Refresh Events';

  @override
  String get bookedEvents => 'Booked Events';

  @override
  String get ticketsAndReservations => 'Your tickets and reservations';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get eventsYouAreInterested => 'Events you are interested in';

  @override
  String get incomingVideoCall => 'Incoming video call';

  @override
  String get incomingVoiceCall => 'Incoming voice call';

  @override
  String get ringing => 'Ringing...';

  @override
  String get speaker => 'Speaker';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get videoOff => 'Video Off';

  @override
  String get video => 'Video';

  @override
  String get decline => 'Decline';

  @override
  String get flip => 'Flip';

  @override
  String get callEnded => 'Call Ended';

  @override
  String get howWasCallQuality => 'How was the call quality?';

  @override
  String get switchToVideoCall => 'Switch to Video Call?';

  @override
  String get otherWantsVideoOn => 'The other user wants to turn on video.';

  @override
  String get switchToVoiceCall => 'Switch to Voice Call?';

  @override
  String get otherWantsVideoOff => 'The other user wants to turn off video.';

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get incomingVideoCallTitle => 'Incoming Video Call';

  @override
  String get incomingVoiceCallTitle => 'Incoming Voice Call';

  @override
  String get errorTitle => 'Error';

  @override
  String get successTitle => 'Success';

  @override
  String get great => 'Great!';

  @override
  String get peoples => 'Peoples';

  @override
  String get chatTab => 'Chat';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String percentComplete(String percent) {
    return '$percent% complete';
  }

  @override
  String get profileStrength => 'Profile strength';

  @override
  String get photosAndVideos => 'Photos and videos';

  @override
  String get pickSomeTrueYou => 'Pick some that show the true you.';

  @override
  String get holdDragReorder => 'Hold and drag media to reorder';

  @override
  String get bestPhoto => 'Best photo';

  @override
  String get aboutYouSection => 'About you';

  @override
  String get aboutYouHint => 'About you...';

  @override
  String get writeFunIntro => 'Write a fun intro.';

  @override
  String get letPeopleKnowDate =>
      'Let people know what it\'s like to date you.';

  @override
  String get addAPrompt => 'Add a prompt';

  @override
  String get prompts => 'Prompts';

  @override
  String get prompt => 'Prompt';

  @override
  String get addVoiceIntro => 'Add a voice intro';

  @override
  String get letPeopleHearVoice => 'Let people hear your voice.';

  @override
  String get reRecordIntro => 'Re-record intro';

  @override
  String get deleteVoiceIntro => 'Delete Voice Intro?';

  @override
  String get removeVoiceIntroBody =>
      'This will remove your voice intro from your profile.';

  @override
  String get interests => 'Interests';

  @override
  String get addFavoriteInterests => 'Add your favorite interests';

  @override
  String get getSpecificThingsYouLove =>
      'Get specific about the things you love.';

  @override
  String get lifestyle => 'Lifestyle';

  @override
  String get addLifestylePrefs => 'Add your lifestyle preferences';

  @override
  String get habitsAndPrefs => 'Your habits and preferences.';

  @override
  String get iAmLookingFor => 'I am looking for';

  @override
  String get addWhatLookingFor => 'Add what you are looking for';

  @override
  String get letOthersKnowWant => 'Let others know what you want to find';

  @override
  String get qualitiesIValue => 'Qualities i value';

  @override
  String get addQualitiesYouValue => 'Add qualities you value';

  @override
  String get chooseThreeQualitiesValue =>
      'Choose up to 3 qualities you value in a person';

  @override
  String get myCausesSection => 'My causes and communities';

  @override
  String get addYourCauses => 'Add your causes and communities';

  @override
  String get addUpTo3Causes => 'Add up to 3 causes close to your heart.';

  @override
  String get addLanguagesYouKnow => 'Add Languages you know';

  @override
  String get moreAboutYou => 'More about you';

  @override
  String get heightLabel => 'Height';

  @override
  String get genderLabel => 'Gender';

  @override
  String get pronounsLabel => 'Pronouns';

  @override
  String get pickYourPronouns => 'Pick your pronouns';

  @override
  String get addYourPronouns => 'Add your pronouns';

  @override
  String get workLabel => 'Work';

  @override
  String get educationLevelLabel => 'Education level';

  @override
  String get hometownLabel => 'Hometown';

  @override
  String get locationLabel => 'Location';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get drinkingLabel => 'Drinking';

  @override
  String get smokingLabel => 'Smoking';

  @override
  String get kidsLabel => 'Kids';

  @override
  String get kidsPreferenceLabel => 'Kids Preference';

  @override
  String get politicsLabel => 'Politics';

  @override
  String get zodiacLabel => 'Zodiac';

  @override
  String get educatedAtLabel => 'Educated at';

  @override
  String get connectedAccounts => 'Connected accounts';

  @override
  String get connectMySpotify => 'Connect my spotify';

  @override
  String get showFavoriteMusic => 'Show your favorite music';

  @override
  String get spotifyNote =>
      'Show your top spotify artists on your profile and allow blindly to highlight who have in common with others.';

  @override
  String get verification => 'Verification';

  @override
  String get verified => 'Verified';

  @override
  String get invalidLocation => 'Invalid Location';

  @override
  String get locationFound => 'Location Found';

  @override
  String get alreadyVerified => 'You have been already verified';

  @override
  String get verificationSuccessful => 'Verification Successful';

  @override
  String get documentNotVerified => 'Document could not be verified.';

  @override
  String get verificationFailed => 'Verification Failed';

  @override
  String get veriffReason =>
      'We could not verify your ID. Veriff provided this reason:';

  @override
  String get tryClearerImage => 'Please try again with a clearer image.';

  @override
  String get veriffWaiting => 'Veriff finished. Waiting for webhook update...';

  @override
  String get verificationSubmitted =>
      'Verification Submitted! Reviewing your ID...';

  @override
  String get verifyYourProfile => 'Verify Your Profile';

  @override
  String get youAreVerified => 'You are Verified!';

  @override
  String get quickCheckSafe => 'A quick check to keep you safe';

  @override
  String get identityConfirmed => 'Your identity has been confirmed.';

  @override
  String get veriffExplainer =>
      'To confirm your identity, we use Veriff for secure document scanning.';

  @override
  String get verifyingResults => 'Verifying Results...';

  @override
  String get verificationComplete => 'Verification Complete';

  @override
  String get tapToScanDocument => 'Tap to Scan Document';

  @override
  String get prepareIdCard => 'Prepare your physical ID card';

  @override
  String get ensureGoodLighting => 'Ensure good lighting';

  @override
  String get readyForSelfie => 'Be ready for a quick selfie';

  @override
  String get processing => 'Processing...';

  @override
  String get startVerification => 'Start Verification';

  @override
  String get poweredByVeriff => 'Powered by Veriff';

  @override
  String get alignWithCamera => 'Align yourself with the camera';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required for verification.';

  @override
  String get noCameraFound => 'No camera found on device.';

  @override
  String get reviewingYourPhotos => 'We\'re reviewing your photos';

  @override
  String get verificationInProgress =>
      'Your profile verification is in progress. This usually takes a few seconds.';

  @override
  String get verifiedSuccessfully => 'Verified Successfully!';

  @override
  String get profileVerificationDone =>
      'Profile verification successfully completed';

  @override
  String get gotIt => 'Got it';

  @override
  String get copyThisPose => 'Copy this pose';

  @override
  String get selfieVerification => 'Selfie Verification';

  @override
  String get proveRealDeal => 'Prove You\'re the\nReal Deal';

  @override
  String get quickHelpsSafe =>
      'This quick helps takes keep our community safe and authentic';

  @override
  String get getVerifiedBadge => 'Get a verified badge';

  @override
  String get buildTrustBody =>
      'Build trust with other users and shown you\'re real.';

  @override
  String get keepCommunitySafe => 'Keep the community safe';

  @override
  String get weedOutFakes => 'Help us weed out fake profiles and bots.';

  @override
  String get copySimplePose => 'Copy a simple pose';

  @override
  String get quickSelfieConfirm =>
      'You\'ll take quick selfie to confirm your identity';

  @override
  String get selfieNotOnProfile =>
      'Note: Your selfie is only for verification and won\'t to be on your profile';

  @override
  String get getVerified => 'Get verified';

  @override
  String get voiceIntroTooShort => 'Voice intro must be at least 1 second';

  @override
  String get recordVoiceIntroFirst => 'Please record a voice intro';

  @override
  String get recordingBetween1And30 =>
      'Recording must be between 1 and 30 seconds';

  @override
  String get recordShortIntro => 'Record a short intro';

  @override
  String get personalityShine =>
      'Let your personality shine through. Record a 30 seconds short intro.';

  @override
  String get recordAgain => 'Record Again';

  @override
  String get voicePromptsHelp =>
      'Voice prompts help you stand out and make deeper connections. Share who you really are';

  @override
  String get threeXMatches => '3x more matches in voice record';

  @override
  String get startConversationNaturally => 'Start conversation naturally';

  @override
  String get showYourPersonality => 'Show your personality';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String failedUploadVoice(String error) {
    return 'Failed to upload voice intro: $error';
  }

  @override
  String get failedToStartRecording => 'Failed to start recording';

  @override
  String get failedToStopRecording => 'Failed to stop recording';

  @override
  String get failedToPlayAudio => 'Failed to play audio';

  @override
  String get navLikes => 'Likes';
}
