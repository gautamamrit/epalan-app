// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'ePalan';

  @override
  String welcome(String name) {
    return 'स्वागतम्, $name!';
  }

  @override
  String get welcomeSubtitle => 'तपाईंको क्षेत्रको पछिल्लो पशुधन मूल्यहरू';

  @override
  String get home => 'गृह';

  @override
  String get animals => 'पशुहरू';

  @override
  String get prices => 'मूल्य';

  @override
  String get more => 'थप';

  @override
  String get marketPrices => 'बजार मूल्य';

  @override
  String get quickActions => 'छिटो कार्यहरू';

  @override
  String get addAnimal => 'पशु\nथप्नुहोस्';

  @override
  String get dailyRecord => 'दैनिक\nरेकर्ड';

  @override
  String get scanQr => 'QR\nस्क्यान';

  @override
  String get selectFarm => 'फार्म छान्नुहोस्';

  @override
  String get selectProvince => 'प्रदेश छान्नुहोस्';

  @override
  String get allItems => 'सबै वस्तुहरू';

  @override
  String itemsSelected(int count) {
    return '$count वस्तु छानिएको';
  }

  @override
  String get filterItems => 'वस्तु फिल्टर';

  @override
  String get clearAll => 'सबै हटाउनुहोस्';

  @override
  String get dueToday => 'आज बाँकी';

  @override
  String get overdue => 'म्याद सकिएको';

  @override
  String get noOverdueTasks => 'कुनै म्याद सकिएको कार्य छैन';

  @override
  String get allCaughtUp => 'सबै सकियो!';

  @override
  String get noHealthTasksDueToday => 'आज कुनै स्वास्थ्य कार्य बाँकी छैन';

  @override
  String get selectFarmToSeeOverview => 'अवलोकन हेर्न फार्म छान्नुहोस्';

  @override
  String get active => 'सक्रिय';

  @override
  String get past => 'विगत';

  @override
  String get noActiveAnimals => 'कुनै सक्रिय पशु छैन';

  @override
  String get addAnimalsToBeginTracking => 'ट्र्याकिङ सुरु गर्न पशु थप्नुहोस्';

  @override
  String get noPastAnimals => 'कुनै विगतका पशु छैनन्';

  @override
  String get pastAnimalsWillAppearHere => 'विगतका पशुहरू यहाँ देखिनेछन्';

  @override
  String get dailyRecords => 'दैनिक रेकर्डहरू';

  @override
  String get vaccinations => 'खोपहरू';

  @override
  String get medications => 'औषधिहरू';

  @override
  String nRecords(int count) {
    return '$count रेकर्डहरू';
  }

  @override
  String get noRecordsYet => 'अहिलेसम्म कुनै रेकर्ड छैन';

  @override
  String get addYourFirstDailyRecord => 'तपाईंको पहिलो दैनिक रेकर्ड थप्नुहोस्';

  @override
  String nPendingOfTotal(int pending, int total) {
    return '$total मध्ये $pending बाँकी';
  }

  @override
  String get noVaccinationsScheduled => 'कुनै खोप तालिकाबद्ध छैन';

  @override
  String get noMedicationsScheduled => 'कुनै औषधि तालिकाबद्ध छैन';

  @override
  String get edit => 'सम्पादन';

  @override
  String get delete => 'मेट्नुहोस्';

  @override
  String get endTracking => 'ट्र्याकिङ\nअन्त्य';

  @override
  String get qrCode => 'QR\nकोड';

  @override
  String get add => 'थप्नुहोस्';

  @override
  String get save => 'सुरक्षित गर्नुहोस्';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get markComplete => 'पूरा भएको चिन्ह लगाउनुहोस्';

  @override
  String get completed => 'पूरा भएको';

  @override
  String get pending => 'बाँकी';

  @override
  String updated(String time) {
    return '$time अपडेट गरिएको';
  }

  @override
  String source(String name) {
    return 'स्रोत: $name';
  }

  @override
  String get noDataAvailable => 'कुनै डाटा उपलब्ध छैन';

  @override
  String get noPriceDataAvailable => 'कुनै मूल्य डाटा उपलब्ध छैन';

  @override
  String get pricesWillAppearHere => 'मूल्यहरू उपलब्ध भएपछि यहाँ देखिनेछन्';

  @override
  String get failedToLoadPrices => 'मूल्यहरू लोड गर्न असफल';

  @override
  String get showTrend => 'प्रवृत्ति देखाउनुहोस्';

  @override
  String get hideTrend => 'प्रवृत्ति लुकाउनुहोस्';

  @override
  String get latestPrices => 'पछिल्लो मूल्यहरू';

  @override
  String get manageFarms => 'फार्महरू व्यवस्थापन';

  @override
  String get team => 'टोली';

  @override
  String get helpAndSupport => 'मद्दत र सहयोग';

  @override
  String get logout => 'लग आउट';

  @override
  String get logoutConfirmation => 'के तपाईं लग आउट गर्न निश्चित हुनुहुन्छ?';

  @override
  String get viewProfile => 'प्रोफाइल हेर्नुहोस्';

  @override
  String version(String number) {
    return 'संस्करण $number';
  }

  @override
  String get guestUser => 'अतिथि प्रयोगकर्ता';

  @override
  String get pleaseSelectFarmFirst => 'कृपया पहिले फार्म छान्नुहोस्';

  @override
  String get noActiveAnimalsToRecord => 'रेकर्ड गर्न कुनै सक्रिय पशु छैन';

  @override
  String get selectAnimal => 'पशु छान्नुहोस्';

  @override
  String nActiveAnimals(int count) {
    return '$count सक्रिय पशु';
  }

  @override
  String get alive => 'जीवित';

  @override
  String get mortality => 'मृत्युदर';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get province => 'प्रदेश';

  @override
  String get items => 'वस्तुहरू';

  @override
  String get welcomeToEpalan => 'ePalan मा\nस्वागत छ!';

  @override
  String get farmersCompanion =>
      'किसानको साथी, हरपल\nFarmer\'s Companion, Always';

  @override
  String get slogan => 'किसानको साथी, हरपल';

  @override
  String get smartFarmManagement => 'स्मार्ट फार्म\nव्यवस्थापन';

  @override
  String get smartFarmManagementDesc =>
      'आधुनिक पशुपालन किसानहरूको लागि\nस्मार्ट फार्म व्यवस्थापन।';

  @override
  String get trackYourAnimals => 'तपाईंका पशुहरू\nट्र्याक गर्नुहोस्';

  @override
  String get trackYourAnimalsDesc =>
      'तपाईंका सबै पशुधनको स्वास्थ्य, वृद्धि\nर प्रदर्शन अनुगमन गर्नुहोस्।';

  @override
  String get healthManagement => 'स्वास्थ्य\nव्यवस्थापन';

  @override
  String get healthManagementDesc =>
      'स्मार्ट रिमाइन्डरहरूको साथ खोप वा\nऔषधि कहिल्यै नछुटाउनुहोस्।';

  @override
  String get insightsAnalytics => 'अन्तर्दृष्टि र\nविश्लेषण';

  @override
  String get insightsAnalyticsDesc =>
      'विस्तृत रिपोर्ट र चार्टहरूको साथ\nडाटामा आधारित निर्णयहरू लिनुहोस्।';

  @override
  String get logIn => 'लग इन';

  @override
  String get createNewAccount => 'नयाँ खाता बनाउनुहोस्';

  @override
  String get enterCredentials =>
      'जारी राख्न आफ्नो प्रमाणहरू प्रविष्ट गर्नुहोस्';

  @override
  String get email => 'इमेल *';

  @override
  String get password => 'पासवर्ड *';

  @override
  String get forgotPassword => 'पासवर्ड बिर्सनुभयो?';

  @override
  String get dontHaveAccount => 'खाता छैन? ';

  @override
  String get signUp => 'साइन अप';

  @override
  String get createAccount => 'खाता बनाउनुहोस्';

  @override
  String get joinEpalan =>
      'तपाईंको फार्म व्यवस्थापन गर्न ePalan मा सामेल हुनुहोस्';

  @override
  String get name => 'नाम';

  @override
  String get firstName => 'पहिलो नाम *';

  @override
  String get middleName => 'बीचको नाम';

  @override
  String get lastName => 'थर *';

  @override
  String get confirmPassword => 'पासवर्ड पुष्टि गर्नुहोस् *';

  @override
  String get required => 'आवश्यक';

  @override
  String get pleaseEnterEmail => 'कृपया आफ्नो इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get pleaseEnterValidEmail => 'कृपया मान्य इमेल प्रविष्ट गर्नुहोस्';

  @override
  String get pleaseEnterPassword => 'कृपया पासवर्ड प्रविष्ट गर्नुहोस्';

  @override
  String get atLeast6Characters => 'कम्तिमा ६ अक्षर';

  @override
  String get pleaseConfirmPassword => 'कृपया पासवर्ड पुष्टि गर्नुहोस्';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मिलेन';

  @override
  String get alreadyHaveAccount => 'पहिले नै खाता छ? ';

  @override
  String get registrationFailed => 'दर्ता असफल भयो';

  @override
  String get forgotPasswordTitle => 'पासवर्ड बिर्सनुभयो';

  @override
  String get forgotPasswordDesc =>
      'आफ्नो इमेल प्रविष्ट गर्नुहोस् र हामी तपाईंलाई रिसेट कोड पठाउनेछौं';

  @override
  String get sendResetCode => 'रिसेट कोड पठाउनुहोस्';

  @override
  String get enterValidEmail => 'मान्य इमेल प्रविष्ट गर्नुहोस्';
}
