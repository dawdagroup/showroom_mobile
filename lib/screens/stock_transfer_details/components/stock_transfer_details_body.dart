import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../db/database_helper.dart';
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

  Widget _buildActionButton(){
    Size size = MediaQuery.of(context).size;
    // check if the from warehouse code is in the showroom warehouse list
    bool isFromWarehouseInShowroom = showroomWarehouseList.any((warehouse) => warehouse.code == stockTransferDetailsModal!.fromWarehouseCode);

    // check if the to warehouse code is in the showroom warehouse list
    bool isToWarehouseInShowroom = showroomWarehouseList.any((warehouse) => warehouse.code == stockTransferDetailsModal!.toWarehouseCode);

    if (stockTransferDetailsModal!.approvalStatus == "approved" && stockTransferDetailsModal!.status == "active") {   

      if (isToWarehouseInShowroom && stockTransferDetailsModal!.goodsIssueNumber != null) {
        return RoundedButton(btnText: "Receive Goods", press: () {
          Navigator.pushNamed(context, "/receive_goods", arguments: stockTransferDetailsModal!.transferNumber.toString());
        },  btnColor: kSecondaryColor, textColor: Colors.white );
      } else if(isToWarehouseInShowroom && stockTransferDetailsModal!.goodsIssueNumber == null) {
        return SizedBox(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: size.width * 0.07),
                    child: const Text("Comments: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                  ),
                ],
              ),
              const Text("Stock Transfer is approved pending goods issue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),),
            ],
          ),
        );
      }else if (isToWarehouseInShowroom && stockTransferDetailsModal!.goodsIssueNumber == null) {
        return RoundedButton(btnText: "Receive Goods", press: () {
          Navigator.pushNamed(context, "/receive_goods", arguments: stockTransferDetailsModal!.transferNumber.toString());
        },  btnColor: kSecondaryColor, textColor: Colors.white );
      }else if (isFromWarehouseInShowroom && stockTransferDetailsModal!.goodsIssueNumber == null) {

        return RoundedButton(btnText: "Create Goods Issue", press: () {
          Navigator.pushNamed(context, "/create_goods_issue", arguments:  stockTransferDetailsModal!.transferNumber.toString());
        },  btnColor: kSecondaryColor, textColor: Colors.white );
      }

    }

    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.07),
                child: const Text("Comments: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
              ),
            ],
          ),
          const Text("Stock Transfer is not approved or inactive", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.red),),
        ],
      ),
    );
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stockTransferDetailsModal!.products.length,
                itemBuilder: (context, index) {
                  return StockTransferProductCard(
                    product: stockTransferDetailsModal!.products[index],
                  );
                },
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