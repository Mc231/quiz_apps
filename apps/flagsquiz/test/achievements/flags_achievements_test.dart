import 'package:flags_quiz/achievements/flags_achievements.dart';
import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/achievements/base_achievements.dart';
import 'package:quiz_engine/src/l10n/generated/quiz_engine_localizations.dart';
import 'package:shared_services/shared_services.dart';

/// Mock AppLocalizations for testing.
class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super('en');

  // Explorer achievements
  @override
  String get achievementExploreAfrica => 'African Explorer';
  @override
  String get achievementExploreAfricaDesc => 'Complete a quiz about Africa';
  @override
  String get achievementExploreAsia => 'Asian Explorer';
  @override
  String get achievementExploreAsiaDesc => 'Complete a quiz about Asia';
  @override
  String get achievementExploreEurope => 'European Explorer';
  @override
  String get achievementExploreEuropeDesc => 'Complete a quiz about Europe';
  @override
  String get achievementExploreNorthAmerica => 'North American Explorer';
  @override
  String get achievementExploreNorthAmericaDesc =>
      'Complete a quiz about North America';
  @override
  String get achievementExploreSouthAmerica => 'South American Explorer';
  @override
  String get achievementExploreSouthAmericaDesc =>
      'Complete a quiz about South America';
  @override
  String get achievementExploreOceania => 'Oceanian Explorer';
  @override
  String get achievementExploreOceaniaDesc => 'Complete a quiz about Oceania';
  @override
  String get achievementWorldTraveler => 'World Traveler';
  @override
  String get achievementWorldTravelerDesc =>
      'Complete a quiz in every continent';

  // Region Mastery achievements
  @override
  String get achievementMasterEurope => 'Europe Master';
  @override
  String get achievementMasterEuropeDesc => 'Get 5 perfect scores in Europe';
  @override
  String get achievementMasterAsia => 'Asia Master';
  @override
  String get achievementMasterAsiaDesc => 'Get 5 perfect scores in Asia';
  @override
  String get achievementMasterAfrica => 'Africa Master';
  @override
  String get achievementMasterAfricaDesc => 'Get 5 perfect scores in Africa';
  @override
  String get achievementMasterAmericas => 'Americas Master';
  @override
  String get achievementMasterAmericasDesc =>
      'Get 5 perfect scores in North or South America';
  @override
  String get achievementMasterOceania => 'Oceania Master';
  @override
  String get achievementMasterOceaniaDesc => 'Get 5 perfect scores in Oceania';
  @override
  String get achievementMasterWorld => 'World Master';
  @override
  String get achievementMasterWorldDesc =>
      'Get 5 perfect scores in All Countries';

  // Collection achievements
  @override
  String get achievementFlagCollector => 'Flag Collector';
  @override
  String get achievementFlagCollectorDesc =>
      'Answer every flag correctly at least once';

  // Required overrides for other strings
  @override
  String get selectRegion => 'Select Region';
  @override
  String get all => 'All';
  @override
  String get europe => 'Europe';
  @override
  String get asia => 'Asia';
  @override
  String get africa => 'Africa';
  @override
  String get northAmerica => 'North America';
  @override
  String get southAmerica => 'South America';
  @override
  String get oceania => 'Oceania';
  @override
  String get yourScore => 'Your Score';
  @override
  String get settings => 'Settings';
  @override
  String get history => 'History';
  @override
  String get statistics => 'Statistics';
  @override
  String get play => 'Play';
  @override
  String get challenges => 'Challenges';
  @override
  String get practice => 'Practice';
  @override
  String get questions => 'questions';
  @override
  String get exitDialogTitle => 'Exit Quiz?';
  @override
  String get exitDialogMessage => 'Are you sure?';
  @override
  String get exitDialogConfirm => 'Yes';
  @override
  String get exitDialogCancel => 'No';
  @override
  String get correctFeedback => 'Correct!';
  @override
  String get incorrectFeedback => 'Incorrect!';
  @override
  String get hint5050Label => '50/50';
  @override
  String get hintSkipLabel => 'Skip';
  @override
  String get timerSecondsSuffix => 's';
  @override
  String get videoLoadError => 'Failed to load video';
  @override
  String get audioAndHaptics => 'Audio';
  @override
  String get soundEffects => 'Sound';
  @override
  String get soundEffectsDescription => 'Sound effects';
  @override
  String get backgroundMusic => 'Music';
  @override
  String get backgroundMusicDescription => 'Background music';
  @override
  String get hapticFeedback => 'Haptics';
  @override
  String get hapticFeedbackDescription => 'Vibrate';
  @override
  String get quizBehavior => 'Quiz';
  @override
  String get showAnswerFeedback => 'Feedback';
  @override
  String get showAnswerFeedbackDescription => 'Show feedback';
  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get themeSystem => 'System';
  @override
  String get selectTheme => 'Select Theme';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get aboutThisApp => 'About';
  @override
  String get privacyPolicy => 'Privacy';
  @override
  String get termsOfService => 'Terms';
  @override
  String get openSourceLicenses => 'Licenses';
  @override
  String get advanced => 'Advanced';
  @override
  String get resetToDefaults => 'Reset';
  @override
  String get resetToDefaultsDescription => 'Reset all';
  @override
  String get resetSettings => 'Reset Settings';
  @override
  String get resetSettingsMessage => 'Reset all settings?';
  @override
  String get cancel => 'Cancel';
  @override
  String get reset => 'Reset';
  @override
  String get close => 'Close';
  @override
  String get settingsResetToDefaults => 'Settings reset';
  @override
  String couldNotOpenUrl(String url) => 'Could not open $url';
  @override
  String get credits => 'Credits';
  @override
  String get attributions => 'Attributions';
  @override
  String get build => 'Build';
  @override
  String get sessionCompleted => 'Completed';
  @override
  String get sessionCancelled => 'Cancelled';
  @override
  String get sessionTimeout => 'Timeout';
  @override
  String get sessionFailed => 'Failed';
  @override
  String get perfectScore => 'Perfect!';
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String daysAgo(int count) => '$count days ago';
  @override
  String get noSessionsYet => 'No sessions';
  @override
  String get startPlayingToSee => 'Start playing';
  @override
  String get sessionDetails => 'Details';
  @override
  String get reviewAnswers => 'Review';
  @override
  String questionNumber(int number) => 'Question $number';
  @override
  String get yourAnswer => 'Your answer';
  @override
  String get correctAnswer => 'Correct answer';
  @override
  String get skipped => 'Skipped';
  @override
  String get practiceWrongAnswers => 'Practice';
  @override
  String get exportSession => 'Export';
  @override
  String get totalSessions => 'Total Sessions';
  @override
  String get totalQuestions => 'Total Questions';
  @override
  String get averageScore => 'Average Score';
  @override
  String get bestScore => 'Best Score';
  @override
  String get accuracy => 'Accuracy';
  @override
  String get timePlayed => 'Time Played';
  @override
  String get perfectScores => 'Perfect Scores';
  @override
  String get currentStreak => 'Current Streak';
  @override
  String get bestStreak => 'Best Streak';
  @override
  String get weeklyTrend => 'Weekly Trend';
  @override
  String get improving => 'Improving';
  @override
  String get declining => 'Declining';
  @override
  String get stable => 'Stable';
  @override
  String get noStatisticsYet => 'No stats';
  @override
  String get playQuizzesToSee => 'Play quizzes';
  @override
  String get exportAsJson => 'JSON';
  @override
  String get exportAsCsv => 'CSV';
  @override
  String get exportSuccess => 'Exported';
  @override
  String get exportError => 'Export failed';
  @override
  String get share => 'Share';
  @override
  String get delete => 'Delete';
  @override
  String get deleteSession => 'Delete Session';
  @override
  String get deleteSessionMessage => 'Delete?';
  @override
  String get sessionDeleted => 'Deleted';
  @override
  String get overview => 'Overview';
  @override
  String get insights => 'Insights';
  @override
  String get recentSessions => 'Recent';
  @override
  String get viewAll => 'View All';
  @override
  String get hours => 'hr';
  @override
  String get minutes => 'min';
  @override
  String get seconds => 'sec';
  @override
  String get days => 'days';
  @override
  String get duration => 'Duration';
  @override
  String get score => 'Score';
  @override
  String get correct => 'Correct';
  @override
  String get incorrect => 'Incorrect';

  // Country name stubs - just returning the code for testing
  @override
  String get ad => 'AD';
  @override
  String get ae => 'AE';
  @override
  String get ag => 'AG';
  @override
  String get ai => 'AI';
  @override
  String get af => 'AF';
  @override
  String get al => 'AL';
  @override
  String get am => 'AM';
  @override
  String get ao => 'AO';
  @override
  String get aq => 'AQ';
  @override
  String get ar => 'AR';
  @override
  String get at => 'AT';
  @override
  String get au => 'AU';
  @override
  String get aw => 'AW';
  @override
  String get ax => 'AX';
  @override
  String get az => 'AZ';
  @override
  String get ba => 'BA';
  @override
  String get bb => 'BB';
  @override
  String get bd => 'BD';
  @override
  String get be => 'BE';
  @override
  String get bf => 'BF';
  @override
  String get bg => 'BG';
  @override
  String get bh => 'BH';
  @override
  String get bi => 'BI';
  @override
  String get bj => 'BJ';
  @override
  String get bl => 'BL';
  @override
  String get bm => 'BM';
  @override
  String get bn => 'BN';
  @override
  String get bo => 'BO';
  @override
  String get bq => 'BQ';
  @override
  String get br => 'BR';
  @override
  String get bs => 'BS';
  @override
  String get bt => 'BT';
  @override
  String get bv => 'BV';
  @override
  String get bw => 'BW';
  @override
  String get by => 'BY';
  @override
  String get bz => 'BZ';
  @override
  String get ca => 'CA';
  @override
  String get cc => 'CC';
  @override
  String get cd => 'CD';
  @override
  String get cf => 'CF';
  @override
  String get cg => 'CG';
  @override
  String get ch => 'CH';
  @override
  String get ci => 'CI';
  @override
  String get ck => 'CK';
  @override
  String get cl => 'CL';
  @override
  String get cm => 'CM';
  @override
  String get cn => 'CN';
  @override
  String get co => 'CO';
  @override
  String get cr => 'CR';
  @override
  String get cu => 'CU';
  @override
  String get cv => 'CV';
  @override
  String get cw => 'CW';
  @override
  String get cx => 'CX';
  @override
  String get cy => 'CY';
  @override
  String get cz => 'CZ';
  @override
  String get de => 'DE';
  @override
  String get dj => 'DJ';
  @override
  String get dk => 'DK';
  @override
  String get dm => 'DM';
  @override
  String get doZ => 'DO';
  @override
  String get dz => 'DZ';
  @override
  String get ec => 'EC';
  @override
  String get ee => 'EE';
  @override
  String get eg => 'EG';
  @override
  String get eh => 'EH';
  @override
  String get er => 'ER';
  @override
  String get es => 'ES';
  @override
  String get et => 'ET';
  @override
  String get fi => 'FI';
  @override
  String get fj => 'FJ';
  @override
  String get fk => 'FK';
  @override
  String get fm => 'FM';
  @override
  String get fo => 'FO';
  @override
  String get fr => 'FR';
  @override
  String get ga => 'GA';
  @override
  String get gb => 'GB';
  @override
  String get gd => 'GD';
  @override
  String get ge => 'GE';
  @override
  String get gf => 'GF';
  @override
  String get gg => 'GG';
  @override
  String get gh => 'GH';
  @override
  String get gi => 'GI';
  @override
  String get gl => 'GL';
  @override
  String get gm => 'GM';
  @override
  String get gn => 'GN';
  @override
  String get gp => 'GP';
  @override
  String get gq => 'GQ';
  @override
  String get gr => 'GR';
  @override
  String get gs => 'GS';
  @override
  String get gt => 'GT';
  @override
  String get gu => 'GU';
  @override
  String get gw => 'GW';
  @override
  String get gy => 'GY';
  @override
  String get hk => 'HK';
  @override
  String get hm => 'HM';
  @override
  String get hn => 'HN';
  @override
  String get hr => 'HR';
  @override
  String get ht => 'HT';
  @override
  String get hu => 'HU';
  @override
  String get id => 'ID';
  @override
  String get ie => 'IE';
  @override
  String get il => 'IL';
  @override
  String get im => 'IM';
  @override
  String get inZ => 'IN';
  @override
  String get io => 'IO';
  @override
  String get iq => 'IQ';
  @override
  String get ir => 'IR';
  @override
  String get isZ => 'IS';
  @override
  String get it => 'IT';
  @override
  String get je => 'JE';
  @override
  String get jm => 'JM';
  @override
  String get jo => 'JO';
  @override
  String get jp => 'JP';
  @override
  String get ke => 'KE';
  @override
  String get kg => 'KG';
  @override
  String get kh => 'KH';
  @override
  String get ki => 'KI';
  @override
  String get km => 'KM';
  @override
  String get kn => 'KN';
  @override
  String get kp => 'KP';
  @override
  String get kr => 'KR';
  @override
  String get kw => 'KW';
  @override
  String get ky => 'KY';
  @override
  String get kz => 'KZ';
  @override
  String get la => 'LA';
  @override
  String get lb => 'LB';
  @override
  String get lc => 'LC';
  @override
  String get li => 'LI';
  @override
  String get lk => 'LK';
  @override
  String get lr => 'LR';
  @override
  String get ls => 'LS';
  @override
  String get lt => 'LT';
  @override
  String get lu => 'LU';
  @override
  String get lv => 'LV';
  @override
  String get ly => 'LY';
  @override
  String get ma => 'MA';
  @override
  String get mc => 'MC';
  @override
  String get md => 'MD';
  @override
  String get me => 'ME';
  @override
  String get mf => 'MF';
  @override
  String get mg => 'MG';
  @override
  String get mh => 'MH';
  @override
  String get mk => 'MK';
  @override
  String get ml => 'ML';
  @override
  String get mm => 'MM';
  @override
  String get mn => 'MN';
  @override
  String get mo => 'MO';
  @override
  String get mp => 'MP';
  @override
  String get mq => 'MQ';
  @override
  String get mr => 'MR';
  @override
  String get ms => 'MS';
  @override
  String get mt => 'MT';
  @override
  String get mu => 'MU';
  @override
  String get mv => 'MV';
  @override
  String get mw => 'MW';
  @override
  String get mx => 'MX';
  @override
  String get my => 'MY';
  @override
  String get mz => 'MZ';
  @override
  String get na => 'NA';
  @override
  String get nc => 'NC';
  @override
  String get ne => 'NE';
  @override
  String get nf => 'NF';
  @override
  String get ng => 'NG';
  @override
  String get ni => 'NI';
  @override
  String get nl => 'NL';
  @override
  String get no => 'NO';
  @override
  String get np => 'NP';
  @override
  String get nr => 'NR';
  @override
  String get nu => 'NU';
  @override
  String get nz => 'NZ';
  @override
  String get om => 'OM';
  @override
  String get pa => 'PA';
  @override
  String get pe => 'PE';
  @override
  String get pf => 'PF';
  @override
  String get pg => 'PG';
  @override
  String get ph => 'PH';
  @override
  String get pk => 'PK';
  @override
  String get pl => 'PL';
  @override
  String get pm => 'PM';
  @override
  String get pn => 'PN';
  @override
  String get pr => 'PR';
  @override
  String get ps => 'PS';
  @override
  String get pt => 'PT';
  @override
  String get pw => 'PW';
  @override
  String get py => 'PY';
  @override
  String get qa => 'QA';
  @override
  String get re => 'RE';
  @override
  String get ro => 'RO';
  @override
  String get rs => 'RS';
  @override
  String get ru => 'RU';
  @override
  String get rw => 'RW';
  @override
  String get sa => 'SA';
  @override
  String get sb => 'SB';
  @override
  String get sc => 'SC';
  @override
  String get sd => 'SD';
  @override
  String get se => 'SE';
  @override
  String get sg => 'SG';
  @override
  String get sh => 'SH';
  @override
  String get si => 'SI';
  @override
  String get sj => 'SJ';
  @override
  String get sk => 'SK';
  @override
  String get sl => 'SL';
  @override
  String get sm => 'SM';
  @override
  String get sn => 'SN';
  @override
  String get so => 'SO';
  @override
  String get sr => 'SR';
  @override
  String get ss => 'SS';
  @override
  String get st => 'ST';
  @override
  String get sv => 'SV';
  @override
  String get sx => 'SX';
  @override
  String get sy => 'SY';
  @override
  String get sz => 'SZ';
  @override
  String get tc => 'TC';
  @override
  String get td => 'TD';
  @override
  String get tf => 'TF';
  @override
  String get tg => 'TG';
  @override
  String get th => 'TH';
  @override
  String get tj => 'TJ';
  @override
  String get tk => 'TK';
  @override
  String get tl => 'TL';
  @override
  String get tm => 'TM';
  @override
  String get tn => 'TN';
  @override
  String get to => 'TO';
  @override
  String get tr => 'TR';
  @override
  String get tt => 'TT';
  @override
  String get tv => 'TV';
  @override
  String get tw => 'TW';
  @override
  String get tz => 'TZ';
  @override
  String get ua => 'UA';
  @override
  String get ug => 'UG';
  @override
  String get um => 'UM';
  @override
  String get us => 'US';
  @override
  String get uy => 'UY';
  @override
  String get uz => 'UZ';
  @override
  String get va => 'VA';
  @override
  String get vc => 'VC';
  @override
  String get ve => 'VE';
  @override
  String get vg => 'VG';
  @override
  String get vi => 'VI';
  @override
  String get vn => 'VN';
  @override
  String get vu => 'VU';
  @override
  String get wf => 'WF';
  @override
  String get ws => 'WS';
  @override
  String get xk => 'XK';
  @override
  String get ye => 'YE';
  @override
  String get yt => 'YT';
  @override
  String get za => 'ZA';
  @override
  String get zm => 'ZM';
  @override
  String get zw => 'ZW';

  // Dart reserved word, but generated as getter
  @override
  // ignore: non_constant_identifier_names
  String get as => 'AS';
}

