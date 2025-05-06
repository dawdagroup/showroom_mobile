import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../db/database_helper.dart';
import '../../../modals/customer_points_modal.dart';
import '../../../modals/invoice_details_modal.dart';
import '../../../modals/payment_details_modal.dart';
import '../../../modals/printer_address_modal.dart';
import '../../../modals/printer_layout_modal.dart';
import '../../../modals/showroom_modal.dart';
import '../../../modals/transaction_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/printer_service.dart';
import 'invoice_details_product_card.dart';

class InvoiceDetailsBody extends StatefulWidget {
  final String invoiceNumber;
  const InvoiceDetailsBody({super.key, required this.invoiceNumber});

  @override
  State<InvoiceDetailsBody> createState() => _InvoiceDetailsBodyState();
}

class _InvoiceDetailsBodyState extends State<InvoiceDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isLoading = false;

  InvoiceDetailsModal? invoiceDetailsObj;
  List<PrinterLayoutModal> printerLayoutList = [];
  List<TransactionModal> loyaltyTransactionList = [];

  CustomerPointsModal?  customerPoints;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    fetchInvoiceDetails();

    fetchPrinterLayouts();

    fetchLoyaltyTransaction();

  }

  Widget _buildActionButton(){
    if (invoiceDetailsObj!.invoiceStatus == "C"){   
      return RoundedButton(btnText: "View Delivery Note", press: () {
        Navigator.pushNamed(context, "/delivery_details", arguments: invoiceDetailsObj!.invoiceNumber.toString());
      },  btnColor: kPrimaryColor, textColor: Colors.white );
    }
    return const SizedBox();
  }

  Future<void> fetchInvoiceDetails() async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getInvoiceDetails(widget.invoiceNumber.toString(), token);

      if (response["status"] == "success" && response["data"].length > 0) {
        invoiceDetailsObj = invoiceDetailsModalFromJson(jsonEncode(response["data"][0]));
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred: $e");
    }
    setState(() { isLoading = false; });
  }

  Future<void> fetchPrinterLayouts() async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getPrinterLayouts(token);

      if (response["status"] == "success" && response["data"].length > 0) {
        for (var data in response["data"]) {
          PrinterLayoutModal printerLayout = printerLayoutModalFromJson(jsonEncode(data));
          printerLayoutList.add(printerLayout);
        }
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred: $e");
    }
    setState(() { isLoading = false; });
  }

  Future<void> fetchLoyaltyTransaction() async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      Map<String, dynamic> filters = {};

      filters["invoice_number"] = widget.invoiceNumber.toString();

      var response = await  apiService.filterLoyaltyTransaction(token, filters);

      if (response["status"] == "success" && response["data"].length > 0) {
        for (var data in response["data"]) {
          TransactionModal transactionModal = transactionModalFromJson(jsonEncode(data));
          loyaltyTransactionList.add(transactionModal);
        }

        // fetch customer points

        var customerPointsResponse = await apiService.getCustomerLoyaltyPoints(token, loyaltyTransactionList[0].customerId.toString());

        if (customerPointsResponse["status"] == "success" && customerPointsResponse["data"].length > 0) {
          customerPoints = customerPointsModalFromJson(jsonEncode(customerPointsResponse["data"][0]));
        }

      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred: $e");
    }
    setState(() { isLoading = false; });
  }

  Future<void> printInvoiceDialoge() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    TextEditingController inputLayoutController = TextEditingController();

    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                height: size.height * 0.4,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/azone.png", height: 50, width: 50,),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Print Invoice", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          Row(
                            children: [
                              const Text("Select Layout:", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: size.width * 0.01,),
                              const Text("*", style: TextStyle(color: Colors.red),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          SizedBox(
                            width: size.width * 0.8,
                            child: DropdownButton<PrinterLayoutModal>(
                              value: printerLayoutList.firstWhereOrNull(
                                (element) => element.id.toString() == inputLayoutController.text,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              hint: const Text("Select Layout"),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (PrinterLayoutModal? newValue) {
                                setState(() {
                                  inputLayoutController.text = newValue?.id.toString() ?? '';
                                });
                              },
                              items: printerLayoutList.map((value) {
                                return DropdownMenuItem<PrinterLayoutModal>(
                                  value: value,
                                  child: Text(value.name),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02,),
                          RoundedButton(
                            btnText: "Print", 
                            press: () { 
                              Navigator.pop(context); 
                              processPrintRequest(int.parse(inputLayoutController.text)); 
                            }, 
                            btnColor: kSecondaryColor, 
                            textColor: Colors.white
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Future<void> processPrintRequest(int layoutId) async {

    if (invoiceDetailsObj == null) {
      dynamicMaster.displayError(context, "Error", "No invoice details found.");
      return;
    }

    var token = await sessionProvider.authProvider.token;

    // Ensure token is not null
    if (token == null) {
      dynamicMaster.displayError(context, "Error", "No valid session token.");
      return;
    }
    
    ShowroomModal? showroomDetails = await _dbHelper.getShowroom();

    
    if(showroomDetails == null) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "No showroom details found.");
      return;
    }

    if (layoutId == 1) {
      try {

        Map<String, dynamic> filters = {};

        filters["showroom_id"] = showroomDetails.showroom_id.toString();
        filters["printer_type_id"] = 2.toString();

        var printerAddressResults = await apiService.getPrinterShowroomAddress(token, filters);

        if(printerAddressResults["status"] == "success"){
          PrinterAddressModal printerAddress = printerAddressModalFromJson(jsonEncode(printerAddressResults["data"][0]));

          var paymentDetails = await apiService.getInvoicePaymentDetails(token, invoiceDetailsObj!.invoiceNumber.toString());

          PaymentDetailsModal? paymentDetailsModal;

          if(paymentDetails["status"] == "success" && paymentDetails["data"].length > 0){
            paymentDetailsModal = paymentDetailsModalFromJson(jsonEncode(paymentDetails["data"][0]));
          }

          final printerService = PrinterService(printerIp: printerAddress.address);

          Map<String, String> pointsSummary = {};

          if(loyaltyTransactionList.isNotEmpty){
            double pointsEarned = 0;
            double pointsRedeemed = 0;
            double pointsBalance = customerPoints?.balancePoints ?? 0;
            for (var transaction in loyaltyTransactionList) {
              pointsEarned += transaction.pointsEarned;
              pointsRedeemed += transaction.pointsRedeemed;
            }

            pointsSummary["Points Earned"] = pointsEarned.toString();
            pointsSummary["Points Redeemed"] = pointsRedeemed.toString();
            pointsSummary["Points Balance"] = pointsBalance.toString();
          }else{
            pointsSummary["Points Earned"] = "0";
            pointsSummary["Points Redeemed"] = "0";
            pointsSummary["Points Balance"] = customerPoints?.balancePoints.toString() ?? "0";
          }

          await printerService.printReceipt(invoiceDetailsObj!, pointsSummary, paymentDetailsModal);

          dynamicMaster.displaySuccessMessage(context, "Print successful");
        }else{
          dynamicMaster.displayError(context, "Error", printerAddressResults["message"]);
        }
      } catch (e) {
        dynamicMaster.displayError(context, "Error", "Failed to print: $e");
      }
    } else if(layoutId == 5){
      // redirect to pdf viewer
      Navigator.pushNamed(context, "/pdf_view", arguments: {
        "documentType": "invoice",
        "documentNumber": widget.invoiceNumber.toString(),
        "printerTypeId": 3,
        "layoutId": 5,
        "showroomId": showroomDetails.showroom_id.toString()
      });
    }else{
      
      try {
        Map<String, dynamic> filters = {};

        filters["layout_id"] = layoutId.toString();
        filters["printer_type_id"] = 3.toString();
        filters["showroom_id"] = showroomDetails.showroom_id.toString();
        filters["documentNumber"] = invoiceDetailsObj!.invoiceNumber.toString();
        filters["documentType"] = "invoice";
        
        var response = await apiService.processDocumentPrint(token, filters);

        if(response["status"] == "success"){
          dynamicMaster.displaySuccessMessage(context, "Print successful");
        }else{
          dynamicMaster.displayError(context, "Error", response["message"]);
        }
      } catch (e) {
        dynamicMaster.displayError(context, "Error", "Failed to print: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: isLoading ? 
      const Center(child: CircularProgressIndicator()) :
      invoiceDetailsObj == null ?
      const Center(child: Text("Invoice details found.")) :
      SingleChildScrollView(
        child: Column(
          children: [
            // invoice header
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
                                Text("Invoice No: ${invoiceDetailsObj!.invoiceNumber.toString()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(DateFormat('dd-MMMM-yyyy').format(invoiceDetailsObj!.invoiceDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(invoiceDetailsObj!.invoiceTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                              width: size.width * 0.1,
                              child: invoiceDetailsObj!.invoiceStatus == "C" ?
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
                                "Created By: ${invoiceDetailsObj!.servedBy}", 
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
                                  child: Text(invoiceDetailsObj!.customerName.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(invoiceDetailsObj!.customerPhoneNo.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
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
                        onPressed: () {}, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add),
                            Text("Add Item"),
                          ],
                        )
                      ),
                      ElevatedButton(
                        onPressed: () { printInvoiceDialoge(); }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.print),
                            Text("Print Invoice"),
                          ],
                        ),
                      ),

                    ],
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: invoiceDetailsObj!.invoiceItems.length,
                      itemBuilder: (context, index) {
                        return InvoiceDetailsProductCard(invoiceItem: invoiceDetailsObj!.invoiceItems[index],);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02,),
            _buildActionButton()
          ],
        ),
      ),
    );
  }
}