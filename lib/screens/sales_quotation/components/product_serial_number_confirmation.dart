import 'dart:convert';

import '../../../modals/product_modal.dart';
import '../../../modals/product_stock_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'product_serial_number_card.dart';

class ProductSerialNumberConfirmation extends StatefulWidget {
  const ProductSerialNumberConfirmation({super.key});

  @override
  State<ProductSerialNumberConfirmation> createState() => _ProductSerialNumberConfirmationState();
}

class _ProductSerialNumberConfirmationState extends State<ProductSerialNumberConfirmation> {
  final CartController controller = Get.find();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  DynamicMaster dynamicMaster = DynamicMaster();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<WarehouseModal> warehouseList = [];
  List<bool> productStockStatus = [];
  List<ProductModal> productList = [];

  String? _cachedToken;

  @override
  void initState() {

    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    _initialize();

  }
  Future<void> _initialize() async {
  _cachedToken = await sessionProvider.authProvider.token;

  await _getWarehouses();
  _preFetchProductStockStatus();
  // setState(() {}); // trigger rebuild once fully ready
}

  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();


    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        warehouseList = fetchedWarehouseList;
      });
    }
  }

  Future<bool> checkProductStock(ProductModal product, int quantity) async{
    bool output = false;

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
          setState(() {
            warehouse = warehouseObj;
          });

          break;
        }
      }
    }

    print("Warehouse: ${warehouse?.isVirtual} - ${warehouse?.code}");

    if(warehouse == null || warehouse!.isVirtual == 1){
      // if no warehouse found, return false
      return false;
    }

    productList.add(product);

    // if the warehouse is not virtual, check the stock
    // if the warehouse is virtual, we assume stock is always available
    // but we can still check the stock if needed

    Map<String, dynamic> filters = {
      "warehouseCode": warehouse!.code,
      "itemCode": product.itemCode,
    };

    var token = _cachedToken;

    if(token == null){
      return false;
    }

    // check the stock of the product
    var response = await apiService.filterProductStock(token, filters);

    if(response["status"] == "success" && response["data"].isNotEmpty){
      ProductStockModal productStock = productStockModalFromJson(jsonEncode(response["data"][0]));

      if(productStock.onHand >= quantity){
        output = true;
      }else{
        output = false;
      }
    }else{
      output = false;
    }

    return output;
  }
  
  Future<void> _preFetchProductStockStatus() async {
    productStockStatus.clear();
    // Ensure we have the latest products from the controller
    for (var product in controller.products.keys) {
      bool status = await checkProductStock(product, controller.products[product]!);

      productStockStatus.add(status);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // If statuses isn't the same length as products, we're still loading.
    if (productStockStatus.length < controller.products.length) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (productList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
        height: size.height * 0.5,
        margin: EdgeInsets.only(top: size.height * 0.1),
        child: ListView.builder(
          itemCount: productList.length,
          itemBuilder: (context, index) {
            // get the product from the controller
            ProductModal product = productList[index];
            int quantity = controller.products[productList[index]] ?? 0;

            return ProductSerialNumberCard(
              controller: controller,
              product: product,
              quantity: quantity,
              index: index,
            );
          },
        ),
      );

  }
}