/// Mock QuizEngineLocalizations for testing.
class MockQuizEngineLocalizations extends QuizEngineLocalizations {
  MockQuizEngineLocalizations() : super('en');

  @override
  String get achievementFirstQuiz => 'First Steps';
  @override
  String get achievementFirstQuizDesc => 'Complete your first quiz';
  @override
  String get achievementFirstPerfect => 'Perfectionist';
  @override
  String get achievementFirstPerfectDesc => 'Get your first perfect score';
  @override
  String get achievementFirstChallenge => 'Challenger';
  @override
  String get achievementFirstChallengeDesc =>
      'Complete your first challenge mode';

  // All other required overrides with stub values
  @override
  String get achievementQuizzes10 => 'Getting Started';
  @override
  String get achievementQuizzes10Desc => 'Complete 10 quizzes';
  @override
  String get achievementQuizzes50 => 'Quiz Enthusiast';
  @override
  String get achievementQuizzes50Desc => 'Complete 50 quizzes';
  @override
  String get achievementQuizzes100 => 'Quiz Master';
  @override
  String get achievementQuizzes100Desc => 'Complete 100 quizzes';
  @override
  String get achievementQuizzes500 => 'Quiz Legend';
  @override
  String get achievementQuizzes500Desc => 'Complete 500 quizzes';
  @override
  String get achievementQuestions100 => 'Century';
  @override
  String get achievementQuestions100Desc => 'Answer 100 questions';
  @override
  String get achievementQuestions500 => 'Half Thousand';
  @override
  String get achievementQuestions500Desc => 'Answer 500 questions';
  @override
  String get achievementQuestions1000 => 'Thousand Club';
  @override
  String get achievementQuestions1000Desc => 'Answer 1000 questions';
  @override
  String get achievementQuestions5000 => 'Expert';
  @override
  String get achievementQuestions5000Desc => 'Answer 5000 questions';
  @override
  String get achievementCorrect100 => 'Sharp Eye';
  @override
  String get achievementCorrect100Desc => 'Get 100 correct answers';
  @override
  String get achievementCorrect500 => 'Knowledge Keeper';
  @override
  String get achievementCorrect500Desc => 'Get 500 correct answers';
  @override
  String get achievementCorrect1000 => 'Scholar';
  @override
  String get achievementCorrect1000Desc => 'Get 1000 correct answers';
  @override
  String get achievementPerfect5 => 'Rising Star';
  @override
  String get achievementPerfect5Desc => 'Get 5 perfect scores';
  @override
  String get achievementPerfect10 => 'Shining Bright';
  @override
  String get achievementPerfect10Desc => 'Get 10 perfect scores';
  @override
  String get achievementPerfect25 => 'Constellation';
  @override
  String get achievementPerfect25Desc => 'Get 25 perfect scores';
  @override
  String get achievementPerfect50 => 'Galaxy';
  @override
  String get achievementPerfect50Desc => 'Get 50 perfect scores';
  @override
  String get achievementScore9010 => 'High Achiever';
  @override
  String get achievementScore9010Desc => 'Score 90%+ in 10 quizzes';
  @override
  String get achievementScore9510 => 'Excellence';
  @override
  String get achievementScore9510Desc => 'Score 95%+ in 10 quizzes';
  @override
  String get achievementPerfectStreak3 => 'Flawless Run';
  @override
  String get achievementPerfectStreak3Desc => 'Get 3 perfect scores in a row';
  @override
  String get achievementSpeedDemon => 'Speed Demon';
  @override
  String get achievementSpeedDemonDesc => 'Complete a quiz in under 60 seconds';
  @override
  String get achievementLightning => 'Lightning Fast';
  @override
  String get achievementLightningDesc => 'Complete a quiz in under 30 seconds';
  @override
  String get achievementQuickAnswer10 => 'Quick Thinker';
  @override
  String get achievementQuickAnswer10Desc => 'Answer 10 quickly';
  @override
  String get achievementQuickAnswer50 => 'Rapid Fire';
  @override
  String get achievementQuickAnswer50Desc => 'Answer 50 quickly';
  @override
  String get achievementStreak10 => 'On Fire';
  @override
  String get achievementStreak10Desc => 'Get 10 correct in a row';
  @override
  String get achievementStreak25 => 'Unstoppable';
  @override
  String get achievementStreak25Desc => 'Get 25 correct in a row';
  @override
  String get achievementStreak50 => 'Legendary Streak';
  @override
  String get achievementStreak50Desc => 'Get 50 correct in a row';
  @override
  String get achievementStreak100 => 'Mythical';
  @override
  String get achievementStreak100Desc => 'Get 100 correct in a row';
  @override
  String get achievementSurvivalComplete => 'Survivor';
  @override
  String get achievementSurvivalCompleteDesc => 'Complete Survival mode';
  @override
  String get achievementSurvivalPerfect => 'Immortal';
  @override
  String get achievementSurvivalPerfectDesc => 'Complete Survival without dying';
  @override
  String get achievementBlitzComplete => 'Blitz Master';
  @override
  String get achievementBlitzCompleteDesc => 'Complete Blitz mode';
  @override
  String get achievementBlitzPerfect => 'Lightning God';
  @override
  String get achievementBlitzPerfectDesc => 'Complete Blitz perfectly';
  @override
  String get achievementTimeAttack20 => 'Time Warrior';
  @override
  String get achievementTimeAttack20Desc => 'Answer 20+ in Time Attack';
  @override
  String get achievementTimeAttack30 => 'Time Lord';
  @override
  String get achievementTimeAttack30Desc => 'Answer 30+ in Time Attack';
  @override
  String get achievementMarathon50 => 'Endurance';
  @override
  String get achievementMarathon50Desc => 'Answer 50 in Marathon';
  @override
  String get achievementMarathon100 => 'Ultra Marathon';
  @override
  String get achievementMarathon100Desc => 'Answer 100 in Marathon';
  @override
  String get achievementSpeedRunFast => 'Speed Runner';
  @override
  String get achievementSpeedRunFastDesc => 'Complete Speed Run fast';
  @override
  String get achievementAllChallenges => 'Challenge Champion';
  @override
  String get achievementAllChallengesDesc => 'Complete all challenges';
  @override
  String get achievementTime1h => 'Dedicated';
  @override
  String get achievementTime1hDesc => 'Play for 1 hour';
  @override
  String get achievementTime5h => 'Committed';
  @override
  String get achievementTime5hDesc => 'Play for 5 hours';
  @override
  String get achievementTime10h => 'Devoted';
  @override
  String get achievementTime10hDesc => 'Play for 10 hours';
  @override
  String get achievementTime24h => 'Fanatic';
  @override
  String get achievementTime24hDesc => 'Play for 24 hours';
  @override
  String get achievementDays3 => 'Regular';
  @override
  String get achievementDays3Desc => 'Play 3 days in a row';
  @override
  String get achievementDays7 => 'Weekly Warrior';
  @override
  String get achievementDays7Desc => 'Play 7 days in a row';
  @override
  String get achievementDays14 => 'Two Week Streak';
  @override
  String get achievementDays14Desc => 'Play 14 days in a row';
  @override
  String get achievementDays30 => 'Monthly Master';
  @override
  String get achievementDays30Desc => 'Play 30 days in a row';
  @override
  String get achievementNoHints => 'Purist';
  @override
  String get achievementNoHintsDesc => 'Complete without hints';
  @override
  String get achievementNoHints10 => 'True Expert';
  @override
  String get achievementNoHints10Desc => 'Complete 10 without hints';
  @override
  String get achievementNoSkip => 'Determined';
  @override
  String get achievementNoSkipDesc => 'Complete without skipping';
  @override
  String get achievementFlawless => 'Flawless Victory';
  @override
  String get achievementFlawlessDesc => 'Perfect, no hints, no lives lost';
  @override
  String get achievementComeback => 'Comeback King';
  @override
  String get achievementComebackDesc => 'Win after losing 4+ lives';
  @override
  String get achievementClutch => 'Clutch Player';
  @override
  String get achievementClutchDesc => 'Complete Survival with 1 life';

