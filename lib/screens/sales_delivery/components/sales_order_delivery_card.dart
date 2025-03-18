import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/sales_order_controller.dart';
import '../../../modals/product_serial_number_modal.dart';
import '../../../modals/sales_order_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class SalesOrderDeliveryCard extends StatefulWidget {
  final SalesOrderDetailsLineItem salesOrderDetailsLineItem;
  const SalesOrderDeliveryCard({super.key, required this.salesOrderDetailsLineItem});

  @override
  State<SalesOrderDeliveryCard> createState() => _SalesOrderDeliveryCardState();
}

class _SalesOrderDeliveryCardState extends State<SalesOrderDeliveryCard> {
  final SalesOrderController salesOrderController = Get.find<SalesOrderController>();
  
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  List<ProductSerialNumberModal> serialNumberList = [];
  
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

  Future<bool> getProductSerialNumbers() async{

    try{
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return false;
      }

      dynamicMaster.displayLoadingModal(context);

      Map<String, dynamic> filtersParam = {
        "itemCode": widget.salesOrderDetailsLineItem.itemCode,
        "quantity": widget.salesOrderDetailsLineItem.itemOpenQuantity.toString(),
        "warehouseCode": widget.salesOrderDetailsLineItem.itemWarehouseCode,
        "status": "IN"
      };

      var response = await apiService.fetchProductSerialNumbers(token, filtersParam);

      // Close the loading modal.
      Navigator.of(context).pop();

      // Check if the response is successful.
      if(response.isNotEmpty && response["status"] == "success"){
        serialNumberList.clear();
        for (var item in response["data"]) {
          serialNumberList.add(productSerialNumberModalFromJson(jsonEncode(item)));
        }
      }else{
        dynamicMaster.displayError(context, "Error", "No serial numbers found for the product");
        return false;
      }
      
    } catch(e){
      dynamicMaster.displayError(context, "Error", e.toString());
      return false;
    }

    return true;
  }

  Future<void> processNextPage() async{

    var serialsResults = await getProductSerialNumbers();

    if(serialsResults && serialNumberList.isNotEmpty){
      
      Navigator.pushNamed(context, '/sales_order_delivery_product_screen', arguments: {'salesOrderDetailsLineItem': widget.salesOrderDetailsLineItem,'serialNumberList': serialNumberList,});
    }

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        processNextPage();
      },
      child: Container(
          width: size.width,
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
          child: Padding(
            padding: EdgeInsets.only(left: size.width * 0.02, right: size.width * 0.02, top: size.height * 0.01, bottom: size.height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.salesOrderDetailsLineItem.itemImageUrl == null ? Image.asset("assets/images/blank_image.png", width: size.width * 0.3) : Image.network(widget.salesOrderDetailsLineItem.itemImageUrl, width: size.width * 0.3),
                SizedBox(
                  width: size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.salesOrderDetailsLineItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text(widget.salesOrderDetailsLineItem.itemModelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text("Qty: ${widget.salesOrderDetailsLineItem.itemOpenQuantity.toString()}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Obx(() {
                        // Calculate the current count from your reactive map.
                        final scannedCount = salesOrderController.scannedSerials[widget.salesOrderDetailsLineItem.itemCode]?.length ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 10),
                            Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                            Text("Pending Qty: ${widget.salesOrderDetailsLineItem.itemOpenQuantity - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
                          ],
                        );
                      })
                    ],
                  ),
                )
              ],
            ),
          ),
      ),
    );
  }
}