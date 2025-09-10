import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showroom_manager/constant/constants.dart';
import 'package:showroom_manager/modals/product_modal.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../controllers/warehouse_stock_take_controller.dart';
import '../../../services/warehouse_scanner_service.dart';
import 'warehouse_product_card.dart';
import '../serial_scan_screen/warehouse_serial_scan_screen.dart';

class WarehouseProductScanScreen extends StatefulWidget {
  final String stockTakeId;
  const WarehouseProductScanScreen({super.key, required this.stockTakeId});

  @override
  State<WarehouseProductScanScreen> createState() => _WarehouseProductScanScreenState();
}

class _WarehouseProductScanScreenState extends State<WarehouseProductScanScreen> 
    with WidgetsBindingObserver {
  
  final WarehouseScannerService _scannerService = WarehouseScannerService();
  final DynamicMaster _dynamicMaster = DynamicMaster();
  
  late WarehouseStockTakeController _controller;
  StreamSubscription<String>? _scanSubscription;
  StreamSubscription<Exception>? _errorSubscription;
  
  bool _isInitialized = false;
  String get _screenContext => 'product_scan_${widget.stockTakeId}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize controller
    if (Get.isRegistered<WarehouseStockTakeController>()) {
      _controller = Get.find<WarehouseStockTakeController>();
    } else {
      _controller = Get.put(WarehouseStockTakeController());
    }
    
    _initializeScreen();
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

  Future<void> _initializeScreen() async {
    try {
      // Initialize stock take data
      bool stockTakeInitialized = await _controller.initializeStockTake(context, widget.stockTakeId);
      
      if (!stockTakeInitialized) {
        _dynamicMaster.displayError(context, "Error", "Failed to load stock take details");
        Navigator.of(context).pop();
        return;
      }

      // Initialize and start scanner
      await _initializeScanner();
      _isInitialized = true;
      
    } catch (e) {
      debugPrint('WarehouseProductScanScreen: Initialization error: $e');
      _dynamicMaster.displayError(context, "Error", "Failed to initialize screen: $e");
    }
  }

  Future<void> _initializeScanner() async {
    try {
      // Initialize scanner
      bool scannerReady = await _scannerService.initialize();
      if (!scannerReady) {
        throw Exception("Scanner initialization failed");
      }

      // Set up stream subscriptions
      _scanSubscription = _scannerService.scanStream.listen(
        _handleScannedBarcode,
        onError: _handleScanError,
      );
      
      _errorSubscription = _scannerService.errorStream.listen(
        _handleScanError,
      );

      // Start scanning
      await _scannerService.startScan(_screenContext);
      
      debugPrint('WarehouseProductScanScreen: Scanner initialized and started');
    } catch (e) {
      debugPrint('WarehouseProductScanScreen: Scanner initialization failed: $e');
      throw e;
    }
  }

  void _handleScannedBarcode(String barcode) {
    if (!mounted) return;
    
    debugPrint('WarehouseProductScanScreen: Processing barcode: $barcode');
    _processScannedProduct(barcode);
  }

  void _handleScanError(Exception error) {
    if (!mounted) return;
    
    debugPrint('WarehouseProductScanScreen: Scanner error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scanner error: ${error.toString()}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _processScannedProduct(String barcode) async {
    _dynamicMaster.displayLoadingModal(context);

    try {
      var result = await _controller.addScannedProduct(barcode);
      
      Navigator.of(context).pop(); // Close loading modal

      if (result["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product added: ${result["product"]?.itemName ?? "Unknown"}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _dynamicMaster.displayError(context, "Error", result["message"]);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading modal
      debugPrint('WarehouseProductScanScreen: Error processing product: $e');
      _dynamicMaster.displayError(context, "Error", "Failed to process scanned product: $e");
    }
  }

  void _navigateToSerialScan(ProductModal product) {
    // Temporarily stop the scanner
    _scannerService.stopScan(_screenContext);
    
    // Select the product for serial scanning
    _controller.selectProductForSerials(product);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WarehouseSerialScanScreen(
          product: product,
          controller: _controller,
        ),
      ),
    ).then((_) {
      // Restart scanner when returning
      _restartScannerAfterNavigation();
    });
  }

  void _restartScannerAfterNavigation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isInitialized) {
        _scannerService.startScan(_screenContext);
      }
    });
  }

  Future<void> _submitStockTake() async {
    if (_controller.scannedProducts.isEmpty) {
      _dynamicMaster.displayError(context, "Error", "No products scanned to submit");
      return;
    }

    // Confirm submission
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Stock Take"),
        content: Text(
          "Submit stock take with ${_controller.scannedProducts.length} products "
          "and ${_controller.totalScannedItems} total items?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Submit"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      var result = await _controller.submitStockTake();
      
      if (result["success"]) {
        _dynamicMaster.displaySuccessMessage(context, "Stock take submitted successfully");
        Navigator.of(context).pop(); // Return to stock take list
      } else {
        _dynamicMaster.displayError(context, "Error", result["message"]);
      }
    } catch (e) {
      debugPrint('WarehouseProductScanScreen: Submission error: $e');
      _dynamicMaster.displayError(context, "Error", "Failed to submit stock take: $e");
    }
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
        title: Obx(() => Text(
          'Stock Take: ${_controller.stockCountNumber.value.isEmpty ? "Loading..." : _controller.stockCountNumber.value}'
        )),
        backgroundColor: kSecondaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => _controller.scannedProducts.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _submitStockTake,
                  tooltip: 'Submit Stock Take',
                )
              : const SizedBox.shrink()
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header with stock take info
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
                    'Warehouse: ${_controller.warehouseCode.value}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Products Scanned: ${_controller.scannedProducts.length}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total Items: ${_controller.totalScannedItems}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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
                      'Scan product barcodes to add them to the stock take. Tap a product to add serial numbers.',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product list
            Expanded(
              child: _controller.scannedProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No products scanned yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Scan a barcode to get started',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _controller.scannedProducts.length,
                      itemBuilder: (context, index) {
                        ProductModal product = _controller.scannedProducts[index];
                        List<String> serials = _controller.getSerialsForProduct(product);
                        
                        return WarehouseProductCard(
                          product: product,
                          serialCount: serials.length,
                          onTap: () => _navigateToSerialScan(product),
                        );
                      },
                    ),
            ),

            // Submit button
            Obx(() => _controller.scannedProducts.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: size.width,
                      child: RoundedButton(
                        btnText: _controller.isSubmitting.value
                            ? "Submitting..."
                            : "Submit Stock Take (${_controller.scannedProducts.length} products)",
                        press: _controller.isSubmitting.value ? () {} : () => _submitStockTake(),
                        btnColor: kSecondaryColor,
                        textColor: kPrimaryLightColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
            ),
          ],
        );
      }),
    );
  }
}