  // Other required overrides
  @override
  String get play => 'Play';

  @override
  String get challenges => 'Challenges';
  @override
  String get history => 'History';
  @override
  String get statistics => 'Statistics';
  @override
  String get settings => 'Settings';
  @override
  String get score => 'Score';
  @override
  String get correct => 'Correct';
  @override
  String get incorrect => 'Incorrect';
  @override
  String get duration => 'Duration';
  @override
  String get questions => 'questions';
  @override
  String get exitDialogTitle => 'Exit?';
  @override
  String get exitDialogMessage => 'Exit?';
  @override
  String get exitDialogConfirm => 'Yes';
  @override
  String get exitDialogCancel => 'No';
  @override
  String get correctFeedback => 'Correct!';
  @override
  String get incorrectFeedback => 'Incorrect!';
  @override
  String get videoLoadError => 'Error';
  @override
  String get hint5050Label => '50/50';
  @override
  String get hintSkipLabel => 'Skip';
  @override
  String get timerSecondsSuffix => 's';
  @override
  String get hours => 'hr';
  @override
  String get minutes => 'min';
  @override
  String get seconds => 'sec';
  @override
  String get days => 'days';
  @override
  String get sessionCompleted => 'Completed';
  @override
  String get sessionCancelled => 'Cancelled';
  @override
  String get sessionTimeout => 'Timeout';
  @override
  String get sessionFailed => 'Failed';
  @override
  String get perfectScore => 'Perfect!';
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String daysAgo(int count) => '$count days ago';
  @override
  String get noSessionsYet => 'No sessions';
  @override
  String get startPlayingToSee => 'Start playing';
  @override
  String get sessionDetails => 'Details';
  @override
  String get reviewAnswers => 'Review';
  @override
  String questionNumber(int number) => 'Q$number';
  @override
  String get yourAnswer => 'Your answer';
  @override
  String get correctAnswer => 'Correct answer';
  @override
  String get skipped => 'Skipped';
  @override
  String get practiceWrongAnswers => 'Practice';
  @override
  String get totalSessions => 'Sessions';
  @override
  String get totalQuestions => 'Questions';
  @override
  String get averageScore => 'Average';
  @override
  String get bestScore => 'Best';
  @override
  String get accuracy => 'Accuracy';
  @override
  String get timePlayed => 'Time';
  @override
  String get perfectScores => 'Perfect';
  @override
  String get currentStreak => 'Streak';
  @override
  String get bestStreak => 'Best Streak';
  @override
  String get weeklyTrend => 'Trend';
  @override
  String get improving => 'Improving';
  @override
  String get declining => 'Declining';
  @override
  String get stable => 'Stable';
  @override
  String get noStatisticsYet => 'No stats';
  @override
  String get playQuizzesToSee => 'Play';
  @override
  String get overview => 'Overview';
  @override
  String get insights => 'Insights';
  @override
  String get audioAndHaptics => 'Audio';
  @override
  String get soundEffects => 'Sound';
  @override
  String get soundEffectsDescription => 'Sound';
  @override
  String get backgroundMusic => 'Music';
  @override
  String get backgroundMusicDescription => 'Music';
  @override
  String get hapticFeedback => 'Haptics';
  @override
  String get hapticFeedbackDescription => 'Haptics';
  @override
  String get quizBehavior => 'Quiz';
  @override
  String get showAnswerFeedback => 'Feedback';
  @override
  String get showAnswerFeedbackDescription => 'Feedback';
  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get themeSystem => 'System';
  @override
  String get selectTheme => 'Theme';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get build => 'Build';
  @override
  String get aboutThisApp => 'About';
  @override
  String get privacyPolicy => 'Privacy';
  @override
  String get termsOfService => 'Terms';
  @override
  String get openSourceLicenses => 'Licenses';
  @override
  String get advanced => 'Advanced';
  @override
  String get resetToDefaults => 'Reset';
  @override
  String get resetToDefaultsDescription => 'Reset';
  @override
  String get resetSettings => 'Reset';
  @override
  String get resetSettingsMessage => 'Reset?';
  @override
  String get cancel => 'Cancel';
  @override
  String get reset => 'Reset';
  @override
  String get close => 'Close';
  @override
  String get share => 'Share';
  @override
  String get delete => 'Delete';
  @override
  String get viewAll => 'All';
  @override
  String get credits => 'Credits';
  @override
  String get attributions => 'Attributions';
  @override
  String get exportSession => 'Export';
  @override
  String get exportAsJson => 'JSON';
  @override
  String get exportAsCsv => 'CSV';
  @override
  String get exportSuccess => 'Exported';
  @override
  String get exportError => 'Error';
  @override
  String get deleteSession => 'Delete';
  @override
  String get deleteSessionMessage => 'Delete?';
  @override
  String get sessionDeleted => 'Deleted';
  @override
  String get recentSessions => 'Recent';
  @override
  String get settingsResetToDefaults => 'Reset';
  @override
  String couldNotOpenUrl(String url) => 'Error';
  @override
  String get gameOverText => 'Score';
  @override
  String get noData => 'No data';
  @override
  String initializationError(String error) => 'Error';
  @override
  String get quizComplete => 'Complete!';
  @override
  String get excellent => 'Excellent!';
  @override
  String get greatJob => 'Great!';
  @override
  String get goodWork => 'Good!';
  @override
  String get keepPracticing => 'Keep practicing!';
  @override
  String get tryAgain => 'Try again!';
  @override
  String get reviewThisSession => 'Review';
  @override
  String get reviewWrongAnswers => 'Review Wrong';
  @override
  String get done => 'Done';
  @override
  String get playAgain => 'Play Again';
  @override
  String scoreOf(int correct, int total) => '$correct/$total';
  @override
  String get timedOut => 'Timed Out';
  @override
  String get hintsUsed => 'Hints';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get categoryBreakdown => 'Categories';
  @override
  String get noCategoryData => 'No data';
  @override
  String sessionsCount(int count) => '$count';
  @override
  String get noProgressData => 'No data';
  @override
  String get progressSummary => 'Progress';
  @override
  String get change => 'Change';
  @override
  String get lastWeek => 'Week';
  @override
  String get lastMonth => 'Month';
  @override
  String get last3Months => '3 Months';
  @override
  String get lastYear => 'Year';
  @override
  String get allTime => 'All Time';
  @override
  String get bestScores => 'Best';
  @override
  String get fastestPerfect => 'Fastest';
  @override
  String get mostPlayed => 'Most Played';
  @override
  String get bestStreaks => 'Streaks';
  @override
  String get noLeaderboardData => 'No data';
  @override
  String get progress => 'Progress';
  @override
  String get categories => 'Categories';
  @override
  String get leaderboard => 'Leaderboard';
  @override
  String get scoreOverTime => 'Score';
  @override
  String get last7Days => '7 days';
  @override
  String get last30Days => '30 days';
  @override
  String get last90Days => '90 days';
  @override
  String get last365Days => '365 days';
  @override
  String get allTimeData => 'All';
  @override
  String get highestScore => 'Highest';
  @override
  String get lowestScore => 'Lowest';
  @override
  String get noPracticeItems => 'No items';
  @override
  String get noPracticeItemsDescription => 'No wrong answers';
  @override
  String get practice => 'Practice';
  @override
  String get practiceMode => 'Practice';
  @override
  String get practiceEmptyTitle => 'No questions';
  @override
  String get practiceEmptyMessage => 'Great job!';
  @override
  String get practiceStartQuiz => 'Start Quiz';
  @override
  String get practiceStartTitle => 'Practice Mode';
  @override
  String practiceQuestionCount(int count) => '$count questions';
  @override
  String get practiceDescription => 'Questions you got wrong';
  @override
  String get startPractice => 'Start Practice';
  @override
  String get practiceCompleteTitle => 'Complete!';
  @override
  String practiceCorrectCount(int count) => '$count correct';
  @override
  String practiceNeedMorePractice(int count) => '$count need practice';
  @override
  String get practiceKeepGoing => 'Keep practicing!';
  @override
  String get practiceAllCorrect => 'Perfect!';
  @override
  String get practiceDone => 'Done';
  @override
  String wrongCount(int count) => 'Wrong $count times';
  @override
  String get achievements => 'Achievements';
  @override
  String get achievementUnlocked => 'Unlocked!';
  @override
  String achievementsUnlocked(int count, int total) => '$count/$total';
  @override
  String achievementPoints(int points) => '$points pts';
  @override
  String get hiddenAchievement => 'Hidden';
  @override
  String get hiddenAchievementDesc => 'Keep playing!';
  @override
  String get allTiers => 'All Tiers';
  @override
  String achievementProgress(int current, int target) => '$current/$target';
  @override
  String pointsRemaining(int points) => '$points remaining';
  @override
  String get allPointsEarned => 'All earned!';
  @override
  String completionPercentage(int percent) => '$percent%';
  @override
  String get filterAll => 'All';
  @override
  String get filterUnlocked => 'Unlocked';
  @override
  String get filterInProgress => 'In Progress';
  @override
  String get filterLocked => 'Locked';
  @override
  String get noAchievementsFound => 'No achievements found';
  @override
  String get tryChangingFilter => 'Try changing filter';
  @override
  String get noAchievementsInCategory => 'No achievements in category';
  @override
  String get otherAchievements => 'Other achievements';

