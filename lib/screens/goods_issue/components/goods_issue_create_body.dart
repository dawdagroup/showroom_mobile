import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../controllers/stock_transfer_controller.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'goods_issue_create_product_card.dart';

class GoodsIssueCreateBody extends StatefulWidget {
  final String transferNumber;
  const GoodsIssueCreateBody({super.key, required this.transferNumber});

  @override
  State<GoodsIssueCreateBody> createState() => _GoodsIssueCreateBodyState();
}

class _GoodsIssueCreateBodyState extends State<GoodsIssueCreateBody> {
  late final StockTransferController stockTransferController;

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  
  bool isLoading = false;

  StockTransferDetailsModal? stockTransferDetailsModal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    stockTransferController = Get.put(StockTransferController(), tag: widget.transferNumber);
    stockTransferController.stockTransferNumber.value = widget.transferNumber;
  }
  
  @override
  void didChangeDependencies() {  
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getStockTransferDetails();

    stockTransferController.loadScans();
  }
  
  @override
  void dispose() {
    // Clean up the tagged controller when the widget is disposed
    Get.delete<StockTransferController>(tag: widget.transferNumber);
    super.dispose();
  }
  
  Future<void> getStockTransferDetails() async {
    setState(() { isLoading = true;});
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await apiService.getStockTransferDetails(token, widget.transferNumber);

      if(response["status"] == "success"){
        stockTransferDetailsModal = stockTransferDetailsModalFromJson(jsonEncode(response["data"][0]));
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false; });
  }

  Future<void> submitGoodsIssue() async {
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

      var cartDetails = await stockTransferController.getCartDetails();

      // Ensure cart details is not null
      if (cartDetails.isEmpty) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No scanned serials found.");
        setState(() { isLoading = false; });
        return;
      }
      
      final Map<String, dynamic> queryParameters = {
        "productSerial": cartDetails,
        "stockTransferNumber": widget.transferNumber,
      };

      var response = await apiService.processStockTransferGoodsIssue(token, queryParameters);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, response["message"]);
        Get.back();
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
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
      ? const Center(child: CircularProgressIndicator(color: kPrimaryColor,))
      : stockTransferDetailsModal == null
      ? const Center(child: Text("No data found", style: TextStyle(color: kPrimaryColor, fontSize: 20),))
      :  SingleChildScrollView(
        child: Column(
          children: [
            // invoice header
            Container(
              height: size.height * 0.27,
              width: size.width,
              color: kPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.transferNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                        const Text("Goods Issue Form", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01,),
                    Text(DateFormat('dd-MMMM-yyyy').format(stockTransferDetailsModal!.transferDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("From: ${stockTransferDetailsModal!.fromWarehouseName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("To: ${stockTransferDetailsModal!.toWarehouseName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
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
                      itemCount: stockTransferDetailsModal!.products.length,
                      itemBuilder: (context, index) {
                        return GoodsIssueCreateProductCard(
                          product: stockTransferDetailsModal!.products[index],
                          transferNumber: widget.transferNumber,
                        );
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
                if(stockTransferController.scannedSerials.isEmpty){
                  dynamicMaster.displayError(context, "Error", "No scanned serials found");
                  return;
                }
                submitGoodsIssue();
                
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