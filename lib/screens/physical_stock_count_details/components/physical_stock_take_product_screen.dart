
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/navigation_observer.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../controllers/stock_count_controller.dart';
import '../../../modals/product_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';

class PhysicalStockTakeProductScreen extends StatefulWidget {
  final ProductModal product;
  final String physicalStockCountId;
  const PhysicalStockTakeProductScreen({super.key, required this.product, required this.physicalStockCountId});

  @override
  State<PhysicalStockTakeProductScreen> createState() => _PhysicalStockTakeProductScreenState();
}

class _PhysicalStockTakeProductScreenState extends State<PhysicalStockTakeProductScreen>  with RouteAware  {
  late final StockCountController stockCountController;

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  String? productImagePath;

  
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    stockCountController = Get.find<StockCountController>(tag: widget.physicalStockCountId);
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    
    stockCountDetailsObserver.subscribe(this, ModalRoute.of(context)!);

    // Initialize the screen
    initScanner();

  }

  
  @override
  void dispose() {
    // unsubscribe this State object
    stockCountDetailsObserver.unsubscribe(this);
    print("DEBUG: Stopping Honeywell scanner in dispose2()");
    
    honeywellScanner.stopScanner();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when you come back to this screen (e.g. you popped off another route)
    // restart the scanner on returning to this screen
    super.didPopNext();
    print("DEBUG: didPopNext() - Restarting Honeywell scanner");
    initScanner();              // or just   honeywellScanner.startScanner();
    setState(() => scannerEnabled = true);
  }

  @override
  void didPushNext() {
    // Called when you navigate to another screen
    // stop the scanner when navigating away from this screen
    super.didPushNext();
    print("DEBUG: didPushNext()2 - Stopping Honeywell scanner");
    honeywellScanner.stopScanner();
    setState(() => scannerEnabled = false);
  }

  void onDecoded(ScannedData? scannedData) async {
    if (!mounted) return;
    
    this.scannedData = scannedData;
    
    if (scannedData?.code == null) return;
    
    try {
      var results = await stockCountController.addSerialNumber(widget.product.barcode, scannedData!.code!);

      print("results: $results");

      if (!results["success"]) {
        // If the serial number is already scanned, display an error message
        if (mounted) {
          if (results["message"] != null) {
            dynamicMaster.displayError(context, "Error", results["message"]);
          } else {
            dynamicMaster.displayError(context, "Error", "Serial number already scanned.");
          }
        }
      }
    } catch (e) {
      print("Error processing scan: $e");
      if (mounted) {
        dynamicMaster.displayError(context, "Error", "Failed to process scan: $e");
      }
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              // invoice header
              Container(
                height: size.height * 0.25,
                width: size.width,
                color: kPrimaryColor,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.04,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width * 0.3,
                          child: ImageService.isValidItemCode(widget.product.itemCode?.toString()) ? 
                            Image.network(
                              ImageService.getProductImageUrl(widget.product.itemCode.toString()),
                              height: size.height * 0.3, 
                              width: size.width * 0.3,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: kPrimaryLightColor)
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/blank_image.png", 
                                  width: size.width * 0.3, 
                                  fit: BoxFit.cover
                                );
                              },
                            ) :
                            Image.asset("assets/images/blank_image.png", width: size.width * 0.3, fit: BoxFit.cover),
                        ),
                        SizedBox(
                          width: size.width * 0.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(widget.product.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                              SizedBox(height: size.height * 0.01,),
                              Text(widget.product.modelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                              SizedBox(height: size.height * 0.01,),
                              Text(widget.product.itemGroup, softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                              SizedBox(height: size.height * 0.01,),
                              // Wrap the scanned and pending qty fields in an Obx widget:
                              Obx(() => 
                                // Calculate the current count from your reactive map.
                                // final scannedCount = goodsIssueController.scannedSerials[widget.product.itemCode]?.length ?? 0;
                                Text("Scanned Qty: ${stockCountController.scannedSerials[widget.product.barcode]?.length ?? 0}", style: const TextStyle(fontSize: 14, color: Colors.white))
      
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      
              SizedBox(
                height: size.height * 0.64,
                child: Column(
                  children: [
                    Expanded(
                      child: Obx(() {
                        // Convert Set to List for indexing
                        final serialList = stockCountController.scannedSerials[widget.product.barcode]?.toList() ?? [];
                        return ListView.builder(
                          itemCount: serialList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Text("${index + 1}"),
                              title: Text(serialList[index]),
                              trailing: IconButton(onPressed: (){ stockCountController.removeSerialNumber(widget.product.barcode, serialList[index]); }, icon: const Icon(Icons.delete, color: Colors.red,)),
                            );
                          },
                        );
                      }),
                    )
                  ],
                ),
              ),              
              RoundedButton(
                btnText: "Save", 
                press: (){
                  debugPrint("Navigating back from product screen");
                  Navigator.pushNamed(context, '/physical_stock_count_details', arguments:widget.physicalStockCountId);
                }, 
                btnColor: kPrimaryColor, 
                textColor: kPrimaryLightColor
              )
            ],
          ),
        ),
      ),
    );
  }
}