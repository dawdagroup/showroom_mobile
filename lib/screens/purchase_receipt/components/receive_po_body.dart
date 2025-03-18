import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../controllers/po_controller.dart';
import '../../../modals/purchase_order_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'purchase_order_card.dart';

class ReceivePoBody extends StatefulWidget {
  final PurchaseOrderDetailsModal purchaseOrderDetailsObj;
  const ReceivePoBody({super.key, required this.purchaseOrderDetailsObj});

  @override
  State<ReceivePoBody> createState() => _ReceivePoBodyState();
}

class _ReceivePoBodyState extends State<ReceivePoBody> {
  final PurchaseOderController purchaseOderController = Get.put(PurchaseOderController());

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Set the purchase order number in the controller.
    purchaseOderController.purchaseOrderNumber.value = widget.purchaseOrderDetailsObj.documentNumber.toString();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    purchaseOderController.loadScans();
  }

  Future<void> submitPurchaseOrder() async {
    //
    // getCartDetails();
    try {
      dynamicMaster.displayLoadingModal(context);

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var cartDetails = await purchaseOderController.getCartDetails();

      // Ensure cart details is not null
      if (cartDetails.isEmpty) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No scanned serials found.");
        setState(() { isLoading = false; });
        return;
      }
      
      final Map<String, dynamic> queryParameters = {
        "productSerial": cartDetails,
        "poNumber": widget.purchaseOrderDetailsObj.documentNumber.toString(),
      };

      var response = await apiService.processPurchaseOrderReceipt(token, queryParameters);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, response["message"]);
        purchaseOderController.clearCart();

        // wait 2 second then navigate to password update screen
        await Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/receive_goods');
        });
      }else{
        dynamicMaster.displayError(context, "Error", response["message"] ?? "Failed to submit invoice delivery");
      }
      
    } catch (e) {
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
              height: size.height * 0.25,
              width: size.width,
              color: kPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01,),
                    const Text("Purchase Receipt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("Po No: ${widget.purchaseOrderDetailsObj.documentNumber.toString()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text(DateFormat('dd-MMMM-yyyy').format(widget.purchaseOrderDetailsObj.documentDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("Supplier: ${widget.purchaseOrderDetailsObj.cardName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.65,
              width: size.width,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.purchaseOrderDetailsObj.lineItems.length,
                      itemBuilder: (context, index) {
                        if (widget.purchaseOrderDetailsObj.lineItems[index].itemOpenQuantity <= 0) {
                          return Container();
                        }
                        return PurchaseOrderCard(purchaseOrderLineItem: widget.purchaseOrderDetailsObj.lineItems[index],);
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
                if(purchaseOderController.scannedSerials.isEmpty){
                  dynamicMaster.displayError(context, "Error", "No scanned serials found");
                }else{
                  submitPurchaseOrder();
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