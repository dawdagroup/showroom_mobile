import 'dart:async';
import 'package:flutter/material.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

/// Enhanced Honeywell Scanner Service specifically for warehouse stock-take operations
/// Provides clean lifecycle management and context-aware scanning
class WarehouseScannerService {
  static final WarehouseScannerService _instance = WarehouseScannerService._internal();
  factory WarehouseScannerService() => _instance;
  WarehouseScannerService._internal();

  HoneywellScanner? _scanner;
  bool _isInitialized = false;
  bool _isScanning = false;
  String? _currentContext;

  // Broadcast streams for multiple listeners
  final StreamController<String> _scanController = StreamController<String>.broadcast();
  final StreamController<Exception> _errorController = StreamController<Exception>.broadcast();

  /// Stream of successfully scanned barcodes
  Stream<String> get scanStream => _scanController.stream;
  
  /// Stream of scanner errors
  Stream<Exception> get errorStream => _errorController.stream;

  /// Check if scanner is currently active
  bool get isScanning => _isScanning;

  /// Get current scanning context for debugging
  String? get currentContext => _currentContext;

  /// Initialize the Honeywell scanner with optimal settings
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _scanner = HoneywellScanner();
      
      // Verify device support
      bool isSupported = await _scanner!.isSupported();
      if (!isSupported) {
        debugPrint('WarehouseScannerService: Device not supported for Honeywell scanning');
        return false;
      }

      // Configure scanner for warehouse use
      await _configureWarehouseSettings();
      
      // Set up scan callbacks
      _scanner!.onScannerDecodeCallback = _handleScannedData;
      _scanner!.onScannerErrorCallback = _handleScannerError;