  // Accessibility labels
  @override
  String get accessibilityDoubleTapToView => 'Double tap to view details';
  @override
  String get accessibilityDoubleTapToDismiss => 'Double tap to dismiss';
  @override
  String accessibilityAchievementUnlocked(String name, String tier, int points) =>
      '$name, $tier achievement, $points points, unlocked';
  @override
  String accessibilityAchievementLocked(
          String name, String tier, int points, int progress) =>
      '$name, $tier achievement, $points points, locked, $progress percent complete';
  @override
  String accessibilityAchievementNotification(
          String name, String tier, int points) =>
      'Achievement unlocked: $name, $tier, plus $points points';
  @override
  String accessibilityProgressBar(int current, int target) =>
      'Progress: $current of $target';
  @override
  String accessibilityTierBadge(String tier) => '$tier tier';
  @override
  String accessibilityPointsBadge(int points) => '$points points';

  // Score-related strings
  @override
  String get pointsLabel => 'pts';
  @override
  String get totalScore => 'Total Score';
  @override
  String get basePoints => 'Base Points';
  @override
  String get timeBonus => 'Time Bonus';
  @override
  String get streakBonus => 'Streak Bonus';
  @override
  String get bonus => 'Bonus';
  @override
  String get scoreBreakdown => 'Score Breakdown';
  @override
  String pointsEarned(int points) => '$points pts';
  @override
  String scorePlusBonus(int base, int bonus) => '$base + $bonus bonus';

