import 'package:flutter/foundation.dart';

class Config {
  /// Determine if the app is running in production mode.
  /// You can also use a custom dart-define flag if needed.
  static bool get isProduction => kReleaseMode;
  // static bool get isProduction => true; // Set to true for production, false for development

  static const String releaseRegion = "KENYA"; // Change to "UGANDA" for Uganda release

  /// The scheme for your requests.
  static String get scheme => isProduction ? 'https' : 'http';

  /// The host (domain or IP) for your backend.
  // static String get host => isProduction ? 'backend-api.azone.co.ke' : '192.168.1.15';

  // static String get host => isProduction ? 'beta.azone.co.ke' : '192.168.1.15';

  static String get host => isProduction ? releaseRegion == "UGANDA" ? 'ug.azone.co.ke' : 'backend-api.azone.co.ke' : '192.168.1.15';

  static double get defaultVatRate => releaseRegion == "UGANDA" ? 0.18 : 0.16;

  static String get defaultCurrency => releaseRegion == "UGANDA" ? 'UGX' : 'KES';

  static String get taxPinName => releaseRegion == "UGANDA" ? 'TIN' : 'KRA PIN';

  static String get taxPinValue => releaseRegion == "UGANDA" ? '1013079012' : 'P051633009W';

  static String get regionPhonePrefix => releaseRegion == "UGANDA" ? '+256' : '+254';

  static String get regionTelephone => releaseRegion == "UGANDA" ? '+256 754 121121' : '0800 722242';

  static String get regionEmail => releaseRegion == "UGANDA" ? 'info@azone.co.ug' : 'info@azone.co.ke';

  static String get regionPoBox => releaseRegion == "UGANDA" ? 'P.O.BOX 30961, KAMPALA, UGANDA' : 'P.O.BOX 82580-80100 Mombasa Kenya';

  static String get regionName => releaseRegion == "UGANDA" ? 'APPLIANCE ZONE UGANDA LIMITED' : 'APPLIANCE ZONE LIMITED';

  /// The port number for development (null in production).
  static int? get port => isProduction ? null : 8000;

  /// The common server namespace (if any).
  static String get serverNameSpace => '/api/v1';

  /// Sentry DSN for error tracking.
  static String get sentryDsn => isProduction ? 'https://f99eeb58caccbfd48752abd8ac80cf70@o4508935326597120.ingest.de.sentry.io/4508935331840080' : 'https://14336f257be4a9fb0aee342196d87efa@o4508935326597120.ingest.de.sentry.io/4508958356865104';

  /// Get the current environment.
  static String get environment => isProduction ? 'production' : 'development';
}
