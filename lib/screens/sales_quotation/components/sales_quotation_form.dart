import 'dart:convert';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../config/config.dart';
import '../../../constant/constants.dart';
import '../../../modals/tax_group_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';

import '../../../modals/product_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../modals/product_stock_modal.dart';
import 'cart_products.dart';

class SalesQuotationForm extends StatefulWidget {
  const SalesQuotationForm({super.key});

  @override
  State<SalesQuotationForm> createState() => _SalesQuotationFormState();
}

class _SalesQuotationFormState extends State<SalesQuotationForm> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final CartController cartController;
  
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;
  
  List<TaxGroupModal> taxGroups = [];
  List<WarehouseModal> warehouseList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    cartController = Get.put(CartController(context));
    init();
  } 
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      honeywellScanner.startScanner();
    } else if (state == AppLifecycleState.paused) {
      honeywellScanner.stopScanner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    honeywellScanner.stopScanner();
    super.dispose();
  }

  Future<void> init() async {
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    honeywellScanner.onScannerDecodeCallback = onDecoded;
    honeywellScanner.onScannerErrorCallback = onError;
    await honeywellScanner.startScanner();
  
    if (mounted) setState(() { });

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

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);
    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner.setProperties(properties);
  }

  // @override
  void onDecoded(ScannedData? scannedData) {
    setState(() {
      this.scannedData = scannedData;
      // _scanBarcode = scannedData?.code as String;
      fetchProduct(scannedData?.code as String);
      // getData();
    });
    // TODO: implement onDecoded
  }

  // @override
  void onError(Exception error) { }

  Future<void> fetchProduct(String barcode) async {
    dynamicMaster.displayLoadingModal(context);

    try {
      var token = await sessionProvider.authProvider.token;
      // String token = sessionProvider.authProvider.token!;

      if(token == null){
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }
      var response = await apiService.fecthProductDetails(token, {"barcode": barcode});

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        ProductModal product = productModalFromJson(jsonEncode(response["data"][0]));
        setState(() {
          cartController.addProduct(product);
        });

      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

  Future<bool> validateProductsStock() async{
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return false;
      }

      // for each product, check the stock
      for (var product in cartController.products.keys.toList()) {
        WarehouseModal? warehouse;

        final productRequest = await _dbHelper.queryRaw('SELECT a.*, b.item_code FROM cart_product_request a LEFT JOIN cart_products b ON (a.cart_products_id = b.id) WHERE b.item_code = ?',[product.itemCode]);
        
        if(productRequest.isNotEmpty){
          if(productRequest.first['warehouse_code'] != null){
            // check the warehouse if its a virtual warehouse
            for (var warehouseObj in warehouseList) {
              if(warehouseObj.code.toString() == productRequest.first['warehouse_code']){
                warehouse = warehouseObj;
                break;
              }
            }
          }else{
            // get the default store warehouse
            for (var warehouseObj in warehouseList) {
              if(warehouseObj.isStore.toString() == "1"){
                warehouse = warehouseObj;
                break;
              }
            }
          }
        }else{
          // get the default store warehouse
          for (var warehouseObj in warehouseList) {
            if(warehouseObj.isStore.toString() == "1"){
              warehouse = warehouseObj;
              break;
            }
          }
        }

        if(warehouse == null || warehouse.isVirtual.toString() == "1"){
          // continue if no warehouse found or if the warehouse is virtual
          continue;
        }
        
        Map<String, dynamic> filters = {
          "warehouseCode": warehouse.code,
          "itemCode": product.itemCode,
        };

        // check the stock of the product
        var response = await apiService.filterProductStock(token, filters);

        if(response["status"] == "success"){
          ProductStockModal productStock = productStockModalFromJson(jsonEncode(response["data"][0]));

          if(cartController.products[product] > productStock.onHand){
            Navigator.of(context).pop();
            dynamicMaster.displayError(context, "Error", "Insufficient stock for ${product.itemCode}. Available stock is ${productStock.onHand}. Please reduce the quantity or select a different warehouse");
            return false;
          }else{
            return true;
          }
        }else{
          return true;
        }
      }

      return true;

    } catch (e) {
      print("Error validating products stock: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(theme, context, _scaffoldKey),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CardProducts(),
            Obx(() => 
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(50.0),
                    // topLeft: Radius.circular(50.0),
                    // topLeft: Radius.circular(50)
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF363f93).withOpacity(0.3),
                        offset: const Offset(-10.0, 0.0),
                        blurRadius: 20.0,
                        spreadRadius: 4.0
                    )
                  ]
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                      child: Row(
                        children: [
                          Text(
                            'Sub-Total: ${NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(cartController.subTotal)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                      child: Row(
                        children: [
                          Text(
                            'VAT: ${NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(cartController.vatAmount)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                      child: Row(
                        children: [
                          Text(
                            'Total: ${NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(cartController.subTotal + cartController.vatAmount)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),

                    RoundedButton(
                      btnText: "Proceed to Checkout", 
                      press: () async {
                        dynamicMaster.displayLoadingModal(context);
                        if(await validateProductsStock()){
                          print("Products stock validated successfully");
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/checkout');
                        }
                      }, 
                      btnColor: kSecondaryColor, 
                      textColor: kDefaultIconLightColor
                    ),

                    SizedBox(height: size.height * 0.01),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}