  // Lives and hints strings
  @override
  String get livesLabel => 'Lives';
  @override
  String get livesTooltip => 'Lives remaining';
  @override
  String livesAccessibilityLabel(int count) => '$count lives remaining';
  @override
  String get fiftyFiftyTooltip => '50/50 hint';
  @override
  String fiftyFiftyAccessibilityLabel(int count) => '$count 50/50 hints remaining';
  @override
  String get skipTooltip => 'Skip hint';
  @override
  String skipAccessibilityLabel(int count) => '$count skip hints remaining';
  @override
  String get resourceDepleted => 'No more available';
  @override
  String get getMoreLives => 'Get More Lives';
  @override
  String get getMoreHints => 'Get More Hints';
  @override
  String get fiftyFiftyLabel => '50/50';
  @override
  String get skipLabel => 'Skip';
  @override
  String get needMoreLives => 'Need More Lives?';
  @override
  String get needMoreHints => 'Need More Hints?';
  @override
  String get needMoreSkips => 'Need More Skips?';
  @override
  String resourceRemaining(int count) => '$count remaining';
  @override
  String watchAdForResource(int count, String resource) =>
      'Watch Ad for +$count $resource';
  @override
  String buyResource(String resource) => 'Buy $resource...';
  @override
  String get noThanks => 'No Thanks';
  @override
  String get buyLives => 'Buy Lives';
  @override
  String get buyHints => 'Buy Hints';
  @override
  String get buySkips => 'Buy Skips';
  @override
  String get bestValue => 'Best Value';
  @override
  String get restorePurchases => 'Restore Purchases';
  @override
  String get noConnection => 'No Connection';
  @override
  String get connectToRestore => 'Connect to restore';
  @override
  String get ok => 'OK';
  @override
  String purchaseSuccess(int count, String resource) =>
      'Purchase successful! +$count $resource';
  @override
  String get purchaseFailed => 'Purchase failed';
  @override
  String get purchaseCancelled => 'Purchase cancelled';
  @override
  String get purchasePending => 'Purchase pending';
  @override
  String get purchasesRestored => 'Purchases restored';
  @override
  String adWatchSuccess(int count, String resource) =>
      '+$count $resource added!';
  @override
  String get adNotAvailable => 'Ad not available';
  @override
  String get dailyLimitReset => 'Daily resources reset!';
  @override
  String freeResourcesInfo(int count, String resource) =>
      '$count free $resource per day';

