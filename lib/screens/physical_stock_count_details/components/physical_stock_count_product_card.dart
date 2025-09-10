
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/stock_count_controller.dart';
import '../../../modals/product_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';
import 'physical_stock_take_product_screen.dart';

class PhysicalStockCountProductCard extends StatefulWidget {
  final ProductModal product;
  final String physicalStockCountId;
  const PhysicalStockCountProductCard({super.key, required this.product, required this.physicalStockCountId});

  @override
  State<PhysicalStockCountProductCard> createState() => _PhysicalStockCountProductCardState();
}

class _PhysicalStockCountProductCardState extends State<PhysicalStockCountProductCard> {
  
  late final StockCountController stockCountController;

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  String? productImagePath;

  @override
  void initState() {
    super.initState();
    stockCountController = Get.find<StockCountController>(tag: widget.physicalStockCountId);
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

  }

  void _confirmDeleteProduct() async {
    try {
      // Remove the product from the stock count controller
      var result = await stockCountController.removeProduct(widget.product.barcode);
      
      if (result["success"]) {
        debugPrint("Product ${widget.product.itemCode} removed from stock count");

        dynamicMaster.displaySuccessMessage(context, "${widget.product.itemCode} removed from stock count");
        
      } else {
        dynamicMaster.displayError(context, "Error", result["message"]);
      }
    } catch (e) {
      debugPrint("Error removing product: $e");
      dynamicMaster.displayError(context, "Error", "Failed to remove product: $e");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        debugPrint("Navigating to product details screen");

        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PhysicalStockTakeProductScreen(product: widget.product, physicalStockCountId: widget.physicalStockCountId)), (route) => false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhysicalStockTakeProductScreen(product: widget.product, physicalStockCountId: widget.physicalStockCountId),
          ),
        );
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.02, right: size.width * 0.02, top: size.height * 0.01, bottom: size.height * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: size.width * 0.3,
                    child: ImageService.isValidItemCode(widget.product.itemCode?.toString()) ? 
                      Image.network(
                        ImageService.getProductImageUrl(widget.product.itemCode.toString()),
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
                        Text(widget.product.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                        SizedBox(height: size.height * 0.01,),
                        Text(widget.product.modelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                        SizedBox(height: size.height * 0.01,),
                        Obx(() {
                          return Text("Scanned Qty: ${stockCountController.scannedSerials[widget.product.barcode]?.length ?? 0}", style: const TextStyle(fontSize: 14, color: Colors.white));
                        })
                      ],
                    ),
                  )
                ],
              ),
            ),
            // Delete button positioned in top-right corner
            Positioned(
              top: 5,
              right: 5,
              child:  IconButton(
                onPressed: (){
                  _confirmDeleteProduct();
                }, 
                icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                    size: 16,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}