import 'dart:convert';

import '../../../modals/product_modal.dart';
import '../../../constant/constants.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../modals/product_serial_number_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../providers/user_provider.dart';

class ProductSerialNumberCard extends StatefulWidget {
  final CartController controller;
  final ProductModal product;
  final int quantity;
  final int index;
  const ProductSerialNumberCard({super.key, required this.controller, required this.product, required this.quantity, required this.index});

  @override
  State<ProductSerialNumberCard> createState() => _ProductSerialNumberCardState();
}

class _ProductSerialNumberCardState extends State<ProductSerialNumberCard> {
  final CartController controller = Get.find();
  UserProvider userProvider = UserProvider();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  DynamicMaster dynamicMaster = DynamicMaster();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  List<String> scannedSerialNumberList = [];
  List<WarehouseModal> warehouseList = [];
  List<ProductSerialNumberModal> serialNumberList = [];

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _getWarehouses();
  }

  
  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();

    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        warehouseList = fetchedWarehouseList;
      });
    }
  }

  Future<void> _saveProductSerialNo(String serialNumber) async {
    int productId = await  _dbHelper.getOrCreateProductId(widget.product);

    await _dbHelper.insertCartProductSerialNumber(productId, serialNumber);
  }

  Future<void> showPreferenceDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    HoneywellScanner honeywellScanner = HoneywellScanner();

    WarehouseModal? warehouse;

    isDeviceSupported = await honeywellScanner.isSupported();
    await honeywellScanner.startScanner();
    
    bool isLoadingSerialNumber = false;
    
    IconButton closeButtonWidget = IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.clear,
        size: 30,
      ),
    );
    
    setState(() {
      isLoadingSerialNumber = true;
    });

    var token = await sessionProvider.authProvider.token;

    if(token == null){
      dynamicMaster.displayError(context, "Error", "Session expired, please login again");
      return;
    }

    final productRequest = await _dbHelper.queryRaw('SELECT a.*, b.item_code FROM cart_product_request a LEFT JOIN cart_products b ON (a.cart_products_id = b.id) WHERE b.item_code = ?',[widget.product.itemCode]);

    if(productRequest.isNotEmpty){
      if(productRequest.first['warehouse_code'] != null){
        // check the warehouse if its a virtual warehouse
        warehouse = warehouseList.firstWhere((element) => element.code == productRequest.first['warehouse_code']);
      }else{
        // get the default store warehouse
        warehouse = warehouseList.firstWhere((element) => element.isStore.toString() == "1");
      }
    }else{
      // get the default store warehouse
      warehouse = warehouseList.firstWhere((element) => element.isStore.toString() == "1");
    }

    Map<String, dynamic> filtersParam = {
      "itemCode": widget.product.itemCode,
      "quantity": widget.quantity.toString(),
      "warehouseCode": warehouse.code,
      "status": "IN"
    };

    var response = await apiService.fetchProductSerialNumbers(token, filtersParam);
    
    setState(() {
      isLoadingSerialNumber = false;
    });

    if(response.isNotEmpty && response["status"] == "success"){
      serialNumberList.clear();
      for (var item in response["data"]) {
        serialNumberList.add(productSerialNumberModalFromJson(jsonEncode(item)));
      }
    }else{
      dynamicMaster.displayError(context, "Error", "No serial numbers found for the product");
      return;
    }

    return showDialog(
      context: context, 
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            
            honeywellScanner.onScannerDecodeCallback = (scannedData) {
              String serialNumber = scannedData?.code as String;
              if (serialNumber.isNotEmpty) {
                bool isCorrectSerialNo = false;
                for (var serialNumberObj in serialNumberList) {
                  if (serialNumberObj.serialNo == serialNumber) {
                    setState(() {
                      scannedSerialNumberList.add(serialNumber);
                      isCorrectSerialNo = true;
                    });
                    _saveProductSerialNo(serialNumber);
                    break;
                  }
                }
                // if (serialNumberList.contains(serialNumber) && !scannedSerialNumberList.contains(serialNumber)) {
                //   setState(() {
                //     scannedSerialNumberList.add(serialNumber);
                //     widget.product.scannedSerialNumberList?.add(serialNumber);
                //   });
                if(isCorrectSerialNo == false){
                  
                  Fluttertoast.showToast(
                    msg: "Serial number is not marked for delivery",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP_RIGHT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              }
            };

            honeywellScanner.onScannerErrorCallback = (error) {
              print("Error: $error");
            };

            return Dialog(
              child: Container(
                width: size.width,
                height: size.height * 0.5,
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/azone.png",
                          height: 70,
                          width: 70,
                        ),
                        closeButtonWidget,
                      ],
                    ),
                    Text(
                      widget.product.modelNo,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Divider(height: 10,thickness: 1,),
                    SizedBox(height: size.height * 0.02,),
                    Expanded(
                      child: isLoadingSerialNumber ?
                      const Center(
                        child: CircularProgressIndicator(),
                      ) :
                      serialNumberList.isEmpty ?
                      const Center(
                        child: Text("No serial numbers found", style: TextStyle(color: Colors.red, fontSize: 16.0),),
                      ) :
                      ListView.builder(
                        itemCount: serialNumberList.length,
                        itemBuilder: (context, index){
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              title: Text(serialNumberList[index].serialNo),
                              tileColor: scannedSerialNumberList.contains(serialNumberList[index].serialNo) ? Colors.greenAccent : Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 0.02,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            honeywellScanner.stopScanner();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Close"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            honeywellScanner.stopScanner();
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor
                          ),
                          child: const Text("Save", style: TextStyle(color: Colors.white),),
                        ),
                      ]
                    ),
                  ],
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
      onTap: () {
        showPreferenceDialog(context);
      },
      child: Container(
        width: size.width,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow:  [
            BoxShadow(
              color: Colors.black12.withOpacity(0.3),
              offset: const Offset(-10.0, 10.0),
              blurRadius: 20.0,
              spreadRadius: 4.0
            )
          ]
        ),
        padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.product.modelNo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            SizedBox(height:  size.height * 0.02,),
            Row(
              children: [
                Text(
                  'Quantity: ${widget.quantity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            SizedBox(height:  size.height * 0.02,),
            Row(
              children: [
                Text(
                  'Total Scanned: ${scannedSerialNumberList.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}