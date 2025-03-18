import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../controllers/goods_issue_controller.dart';
import '../../../modals/goods_issue_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class GoodsIssueProductCard extends StatefulWidget {
  final GoodsIssueDetailsLineItem goodsIssueDetailsLineItem;
  const GoodsIssueProductCard({super.key, required this.goodsIssueDetailsLineItem});

  @override
  State<GoodsIssueProductCard> createState() => _GoodsIssueProductCardState();
}

class _GoodsIssueProductCardState extends State<GoodsIssueProductCard> {
  final GoodsIssueController goodsIssueController = Get.find<GoodsIssueController>();

  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
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
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context, '/goods_issue_product_screen', arguments: widget.goodsIssueDetailsLineItem);
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
                widget.goodsIssueDetailsLineItem.itemImageUrl == null ? Image.asset("assets/images/blank_image.png", width: size.width * 0.3) : Image.network(widget.goodsIssueDetailsLineItem.itemImageUrl, width: size.width * 0.3),
                SizedBox(
                  width: size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.goodsIssueDetailsLineItem.itemCode, style: const TextStyle(fontSize: 16, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text(widget.goodsIssueDetailsLineItem.itemModelNo,softWrap: true, style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Text("Qty: ${widget.goodsIssueDetailsLineItem.itemOpenQuantity.toString()}", style: const TextStyle(fontSize: 14, color: Colors.white),),
                      SizedBox(height: size.height * 0.01,),
                      Obx(() {
                        // Calculate the current count from your reactive map.
                        final scannedCount = goodsIssueController.scannedSerials[widget.goodsIssueDetailsLineItem.itemCode]?.length ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 10),
                            Text("Scanned Qty: $scannedCount", style: const TextStyle(fontSize: 14, color: Colors.white)),
                            Text("Pending Qty: ${widget.goodsIssueDetailsLineItem.itemOpenQuantity - scannedCount}", style: const TextStyle(fontSize: 14, color: Colors.white)),
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