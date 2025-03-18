import 'package:flutter/foundation.dart';

class Config {
  /// Determine if the app is running in production mode.
  /// You can also use a custom dart-define flag if needed.
  static bool get isProduction => kReleaseMode;

  /// The scheme for your requests.
  static String get scheme => isProduction ? 'https' : 'http';

  /// The host (domain or IP) for your backend.
  static String get host => isProduction ? 'backend-api.azone.co.ke' : '192.168.1.15';

  /// The port number for development (null in production).
  static int? get port => isProduction ? null : 8000;

  /// The common server namespace (if any).
  static String get serverNameSpace => '/api/v1';

  /// Sentry DSN for error tracking.
  static String get sentryDsn => isProduction ? 'https://f99eeb58caccbfd48752abd8ac80cf70@o4508935326597120.ingest.de.sentry.io/4508935331840080' : 'https://14336f257be4a9fb0aee342196d87efa@o4508935326597120.ingest.de.sentry.io/4508958356865104';

  /// Get the current environment.
  static String get environment => isProduction ? 'production' : 'development';
}
