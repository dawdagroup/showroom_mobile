import 'package:flutter/material.dart';
import 'package:showroom_manager/services/scanner_service.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';

/// A widget that provides scanner functionality to its child widgets
/// This widget manages the scanner lifecycle and ensures proper cleanup
class ScannerProvider extends StatefulWidget {
  final Widget child;
  final String screenName;
  final Function(ScannedData?)? onScan;
  final Function(Exception)? onError;

  const ScannerProvider({
    Key? key,
    required this.child,
    required this.screenName,
    this.onScan,
    this.onError,
  }) : super(key: key);

  @override
  State<ScannerProvider> createState() => _ScannerProviderState();
}

class _ScannerProviderState extends State<ScannerProvider> with WidgetsBindingObserver {
  final ScannerService _scannerService = ScannerService();
  bool _isActive = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Use post frame callback to ensure widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _startScanner();
      }
    });
  }

  @override
  void didUpdateWidget(ScannerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the screen name changed or widget was rebuilt with new key, restart the scanner
    if (oldWidget.screenName != widget.screenName || oldWidget.key != widget.key) {
      debugPrint("ScannerProvider updated - restarting scanner for ${widget.screenName}");
      _isActive = false; // Reset the flag
      // Small delay to ensure proper cleanup
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!_isDisposed && mounted) {
          _startScanner();
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed - restarting scanner for ${widget.screenName}");
      if (!_isDisposed) {
        _startScanner();
      }
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.inactive || 
               state == AppLifecycleState.detached || 
               state == AppLifecycleState.hidden) {
      debugPrint("App paused - pausing scanner for ${widget.screenName}");
      _scannerService.pauseScanner();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isActive = false;
    WidgetsBinding.instance.removeObserver(this);
    _scannerService.stopScanner(widget.screenName);
    super.dispose();
  }

  Future<void> _startScanner() async {
    if (_isDisposed || _isActive) return;
    
    try {
      _isActive = true;
      debugPrint("Starting scanner for ${widget.screenName}");
      await _scannerService.startScanner(
        widget.screenName,
        onScan: widget.onScan,
        onError: widget.onError,
      );
      
      // Only update state if still mounted and not disposed
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    } catch (e) {
      _isActive = false;
      debugPrint("Error starting scanner: $e");
      if (widget.onError != null) {
        widget.onError!(Exception("Failed to start scanner: $e"));
      }
    }
  }

  /// Method to manually restart the scanner (can be called from parent)
  void restartScanner() {
    if (!_isDisposed) {
      debugPrint("Manually restarting scanner for ${widget.screenName}");
      _startScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
