// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ePalan';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get welcomeSubtitle => 'Latest livestock prices in your area';

  @override
  String get home => 'Home';

  @override
  String get animals => 'Animals';

  @override
  String get prices => 'Prices';

  @override
  String get more => 'More';

  @override
  String get marketPrices => 'Market Prices';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get addAnimal => 'Add\nAnimal';

  @override
  String get dailyRecord => 'Daily\nRecord';

  @override
  String get scanQr => 'Scan\nQR';

  @override
  String get selectFarm => 'Select Farm';

  @override
  String get selectProvince => 'Select Province';

  @override
  String get allItems => 'All Items';

  @override
  String itemsSelected(int count) {
    return '$count items selected';
  }

  @override
  String get filterItems => 'Filter Items';

  @override
  String get clearAll => 'Clear all';

  @override
  String get dueToday => 'Due today';

  @override
  String get overdue => 'Overdue';

  @override
  String get noOverdueTasks => 'No overdue tasks';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noHealthTasksDueToday => 'No health tasks due today';

  @override
  String get selectFarmToSeeOverview => 'Select a farm to see overview';

  @override
  String get active => 'Active';

  @override
  String get past => 'Past';

  @override
  String get noActiveAnimals => 'No active animals';

  @override
  String get addAnimalsToBeginTracking => 'Add animals to begin tracking';

  @override
  String get noPastAnimals => 'No past animals';

  @override
  String get pastAnimalsWillAppearHere => 'Past animals will appear here';

  @override
  String get dailyRecords => 'Daily Records';

  @override
  String get vaccinations => 'Vaccinations';

  @override
  String get medications => 'Medications';

  @override
  String nRecords(int count) {
    return '$count records';
  }

  @override
  String get noRecordsYet => 'No records yet';

  @override
  String get addYourFirstDailyRecord => 'Add your first daily record';

  @override
  String nPendingOfTotal(int pending, int total) {
    return '$pending pending of $total';
  }

  @override
  String get noVaccinationsScheduled => 'No vaccinations scheduled';

  @override
  String get noMedicationsScheduled => 'No medications scheduled';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get endTracking => 'End\nTracking';

  @override
  String get qrCode => 'QR\nCode';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String get completed => 'COMPLETED';

  @override
  String get pending => 'PENDING';

  @override
  String updated(String time) {
    return 'Updated $time';
  }

  @override
  String source(String name) {
    return 'Source: $name';
  }

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noPriceDataAvailable => 'No price data available';

  @override
  String get pricesWillAppearHere => 'Prices will appear here once available';

  @override
  String get failedToLoadPrices => 'Failed to load prices';

  @override
  String get showTrend => 'Show trend';

  @override
  String get hideTrend => 'Hide trend';

  @override
  String get latestPrices => 'Latest Prices';

  @override
  String get manageFarms => 'Manage Farms';

  @override
  String get team => 'Team';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get viewProfile => 'View Profile';

  @override
  String version(String number) {
    return 'Version $number';
  }

  @override
  String get guestUser => 'Guest User';

  @override
  String get pleaseSelectFarmFirst => 'Please select a farm first';

  @override
  String get noActiveAnimalsToRecord => 'No active animals to record for';

  @override
  String get selectAnimal => 'Select Animal';

  @override
  String nActiveAnimals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'animals',
      one: 'animal',
    );
    return '$count active $_temp0';
  }

  @override
  String get alive => 'Alive';

  @override
  String get mortality => 'Mortality';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get nepali => 'Nepali';

  @override
  String get province => 'Province';

  @override
  String get items => 'Items';

  @override
  String get welcomeToEpalan => 'Welcome to\nePalan!';

  @override
  String get farmersCompanion =>
      'Farmer\'s Companion, Always\nकिसानको साथी, हरपल';

  @override
  String get slogan => 'Farmer\'s Companion, Always';

  @override
  String get smartFarmManagement => 'Smart Farm\nManagement';

  @override
  String get smartFarmManagementDesc =>
      'Smart farm management for modern\nlivestock farmers.';

  @override
  String get trackYourAnimals => 'Track Your\nAnimals';

  @override
  String get trackYourAnimalsDesc =>
      'Monitor health, growth, and performance\nof all your livestock.';

  @override
  String get healthManagement => 'Health\nManagement';

  @override
  String get healthManagementDesc =>
      'Never miss vaccinations or medications\nwith smart reminders.';

  @override
  String get insightsAnalytics => 'Insights &\nAnalytics';

  @override
  String get insightsAnalyticsDesc =>
      'Make data-driven decisions with\ndetailed reports and charts.';

  @override
  String get logIn => 'Log In';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get enterCredentials => 'Enter your credentials to continue';

  @override
  String get email => 'Email *';

  @override
  String get password => 'Password *';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinEpalan => 'Join ePalan to manage your farm';

  @override
  String get name => 'Name';

  @override
  String get firstName => 'First Name *';

  @override
  String get middleName => 'Middle Name';

  @override
  String get lastName => 'Last Name *';

  @override
  String get confirmPassword => 'Confirm Password *';

  @override
  String get required => 'Required';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get atLeast6Characters => 'At least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordDesc =>
      'Enter your email and we\'ll send you a reset code';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get enterValidEmail => 'Enter a valid email';
}