  // Missing accessibility methods
  @override
  String accessibilityCategoryButton(String category) => 'Category: $category';
  @override
  String accessibilityCategoryWithQuestions(String category, int count) =>
      '$category, $count questions';
  @override
  String get accessibilityDoubleTapToSelect => 'Double tap to select';
  @override
  String get accessibilityDoubleTapToStart => 'Double tap to start';
  @override
  String accessibilityChallengeButton(String name, String difficulty) =>
      '$name, $difficulty';
  @override
  String accessibilityAnswerOption(String answer) => 'Answer: $answer';
  @override
  String accessibilityAnswerDisabled(String answer) => '$answer, disabled';
  @override
  String accessibilitySessionCard(String date, int score, int total) =>
      '$date, $score of $total';
  @override
  String accessibilityStatistic(String label, String value) => '$label: $value';
  @override
  String accessibilityProgress(int percent) => '$percent percent complete';
  @override
  String accessibilityLivesRemaining(int count) => '$count lives remaining';
  @override
  String accessibilityHintsRemaining(int count, String type) =>
      '$count $type hints remaining';
  @override
  String accessibilityTimer(int seconds) => '$seconds seconds remaining';
  @override
  String get accessibilityCorrectAnswer => 'Correct answer';
  @override
  String get accessibilityIncorrectAnswer => 'Incorrect answer';
  @override
  String accessibilityQuestionNumber(int current, int total) =>
      'Question $current of $total';

