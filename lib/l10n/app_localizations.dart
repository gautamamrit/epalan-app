import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

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
    Locale('en'),
    Locale('ne')
  ];

  /// App name displayed in header
  ///
  /// In en, this message translates to:
  /// **'ePalan'**
  String get appName;

  /// Home screen greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// Market prices subtitle
  ///
  /// In en, this message translates to:
  /// **'Latest livestock prices in your area'**
  String get welcomeSubtitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Animals tab label
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// Prices tab label
  ///
  /// In en, this message translates to:
  /// **'Prices'**
  String get prices;

  /// More tab label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Market prices screen title
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// Quick actions card title
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// Add animal quick action label
  ///
  /// In en, this message translates to:
  /// **'Add\nAnimal'**
  String get addAnimal;

  /// Daily record quick action label
  ///
  /// In en, this message translates to:
  /// **'Daily\nRecord'**
  String get dailyRecord;

  /// Scan QR quick action label
  ///
  /// In en, this message translates to:
  /// **'Scan\nQR'**
  String get scanQr;

  /// Farm selector placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Farm'**
  String get selectFarm;

  /// Province selector placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// Item filter default text
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// Item filter selection text
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String itemsSelected(int count);

  /// Item filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter Items'**
  String get filterItems;

  /// Clear all filters button
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// Due today section title
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get dueToday;

  /// Overdue section title
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No overdue tasks message
  ///
  /// In en, this message translates to:
  /// **'No overdue tasks'**
  String get noOverdueTasks;

  /// All tasks done title
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No tasks due subtitle
  ///
  /// In en, this message translates to:
  /// **'No health tasks due today'**
  String get noHealthTasksDueToday;

  /// No farm selected message
  ///
  /// In en, this message translates to:
  /// **'Select a farm to see overview'**
  String get selectFarmToSeeOverview;

  /// Active filter tab
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Past filter tab
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Empty state title for active animals
  ///
  /// In en, this message translates to:
  /// **'No active animals'**
  String get noActiveAnimals;

  /// Empty state subtitle for active animals
  ///
  /// In en, this message translates to:
  /// **'Add animals to begin tracking'**
  String get addAnimalsToBeginTracking;

  /// Empty state title for past animals
  ///
  /// In en, this message translates to:
  /// **'No past animals'**
  String get noPastAnimals;

  /// Empty state subtitle for past animals
  ///
  /// In en, this message translates to:
  /// **'Past animals will appear here'**
  String get pastAnimalsWillAppearHere;

  /// Daily records section title
  ///
  /// In en, this message translates to:
  /// **'Daily Records'**
  String get dailyRecords;

  /// Vaccinations section title
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinations;

  /// Medications section title
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// Record count
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String nRecords(int count);

  /// Empty records message
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecordsYet;

  /// Empty records subtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first daily record'**
  String get addYourFirstDailyRecord;

  /// Pending count
  ///
  /// In en, this message translates to:
  /// **'{pending} pending of {total}'**
  String nPendingOfTotal(int pending, int total);

  /// Empty vaccinations message
  ///
  /// In en, this message translates to:
  /// **'No vaccinations scheduled'**
  String get noVaccinationsScheduled;

  /// Empty medications message
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled'**
  String get noMedicationsScheduled;

  /// Edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// End tracking action label
  ///
  /// In en, this message translates to:
  /// **'End\nTracking'**
  String get endTracking;

  /// QR code action label
  ///
  /// In en, this message translates to:
  /// **'QR\nCode'**
  String get qrCode;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Mark complete button label
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// Completed section header
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completed;

  /// Pending section header
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// Updated time ago text
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updated(String time);

  /// Price source text
  ///
  /// In en, this message translates to:
  /// **'Source: {name}'**
  String source(String name);

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No prices title
  ///
  /// In en, this message translates to:
  /// **'No price data available'**
  String get noPriceDataAvailable;

  /// No prices subtitle
  ///
  /// In en, this message translates to:
  /// **'Prices will appear here once available'**
  String get pricesWillAppearHere;

  /// Price load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load prices'**
  String get failedToLoadPrices;

  /// Show chart trend button
  ///
  /// In en, this message translates to:
  /// **'Show trend'**
  String get showTrend;

  /// Hide chart trend button
  ///
  /// In en, this message translates to:
  /// **'Hide trend'**
  String get hideTrend;

  /// Latest prices section title
  ///
  /// In en, this message translates to:
  /// **'Latest Prices'**
  String get latestPrices;

  /// Manage farms menu item
  ///
  /// In en, this message translates to:
  /// **'Manage Farms'**
  String get manageFarms;

  /// Team menu item
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// Help menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// View profile button
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// App version text
  ///
  /// In en, this message translates to:
  /// **'Version {number}'**
  String version(String number);

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No farm selected error
  ///
  /// In en, this message translates to:
  /// **'Please select a farm first'**
  String get pleaseSelectFarmFirst;

  /// No animals for record error
  ///
  /// In en, this message translates to:
  /// **'No active animals to record for'**
  String get noActiveAnimalsToRecord;

  /// Animal picker title
  ///
  /// In en, this message translates to:
  /// **'Select Animal'**
  String get selectAnimal;

  /// Active animal count
  ///
  /// In en, this message translates to:
  /// **'{count} active {count, plural, =1{animal} other{animals}}'**
  String nActiveAnimals(int count);

  /// Alive stat label
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get alive;

  /// Mortality stat label
  ///
  /// In en, this message translates to:
  /// **'Mortality'**
  String get mortality;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Nepali language option
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get nepali;

  /// Province label
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// Items label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Onboarding slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nePalan!'**
  String get welcomeToEpalan;

  /// Onboarding slide 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Farmer\'s Companion, Always\nकिसानको साथी, हरपल'**
  String get farmersCompanion;

  /// Brand slogan below ePalan name
  ///
  /// In en, this message translates to:
  /// **'Farmer\'s Companion, Always'**
  String get slogan;

  /// Onboarding slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Manage All\nYour Farms'**
  String get smartFarmManagement;

  /// Onboarding slide 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Multiple farms, team members, and all\nlivestock types in one place.'**
  String get smartFarmManagementDesc;

  /// Onboarding slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Track Every\nAnimal'**
  String get trackYourAnimals;

  /// Onboarding slide 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Log mortality, weight, feed, and eggs\n— see performance at a glance.'**
  String get trackYourAnimalsDesc;

  /// Onboarding slide 4 title
  ///
  /// In en, this message translates to:
  /// **'Stay On Top\nof Health'**
  String get healthManagement;

  /// Onboarding slide 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Recommended schedules for vaccinations\nand medications — reminders included.'**
  String get healthManagementDesc;

  /// Onboarding slide 5 title
  ///
  /// In en, this message translates to:
  /// **'Live Market\nPrices'**
  String get liveMarketPrices;

  /// Onboarding slide 5 subtitle
  ///
  /// In en, this message translates to:
  /// **'Check today\'s livestock prices by\nprovince before you buy or sell.'**
  String get liveMarketPricesDesc;

  /// Log in button
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// Create account link
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// Login subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to continue'**
  String get enterCredentials;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email *'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get password;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Sign up link
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Create account button/title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Register subtitle
  ///
  /// In en, this message translates to:
  /// **'Join ePalan to manage your farm'**
  String get joinEpalan;

  /// Name section header
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// First name field
  ///
  /// In en, this message translates to:
  /// **'First Name *'**
  String get firstName;

  /// Middle name field
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleName;

  /// Last name field
  ///
  /// In en, this message translates to:
  /// **'Last Name *'**
  String get lastName;

  /// Confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password *'**
  String get confirmPassword;

  /// Required field error
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Email format error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// Password length error
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// Confirm password error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Registration error
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// Forgot password description
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset code'**
  String get forgotPasswordDesc;

  /// Send reset code button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// Email validation
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
