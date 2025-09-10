
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/po_controller.dart';
import '../../../modals/purchase_order_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';

class PurchaseOrderCard extends StatefulWidget {
  final PurchaseOrderLineItem purchaseOrderLineItem;
  final String purchaseOrderNumber;
  const PurchaseOrderCard({super.key, required this.purchaseOrderLineItem, required this.purchaseOrderNumber});

  @override
  State<PurchaseOrderCard> createState() => _PurchaseOrderCardState();
}

class _PurchaseOrderCardState extends State<PurchaseOrderCard> {
  late final PurchaseOderController purchaseOderController;
  
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  String? productImagePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Get the tagged controller instance
    purchaseOderController = Get.find<PurchaseOderController>(tag: widget.purchaseOrderNumber);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

  }

  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/purchase_order_product_screen', arguments: {
          'purchaseOrderLineItem': widget.purchaseOrderLineItem,
          'purchaseOrderNumber': widget.purchaseOrderNumber,
        });
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
                SizedBox(
                  width: size.width * 0.3,
                  child: ImageService.isValidItemCode(widget.purchaseOrderLineItem.itemCode?.toString()) ? 
                    Image.network(
                      ImageService.getProductImageUrl(widget.purchaseOrderLineItem.itemCode.toString()),
                      height: size.height * 0.3, 
                      width: size.width * 0.3,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: kPrimaryLightColor)
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/blank_image.png", 
                          width: size.width * 0.3, 
                          fit: BoxFit.cover
                        );
                      },
                    ) :
                    Image.asset("assets/images/blank_image.png", width: size.width * 0.3, fit: BoxFit.cover),
                ),
                SizedBox(
                  width: size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.purchaseOrderLineItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text(widget.purchaseOrderLineItem.itemModelNumber,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text("Qty: ${widget.purchaseOrderLineItem.itemOpenQuantity.toString()}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Obx(() {
                        // Calculate the current count from your reactive map.
                        final scannedCount = purchaseOderController.scannedSerials[widget.purchaseOrderLineItem.itemCode]?.length ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 10),
                            Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                            Text("Pending Qty: ${widget.purchaseOrderLineItem.itemOpenQuantity - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
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