  // Missing error/state methods
  @override
  String get retry => 'Retry';
  @override
  String get errorTitle => 'Error';
  @override
  String get errorGeneric => 'Something went wrong';
  @override
  String get errorNetwork => 'Network error';
  @override
  String get errorServer => 'Server error';
  @override
  String get loadingData => 'Loading...';

  // Missing export methods
  @override
  String get exportData => 'Export Data';
  @override
  String get exportDataDescription => 'Export your quiz data';
  @override
  String get exportDataDialogMessage => 'Export?';
  @override
  String get exportDataIncludes => 'Includes:';
  @override
  String get exportIncludesQuizHistory => 'Quiz history';
  @override
  String get exportIncludesAnswers => 'Answer details';
  @override
  String get exportIncludesStatistics => 'Statistics';
  @override
  String get exportIncludesSettings => 'Settings';
  @override
  String get export => 'Export';
  @override
  String get exportDataSubject => 'Quiz Data Export';
  @override
  String exportDataSuccess(int count) => 'Exported $count sessions';
  @override
  String get exportDataError => 'Export failed';
  @override
  String get dataAndPrivacy => 'Data & Privacy';

  // Missing leaderboard methods
  @override
  String get globalLeaderboard => 'Global Leaderboard';
  @override
  String get globalLeaderboardComingSoon => 'Coming soon';

  // Missing purchase methods
  @override
  String get purchaseNotAvailable => 'This product is not available.';
  @override
  String get purchaseAlreadyOwned => 'You already own this item.';

  // Shop section
  @override
  String get shop => 'Shop';
  @override
  String get removeAds => 'Remove Ads';
  @override
  String get removeAdsDescription => 'Enjoy ad-free gameplay forever';
  @override
  String get removeAdsPurchased => 'Ads Removed';
  @override
  String get removeAdsPurchasedDescription => 'Thank you for your purchase!';
  @override
  String get bundles => 'Bundles';
  @override
  String get bundleStarterTitle => 'Starter Pack';
  @override
  String get bundleStarterDescription => '5 lives + 5 fifty-fifty + 5 skips';
  @override
  String get bundleValueTitle => 'Value Pack';
  @override
  String get bundleValueDescription => '15 lives + 15 fifty-fifty + 15 skips';
  @override
  String get bundleProTitle => 'Pro Pack';
  @override
  String get bundleProDescription => '50 lives + 50 fifty-fifty + 50 skips';
  @override
  String get purchasing => 'Purchasing...';
  @override
  String get restoring => 'Restoring...';
  @override
  String get restorePurchasesDescription => 'Restore previous purchases';
  @override
  String get storeUnavailable => 'Store unavailable';
  @override
  String get storeUnavailableDescription => 'Unable to connect to the store.';
  @override
  String get noPurchasesToRestore => 'No purchases to restore';
  @override
  String purchasesRestoredCount(int count) => '$count purchases restored';
  @override
  String get buy => 'Buy';
  @override
  String get purchased => 'Purchased';

  // Rate App localizations
  @override
  String rateAppLoveDialogTitle(String appName) => 'Enjoying $appName?';
  @override
  String get rateAppLoveDialogYes => 'Yes!';
  @override
  String get rateAppLoveDialogNo => 'Not Really';
  @override
  String get rateAppFeedbackTitle => 'Feedback';
  @override
  String get rateAppFeedbackMessage => 'What could be better?';
  @override
  String get rateAppFeedbackEmailButton => 'Send Email';
  @override
  String get rateAppFeedbackDismiss => 'Maybe Later';
  @override
  String get rateAppThankYou => 'Thank you!';
  @override
  String get accessibilityRateDialogTitle => 'Rate dialog';
  @override
  String get accessibilityFeedbackDialogTitle => 'Feedback dialog';

  // Image answer accessibility localizations
  @override
  String accessibilityImageAnswer(String label) => 'Image answer: $label';
  @override
  String accessibilityImageAnswerDisabled(String label) =>
      'Image answer $label, eliminated';
  @override
  String get imageLoadError => 'Failed to load image';
}

