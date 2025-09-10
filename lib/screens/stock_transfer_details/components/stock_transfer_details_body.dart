import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../db/database_helper.dart';
import '../../../modals/goods_issue_details_modal.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'stock_transfer_product_card.dart';

class StockTransferDetailsBody extends StatefulWidget {
  final String stockTransferNumber;
  const StockTransferDetailsBody({super.key, required this.stockTransferNumber});

  @override
  State<StockTransferDetailsBody> createState() => _StockTransferDetailsBodyState();
}

class _StockTransferDetailsBodyState extends State<StockTransferDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  StockTransferDetailsModal? stockTransferDetailsModal;
  List<WarehouseModal> showroomWarehouseList = [];
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
    getStockTransferDetails();
    _getWarehouses();
  }

  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();

    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        showroomWarehouseList = fetchedWarehouseList;
      });
    }
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

      var response = await apiService.getStockTransferDetails(token, widget.stockTransferNumber);

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

  Widget comment(String text, Color color) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: size.width * 0.07),
            child: const Text("Comments: ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Text(text,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final details = stockTransferDetailsModal!;
    print("Warehouse Codes: ${details.fromWarehouseCode}, ${details.toWarehouseCode}");
    print("Showroom Warehouses: ${showroomWarehouseList.map((w) => w.code).join(', ')}");
    final fromInShowroom = showroomWarehouseList.any((w) => w.code == details.fromWarehouseCode);
    final toInShowroom = showroomWarehouseList.any((w) => w.code == details.toWarehouseCode);

    print("From in Showroom: $fromInShowroom, To in Showroom: $toInShowroom");

    // Check if transfer is completed
    if (details.goodsReceiptNumber != null) {
      return comment("Stock Transfer completed", Colors.green);
    }

    // Check approval status first
    if (details.approvalStatus == "cancelled" || details.approvalStatus == "rejected") {
      return comment("Stock Transfer has been ${details.approvalStatus}", Colors.red);
    }

    if (details.approvalStatus == "pending") {
      return comment("Stock Transfer is pending approval", Colors.orange);
    }

    // Check if transfer is inactive
    if (details.status == "inactive") {
      return comment("Stock Transfer is inactive", Colors.red);
    }

    // Must be approved and active for any actions
    if (details.approvalStatus != "approved" || details.status != "active") {
      return comment("Stock Transfer is not approved or inactive", Colors.red);
    }

    // From warehouse actions - Create goods issue
    if (fromInShowroom && details.goodsIssueNumber == null) {
      return RoundedButton(
        btnText: "Create Goods Issue",
        press: () => Navigator.pushNamed(
            context, "/create_goods_issue",
            arguments: details.transferNumber.toString()),
        btnColor: kSecondaryColor,
        textColor: Colors.white,
      );
    }

    // To warehouse actions - Receive goods
    if (toInShowroom && details.goodsIssueNumber != null && details.goodsReceiptNumber == null) {
      print("To warehouse is in showroom");
      return RoundedButton(
        btnText: "Receive Goods",
        press: () {
          _handleReceiveAction();
        },
          btnColor: kSecondaryColor,
          textColor: Colors.white,
        );
    }

    // Transfer between external warehouses
    if (!fromInShowroom && !toInShowroom) {
      if (details.goodsIssueNumber == null) {
        return comment("Goods issue pending from external warehouse", Colors.blue);
      } else if (details.goodsReceiptNumber == null) {
        return comment("Goods receipt pending at external warehouse", Colors.blue);
      }
    }

    // Goods issue created but not applicable for this showroom
    if (details.goodsIssueNumber != null && !toInShowroom) {
      return comment("Goods issued - awaiting receipt at destination", Colors.blue);
    }

    // No goods issue created but not applicable for this showroom
    if (details.goodsIssueNumber == null && !fromInShowroom) {
      return comment("Awaiting goods issue from source warehouse", Colors.blue);
    }

    // Fallback
    return comment("No actions available for this transfer", Colors.grey);
  }

  Future<void> _handleReceiveAction() async {
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        return;
      }

      if(stockTransferDetailsModal == null){
        dynamicMaster.displayError(context, "Error", "No stock transfer details found");
        return;
      }

      if(stockTransferDetailsModal!.goodsReceiptNumber != null){
        dynamicMaster.displayError(context, "Error", "Stock Transfer has already been received");
        return;
      }

      if(stockTransferDetailsModal!.status == "inactive"){
        dynamicMaster.displayError(context, "Error", "Stock Transfer is inactive");
        return;
      }

      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.getGoodsIssueDetails(stockTransferDetailsModal!.goodsIssueNumber.toString(), token);

      Navigator.pop(context);

      if(response["status"] == "success" && response["data"] != null){
        var goodsIssueObject = goodsIssueDetailsModalFromJson(jsonEncode(response["data"][0]));

        if(goodsIssueObject.documentStatus == "C"){
          dynamicMaster.displayError(context, "Error", "Goods Issue has already been closed");
          return;
        }

        Navigator.pushNamed(context, "/receive_goods_issue", arguments: goodsIssueObject);

      } else {
        dynamicMaster.displayError(context, "Error", "Failed to fetch goods issue details");
      }

    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: isLoading ? 
        const Center(child: CircularProgressIndicator()) : 
        stockTransferDetailsModal == null ? 
        const Center(child: Text("No Data Found!")) : 
        SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.35,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE5CCB8), 
                    Color(0xFFD1B299), 
                    Color(0xFFF3D4B3)
                  ]
                )
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.01,),
                                Text("Stock Transfer No: ${stockTransferDetailsModal!.transferNumber}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(DateFormat('dd-MMMM-yyyy').format(stockTransferDetailsModal!.transferDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                Text("Stock Status: ${stockTransferDetailsModal!.status}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                              width: size.width * 0.1,
                              child: stockTransferDetailsModal!.status == "inactive" ?
                              Image.asset("assets/icons/padlock.png") :
                              Image.asset("assets/icons/open-lock43.png"),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: size.width * 0.35,
                              child: Text(
                                "Created By: ${stockTransferDetailsModal!.createdByName}", 
                                softWrap: true, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Transfer Info",
                              style: TextStyle(letterSpacing: sqrt1_2, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: size.height * 0.01,),
                            Row(
                              children: [
                                const Text("From Warehouse: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(stockTransferDetailsModal!.fromWarehouseCode, softWrap: true, style: const TextStyle(fontSize: 16, color: kSecondaryColor),),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("To Warehouse: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(stockTransferDetailsModal!.toWarehouseCode, softWrap: true, style: const TextStyle(fontSize: 16, color: kSecondaryColor),),
                              ],
                            ),
                          ],
                        )
                      ],
                    )

                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02,),
            SizedBox(
              height: size.height * 0.53,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () { 
                          // printInvoiceDialoge(); 
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.print),
                            Text("Print Goods Issue"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.45,
                    width: size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: stockTransferDetailsModal!.products.length,
                      itemBuilder: (context, index) {
                        return StockTransferProductCard(
                          product: stockTransferDetailsModal!.products[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02,),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }
}