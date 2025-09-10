
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/po_controller.dart';
import '../../../modals/purchase_order_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';

class PurchaseOrderProductScreen extends StatefulWidget {
  final PurchaseOrderLineItem purchaseOrderLineItem;
  final String purchaseOrderNumber;
  const PurchaseOrderProductScreen({super.key, required this.purchaseOrderLineItem, required this.purchaseOrderNumber});

  @override
  State<PurchaseOrderProductScreen> createState() => _PurchaseOrderProductScreenState();
}

class _PurchaseOrderProductScreenState extends State<PurchaseOrderProductScreen>  with WidgetsBindingObserver {
  late final PurchaseOderController purchaseOderController;

  
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  String? productImagePath;
  
  HoneywellScanner honeywellScanner = HoneywellScanner();
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    // Get the tagged controller instance
    purchaseOderController = Get.find<PurchaseOderController>(tag: widget.purchaseOrderNumber);
    init();
  } 
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      honeywellScanner.startScanner();
    } else if (state == AppLifecycleState.paused) {
      honeywellScanner.stopScanner();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    honeywellScanner.stopScanner();
    super.dispose();
  }

  // @override
  void onDecoded(ScannedData? scannedData) async{
    // get the total scanned serials for the item
    final scannedCount = purchaseOderController.scannedSerials[widget.purchaseOrderLineItem.itemCode]?.length ?? 0;

    if (scannedCount >= widget.purchaseOrderLineItem.itemOpenQuantity) {
      dynamicMaster.displayError(context, "Error", "You have already scanned all the serials for this item.");
      return;
    }

    bool results = await purchaseOderController.addProductSerialNumber(widget.purchaseOrderLineItem.itemCode, scannedData?.code as String);

    if (!results) {
      dynamicMaster.displayError(context, "Error", "Serial number already scanned.");
    }
  }

  // @override
  void onError(Exception error) { }

  Future<void> init() async {
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    honeywellScanner.onScannerDecodeCallback = onDecoded;
    honeywellScanner.onScannerErrorCallback = onError;
    await honeywellScanner.startScanner();
  
    if (mounted) setState(() { });
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
                        child: ImageService.isValidItemCode(widget.purchaseOrderLineItem.itemCode?.toString()) ? 
                          Image.network(
                            ImageService.getProductImageUrl(widget.purchaseOrderLineItem.itemCode.toString()),
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
                            Text(widget.purchaseOrderLineItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text(widget.purchaseOrderLineItem.itemModelNumber,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text("Qty: ${widget.purchaseOrderLineItem.itemOpenQuantity}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            // Wrap the scanned and pending qty fields in an Obx widget:
                            Obx(() {
                              // Calculate the current count from your reactive map.
                              final scannedCount = purchaseOderController.scannedSerials[widget.purchaseOrderLineItem.itemCode]?.length ?? 0;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10),
                                  Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  Text("Pending Qty: ${widget.purchaseOrderLineItem.itemOpenQuantity - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
                                ],
                              );
                            }),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              height: size.height * 0.7,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      // Convert Set to List for indexing
                      final serialList = purchaseOderController.scannedSerials[widget.purchaseOrderLineItem.itemCode]?.toList() ?? [];
                      return ListView.builder(
                        itemCount: serialList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text("${index + 1}"),
                            title: Text(serialList[index]),
                            trailing: IconButton(onPressed: (){ purchaseOderController.removeProductSerialNumber(widget.purchaseOrderLineItem.itemCode, serialList[index]); }, icon: const Icon(Icons.delete, color: Colors.red,)),
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}