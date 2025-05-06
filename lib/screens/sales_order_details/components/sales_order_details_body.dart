import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../db/database_helper.dart';
import '../../../modals/printer_layout_modal.dart';
import '../../../modals/sales_order_details_modal.dart';
import '../../../modals/showroom_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'sale_order_product_card.dart';

class SalesOrderDetailsBody extends StatefulWidget {
  final String salesOrderNumber;
  const SalesOrderDetailsBody({super.key, required this.salesOrderNumber});

  @override
  State<SalesOrderDetailsBody> createState() => _SalesOrderDetailsBodyState();
}

class _SalesOrderDetailsBodyState extends State<SalesOrderDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isLoading = false;

  SalesOrderDetailsModal? salesOrderDetailsObj;
  
  List<PrinterLayoutModal> printerLayoutList = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    fetchSalesOrderDetails();
  }

  Future<void> fetchSalesOrderDetails() async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getSalesOrderDetails(widget.salesOrderNumber.toString(), token);

      if (response["status"] == "success" && response["data"].length > 0) {
        salesOrderDetailsObj = salesOrderDetailsModalFromJson(jsonEncode(response["data"][0]));
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred: $e");
    }
    setState(() { isLoading = false; });
  }

  Future<void> saleOrderUpdateDialog() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.close),
    );

    TextEditingController inputReceiptNumberController = TextEditingController();

    // Variable to hold the captured image.
    XFile? _capturedImage;

    return showDialog(
      context: context,
      builder: (context) {
        // Using StatefulBuilder to allow state updates (e.g., updating image preview).
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                // Increase the height to accommodate the image preview.
                height: size.height * 0.6,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top row with the logo and close button.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/images/azone.png",
                            height: 50,
                            width: 50,
                          ),
                          closeButtonWidget,
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Update Sales Order",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 10, thickness: 1),
                      SizedBox(height: size.height * 0.02),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Receipt number input.
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  "Enter Receipt Number:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "*",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Receipt Number (required)',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1, color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.5, color: kPrimaryColor),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              controller: inputReceiptNumberController,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // Button to take a photo.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ImagePicker _picker = ImagePicker();
                                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                                if (photo != null) {
                                  setState(() {
                                    _capturedImage = photo;
                                  });
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Take Photo"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor, // Button background color
                                foregroundColor: Colors.white,  // Button text color
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          // Image preview (if a photo has been captured).
                          if (_capturedImage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Image.file(
                                  File(_capturedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          SizedBox(height: size.height * 0.02),
                          // Your existing Print button.
                          Center(
                            child: RoundedButton(
                              btnText: "Update Order",
                              press: () {
                                Navigator.pop(context);
                                uploadSaleOrderData(inputReceiptNumberController.text, _capturedImage);
                              },
                              btnColor: kSecondaryColor,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  /// Uploads sale order data including receipt number and an optional image to the backend API.
  /// 
  /// [receiptNumber] - The receipt number as a String.
  /// [capturedImage] - The image captured via the camera, or null if no image is available.
  Future<void> uploadSaleOrderData(String receiptNumber, XFile? capturedImage) async {
    
    // Prepare the JSON payload.
    Map<String, dynamic> payload = {
      "receiptNumber": receiptNumber,
      "salesOrderNumber": salesOrderDetailsObj!.saleOrderNumber.toString(),
    };

    // If an image was captured, read its bytes and encode as a Base64 string.
    if (capturedImage != null) {
      final bytes = await capturedImage.readAsBytes();
      final String base64Image = base64Encode(bytes);
      payload["imageData"] = base64Image;
    }

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      dynamicMaster.displayLoadingModal(context);

      var response = await  apiService.processSalesOrderUpdate(token, payload);

      Navigator.pop(context);

      if (response["status"] == "success" && response["data"].length > 0) {
        dynamicMaster.displaySuccessMessage(context, response["message"]);
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred: $e");
    }
  }

  Future<void> processPrintRequest(int layoutId) async {

    if (salesOrderDetailsObj == null) {
      dynamicMaster.displayError(context, "Error", "No sales order details found.");
      return;
    }

    var token = await sessionProvider.authProvider.token;

    // Ensure token is not null
    if (token == null) {
      dynamicMaster.displayError(context, "Error", "No valid session token.");
      return;
    }

    ShowroomModal? showroomDetails = await _dbHelper.getShowroom();

    try {
      Map<String, dynamic> filters = {};

      filters["layout_id"] = layoutId.toString();
      filters["printer_type_id"] = 3.toString();
      filters["showroom_id"] = showroomDetails?.showroom_id.toString();
      filters["documentNumber"] = widget.salesOrderNumber;
      filters["documentType"] = "sales_note";
      
      dynamicMaster.displayLoadingModal(context);
    
      var response = await apiService.processDocumentPrint(token, filters);
      
      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, "Print successful");
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "Failed to print: $e");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
      child: isLoading ? 
      const Center(child: CircularProgressIndicator()) :
      salesOrderDetailsObj == null ?
      const Center(child: Text("Sales order details found.")) :
      SingleChildScrollView(
        child: Column(
          children: [
            
            Container(
              height: size.height * 0.3,
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
                                Text("Sales Order No: ${salesOrderDetailsObj!.saleOrderNumber.toString()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(DateFormat('dd-MMMM-yyyy').format(salesOrderDetailsObj!.documentDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(salesOrderDetailsObj!.docTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                              width: size.width * 0.1,
                              child: salesOrderDetailsObj!.documentStatus == "C" ?
                              Image.asset("assets/icons/padlock.png") :
                              Image.asset("assets/icons/open-lock43.png"),
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
                                "Created By: ${salesOrderDetailsObj!.servedBy}", 
                                softWrap: true, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Customer Info",
                                  style: TextStyle(letterSpacing: sqrt1_2, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: size.height * 0.01,),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(salesOrderDetailsObj!.customerName.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(salesOrderDetailsObj!.customerPhone.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
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

            // invoice items
            SizedBox(
              height: size.height * 0.6,
              width: size.width,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          saleOrderUpdateDialog();
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add),
                            Text("Update Order"),
                          ],
                        )
                      ),
                      ElevatedButton(
                        onPressed: () { 
                          processPrintRequest(4);
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.print),
                            Text("Print Order"),
                          ],
                        ),
                      ),

                    ],
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: salesOrderDetailsObj!.lineItems.length,
                      itemBuilder: (context, index) {
                        return SaleOrderProductCard(lineItem: salesOrderDetailsObj!.lineItems[index],);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}