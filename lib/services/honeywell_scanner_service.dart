import 'dart:async';
import 'package:flutter/material.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

/// Enhanced Honeywell Scanner Service with proper lifecycle management
/// Provides a clean Stream<String> API for barcode scanning
class HoneywellScannerService {
  static final HoneywellScannerService _instance = HoneywellScannerService._internal();
  factory HoneywellScannerService() => _instance;
  HoneywellScannerService._internal();

  HoneywellScanner? _scanner;
  bool _isInitialized = false;
  bool _isActive = false;
  String? _currentContext;

  // Stream for broadcasting scan results
  final StreamController<String> _scanController = StreamController<String>.broadcast();
  final StreamController<Exception> _errorController = StreamController<Exception>.broadcast();

  /// Stream of scanned barcode strings
  Stream<String> get scanStream => _scanController.stream;
  
  /// Stream of scanner errors
  Stream<Exception> get errorStream => _errorController.stream;

  /// Check if scanner is currently active
  bool get isActive => _isActive;

  /// Get current scanning context
  String? get currentContext => _currentContext;

  /// Initialize the scanner with default properties
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _scanner = HoneywellScanner();
      
      // Check device support
      bool isSupported = await _scanner!.isSupported();
      if (!isSupported) {
        debugPrint('HoneywellScannerService: Device not supported');
        return false;
      }

      // Configure scanner properties
      _configureScannerProperties();
      
      // Set up callbacks
      _scanner!.onScannerDecodeCallback = _onScanned;
      _scanner!.onScannerErrorCallback = _onError;

      _isInitialized = true;
      debugPrint('HoneywellScannerService: Initialized successfully');
      return true;
    } catch (e) {
      debugPrint('HoneywellScannerService: Initialization failed - $e');
      _addError(Exception('Scanner initialization failed: $e'));
      return false;
    }
  }

  /// Configure scanner properties for optimal performance
  void _configureScannerProperties() {
    if (_scanner == null) return;

    try {
      List<CodeFormat> codeFormats = [];
      codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
      codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);

      Map<String, dynamic> properties = {
        ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
        'DEC_CODABAR_START_STOP_TRANSMIT': true,
        'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
        'DEC_CODE39_CHECK_DIGIT_TRANSMIT': false,
        'DEC_CODE128_CHECK_DIGIT_TRANSMIT': false,
        // Additional performance settings
        'DEC_PICKLIST_MODE': 0, // Disabled for better performance
        'DEC_MULTIPLE_DECODE': 0, // Single decode mode
      };

      _scanner!.setProperties(properties);
      debugPrint('HoneywellScannerService: Properties configured');
    } catch (e) {
      debugPrint('HoneywellScannerService: Failed to configure properties - $e');
    }
  }

  /// Start scanning with context identification
  Future<bool> startScan(String context) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    // Stop previous session if different context
    if (_isActive && _currentContext != context) {
      await _stopScanInternal();
    }

    try {
      _currentContext = context;
      
      if (!_isActive) {
        await _scanner!.startScanner();
        _isActive = true;
        debugPrint('HoneywellScannerService: Started scanning for context: $context');
      } else {
        debugPrint('HoneywellScannerService: Already active, switched to context: $context');
      }

      return true;
    } catch (e) {
      debugPrint('HoneywellScannerService: Start scan failed - $e');
      _addError(Exception('Failed to start scanner: $e'));
      
      // Recovery attempt
      _isInitialized = false;
      _isActive = false;
      return false;
    }
  }

  /// Stop scanning for specific context
  Future<void> stopScan(String context) async {
    if (_currentContext == context) {
      await _stopScanInternal();
      _currentContext = null;
      debugPrint('HoneywellScannerService: Stopped scanning for context: $context');
    }
  }

  /// Internal stop implementation
  Future<void> _stopScanInternal() async {
    if (_scanner != null && _isActive) {
      try {
        await _scanner!.stopScanner();
        _isActive = false;
        debugPrint('HoneywellScannerService: Scanner stopped internally');
      } catch (e) {
        debugPrint('HoneywellScannerService: Stop scanner error - $e');
      }
    }
  }

  /// Pause scanning (for app lifecycle changes)
  Future<void> pauseScanning() async {
    if (_isActive) {
      await _stopScanInternal();
      debugPrint('HoneywellScannerService: Scanner paused');
    }
  }

  /// Resume scanning (for app lifecycle changes)
  Future<void> resumeScanning() async {
    if (_isInitialized && !_isActive && _currentContext != null) {
      try {
        await _scanner!.startScanner();
        _isActive = true;
        debugPrint('HoneywellScannerService: Scanner resumed for context: $_currentContext');
      } catch (e) {
        debugPrint('HoneywellScannerService: Resume failed - $e');
        _addError(Exception('Failed to resume scanner: $e'));
      }
    }
  }

  /// Handle scanned data
  void _onScanned(ScannedData? scannedData) {
    if (scannedData?.code != null) {
      String barcode = scannedData!.code!.trim();
      
      // Basic validation
      if (barcode.isNotEmpty && _isValidBarcode(barcode)) {
        debugPrint('HoneywellScannerService: Valid scan received - $barcode (context: $_currentContext)');
        
        if (!_scanController.isClosed) {
          _scanController.add(barcode);
        }
      } else {
        debugPrint('HoneywellScannerService: Invalid barcode rejected - $barcode');
        _addError(Exception('Invalid barcode format: $barcode'));
      }
    }
  }

  /// Handle scanner errors
  void _onError(Exception error) {
    debugPrint('HoneywellScannerService: Scanner error - $error');
    _addError(error);
  }

  /// Add error to stream
  void _addError(Exception error) {
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  /// Basic barcode validation
  bool _isValidBarcode(String barcode) {
    // Reject HTTP/HTTPS URLs that might be accidentally scanned
    if (barcode.toLowerCase().startsWith('http://') || 
        barcode.toLowerCase().startsWith('https://')) {
      return false;
    }

    // Reject very short codes (likely noise)
    if (barcode.length < 3) {
      return false;
    }

    // Reject codes that are only whitespace
    if (barcode.trim().isEmpty) {
      return false;
    }

    return true;
  }

  /// Force restart scanner (useful for recovery)
  Future<void> restartScanner() async {
    String? currentCtx = _currentContext;
    await _stopScanInternal();
    _isInitialized = false;
    
    if (currentCtx != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      await startScan(currentCtx);
    }
  }

  /// Get scanner status information
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isActive': _isActive,
      'currentContext': _currentContext,
      'hasListeners': _scanController.hasListener,
    };
  }

  /// Dispose of the scanner service
  void dispose() {
    debugPrint('HoneywellScannerService: Disposing service');
    _stopScanInternal();
    
    if (!_scanController.isClosed) {
      _scanController.close();
    }
    
    if (!_errorController.isClosed) {
      _errorController.close();
    }

    _isInitialized = false;
    _isActive = false;
    _currentContext = null;
    _scanner = null;
  }
}
