import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/controllers/stock_count_controller.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../providers/scanner_provider.dart';
import '../../../constant/constants.dart';
import '../../../modals/product_modal.dart';
import '../../../modals/pysical_stock_take_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'physical_stock_count_product_card.dart';

class PhysicalStockCountDetailsBody extends StatefulWidget {
  final String physicalStockCountId;
  const PhysicalStockCountDetailsBody({super.key, required this.physicalStockCountId});

  @override
  State<PhysicalStockCountDetailsBody> createState() => _PhysicalStockCountDetailsBodyState();
}

class _PhysicalStockCountDetailsBodyState extends State<PhysicalStockCountDetailsBody> with WidgetsBindingObserver {
  late final StockCountController stockCountController;
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;

  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  bool isLoading = true;
  bool isProcessingSubmit = true;
  bool _isInitialized = false;
  bool _wasInBackground = false;
  int _scannerKey = 0; // Key to force ScannerProvider rebuild
  PhysicalStockTakeDetailsModal? physicalStockTakeDetailsModal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Don't call _initializeScreen here since we need context dependencies
    _checkAndRestartScanner();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    // Now initialize the screen after dependencies are available
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeScreen();
    } else {
      // If we're already initialized and didChangeDependencies is called again,
      // it might mean we're returning from navigation
      debugPrint("didChangeDependencies called on already initialized screen - possible navigation return");
      _checkAndRestartScanner();
    }
  }

  void _checkAndRestartScanner() {
    // Add a small delay to ensure navigation is complete
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _isInitialized && physicalStockTakeDetailsModal != null) {
        debugPrint("Checking if scanner restart is needed - incrementing key from $_scannerKey to ${_scannerKey + 1}");
        setState(() {
          _scannerKey++;
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      _wasInBackground = true;
    } else if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      debugPrint("Returned to stock details screen - restarting scanner");
      // Force ScannerProvider to rebuild by changing its key
      setState(() {
        _scannerKey++;
      });
    }
  }

  /// Override this to detect when we return from other screens
  @override
  void activate() {
    super.activate();
    debugPrint("Stock details screen activated - user returned to screen");
    // Only restart scanner if we've been away and have completed initialization
    if (_isInitialized && physicalStockTakeDetailsModal != null) {
      debugPrint("Screen initialized, attempting scanner restart");
      // Check if this is likely a return from navigation by looking at the current scanner state
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          debugPrint("Forcing scanner restart by incrementing key from $_scannerKey to ${_scannerKey + 1}");
          // Force restart by incrementing the key
          setState(() {
            _scannerKey++;
          });
        }
      });
    } else {
      debugPrint("Screen not yet initialized (_isInitialized: $_isInitialized, modal: ${physicalStockTakeDetailsModal != null})");
    }
  }

  Future<void> _initializeScreen() async {
    try {
      await getPhysicalStockCountDetails();

      if (physicalStockTakeDetailsModal == null) {
        return;
      }

      // Check if the controller already exists to avoid duplicates
      if (Get.isRegistered<StockCountController>()) {
        stockCountController = Get.find<StockCountController>();
      } else {
        stockCountController = Get.put(StockCountController(context, physicalStockTakeDetailsModal!));
      }

      // Listen for scanner restart triggers from the controller
      stockCountController.addListener(_onControllerUpdate);
    } catch (e) {
      debugPrint('Error initializing screen: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onControllerUpdate() {
    // This is called when the controller's update() method is triggered
    debugPrint("Controller updated - triggering scanner restart");
    _restartScannerAfterNavigation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove controller listener if it exists
    if (Get.isRegistered<StockCountController>()) {
      try {
        stockCountController.removeListener(_onControllerUpdate);
      } catch (e) {
        debugPrint("Error removing controller listener: $e");
      }
    }
    super.dispose();
  }

  void _restartScannerAfterNavigation() {
    // Add a delay to ensure navigation is complete
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _isInitialized && physicalStockTakeDetailsModal != null && !_wasInBackground) {
        debugPrint("Restarting scanner after navigation return - key: $_scannerKey -> ${_scannerKey + 1}");
        setState(() {
          _scannerKey++;
        });
      }
    });
  }

  Future<void> getPhysicalStockCountDetails() async {
    setState(() { isLoading = true; physicalStockTakeDetailsModal = null; });
    try{

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getPhysicalStockCountDetails(token, widget.physicalStockCountId);

      if (response["status"] == "success" && response["data"].isNotEmpty) {
        physicalStockTakeDetailsModal = physicalStockTakeDetailsModalFromJson(jsonEncode(response["data"][0]));
        // Save to local database
        setState(() {
          physicalStockTakeDetailsModal = physicalStockTakeDetailsModal;
          isLoading = false;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch(e){
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false;});
  }
  
  void onDecoded(ScannedData? scannedData) {
    if (!mounted) return;
    
    print("Scanned data: $scannedData");
    this.scannedData = scannedData;
    
    if (scannedData?.code != null) {
      fetchProduct(scannedData!.code!);
    }
  }

  void onError(Exception error) {
    if (!mounted) return;
    print("Scanner error: $error");
  }

  /// Method to restart the scanner (can be called when returning to this screen)
  void restartScanner() {
    if (mounted) {
      debugPrint("Manually restarting scanner for stock details");
      setState(() {
        _scannerKey++;
      });
    }
  }

  Future<void> fetchProduct(String barcode) async {
    dynamicMaster.displayLoadingModal(context);

    try {
      var token = await sessionProvider.authProvider.token;
      // String token = sessionProvider.authProvider.token!;

      if(token == null){
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }

      var response = await apiService.fecthProductDetails(token, {"barcode": barcode});

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        ProductModal product = productModalFromJson(jsonEncode(response["data"][0]));

        var productStockTakeResponse = await stockCountController.addProduct(product);

        if(!productStockTakeResponse["success"]){
          dynamicMaster.displayError(context, "Error", productStockTakeResponse["message"]);
          return;
        }
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
        return;
      }

    } catch (e) {
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

  Future<void> submintStockTake() async {
    dynamicMaster.displayLoadingModal(context);

    setState(() {
      isProcessingSubmit = true;
    });

    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        setState(() { isProcessingSubmit = false; });
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }

      var stocktakeDetails = await stockCountController.fetchStocTakeDetails();

      if(!stocktakeDetails["success"]){
        setState(() { isProcessingSubmit = false; });
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", stocktakeDetails["message"]);
        return;
      }

      // remove the success key from stocktakeDetails
      stocktakeDetails.remove("success");

      Map<String, dynamic> queryParameters = {
        "productSerial":  stocktakeDetails,
        "stockCountNumber": physicalStockTakeDetailsModal!.stockCountNumber,
      };

      var response = await apiService.processPhysicalStockData(token, queryParameters);

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        setState(() { isProcessingSubmit = false; });
        dynamicMaster.displaySuccessMessage(context, "Stock count submitted successfully");
        stockCountController.clearScans();
      }else{
        setState(() { isProcessingSubmit = false; });
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      setState(() { isProcessingSubmit = false; });
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    debugPrint("Building PhysicalStockCountDetailsBody with scanner key: $_scannerKey");
    return ScannerProvider(
      key: ValueKey(_scannerKey), // This forces rebuild when key changes
      screenName: 'stock_details',
      onScan: onDecoded,
      onError: onError,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: isLoading
        ? const Center(child: CircularProgressIndicator())
        : physicalStockTakeDetailsModal == null
        ? const Center(child: Text("No data found"))
        :SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height * 0.28,
                width: size.width,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE5CCB8), 
                      Color(0xFFD1B299), 
                      Color(0xFFF3D4B3)
                    ]
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.01,),
                                  Text("ST No: ${physicalStockTakeDetailsModal!.stockCountNumber}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                  // SizedBox(height: size.height * 0.01,),
                                  Text(DateFormat('dd-MMMM-yyyy').format(physicalStockTakeDetailsModal!.createdAt), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  // SizedBox(height: size.height * 0.01,),
                                  Obx(() => Text("Products Scanned: ${stockCountController.scannedProducts.length}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.1,
                                width: size.width * 0.1,
                                child: physicalStockTakeDetailsModal!.status == "active" ?
                                Image.asset("assets/icons/open-lock43.png"):
                                Image.asset("assets/icons/padlock.png"),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: size.width * 0.35,
                                child: Text(
                                  "Created By: ${physicalStockTakeDetailsModal!.createdByName ?? "N/A"}", 
                                  softWrap: true, 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    "Warehouse Info",
                                    style: TextStyle(letterSpacing: sqrt1_2, fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  SizedBox(
                                    width: size.width * 0.4,
                                    child: Text(physicalStockTakeDetailsModal!.warehouseCode, softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                  ),
                                ],
                              )
                              
                            ],
                          )
                        ],
                      )

                    ],
                  ),
                ),
              ),

              Obx(() => 
                SizedBox(
                  height: size.height * 0.63,
                  child: stockCountController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : stockCountController.scannedProducts.isEmpty
                  ? const Center(child: Text("No products scanned yet"))
                  : ListView.builder(
                    itemCount: stockCountController.scannedProducts.length,
                    itemBuilder: (context, index) {
                      ProductModal productModal = stockCountController.scannedProducts.keys.toList()[index];

                      return PhysicalStockCountProductCard(
                        product: productModal,
                      );

                    },
                  ),
                )
              ),
              
              RoundedButton(
                btnText: "Submit Stock Count", 
                press: (){
                  submintStockTake();
                }, 
                btnColor: kSecondaryColor, 
                textColor: kPrimaryLightColor
              )
            ],
          ),
        ),
      ),
    );
  }
}