      _isInitialized = true;
      debugPrint('WarehouseScannerService: Successfully initialized');
      return true;
    } catch (e) {
      debugPrint('WarehouseScannerService: Initialization failed: $e');
      _emitError(Exception('Scanner initialization failed: $e'));
      return false;
    }
  }

  /// Configure scanner properties optimized for warehouse operations
  Future<void> _configureWarehouseSettings() async {
    if (_scanner == null) return;

    try {
      // Enable all common barcode formats for warehouse operations
      List<CodeFormat> warehouseFormats = [
        ...CodeFormatUtils.ALL_1D_FORMATS, // UPC, EAN, Code39, Code128, etc.
        ...CodeFormatUtils.ALL_2D_FORMATS, // QR codes, Data Matrix, etc.
      ];

      Map<String, dynamic> properties = {
        ...CodeFormatUtils.getAsPropertiesComplement(warehouseFormats),
        // Warehouse-specific optimizations
        'DEC_CODABAR_START_STOP_TRANSMIT': true,
        'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
        'DEC_CODE39_CHECK_DIGIT_TRANSMIT': false,
        'DEC_CODE128_CHECK_DIGIT_TRANSMIT': false,
        'DEC_PICKLIST_MODE': 0, // Disable for better performance
        'DEC_MULTIPLE_DECODE': 0, // Single decode for cleaner results
        'DEC_SEARCH_AND_SHIP': 1, // Good for warehouse scanning
      };

      await _scanner!.setProperties(properties);
      debugPrint('WarehouseScannerService: Warehouse-optimized properties configured');
    } catch (e) {
      debugPrint('WarehouseScannerService: Failed to configure properties: $e');
    }
  }

  /// Start scanning with context identification for proper lifecycle management
  Future<bool> startScan(String context) async {
    debugPrint('WarehouseScannerService: Starting scan for context: $context');

    // Initialize if not already done
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    // Handle context switching
    if (_isScanning && _currentContext != context) {
      await _stopScanInternal();
      await Future.delayed(const Duration(milliseconds: 200)); // Brief pause for cleanup
    }

    try {
      _currentContext = context;
      
      if (!_isScanning) {
        await _scanner!.startScanner();
        _isScanning = true;
        debugPrint('WarehouseScannerService: Scanner started for context: $context');
      }

      return true;
    } catch (e) {
      debugPrint('WarehouseScannerService: Failed to start scanning: $e');
      _emitError(Exception('Failed to start scanner: $e'));
      
      // Attempt recovery
      await _attemptRecovery();
      return false;
    }
  }

  /// Stop scanning for specific context (prevents conflicts)
  Future<void> stopScan(String context) async {
    if (_currentContext == context) {
      await _stopScanInternal();
      _currentContext = null;
      debugPrint('WarehouseScannerService: Stopped scanning for context: $context');
    } else {
      debugPrint('WarehouseScannerService: Ignoring stop request for non-matching context: $context (current: $_currentContext)');
    }
  }

  /// Internal stop implementation
  Future<void> _stopScanInternal() async {
    if (_scanner != null && _isScanning) {
      try {
        await _scanner!.stopScanner();
        _isScanning = false;
        debugPrint('WarehouseScannerService: Scanner stopped internally');
      } catch (e) {
        debugPrint('WarehouseScannerService: Error stopping scanner: $e');
      }
    }
  }

  /// Handle app lifecycle changes - pause scanning
  Future<void> pauseForLifecycle() async {
    if (_isScanning) {
      await _stopScanInternal();
      debugPrint('WarehouseScannerService: Paused for app lifecycle');
    }
  }

  /// Handle app lifecycle changes - resume scanning
  Future<void> resumeForLifecycle() async {
    if (_isInitialized && !_isScanning && _currentContext != null) {
      try {
        await _scanner!.startScanner();
        _isScanning = true;
        debugPrint('WarehouseScannerService: Resumed from lifecycle for context: $_currentContext');
      } catch (e) {
        debugPrint('WarehouseScannerService: Failed to resume: $e');
        _emitError(Exception('Failed to resume scanner: $e'));
      }
    }
  }

  /// Handle successful barcode scan
  void _handleScannedData(ScannedData? scannedData) {
    if (scannedData?.code != null && _currentContext != null) {
      String barcode = scannedData!.code!.trim();
      
      if (_isValidWarehouseBarcode(barcode)) {
        debugPrint('WarehouseScannerService: Valid barcode scanned: $barcode (context: $_currentContext)');
        
        if (!_scanController.isClosed) {
          _scanController.add(barcode);
        }
      } else {
        debugPrint('WarehouseScannerService: Invalid barcode rejected: $barcode');
        _emitError(Exception('Invalid barcode format: $barcode'));
      }
    }
  }

  /// Handle scanner errors
  void _handleScannerError(Exception error) {
    debugPrint('WarehouseScannerService: Scanner error: $error');
    _emitError(error);
  }

  /// Emit error to stream if available
  void _emitError(Exception error) {
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  /// Validate barcode for warehouse operations
  bool _isValidWarehouseBarcode(String barcode) {
    // Reject obviously invalid inputs
    if (barcode.length < 4 || barcode.trim().isEmpty) {
      return false;
    }

    // Reject URLs that might be accidentally scanned
    String lowerBarcode = barcode.toLowerCase();
    if (lowerBarcode.startsWith('http://') || lowerBarcode.startsWith('https://')) {
      return false;
    }

    // Reject codes with only whitespace/control characters
    if (barcode.replaceAll(RegExp(r'\s'), '').isEmpty) {
      return false;
    }

    return true;
  }

  /// Recovery mechanism for scanner failures
  Future<void> _attemptRecovery() async {
    debugPrint('WarehouseScannerService: Attempting recovery...');
    
    String? previousContext = _currentContext;
    await _stopScanInternal();
    _isInitialized = false;
    _currentContext = null;
    
    // Wait before recovery attempt
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (previousContext != null) {
      await startScan(previousContext);
    }
  }

  /// Force restart the scanner (for manual recovery)
  Future<void> restartScanner([String? newContext]) async {
    debugPrint('WarehouseScannerService: Manual restart requested');
    
    String? contextToRestore = newContext ?? _currentContext;
    await _stopScanInternal();
    _isInitialized = false;
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (contextToRestore != null) {
      await startScan(contextToRestore);
    }
  }

  /// Get detailed status information for debugging
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isScanning': _isScanning,
      'currentContext': _currentContext,
      'scanStreamHasListeners': _scanController.hasListener,
      'errorStreamHasListeners': _errorController.hasListener,
      'scanControllerIsClosed': _scanController.isClosed,
      'errorControllerIsClosed': _errorController.isClosed,
    };
  }

  /// Clean disposal of all resources
  void dispose() {
    debugPrint('WarehouseScannerService: Disposing all resources');
    
    _stopScanInternal();
    
    if (!_scanController.isClosed) {
      _scanController.close();
    }
    
    if (!_errorController.isClosed) {
      _errorController.close();
    }

    _isInitialized = false;
    _isScanning = false;
    _currentContext = null;
    _scanner = null;
  }
}
