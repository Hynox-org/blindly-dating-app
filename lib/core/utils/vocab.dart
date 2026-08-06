import 'package:blindly_dating_app/l10n/app_localizations.dart';

/// Translates a profile *value* for display without changing the value itself.
///
/// Religions, languages, habits and the rest are stored in Supabase and matched
/// against in filters as canonical English strings, so they must stay English on
/// the wire. Screens keep passing those values around and only wrap them in
/// [vocabLabel] at the point they are rendered.
///
/// Unknown values (DB-driven interest chips, free-text professions) fall through
/// unchanged.
String vocabLabel(AppLocalizations l10n, String value) {
  switch (value.trim()) {
    // Languages
    case 'English':
      return l10n.vEnglish;
    case 'Hindi':
      return l10n.vHindi;
    case 'Tamil':
      return l10n.vTamil;
    case 'Telugu':
      return l10n.vTelugu;
    case 'Kannada':
      return l10n.vKannada;
    case 'Malayalam':
      return l10n.vMalayalam;
    case 'Marathi':
      return l10n.vMarathi;
    case 'Bengali':
      return l10n.vBengali;
    case 'Gujarati':
      return l10n.vGujarati;
    case 'Punjabi':
      return l10n.vPunjabi;
    case 'Odia':
      return l10n.vOdia;
    case 'Spanish':
      return l10n.vSpanish;
    case 'French':
      return l10n.vFrench;
    case 'German':
      return l10n.vGerman;
    case 'Italian':
      return l10n.vItalian;
    case 'Portuguese':
      return l10n.vPortuguese;
    case 'Russian':
      return l10n.vRussian;
    case 'Japanese':
      return l10n.vJapanese;
    case 'Korean':
      return l10n.vKorean;
    case 'Chinese':
      return l10n.vChinese;
    case 'Arabic':
      return l10n.vArabic;
    case 'Turkish':
      return l10n.vTurkish;
    case 'Others':
      return l10n.vOthers;
    case 'Other':
      return l10n.vOther;

    // Religion
    case 'Hindu':
      return l10n.vHindu;
    case 'Christian':
      return l10n.vChristian;
    case 'Muslim':
      return l10n.vMuslim;
    case 'Sikh':
      return l10n.vSikh;
    case 'Jain':
      return l10n.vJain;
    case 'Buddhist':
      return l10n.vBuddhist;
    case 'Atheist':
      return l10n.vAtheist;
    case 'Agnostic':
      return l10n.vAgnostic;
    case 'Spiritual':
      return l10n.vSpiritual;
    case 'Catholic':
      return l10n.vCatholic;
    case 'Latter day saint':
      return l10n.vLatterDaySaint;
    case 'Zoroastrian':
      return l10n.vZoroastrian;
    case 'Jewish':
      return l10n.vJewish;
    case 'Mormon':
      return l10n.vMormon;

    // Relationship type
    case 'Monogamy':
      return l10n.vMonogamy;
    case 'Polyamory':
      return l10n.vPolyamory;
    case 'Open Relationship':
    case 'Open relationship':
      return l10n.vOpenRelationship;
    case 'Non-monogamy':
      return l10n.vNonMonogamy;
    case 'Open to exploring':
      return l10n.vOpenToExploring;
    case 'Short Term':
      return l10n.vShortTerm;
    case 'Long Term':
      return l10n.vLongTerm;

    // Sexual orientation
    case 'Straight':
      return l10n.vStraight;
    case 'Gay':
      return l10n.vGay;
    case 'Lesbian':
      return l10n.vLesbian;
    case 'Bisexual':
      return l10n.vBisexual;
    case 'Asexual':
      return l10n.vAsexual;
    case 'Demisexual':
      return l10n.vDemisexual;
    case 'Pansexual':
      return l10n.vPansexual;
    case 'Queer':
      return l10n.vQueer;
    case 'Questioning':
      return l10n.vQuestioning;

    // Gender / show me
    case 'Women':
      return l10n.vWomen;
    case 'Men':
      return l10n.vMen;
    case 'Everyone':
      return l10n.vEveryone;
    case 'Male':
      return l10n.vMale;
    case 'Female':
      return l10n.vFemale;

    // Dating intention / looking for
    case 'Fun, causal dates':
      return l10n.vFunCasualDates;
    case 'Life partner':
      return l10n.vLifePartner;
    case 'Long-term relationship':
      return l10n.vLongTermRelationship;
    case 'Short-term relationship':
      return l10n.vShortTermRelationship;
    case 'Still figuring it out':
      return l10n.vStillFiguringOut;
    case 'Long-term, open to short':
      return l10n.vLongOpenToShort;
    case 'Short-term, open to long':
      return l10n.vShortOpenToLong;
    case 'Casual dating':
      return l10n.vCasualDating;
    case 'New friends':
      return l10n.vNewFriends;
    case 'Close friends':
      return l10n.vCloseFriends;
    case 'Activity partners':
      return l10n.vActivityPartners;
    case 'Professional networking':
      return l10n.vProfessionalNetworking;
    case 'Workout buddy':
      return l10n.vWorkoutBuddy;
    case 'Travel buddies':
      return l10n.vTravelBuddies;

    // Drinking
    case 'Yes, i drink':
      return l10n.vYesIDrink;
    case 'Occasionally':
      return l10n.vOccasionally;
    case 'Sometimes':
      return l10n.vSometimes;
    case 'Never drink':
      return l10n.vNeverDrink;
    case 'Regularly':
      return l10n.vRegularly;
    case "I'm Sober":
      return l10n.vImSober;
    case 'Socially':
      return l10n.vSocially;
    case 'Never':
      return l10n.vNever;

    // Smoking
    case 'Social smoker':
      return l10n.vSocialSmoker;
    case 'Smoker when drinking':
      return l10n.vSmokerWhenDrinking;
    case 'Non-smoker':
      return l10n.vNonSmoker;
    case 'Smoker':
      return l10n.vSmoker;
    case 'Trying to quit':
      return l10n.vTryingToQuit;

    // Exercise
    case 'Daily':
      return l10n.vDaily;
    case 'Weekly':
      return l10n.vWeekly;

    // Education
    case 'High school':
      return l10n.vHighSchool;
    case 'Grade School':
      return l10n.vGradeSchool;
    case 'Diploma':
      return l10n.vDiploma;
    case 'Under Graduate':
      return l10n.vUnderGraduate;
    case 'Post Graduate':
      return l10n.vPostGraduate;
    case 'Doctorate':
      return l10n.vDoctorate;

    // Political view
    case 'Communist':
      return l10n.vCommunist;
    case 'Socialist':
      return l10n.vSocialist;
    case 'Apolitical':
      return l10n.vApolitical;
    case 'Moderate':
      return l10n.vModerate;
    case 'Not Interested':
      return l10n.vNotInterested;

    // Kids
    case 'Have kids':
      return l10n.vHaveKids;
    case "Don't have kids":
      return l10n.vDontHaveKids;
    case "Don't want kids":
      return l10n.vDontWantKids;
    case 'Want Kids':
      return l10n.vWantKids;
    case 'Open to kids':
      return l10n.vOpenToKids;
    case 'Not Sure':
      return l10n.vNotSure;
    case 'Prefer not to say':
      return l10n.vPreferNotToSay;

    // Zodiac
    case 'Aries':
      return l10n.vAries;
    case 'Taurus':
      return l10n.vTaurus;
    case 'Gemini':
      return l10n.vGemini;
    case 'Cancer':
      return l10n.vCancer;
    case 'Leo':
      return l10n.vLeo;
    case 'Virgo':
      return l10n.vVirgo;
    case 'Libra':
      return l10n.vLibra;
    case 'Scorpio':
      return l10n.vScorpio;
    case 'Sagittarius':
      return l10n.vSagittarius;
    case 'Capricorn':
      return l10n.vCapricorn;
    case 'Aquarius':
      return l10n.vAquarius;
    case 'Pisces':
      return l10n.vPisces;

    // Causes & communities
    case 'Human Rights':
      return l10n.vHumanRights;
    case 'Disability Rights':
      return l10n.vDisabilityRights;
    case 'Feminism':
      return l10n.vFeminism;
    case 'Black Lives Matter':
    case 'Black Live Matters':
      return l10n.vBlackLivesMatter;
    case 'Environmentalism':
      return l10n.vEnvironmentalism;
    case 'LGBTQ Rights':
      return l10n.vLgbtqRights;
    case 'Immigrant Rights':
      return l10n.vImmigrantRights;
    case 'End Religious Hate':
      return l10n.vEndReligiousHate;
    case 'Indigenous Rights':
      return l10n.vIndigenousRights;
    case 'Neuro diversity':
      return l10n.vNeuroDiversity;
    case 'Voter Rights':
      return l10n.vVoterRights;
    case 'Reproductive Rights':
      return l10n.vReproductiveRights;

    // Person qualities
    case 'Ambition':
      return l10n.vAmbition;
    case 'Confidence':
      return l10n.vConfidence;
    case 'Empathy':
      return l10n.vEmpathy;
    case 'Humor':
      return l10n.vHumor;
    case 'Kindness':
      return l10n.vKindness;
    case 'Openness':
      return l10n.vOpenness;
    case 'Optimism':
      return l10n.vOptimism;
    case 'Sassiness':
      return l10n.vSassiness;
    case 'Playfulness':
      return l10n.vPlayfulness;
    case 'Leadership':
      return l10n.vLeadership;
    case 'Humility':
      return l10n.vHumility;
    case 'Loyalty':
      return l10n.vLoyalty;
    case 'Sarcasm':
      return l10n.vSarcasm;
    case 'Gratitude':
      return l10n.vGratitude;
    case 'Curiosity':
      return l10n.vCuriosity;
    case 'Emotional Intelligence':
      return l10n.vEmotionalIntelligence;

    default:
      return value;
  }
}
