import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/stock_transfer_controller.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class GoodsIssueCreateProductBody extends StatefulWidget {
  final StockTransferProduct product;
  const GoodsIssueCreateProductBody({super.key, required this.product});

  @override
  State<GoodsIssueCreateProductBody> createState() => _GoodsIssueCreateProductBodyState();
}

class _GoodsIssueCreateProductBodyState extends State<GoodsIssueCreateProductBody>  with WidgetsBindingObserver {
  final StockTransferController stockTransferController = Get.find<StockTransferController>();
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  String? productImagePath;
  bool isLoading = false;

  
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
    init();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    getProductImage();
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
    final scannedCount = stockTransferController.scannedSerials[widget.product.itemCode]?.length ?? 0;

    if (scannedCount >= widget.product.quantity) {
      dynamicMaster.displayError(context, "Error", "You have already scanned all the serials for this item.");
      return;
    }

    bool results = await stockTransferController.addProductSerialNumber(widget.product.itemCode, scannedData?.code as String);

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

  // get the product image
  Future<void> getProductImage() async {
    setState(() { isLoading = true; });
    try {
      if(widget.product.itemPictureName == null || widget.product.itemPictureName == "") {
        setState(() { isLoading = false; productImagePath = "assets/images/blank_image.png"; });
        return;
      }

      var token = await sessionProvider.authProvider.token;

      if(token == null){
        setState(() { isLoading = false; });
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        return;
      }

      var response = await apiService.getProductImage(token, widget.product.itemPictureName);

      if(response["status"] == "success"){
        setState(() { productImagePath = response["file_path"]; });
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // invoice header
            Container(
              height: size.height * 0.3,
              width: size.width,
              color: kPrimaryColor,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04,),
                  Text("Goods Issue Product Details", style: TextStyle(fontSize: size.width * 0.05, color: Colors.white),),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.3,
                        child: isLoading ? 
                          const Center(child: CircularProgressIndicator()) : 
                          productImagePath == null ? 
                          Image.asset("assets/images/blank_image.png", width: size.width * 0.3) : 
                          Image.file(File(productImagePath!), fit: BoxFit.cover,)
                      ),
                      SizedBox(
                        width: size.width * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.product.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text(widget.product.modelNumber,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            Text("Qty: ${widget.product.quantity}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                            SizedBox(height: size.height * 0.01,),
                            // Wrap the scanned and pending qty fields in an Obx widget:
                            Obx(() {
                              // Calculate the current count from your reactive map.
                              final scannedCount = stockTransferController.scannedSerials[widget.product.itemCode]?.length ?? 0;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10),
                                  Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  Text("Pending Qty: ${widget.product.quantity - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
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
              height: size.height * 0.6,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      // Convert Set to List for indexing
                      final serialList = stockTransferController.scannedSerials[widget.product.itemCode]?.toList() ?? [];
                      return ListView.builder(
                        itemCount: serialList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text("${index + 1}"),
                            title: Text(serialList[index]),
                            trailing: IconButton(onPressed: (){ stockTransferController.removeProductSerialNumber(widget.product.itemCode, serialList[index]); }, icon: const Icon(Icons.delete, color: Colors.red,)),
                          );
                        },
                      );
                    }),
                  )
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02,),
            RoundedButton(
              btnText: "Save", 
              press: (){
                if(stockTransferController.scannedSerials.isEmpty){
                  dynamicMaster.displayError(context, "Error", "No scanned serials found");
                  return;
                }else{
                  Navigator.pop(context);
                }
              },
              btnColor: kSecondaryColor, 
              textColor: kPrimaryLightColor
            )
          ],
        )
      ),
    );
  }
}