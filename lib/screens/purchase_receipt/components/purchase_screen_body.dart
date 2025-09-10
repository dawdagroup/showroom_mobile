import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../modals/goods_issue_details_modal.dart';
import '../../../modals/purchase_order_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class PurchaseScreenBody extends StatefulWidget {
  const PurchaseScreenBody({super.key});

  @override
  State<PurchaseScreenBody> createState() => _PurchaseScreenBodyState();
}

class _PurchaseScreenBodyState extends State<PurchaseScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  
  List<String> documentTypeList = ["Purchase Order","Goods Receipt"];
  bool isDocumentTypeOptionHasErrors = false;
  TextEditingController documentTypeOptionController = TextEditingController();
  TextEditingController documentNumberController = TextEditingController();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

  }

  Future<void> processDocumentQuery() async {

    dynamicMaster.displayLoadingModal(context);

    try{
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        Navigator.pop(context);
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      if(documentTypeOptionController.text == "Purchase Order"){
        var response = await apiService.getPurchaseOrderDetails(documentNumberController.text, token);
        Navigator.pop(context);

        if(response["status"] == "success" && response["data"] != null){
          var purchaseOrderObj = purchaseOrderDetailsModalFromJson(jsonEncode(response["data"][0]));

          if(purchaseOrderObj.documentStatus == "C"){
            dynamicMaster.displayError(context, "Error", "Purchase Order has already been closed");
            return;
          }

          Navigator.pushNamed(context, "/receive_po", arguments: purchaseOrderObj);
        }else{
          dynamicMaster.displayError(context, "Error", response["message"]);
        }
      }else{
        var response = await apiService.getGoodsIssueDetails(documentNumberController.text, token);
        Navigator.pop(context);

        if(response["status"] == "success" && response["data"] != null){
          var goodsIssueObject = goodsIssueDetailsModalFromJson(jsonEncode(response["data"][0]));

          if(goodsIssueObject.documentStatus == "C"){
            dynamicMaster.displayError(context, "Error", "Goods Issue has already been closed");
            return;
          }

          Navigator.pushNamed(context, "/receive_goods_issue", arguments: goodsIssueObject);
        }else{
          dynamicMaster.displayError(context, "Error", response["message"]);
        }
      }

    }catch(e){
      
      print(e);
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "An error occurred");
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.9,
      width: size.width,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.3,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDocumentTypeOptionHasErrors ? Colors.red : Colors.grey,
                    width: 1.0
                  ),
                  borderRadius: BorderRadius.circular(5),
          
                ),
                child: DropdownButton<String>(
                  items: documentTypeList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if(value != null){
                      setState(() {
                        isDocumentTypeOptionHasErrors = false;
                        documentTypeOptionController.text = value;
                      });
                    }
                  },
                  value: documentTypeOptionController.text.isEmpty ? null : documentTypeOptionController.text,
                  isExpanded: true,
                  hint: const Text("Select Document Type"),
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
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
                decoration: const InputDecoration(
                  labelText: 'Enter Document Number',
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
                controller: documentNumberController,
              ),
              SizedBox(height: size.height * 0.02,),
              RoundedButton(
                btnText: "Submit", 
                press: (){
                  if(documentTypeOptionController.text.isEmpty){
                    dynamicMaster.displayError(context, "Error", "Document Type is required");
                    setState(() {
                      isDocumentTypeOptionHasErrors = true;
                    });
                  }else if(documentNumberController.text.isEmpty){
                    dynamicMaster.displayError(context, "Error", "Document Number is required");
                    setState(() {
                      isDocumentTypeOptionHasErrors = false;
                    });
                  }else{
                    processDocumentQuery();
                  }
                }, 
                btnColor: kSecondaryColor, 
                textColor: kPrimaryLightColor
              ),
              SizedBox(height: size.height * 0.02,),
            ],
          ),
        ),
      ),
    );
  }
}