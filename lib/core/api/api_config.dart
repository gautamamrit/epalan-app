/// API Configuration
///
/// The base URL is set at build time via --dart-define=FLAVOR.
class ApiConfig {
  ApiConfig._();

  static const String _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static const String baseUrl = _flavor == 'tst'
      ? 'https://test.api.epalan.com/api/v1'
      : _flavor == 'prod'
          ? 'https://api.epalan.com/api/v1'
          : 'http://10.0.2.2:2000/api/v1';

  // Farmer portal URL (for QR codes, deep links)
  static const String farmerPortalUrl = _flavor == 'tst'
      ? 'https://test.farmer.epalan.com'
      : _flavor == 'prod'
          ? 'https://farmer.epalan.com'
          : 'http://localhost:2001';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
}
