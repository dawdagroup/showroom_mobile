import 'dart:async';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:flutter/material.dart';

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  HoneywellScanner? _honeywellScanner;
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _currentScreen;
  
  // Stream controller for broadcasting scan results
  final StreamController<ScannedData> _scanController = StreamController<ScannedData>.broadcast();
  Stream<ScannedData> get scanStream => _scanController.stream;

  // Current callback functions for different screens
  Function(ScannedData?)? _currentOnScan;
  Function(Exception)? _currentOnError;

  bool get isInitialized => _isInitialized;
  bool get isScanning => _isScanning;
  String? get currentScreen => _currentScreen;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _honeywellScanner = HoneywellScanner();
      
      // Check if device is supported
      bool isSupported = await _honeywellScanner!.isSupported();
      if (!isSupported) {
        debugPrint('Honeywell scanner not supported on this device');
        return false;
      }

      // Set up scanner properties
      _updateScanProperties();
      
      // Set up callbacks
      _honeywellScanner!.onScannerDecodeCallback = _onScanned;
      _honeywellScanner!.onScannerErrorCallback = _onError;
      
      _isInitialized = true;
      debugPrint('Scanner service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize scanner service: $e');
      return false;
    }
  }

  void _updateScanProperties() {
    if (_honeywellScanner == null) return;
    
    List<CodeFormat> codeFormats = [];
    codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);
    
    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    
    _honeywellScanner!.setProperties(properties);
  }

  Future<bool> startScanner(String screenName, {
    Function(ScannedData?)? onScan,
    Function(Exception)? onError,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    try {
      // Stop scanner if it's already running for a different screen
      if (_isScanning && _currentScreen != screenName) {
        await _stopScannerInternal();
      }

      _currentScreen = screenName;
      _currentOnScan = onScan;
      _currentOnError = onError;

      if (!_isScanning) {
        await _honeywellScanner!.startScanner();
        _isScanning = true;
        debugPrint('Scanner started for screen: $screenName');
      } else {
        debugPrint('Scanner already running, switched to screen: $screenName');
      }
      
      return true;
    } catch (e) {
      debugPrint('Failed to start scanner for $screenName: $e');
      // Try to recover by reinitializing
      _isInitialized = false;
      _isScanning = false;
      return false;
    }
  }

  Future<void> stopScanner(String screenName) async {
    if (_currentScreen == screenName) {
      await _stopScannerInternal();
      _currentScreen = null;
      _currentOnScan = null;
      _currentOnError = null;
      debugPrint('Scanner stopped for screen: $screenName');
    }
  }

  Future<void> _stopScannerInternal() async {
    if (_honeywellScanner != null && _isScanning) {
      try {
        await _honeywellScanner!.stopScanner();
        _isScanning = false;
        debugPrint('Scanner stopped internally');
      } catch (e) {
        debugPrint('Error stopping scanner: $e');
      }
    }
  }

  void _onScanned(ScannedData? scannedData) {
    if (scannedData != null) {
      debugPrint('Scanner service received scan: ${scannedData.code} for screen: $_currentScreen');
      
      try {
        // Broadcast to stream
        if (!_scanController.isClosed) {
          _scanController.add(scannedData);
        }
        
        // Call current screen's callback
        if (_currentOnScan != null) {
          _currentOnScan!(scannedData);
        }
      } catch (e) {
        debugPrint('Error processing scan result: $e');
        _onError(Exception('Error processing scan: $e'));
      }
    }
  }

  void _onError(Exception error) {
    debugPrint('Scanner service error: $error');
    
    try {
      if (_currentOnError != null) {
        _currentOnError!(error);
      }
    } catch (e) {
      debugPrint('Error in error callback: $e');
    }
  }

  Future<void> pauseScanner() async {
    if (_isScanning) {
      await _stopScannerInternal();
      debugPrint('Scanner paused');
    }
  }

  Future<void> resumeScanner() async {
    if (_isInitialized && !_isScanning && _currentScreen != null) {
      try {
        await _honeywellScanner!.startScanner();
        _isScanning = true;
        debugPrint('Scanner resumed for screen: $_currentScreen');
      } catch (e) {
        debugPrint('Failed to resume scanner: $e');
      }
    }
  }

  void dispose() {
    _stopScannerInternal();
    _scanController.close();
    _isInitialized = false;
    _currentScreen = null;
    _currentOnScan = null;
    _currentOnError = null;
    debugPrint('Scanner service disposed');
  }
}
