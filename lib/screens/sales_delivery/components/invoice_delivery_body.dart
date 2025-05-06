import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';
import 'package:showroom_manager/constant/constants.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../controllers/invoice_delivery_controller.dart';
import '../../../modals/invoice_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'invoice_delivery_card.dart';

class InvoiceDeliveryBody extends StatefulWidget {
  final InvoiceDetailsModal invoiceDetailsObj;
  const InvoiceDeliveryBody({super.key, required this.invoiceDetailsObj});

  @override
  State<InvoiceDeliveryBody> createState() => _InvoiceDeliveryBodyState();
}

class _InvoiceDeliveryBodyState extends State<InvoiceDeliveryBody> {
  final InvoiceController invoiceController = Get.put(InvoiceController());

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Set the invoice number in the controller.
    invoiceController.invoiceNumber.value = widget.invoiceDetailsObj.invoiceNumber.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    invoiceController.loadScans();
  }

  Future<void> processInvoiceDevlivery() async{
    try{
      dynamicMaster.displayLoadingModal(context);

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var cartDetails = await invoiceController.getCartDetails();

      // Ensure cart details is not null
      if (cartDetails.isEmpty) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No scanned serials found.");
        setState(() { isLoading = false; });
        return;
      }

      final Map<String, dynamic> queryParameters = {
        "productSerial": cartDetails,
        "invoiceNumber": widget.invoiceDetailsObj.invoiceNumber.toString(),
      };

      var response = await apiService.processInvoiceDelivery(token, widget.invoiceDetailsObj.invoiceNumber.toString(), queryParameters);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, response["message"]);
        invoiceController.clearCart();

        // wait 2 second then navigate to sales deliveries screen
        await Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/sales_deliveries');
        });

      }else{
        dynamicMaster.displayError(context, "Error", response["message"] ?? "Failed to submit invoice delivery");
      }
    }catch(e){
      dynamicMaster.displayError(context, "Error", "Error: ${e.toString()}");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                                const Text("Invoice Delivery", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                                Text("Invoice No: ${widget.invoiceDetailsObj.invoiceNumber.toString()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                              ],
                            ),
                            Text(DateFormat('dd-MMMM-yyyy').format(widget.invoiceDetailsObj.invoiceDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
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
                                "Created By: ${widget.invoiceDetailsObj.servedBy}", 
                                softWrap: true, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Customer Info",
                                  style: TextStyle(letterSpacing: sqrt1_2, fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),
                                ),
                                SizedBox(height: size.height * 0.01,),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(widget.invoiceDetailsObj.customerName.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(widget.invoiceDetailsObj.customerPhoneNo.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
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
            SizedBox(
              height: size.height * 0.6,
              width: size.width,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.invoiceDetailsObj.invoiceItems.length,
                      itemBuilder: (context, index) {
                        return InvoiceDeliveryCard(invoiceItem: widget.invoiceDetailsObj.invoiceItems[index],);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02,),
            RoundedButton(
              btnText: "Submit", 
              press: (){
                if(invoiceController.scannedSerials.isEmpty){
                  dynamicMaster.displayError(context, "Error", "No scanned serials found");
                }else{
                  processInvoiceDevlivery();
                }
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