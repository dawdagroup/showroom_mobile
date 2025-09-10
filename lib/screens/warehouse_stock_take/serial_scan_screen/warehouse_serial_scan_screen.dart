import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showroom_manager/constant/constants.dart';
import 'package:showroom_manager/modals/product_modal.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../controllers/warehouse_stock_take_controller.dart';
import '../../../services/warehouse_scanner_service.dart';

class WarehouseSerialScanScreen extends StatefulWidget {
  final ProductModal product;
  final WarehouseStockTakeController controller;

  const WarehouseSerialScanScreen({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<WarehouseSerialScanScreen> createState() => _WarehouseSerialScanScreenState();
}

class _WarehouseSerialScanScreenState extends State<WarehouseSerialScanScreen>
    with WidgetsBindingObserver {
  
  final WarehouseScannerService _scannerService = WarehouseScannerService();
  final DynamicMaster _dynamicMaster = DynamicMaster();
  
  StreamSubscription<String>? _scanSubscription;
  StreamSubscription<Exception>? _errorSubscription;
  
  bool _isInitialized = false;
  String get _screenContext => 'serial_scan_${widget.product.itemCode}';
  
  // Local observable list for immediate UI updates
  final RxList<String> _localSerials = <String>[].obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load existing serials
    _localSerials.value = widget.controller.getSerialsForProduct(widget.product);
    
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupScanner();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _scannerService.pauseForLifecycle();
        break;
      case AppLifecycleState.resumed:
        if (_isInitialized) {
          _scannerService.resumeForLifecycle();
        }
        break;
      default:
        break;
    }
  }

  Future<void> _initializeScanner() async {
    try {
      // Initialize scanner if not already done
      bool scannerReady = await _scannerService.initialize();
      if (!scannerReady) {
        throw Exception("Scanner initialization failed");
      }

      // Set up stream subscriptions
      _scanSubscription = _scannerService.scanStream.listen(
        _handleScannedSerial,
        onError: _handleScanError,
      );
      
      _errorSubscription = _scannerService.errorStream.listen(
        _handleScanError,
      );

      // Start scanning for serials
      await _scannerService.startScan(_screenContext);
      _isInitialized = true;
      
      debugPrint('WarehouseSerialScanScreen: Scanner initialized for serials');
    } catch (e) {
      debugPrint('WarehouseSerialScanScreen: Scanner initialization failed: $e');
      _dynamicMaster.displayError(context, "Scanner Error", "Failed to initialize scanner: $e");
    }
  }

  void _handleScannedSerial(String serialNumber) {
    if (!mounted) return;
    
    debugPrint('WarehouseSerialScanScreen: Processing serial: $serialNumber');
    _processScannedSerial(serialNumber);
  }

  void _handleScanError(Exception error) {
    if (!mounted) return;
    
    debugPrint('WarehouseSerialScanScreen: Scanner error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanner error: ${error.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _processScannedSerial(String serialNumber) {
    try {
      var result = widget.controller.addSerialToSelectedProduct(serialNumber);
      
      if (result["success"]) {
        // Update local list for immediate UI feedback
        _localSerials.add(serialNumber);
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serial added: $serialNumber'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        
        // Scroll to bottom to show new item
        _scrollToBottom();
      } else {
        _dynamicMaster.displayError(context, "Error", result["message"]);
      }
    } catch (e) {
      debugPrint('WarehouseSerialScanScreen: Error processing serial: $e');
      _dynamicMaster.displayError(context, "Error", "Failed to process scanned serial: $e");
    }
  }

  void _scrollToBottom() {
    // Small delay to ensure the list has updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Scroll to bottom if there are items
        // This could be enhanced with a scroll controller if needed
      }
    });
  }

  void _removeSerial(String serialNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Serial"),
        content: Text("Remove serial number '$serialNumber'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.controller.removeSerialFromProduct(widget.product, serialNumber);
              _localSerials.remove(serialNumber);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _finishSerialScanning() {
    Navigator.of(context).pop();
  }

  void _cleanupScanner() {
    _scanSubscription?.cancel();
    _errorSubscription?.cancel();
    _scannerService.stopScan(_screenContext);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serial Number Scanning'),
        backgroundColor: kSecondaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _finishSerialScanning,
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Product information header
          Container(
            width: size.width,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE5CCB8), Color(0xFFD1B299), Color(0xFFF3D4B3)]
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.itemName?.toString() ?? 'Unknown Product',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: ${widget.product.itemCode?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Barcode: ${widget.product.barcode?.toString() ?? 'N/A'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  'Scanned Serials: ${_localSerials.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )),
              ],
            ),
          ),
          
          // Scanning instruction
          Container(
            width: size.width,
            padding: const EdgeInsets.all(12.0),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Scan serial number barcodes for this product. Each serial will be added to the list below.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          
          // Serial numbers list
          Expanded(
            child: Obx(() => _localSerials.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No serial numbers scanned',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Scan serial number barcodes to add them',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _localSerials.length,
                    itemBuilder: (context, index) {
                      String serial = _localSerials[index];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            serial,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                            ),
                          ),
                          subtitle: Text(
                            'Added ${DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _removeSerial(serial),
                            tooltip: 'Remove serial',
                          ),
                        ),
                      );
                    },
                  )
            ),
          ),
          
          // Bottom action bar
          Container(
            width: size.width,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(() => Text(
                  '${_localSerials.length} serial numbers scanned',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                const SizedBox(height: 12),
                SizedBox(
                  width: size.width,
                  child: RoundedButton(
                    btnText: "Done Scanning Serials",
                    press: _finishSerialScanning,
                    btnColor: kSecondaryColor,
                    textColor: kPrimaryLightColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
