import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';
import 'package:showroom_manager/constant/constants.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../db/database_helper.dart';
import '../../../modals/stock_transfer_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class StockTransferScreenBody extends StatefulWidget {
  const StockTransferScreenBody({super.key});

  @override
  State<StockTransferScreenBody> createState() => _StockTransferScreenBodyState();
}

class _StockTransferScreenBodyState extends State<StockTransferScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  List<StockTransferModal> stockTransferList = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
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
    initScreen();
  }

  Future<void> filterPendingStockTransfer({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; stockTransferList = []; });
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        setState(() { isLoading = false; });
        return;
      }

      if(filters.isEmpty){
        var fetchedWarehouseList = await _dbHelper.getWarehouses();
        filters = {
          "status": "pending",
          "from_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
          "to_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
        };
      }

      var response = await apiService.filterStockTransfer(token, filters);

      if(response["status"] == "success"){
        
        for (var item in response["data"]) {
          stockTransferList.add(stockTransferModalFromJson(jsonEncode(item)));
        }

      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false; });
  }

  Future<void> filterPendingStockTransferInit({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        setState(() { isLoading = false; });
        return;
      }

      if(filters.isEmpty){
        var fetchedWarehouseList = await _dbHelper.getWarehouses();
        filters = {
          "from_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
          "to_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
        };
      }

      var response = await apiService.filterStockTransfer(token, filters);

      if(response["status"] == "success"){
        
        for (var item in response["data"]) {
          stockTransferList.add(stockTransferModalFromJson(jsonEncode(item)));
        }

      }

    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false; });
  }

  Future<void> initScreen() async{
    var fetchedWarehouseList = await _dbHelper.getWarehouses();
    final Map<String, dynamic> filters = {
      "is_active": "0",
      "from_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
    };
  
    filterPendingStockTransferInit(filters: filters);

    final Map<String, dynamic> filters2 = {
      "is_active": "0",
      "to_warehouse_code_list": [for (var item in fetchedWarehouseList) item.code].join(","),
    };
    filterPendingStockTransferInit(filters: filters2);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02,),
          const Text("Stock Transfer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),),
          SizedBox(height: size.height * 0.02,),
          Container(
            height: size.height * 0.7,
            width: size.width,
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: isLoading ? const Center(child: CircularProgressIndicator()) :
            stockTransferList.isEmpty ? const Center(child: Text("No Stock Transfer Found")) :
            ListView.builder(
              itemCount: stockTransferList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            children: [
                              const Text("Transfer Number:", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(stockTransferList[index].transferNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("From :", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(stockTransferList[index].fromWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("To :", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(stockTransferList[index].toWarehouseName, style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Created By:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(stockTransferList[index].createdByName, style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Transfer Date:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text(DateFormat('dd-MM-yyyy HH:mm').format(stockTransferList[index].createdAt), style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Application Status:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  dynamicMaster.showBadge(stockTransferList[index].status, stockTransferList[index].status == "pending" ? Colors.yellowAccent : stockTransferList[index].status == "inactive" ? Colors.red : stockTransferList[index].status == "cancelled" ? Colors.red : Colors.green),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              Navigator.pushNamed(context, "/stock_transfer_details", arguments: stockTransferList[index].transferNumber);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height:  size.height * 0.02,),
          RoundedButton(
            btnText: "Request Stock Transfer", 
            press: () {
              Navigator.pushNamed(context, "/stock_transfer_form");
            }, 
            btnColor: kSecondaryColor, 
            textColor: kPrimaryLightColor
          )
        ],
      ),
    );
  }
}