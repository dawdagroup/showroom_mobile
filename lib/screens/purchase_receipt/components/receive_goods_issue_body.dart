import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../controllers/goods_issue_controller.dart';
import '../../../modals/goods_issue_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'goods_issue_product_card.dart';

class ReceiveGoodsIssueBody extends StatefulWidget {
  final GoodsIssueDetailsModal goodsIssueDetailsObj;
  const ReceiveGoodsIssueBody({super.key, required this.goodsIssueDetailsObj});

  @override
  State<ReceiveGoodsIssueBody> createState() => _ReceiveGoodsIssueBodyState();
}

class _ReceiveGoodsIssueBodyState extends State<ReceiveGoodsIssueBody> {
  final GoodsIssueController goodsIssueController = Get.put(GoodsIssueController());

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Set the goods issue number in the controller.
    goodsIssueController.goodsIssueNumber.value = widget.goodsIssueDetailsObj.documentNumber.toString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    goodsIssueController.loadScans();
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

      var cartDetails = await goodsIssueController.getCartDetails();

      // Ensure cart details is not null
      if (cartDetails.isEmpty) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No scanned serials found.");
        setState(() { isLoading = false; });
        return;
      }
      
      final Map<String, dynamic> queryParameters = {
        "productSerial": cartDetails,
        "goodsIssueNumber": widget.goodsIssueDetailsObj.documentNumber.toString(),
      };

      var response = await apiService.processGoodsIssueReceipt(token, queryParameters);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, response["message"]);
        goodsIssueController.clearScans();

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
                    const Text("Goods Issue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("Doc No: ${widget.goodsIssueDetailsObj.documentNumber.toString()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text(DateFormat('dd-MMMM-yyyy').format(widget.goodsIssueDetailsObj.documentDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kPrimaryLightColor),),
                    SizedBox(height: size.height * 0.01,),
                    Text("Supplier: ${widget.goodsIssueDetailsObj.cardName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryLightColor),),
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
                      itemCount: widget.goodsIssueDetailsObj.lineItems.length,
                      itemBuilder: (context, index) {
                        if (widget.goodsIssueDetailsObj.lineItems[index].itemOpenQuantity <= 0) {
                          return Container();
                        }
                        return GoodsIssueProductCard(goodsIssueDetailsLineItem: widget.goodsIssueDetailsObj.lineItems[index],);
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
                if(goodsIssueController.scannedSerials.isEmpty){
                  dynamicMaster.displayError(context, "Error", "No scanned serials found");
                }else{
                  submitGoodsIssue();
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