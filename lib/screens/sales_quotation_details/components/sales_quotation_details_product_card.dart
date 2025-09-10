import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../config/config.dart';
import '../../../constant/constants.dart';
import '../../../modals/sales_quotation_line_item_modal.dart';
import 'package:intl/intl.dart';

import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';

class SalesQuotationDetailsProductCard extends StatefulWidget {
  final SalesQuotationLineItemModal salesQuotationLineItemModal;
  const SalesQuotationDetailsProductCard({super.key, required this.salesQuotationLineItemModal});

  @override
  State<SalesQuotationDetailsProductCard> createState() => _SalesQuotationDetailsProductCardState();
}

class _SalesQuotationDetailsProductCardState extends State<SalesQuotationDetailsProductCard> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  String? productImagePath;
  
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

  Future<void> _showProductDetailsDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));
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
                      Text(widget.salesQuotationLineItemModal.itemCode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Price: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(widget.salesQuotationLineItemModal.itemPrice), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Quantity: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(widget.salesQuotationLineItemModal.quantity.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Discount(%): ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(widget.salesQuotationLineItemModal.itemDiscountPerc.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("VAT Group: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(widget.salesQuotationLineItemModal.itemVatGroup, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("VAT(%): ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(widget.salesQuotationLineItemModal.itemVatPerc.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Warehouse: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              Text(widget.salesQuotationLineItemModal.itemWarehouseCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01,),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => _showProductDetailsDialog(context),
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
              child: ImageService.isValidItemCode(widget.salesQuotationLineItemModal.itemCode?.toString()) ? 
                Image.network(
                  ImageService.getProductImageUrl(widget.salesQuotationLineItemModal.itemCode.toString()),
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
                    Text(widget.salesQuotationLineItemModal.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                    SizedBox(height: size.height * 0.01,),
                    SizedBox(width: size.width * 0.6, child: Text(widget.salesQuotationLineItemModal.itemModelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),)),
                    SizedBox(height: size.height * 0.01,),
                    Text("Qty: ${widget.salesQuotationLineItemModal.quantity.toString()}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                    SizedBox(height: size.height * 0.01,),
                    Text("Price: ${NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(widget.salesQuotationLineItemModal.itemPrice)}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                    SizedBox(height: size.height * 0.01,),
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