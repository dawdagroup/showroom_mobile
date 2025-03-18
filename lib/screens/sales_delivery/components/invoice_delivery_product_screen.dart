import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/invoice_delivery_controller.dart';
import '../../../modals/invoice_details_modal.dart';
import '../../../modals/product_serial_number_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class InvoiceDeliveryProductScreen extends StatefulWidget {
  final InvoiceItem invoiceItem;
  final List<ProductSerialNumberModal> serialNumberList;
  const InvoiceDeliveryProductScreen({super.key, required this.invoiceItem, required this.serialNumberList});

  @override
  State<InvoiceDeliveryProductScreen> createState() => _InvoiceDeliveryProductScreenState();
}

class _InvoiceDeliveryProductScreenState extends State<InvoiceDeliveryProductScreen> with WidgetsBindingObserver {
  // Retrieve the InvoiceController instance.
  final InvoiceController invoiceController = Get.find<InvoiceController>();
  
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  
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
    final scannedCount = invoiceController.scannedSerials[widget.invoiceItem.itemCode]?.length ?? 0;

    if (scannedCount >= widget.invoiceItem.itemOpenQty) {
      dynamicMaster.displayError(context, "Error", "You have already scanned all the serials for this item.");
      return;
    }

    // verify if the serial number is in the list of serial numbers
    if (!widget.serialNumberList.any((element) => element.serialNo == scannedData?.code)) {
      dynamicMaster.displayError(context, "Error", "Serial number has not been marked for delivery.");
      return;
    }

    bool results = await invoiceController.addProductSerialNumber(widget.invoiceItem.itemCode, scannedData?.code as String);

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
                      widget.invoiceItem.itemImageUrl == null ? Image.asset("assets/images/blank_image.png", width: size.width * 0.3,  height: size.height * 0.2) : Image.network(widget.invoiceItem.itemImageUrl, width: size.width * 0.3, height: size.height * 0.2,),
                      SizedBox(
                        width: size.width * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.invoiceItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text(widget.invoiceItem.itemModelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text("Qty: ${widget.invoiceItem.itemOpenQty}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            // Wrap the scanned and pending qty fields in an Obx widget:
                            Obx(() {
                              // Calculate the current count from your reactive map.
                              final scannedCount = invoiceController.scannedSerials[widget.invoiceItem.itemCode]?.length ?? 0;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10),
                                  Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  Text("Pending Qty: ${widget.invoiceItem.itemOpenQty - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
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
                      final serialList = invoiceController.scannedSerials[widget.invoiceItem.itemCode]?.toList() ?? [];
                      return ListView.builder(
                        itemCount: widget.serialNumberList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: serialList.contains(widget.serialNumberList[index].serialNo) ? Colors.green : Colors.white,
                            child: ListTile(
                              leading: Text("${index + 1}"),
                              title: Text(widget.serialNumberList[index].serialNo),
                              trailing: serialList.contains(widget.serialNumberList[index].serialNo) ? const Icon(Icons.check, color: Colors.white,) : const Icon(Icons.pending, color: Colors.red,),
                              
                            ),
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