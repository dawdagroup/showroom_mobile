import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:package_info_plus/package_info_plus.dart';

import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiryDate;
  String? _userEmail;
  String? _userFirstName;
  String? _userLastName;
  String? _userPhoneNumber;
  String? _userStatus;
  String? _userId;

  Future<String?> get token async {
    try {
      // Retrieve the token expiry date from storage
      String? expiryDate = await getTokenExpiryDate();
      
      // Check if the expiry date is available and valid
      if (expiryDate != null) {
        final expiry = DateTime.parse(expiryDate);
        print("expiry date: $expiry");
        print("current date: ${DateTime.now()}");

        // If the token is still valid, return it
        if (expiry.isAfter(DateTime.now())) {
          return await getToken();
        } else {
          print("Token expired");
          print("expiry date: $expiry");
          print("current date: ${DateTime.now()}");
        }
      }
    } catch (e) {
      // Handle any errors that occur during token retrieval
      print('Error retrieving token: $e');
    }
    
    // Return null if the token is expired or an error occurred
    return null;
  }

  Future<bool> get isAuthenticated async {
    return await token != null;
  }

  FlutterSecureStorage get storage => _storage;

  Future<void> login(String username, String password) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final response = await _apiService.login(username, password, info.version);

    print(response);

    if (response["status"] == "success") {
      _expiryDate = DateTime.now().add(Duration(seconds: response['expiresIn']));
      print(_expiryDate);
      _accessToken = response['accessToken'];
      _refreshToken = response['refreshToken'];
      _userEmail = response['data']["email"];
      _userFirstName = response['data']["first_name"];
      _userLastName = response['data']["last_name"];
      _userPhoneNumber = response['data']["phone_number"];
      _userStatus = response['data']["status"];
      _userId = response['data']["_id"].toString();

      
      deleteToken();

      await Future.wait([
        _storage.write(key: 'accessToken', value: _accessToken),
        _storage.write(key: 'expiryDate', value: _expiryDate!.toIso8601String()),
        _storage.write(key: 'refreshToken', value: _refreshToken),
        _storage.write(key: 'userEmail', value: _userEmail),
        _storage.write(key: 'userFirstName', value: _userFirstName),
        _storage.write(key: 'userLastName', value: _userLastName),
        _storage.write(key: 'userPhoneNumber', value: _userPhoneNumber),
        _storage.write(key: 'userStatus', value: _userStatus),
        _storage.write(key: 'userId', value: _userId),
      ]);
    } else {
      throw Exception(response["message"]);
    }

    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    await deleteToken();

    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> deleteToken() async {
    try {
      
      await Future.wait([
        _storage.delete(key: 'accessToken'),
        _storage.delete(key: 'expiryDate'),
        _storage.delete(key: 'refreshToken'),
        _storage.delete(key: 'userEmail'),
        _storage.delete(key: 'userFirstName'),
        _storage.delete(key: 'userLastName'),
        _storage.delete(key: 'userPhoneNumber'),
        _storage.delete(key: 'userStatus'),
        _storage.delete(key: 'userId'),
      ]);
      
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getTokenExpiryDate() async {
    return await _storage.read(key: 'expiryDate');
  }

  Future<void> logout() async {
    _accessToken = null;
    _expiryDate = null;
    await Future.wait([
      _storage.delete(key: 'accessToken'),
      _storage.delete(key: 'expiryDate'),
    ]);
    notifyListeners();
  }

  Future<void> refreshToken() async {
    final url = Uri.parse('https://your-api-url.com/refresh');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    );

    final responseData = json.decode(response.body);
    _accessToken = responseData['accessToken'];
    _expiryDate = DateTime.now().add(Duration(seconds: responseData['expiresIn']));

    await Future.wait([
      _storage.write(key: 'accessToken', value: _accessToken),
      _storage.write(key: 'expiryDate', value: _expiryDate!.toIso8601String()),
    ]);

    notifyListeners();
  }
}
