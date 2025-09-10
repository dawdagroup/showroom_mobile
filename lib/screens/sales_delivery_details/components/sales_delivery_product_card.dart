
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../config/config.dart';
import '../../../constant/constants.dart';
import '../../../modals/delivery_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../services/image_service.dart';

class SalesDeliveryProductCard extends StatefulWidget {
  final DocumentLine deliveryLineItem;
  const SalesDeliveryProductCard({super.key, required this.deliveryLineItem});

  @override
  State<SalesDeliveryProductCard> createState() => _SalesDeliveryProductCardState();
}

class _SalesDeliveryProductCardState extends State<SalesDeliveryProductCard> {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
              child: ImageService.isValidItemCode(widget.deliveryLineItem.itemCode?.toString()) ? 
                Image.network(
                  ImageService.getProductImageUrl(widget.deliveryLineItem.itemCode.toString()),
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
                  Text(widget.deliveryLineItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                  SizedBox(height: size.height * 0.01,),
                  SizedBox(width: size.width * 0.6, child: Text(widget.deliveryLineItem.itemModelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),)),
                  SizedBox(height: size.height * 0.01,),
                  Text("Qty: ${widget.deliveryLineItem.quantity.toString()}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                  SizedBox(height: size.height * 0.01,),
                  Text("Price: ${NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(widget.deliveryLineItem.itemPrice)}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                  SizedBox(height: size.height * 0.01,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}