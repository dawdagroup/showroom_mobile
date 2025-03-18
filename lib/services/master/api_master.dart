import 'dart:io';
import 'package:http/http.dart' as http;

import '../../config/config.dart';


class ApiMaster {
  final client = http.Client();

  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };

  /// Helper method to build URIs dynamically.
  Uri buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    // Build the full path by combining the namespace and endpoint.
    final path = '${Config.serverNameSpace}$endpoint';
    return Uri(
      scheme: Config.scheme,
      host: Config.host,
      port: Config.port, // Will be null in production, which is fine.
      path: path,
      queryParameters: queryParameters,
    );
  }
}
