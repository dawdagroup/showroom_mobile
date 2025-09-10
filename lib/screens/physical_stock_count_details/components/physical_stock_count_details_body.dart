import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/navigation_observer.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../controllers/stock_count_controller.dart';
import '../../../modals/product_modal.dart';
import '../../../modals/pysical_stock_take_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'physical_stock_count_product_card.dart';

class PhysicalStockCountDetailsBody extends StatefulWidget {
  final String physicalStockCountId;
  const PhysicalStockCountDetailsBody({super.key, required this.physicalStockCountId  });

  @override
  State<PhysicalStockCountDetailsBody> createState() => _PhysicalStockCountDetailsBodyState();
}

class _PhysicalStockCountDetailsBodyState extends State<PhysicalStockCountDetailsBody>  with RouteAware {
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
  bool isLoading = false;
  bool isProcessingSubmit = false;
  
  PhysicalStockTakeDetailsModal? physicalStockTakeDetailsModal;

  
  @override
  void initState() {
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // Initialize the screen
    _initializeScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe this State object to be notified
    stockCountDetailsObserver.subscribe(this, ModalRoute.of(context)!);

  }

  @override
  void dispose() {
    // unsubscribe this State object
    stockCountDetailsObserver.unsubscribe(this);
    print("DEBUG: Stopping Honeywell scanner in dispose1()");
    honeywellScanner.stopScanner();
    super.dispose();
  }

  @override
  void didPopNext() async{
    // Called when you come back to this screen (e.g. you popped off another route)
    // restart the scanner on returning to this screen
    super.didPopNext();
    print("DEBUG: didPopNext()1 - Restarting Honeywell scanner");
    await initScanner();
    // Ensure the scanner is enabled after restarting
    setState(() => scannerEnabled = true);
    // });
  }

  @override
  void didPushNext() {
    // Called when you navigate to another screen
    // stop the scanner when navigating away from this screen
    super.didPushNext();
    print("DEBUG: didPushNext() - Stopping Honeywell scanner");
    honeywellScanner.stopScanner();
    setState(() => scannerEnabled = false);
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

  void onDecoded(ScannedData? scannedData) {
    if (!mounted) return;
    
    print("DEBUG: Scanner decoded data: $scannedData");
    print("DEBUG: Scanner enabled status: $scannerEnabled");
    this.scannedData = scannedData;
    
    if (scannedData?.code != null) {
      print("DEBUG: Processing barcode: ${scannedData!.code}");
      fetchProduct(scannedData.code!);
    } else {
      print("DEBUG: Scanned data code is null");
    }
  }

  void onError(Exception error) {
    if (!mounted) return;
    print("DEBUG: Honeywell scanner error occurred: $error");
    print("DEBUG: Scanner enabled status when error occurred: $scannerEnabled");
  }
  
  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);
    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner.setProperties(properties);
  }

  Future<void> initScanner() async {
    print("DEBUG: initScanner() - Starting Honeywell scanner initialization");
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    print("DEBUG: Device supported: $isDeviceSupported");
    honeywellScanner.onScannerDecodeCallback = onDecoded;
    honeywellScanner.onScannerErrorCallback = onError;
    
    try {
      await honeywellScanner.startScanner();
      print("DEBUG: Honeywell scanner started successfully");
      setState(() => scannerEnabled = true);
    } catch (e) {
      print("DEBUG: Error starting Honeywell scanner: $e");
      setState(() => scannerEnabled = false);
    }

    if (mounted) setState(() {});
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
  
  Future<void> _initializeScreen() async {
    print("DEBUG: _initializeScreen() - Starting screen initialization");
    try {
      await getPhysicalStockCountDetails();

      if (physicalStockTakeDetailsModal == null) {
        print("DEBUG: physicalStockTakeDetailsModal is null, exiting initialization");
        return;
      }

      // Check if the controller already exists to avoid duplicates
      if (Get.isRegistered<StockCountController>(tag: widget.physicalStockCountId.toString())) {
        print("DEBUG: StockCountController already registered, using existing instance");
        stockCountController = Get.find<StockCountController>(tag: widget.physicalStockCountId.toString());
      } else {
        print("DEBUG: Creating new StockCountController instance");
        stockCountController = Get.put(StockCountController(context, physicalStockTakeDetailsModal!), tag: widget.physicalStockCountId.toString());
      }
      
      print("DEBUG: Starting Honeywell scanner initialization from _initializeScreen()");

      await initScanner();

    } catch (e) {
      print("DEBUG: Error initializing screen: $e");
      debugPrint('Error initializing screen: $e');
    }
  }

  Future<void> submitStockTake() async {
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
      
      setState(() { isProcessingSubmit = false; });

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, "Stock count submitted successfully");
        stockCountController.clearScans();
      }else{
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
    return SizedBox(
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
                      physicalStockCountId: widget.physicalStockCountId.toString(),
                    );

                  },
                ),
              )
            ),
            
            RoundedButton(
              btnText: "Submit Stock Count",
              press: () {
                submitStockTake();
              }, 
              btnColor: kSecondaryColor, 
              textColor: kPrimaryLightColor
            )
          ],
        ),
      ),
    );
  }
}