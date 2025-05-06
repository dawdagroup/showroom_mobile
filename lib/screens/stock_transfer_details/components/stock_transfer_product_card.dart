import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class StockTransferProductCard extends StatefulWidget {
  final StockTransferProduct product;
  const StockTransferProductCard({super.key, required this.product});

  @override
  State<StockTransferProductCard> createState() => _StockTransferProductCardState();
}

class _StockTransferProductCardState extends State<StockTransferProductCard> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  String? productImagePath;
  bool isLoading = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    getProductImage();
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
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.02, right: size.width * 0.02),
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: const Offset(-10.0, 10.0),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.product.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                SizedBox(height: size.height * 0.01,),
                Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.6,
                      child: Text(widget.product.modelNumber, softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01,),
                Text(widget.product.itemGroup, softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                SizedBox(height: size.height * 0.01,),
                Text("Brand: ${widget.product.itemBrand}" , softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                SizedBox(height: size.height * 0.01,),
                Text("Qty: ${widget.product.quantity.toString()}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),),
              ],
            ),
          )
        ],
      ),
    );
  }
}