void main() {
  late MockAppLocalizations appL10n;
  late MockQuizEngineLocalizations quizL10n;

  setUp(() {
    appL10n = MockAppLocalizations();
    quizL10n = MockQuizEngineLocalizations();
  });

  group('FlagsAchievements', () {
    test('all() returns exactly 14 achievements', () {
      final achievements = FlagsAchievements.all(appL10n);
      expect(achievements.length, equals(FlagsAchievements.count));
      expect(achievements.length, equals(14));
    });

    test('all achievements have unique IDs', () {
      final achievements = FlagsAchievements.all(appL10n);
      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, equals(achievements.length));
    });

    test('all achievements have valid categories', () {
      final achievements = FlagsAchievements.all(appL10n);
      final validCategories = {
        FlagsAchievements.categoryExplorer,
        FlagsAchievements.categoryRegionMastery,
        FlagsAchievements.categoryCollection,
      };

      for (final achievement in achievements) {
        expect(
          validCategories.contains(achievement.category),
          isTrue,
          reason:
              'Achievement ${achievement.id} has invalid category: ${achievement.category}',
        );
      }
    });

    test('all achievements have non-empty icons', () {
      final achievements = FlagsAchievements.all(appL10n);

      for (final achievement in achievements) {
        expect(
          achievement.icon.isNotEmpty,
          isTrue,
          reason: 'Achievement ${achievement.id} has empty icon',
        );
      }
    });

    test('all achievements have valid tiers', () {
      final achievements = FlagsAchievements.all(appL10n);
      final validTiers = AchievementTier.values.toSet();

      for (final achievement in achievements) {
        expect(
          validTiers.contains(achievement.tier),
          isTrue,
          reason: 'Achievement ${achievement.id} has invalid tier',
        );
      }
    });

    test('explorer category has 7 achievements', () {
      final achievements = FlagsAchievements.all(appL10n);
      final explorer = achievements
          .where((a) => a.category == FlagsAchievements.categoryExplorer)
          .toList();
      expect(explorer.length, equals(7));
    });

    test('region mastery category has 6 achievements', () {
      final achievements = FlagsAchievements.all(appL10n);
      final mastery = achievements
          .where((a) => a.category == FlagsAchievements.categoryRegionMastery)
          .toList();
      expect(mastery.length, equals(6));
    });

    test('collection category has 1 achievement', () {
      final achievements = FlagsAchievements.all(appL10n);
      final collection = achievements
          .where((a) => a.category == FlagsAchievements.categoryCollection)
          .toList();
      expect(collection.length, equals(1));
    });

    test('individual achievements have correct IDs', () {
      expect(FlagsAchievements.exploreAfrica(appL10n).id, equals('explore_africa'));
      expect(FlagsAchievements.exploreAsia(appL10n).id, equals('explore_asia'));
      expect(FlagsAchievements.exploreEurope(appL10n).id, equals('explore_europe'));
      expect(FlagsAchievements.exploreNorthAmerica(appL10n).id,
          equals('explore_north_america'));
      expect(FlagsAchievements.exploreSouthAmerica(appL10n).id,
          equals('explore_south_america'));
      expect(FlagsAchievements.exploreOceania(appL10n).id, equals('explore_oceania'));
      expect(FlagsAchievements.worldTraveler(appL10n).id, equals('world_traveler'));
      expect(FlagsAchievements.masterEurope(appL10n).id, equals('master_europe'));
      expect(FlagsAchievements.masterAsia(appL10n).id, equals('master_asia'));
      expect(FlagsAchievements.masterAfrica(appL10n).id, equals('master_africa'));
      expect(FlagsAchievements.masterAmericas(appL10n).id, equals('master_americas'));
      expect(FlagsAchievements.masterOceania(appL10n).id, equals('master_oceania'));
      expect(FlagsAchievements.masterWorld(appL10n).id, equals('master_world'));
      expect(FlagsAchievements.flagCollector(appL10n).id, equals('flag_collector'));
    });

    test('tier distribution is correct', () {
      final achievements = FlagsAchievements.all(appL10n);
      final tierCounts = <AchievementTier, int>{};

      for (final achievement in achievements) {
        tierCounts[achievement.tier] =
            (tierCounts[achievement.tier] ?? 0) + 1;
      }

      // 6 common (explore_*), 7 rare (mastery_*), 1 legendary (flag_collector)
      // Plus world_traveler is rare
      expect(tierCounts[AchievementTier.common], equals(6));
      expect(tierCounts[AchievementTier.rare], equals(6));
      expect(tierCounts[AchievementTier.epic], equals(1));
      expect(tierCounts[AchievementTier.legendary], equals(1));
    });

    test('allWithBase() returns 67 achievements', () {
      final achievements = FlagsAchievements.allWithBase(quizL10n, appL10n);
      expect(achievements.length, equals(FlagsAchievements.totalCount));
      expect(achievements.length, equals(67));
    });

    test('allWithBase() includes both base and flags achievements', () {
      final achievements = FlagsAchievements.allWithBase(quizL10n, appL10n);
      final ids = achievements.map((a) => a.id).toSet();

      // Check some base achievements are included
      expect(ids.contains('first_quiz'), isTrue);
      expect(ids.contains('streak_10'), isTrue);

      // Check flags achievements are included
      expect(ids.contains('explore_africa'), isTrue);
      expect(ids.contains('flag_collector'), isTrue);
    });

    test('totalCount equals base count plus flags count', () {
      expect(
        FlagsAchievements.totalCount,
        equals(BaseAchievements.count + FlagsAchievements.count),
      );
    });
  });

  group('Explorer achievements', () {
    test('all explorer achievements are common tier', () {
      final explorers = [
        FlagsAchievements.exploreAfrica(appL10n),
        FlagsAchievements.exploreAsia(appL10n),
        FlagsAchievements.exploreEurope(appL10n),
        FlagsAchievements.exploreNorthAmerica(appL10n),
        FlagsAchievements.exploreSouthAmerica(appL10n),
        FlagsAchievements.exploreOceania(appL10n),
      ];

      for (final achievement in explorers) {
        expect(achievement.tier, equals(AchievementTier.common));
      }
    });

    test('world traveler is rare tier', () {
      expect(
        FlagsAchievements.worldTraveler(appL10n).tier,
        equals(AchievementTier.rare),
      );
    });

    test('explorer achievements have correct category IDs', () {
      expect(FlagsAchievements.exploreAfrica(appL10n).trigger,
          isA<CategoryTrigger>());
      final trigger =
          FlagsAchievements.exploreAfrica(appL10n).trigger as CategoryTrigger;
      expect(trigger.categoryId, equals('af'));
    });
  });

  group('Region Mastery achievements', () {
    test('all region mastery achievements are rare tier', () {
      final masters = [
        FlagsAchievements.masterEurope(appL10n),
        FlagsAchievements.masterAsia(appL10n),
        FlagsAchievements.masterAfrica(appL10n),
        FlagsAchievements.masterAmericas(appL10n),
        FlagsAchievements.masterOceania(appL10n),
      ];

      for (final achievement in masters) {
        expect(achievement.tier, equals(AchievementTier.rare));
      }
    });

    test('master world is epic tier', () {
      expect(
        FlagsAchievements.masterWorld(appL10n).tier,
        equals(AchievementTier.epic),
      );
    });

    test('mastery achievements require 5 perfect scores', () {
      final trigger =
          FlagsAchievements.masterEurope(appL10n).trigger as CategoryTrigger;
      expect(trigger.requirePerfect, isTrue);
      expect(trigger.requiredCount, equals(5));
    });
  });

  group('Collection achievements', () {
    test('flag collector is legendary tier', () {
      expect(
        FlagsAchievements.flagCollector(appL10n).tier,
        equals(AchievementTier.legendary),
      );
    });

    test('flag collector has custom trigger', () {
      expect(
        FlagsAchievements.flagCollector(appL10n).trigger,
        isA<CustomTrigger>(),
      );
    });
  });
}
