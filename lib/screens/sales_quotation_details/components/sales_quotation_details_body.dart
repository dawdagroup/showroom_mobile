import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';

import '../../../config/config.dart';
import '../../../constant/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../components/rounded_buttons.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../db/database_helper.dart';
import '../../../modals/printer_layout_modal.dart';
import '../../../modals/sale_quotation_invoice_modal.dart';
import '../../../modals/sales_quotation_details_modal.dart';
import '../../../modals/sales_quotation_request_modal.dart';
import '../../../modals/showroom_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'sales_quotation_details_product_card.dart';

class SalesQuotationDetailsBody extends StatefulWidget {
  final String salesQuotationNo;
  const SalesQuotationDetailsBody({super.key, required this.salesQuotationNo});

  @override
  State<SalesQuotationDetailsBody> createState() => _SalesQuotationDetailsBodyState();
}

class _SalesQuotationDetailsBodyState extends State<SalesQuotationDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  SalesQuotationDetailsModal? salesQuotationDetailsModal;
  SalesQuotationRequestModal? salesQuotationRequestModal;
  SaleQuotationInvoiceModal? saleQuotationInvoiceModal;
  List<PrinterLayoutModal> printerLayoutList = [];
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getSaleQuoteInvoiceNumber();

    getSalesQuotationDetails();

    fetchPrinterLayouts();
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

      Map<String, dynamic> filters = {
        "document_name": "sale_quote", // Assuming 3 is the printer type ID for sales quotations
      };

      var response = await  apiService.getPrinterLayouts(filters, token);

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

  Future<void> getSalesQuotationDetails() async {
    
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getSalesQuotationDetails(widget.salesQuotationNo, token);

      if (response["status"] == "success") {
        salesQuotationDetailsModal = salesQuotationDetailsModalFromJson(jsonEncode(response["data"]));

        if (salesQuotationDetailsModal!.salesOrderStatus == "O"){
          // TODO: Add logic search for approval request

          var approvalRequestsResponse = await apiService.getSalesQuotationApprovalRequests(token, widget.salesQuotationNo);

          if (approvalRequestsResponse["status"] == "success") {
            salesQuotationRequestModal = salesQuotationRequestModalFromJson(jsonEncode(approvalRequestsResponse["data"][0]));
          }
        }
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      print(e);
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getSaleQuoteInvoiceNumber() async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.getSalesQuotationInvoiceNumber(widget.salesQuotationNo, token);

      if (response["status"] == "success" && response["data"] != null) {
        saleQuotationInvoiceModal = saleQuotationInvoiceModalFromJson(jsonEncode(response["data"][0]));
      }
      
    } catch (e) {
      print(e);
    }
    setState(() { isLoading = false; });
  }

  Widget _buildActionButton() {
    if (salesQuotationDetailsModal!.salesOrderStatus == "C"){
      // get invoice notification
      if (saleQuotationInvoiceModal == null) {
        return const Text("No invoice found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),);
      }

      return RoundedButton(btnText: "View Invoice", press: () {
        Navigator.pushNamed(context, "/invoice_details", arguments: saleQuotationInvoiceModal!.invoiceNumber.toString());
      },  btnColor: kPrimaryColor, textColor: Colors.white );
    } else if (salesQuotationDetailsModal!.salesOrderStatus == "O" && (salesQuotationRequestModal != null && salesQuotationRequestModal!.approvalStatus == "pending")) {
      return const Text("Approval Request Pending", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),);
    } else if (salesQuotationDetailsModal!.salesOrderStatus == "O" && (salesQuotationRequestModal != null && salesQuotationRequestModal!.approvalStatus == "rejected")) {
      return Column(
        children: [
          const Text("Approval Request Rejected", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),),
          Text(salesQuotationRequestModal!.approvalComment.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),),
        ],
      );
    } else if (salesQuotationDetailsModal!.salesOrderStatus == "O" && (salesQuotationRequestModal != null && salesQuotationRequestModal!.approvalStatus == "approved" || salesQuotationRequestModal == null)) {
      return RoundedButton(btnText: "Convert to Invoice",  press: () {
        Navigator.pushNamed(context, "/convert_to_invoice_checkout", arguments: salesQuotationDetailsModal);
      }, btnColor: kSecondaryColor, textColor: Colors.white);
    }
    return const SizedBox();
  }

  Future<void> printSalesQuotationDialog() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    TextEditingController inputLayoutController = TextEditingController();
    // TextEditingController inputEmailController = TextEditingController();

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
                      const Text("Print Quotation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                            btnText: "Submit", 
                            press: () { 
                              Navigator.pop(context);
                              submitSalesQuotationPrintRequest(inputLayoutController.text); 
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

  Future<void> submitSalesQuotationPrintRequest(String layout) async {

    dynamicMaster.displayLoadingModal(context);

    if (salesQuotationDetailsModal == null) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "No invoice details found.");
      return;
    }

    var token = await sessionProvider.authProvider.token;

    // Ensure token is not null
    if (token == null) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "No valid session token.");
      return;
    }
    
    ShowroomModal? showroomDetails = await _dbHelper.getShowroom();

    if(showroomDetails == null) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "No showroom details found.");
      return;
    }

    if(layout.isEmpty) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "Please select a layout.");
      return;
    }
    
    if(layout == "5"){
      // redirect to pdf viewer
      Navigator.pushNamed(context, "/pdf_view", arguments: {
        "documentType": "sales_quote",
        "documentNumber": widget.salesQuotationNo,
        "printerTypeId": 3,
        "layoutId": 5,
        "showroomId": showroomDetails.showroom_id.toString()
      });
    }else{

      try {
        Map<String, dynamic> filters = {};

        filters["layout_id"] = layout;
        filters["printer_type_id"] = layout;
        filters["showroom_id"] = showroomDetails.showroom_id.toString();
        filters["documentNumber"] = widget.salesQuotationNo;
        filters["documentType"] = "sales_quote";
        
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
  }
  
  Future<void> displayPaymentMeansDialoge() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));
    
    List<FocusNode> listFocusNodes = List.generate(10,(index) => FocusNode(),);

    TextEditingController mpesaRefNumberController = TextEditingController();
    TextEditingController mpesaAmountPaidController = TextEditingController();
    TextEditingController creditCardAmountPaidController = TextEditingController();
    TextEditingController creditCardOptionController = TextEditingController();
    TextEditingController cashPaymentAmountPaidController = TextEditingController();
    
    List<String> creditCardPaymentOptions = ["Credit Card","Pesapal"];

    bool isPaymentOptionHasErrors = false;

    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                height: size.height * 0.5,
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
                      const Text("Payment Means", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          Column(
                            children: [
                              DefaultTabController(
                                length: 3,
                                child: Column(
                                  children: [
                                    const TabBar(
                                      tabs: [
                                        Tab(
                                          child: Text(
                                            "M-Pesa",
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Card",
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Cash",
                                            style: TextStyle(
                                              color: Colors.black
                                            ),
                                          ),
                                        ),
                                        
                                      ]
                                    ),
                                    SizedBox(
                                      height: size.height * 0.25,
                                      child: TabBarView(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: size.height *0.02,),
                                              TextField(
                                                focusNode: listFocusNodes[0],
                                                keyboardType: TextInputType.text,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                                decoration: const InputDecoration(
                                                  labelText: 'M-Pesa Ref Number',
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey
                                                    )
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.5,
                                                      color: kPrimaryColor
                                                    )
                                                  ),
                                                ),
                                                controller: mpesaRefNumberController,
                                              ),
                                              SizedBox(height: size.height * 0.02,),
                                              TextField(
                                                focusNode: listFocusNodes[1],
                                                keyboardType: TextInputType.number,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                                decoration: const InputDecoration(
                                                  labelText: 'Amount Paid',
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey
                                                    )
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.5,
                                                      color: kPrimaryColor
                                                    )
                                                  ),
                                                ),
                                                controller: mpesaAmountPaidController,
                                                onChanged: (value){
                                                  // calculatePaymentBalance();
                                                },
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(height: size.height *0.02,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: isPaymentOptionHasErrors ? Colors.red : Colors.grey,
                                                    width: 1.0
                                                  ),
                                                  borderRadius: BorderRadius.circular(5)
                                                ),
                                                child: DropdownButton<String>(
                                                  focusNode: listFocusNodes[2],
                                                  items: creditCardPaymentOptions.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    if(value != null){
                                                      setState(() {
                                                        isPaymentOptionHasErrors = false;
                                                        creditCardOptionController.text = value;
                                                      });
                                                    }
                                                  },
                                                  value: creditCardOptionController.text.isEmpty ? null : creditCardOptionController.text,
                                                  isExpanded: true,
                                                  hint: const Text("Select Credit Card Option"),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                                                  underline: Container(),
                                                ),
                                              ),
                                              SizedBox(height: size.height * 0.02,),
                                              TextField(
                                                focusNode: listFocusNodes[3],
                                                keyboardType: TextInputType.number,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                                decoration: const InputDecoration(
                                                  labelText: 'Amount Paid',
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey
                                                    )
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.5,
                                                      color: kPrimaryColor
                                                    )
                                                  ),
                                                ),
                                                controller: creditCardAmountPaidController,
                                                onChanged: (value){
                                                  // calculatePaymentBalance();
                                                },
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(height: size.height *0.02,),
                                              TextField(
                                                focusNode: listFocusNodes[4],
                                                keyboardType: TextInputType.number,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                                ),
                                                decoration: const InputDecoration(
                                                  labelText: 'Amount Paid',
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    color: kPrimaryColor,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1,
                                                      color: Colors.grey
                                                    )
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.5,
                                                      color: kPrimaryColor
                                                    )
                                                  ),
                                                ),
                                                controller: cashPaymentAmountPaidController,
                                                onChanged: (value){
                                                  // calculatePaymentBalance();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: (){
                              Navigator.pop(context);

                            }, 
                            child: Text("Cancel"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              Navigator.pop(context);
                              double mpesaAmount = mpesaAmountPaidController.text.isEmpty ? 0 : double.parse(mpesaAmountPaidController.text);
                              double creditCardAmount = creditCardAmountPaidController.text.isEmpty ? 0 : double.parse(creditCardAmountPaidController.text);
                              double cashAmount = cashPaymentAmountPaidController.text.isEmpty ? 0 : double.parse(cashPaymentAmountPaidController.text);
                              
                              processSalesquoteToInvoice(mpesaRefNumberController.text, mpesaAmount, creditCardOptionController.text, creditCardAmount, cashAmount);

                            }, 
                            child: Text("Submit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                          )
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

  void processSalesquoteToInvoice(String mpesaRefNumber, double mpesaAmountPaid, String creditCardOption, double creditCardAmountPaid, double cashPaymentAmountPaid) async {
    var token = await sessionProvider.authProvider.token;

    // Ensure token is not null
    if (token == null) {
      dynamicMaster.displayError(context, "Error", "No valid session token.");
      return;
    }

    double totalAmountPaid = mpesaAmountPaid + creditCardAmountPaid + cashPaymentAmountPaid;

    if (totalAmountPaid < salesQuotationDetailsModal!.salesOrderTotal) {
      dynamicMaster.displayError(context, "Error", "Amount paid is less than the total amount.");
      return;
    }

    if((totalAmountPaid - salesQuotationDetailsModal!.salesOrderTotal) > 1000){
      dynamicMaster.displayError(context, "Error", "Amount paid cannot  be more than ${Config.defaultCurrency} 1000.");
      return;
    }

    ShowroomModal? showroomDetails = await _dbHelper.getShowroom();

    try {
      Map<String, dynamic> filters = {};

      filters["sales_quote_no"] = salesQuotationDetailsModal!.salesOrderId.toString();
      filters["mpesa_ref_number"] = mpesaRefNumber;
      filters["mpesa_amount_paid"] = mpesaAmountPaid;
      filters["credit_card_option"] = creditCardOption;
      filters["credit_card_amount_paid"] = creditCardAmountPaid;
      filters["cash_payment_amount_paid"] = cashPaymentAmountPaid;
      filters["showroom_id"] = showroomDetails?.showroom_id.toString();

      dynamicMaster.displayLoadingModal(context);
      
      var response = await apiService.processSalesQuoteToInvoice(token, filters);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, "Invoice created successfully");
        Navigator.pushNamed(context, "/sales_quotation_details", arguments: widget.salesQuotationNo);
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "Failed to create invoice: $e");
    }


  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: isLoading ? const Center(child: CircularProgressIndicator()) : salesQuotationDetailsModal == null ? const Center(child: Text("No data found.")) : 
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
                                Text("Quotation No: ${salesQuotationDetailsModal!.salesOrderRef.toString()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(DateFormat('dd-MMMM-yyyy').format(salesQuotationDetailsModal!.salesOrderDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(salesQuotationDetailsModal!.salesOrderTotal), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                              width: size.width * 0.1,
                              child: salesQuotationDetailsModal!.salesOrderStatus == "C" ?
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
                                "Created By: ${salesQuotationDetailsModal!.createdBy}", 
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
                                  child: Text(salesQuotationDetailsModal!.customerName.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(salesQuotationDetailsModal!.customerPhoneNumber.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                              ],
                            )
                            
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ),
            SizedBox(
              height: size.height * 0.6,
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
                        onPressed: () { printSalesQuotationDialog(); }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.print),
                            Text("Print Quotation"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: salesQuotationDetailsModal!.lineItems.length,
                      itemBuilder: (context, index) {
                        return SalesQuotationDetailsProductCard(salesQuotationLineItemModal: salesQuotationDetailsModal!.lineItems[index]);
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