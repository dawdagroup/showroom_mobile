
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../db/database_helper.dart';
import '../modals/product_modal.dart';
import '../modals/pysical_stock_take_details_modal.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

class StockCountController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, RxSet<String>> scannedSerials = <String, RxSet<String>>{}.obs;
  final scannedProducts = {}.obs;

  var isLoading = false.obs;

  var warehouseCode = ''.obs;

  /// Observable stock count number.
  /// This is the stock count number that is being processed.
  var stockCountNumber = ''.obs;
  var stockCountId = 0.obs;

  StockCountController(BuildContext context, PhysicalStockTakeDetailsModal physicalStockTakeDetailsModal) {

    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    loadScans(physicalStockTakeDetailsModal);
  }

  // Load existing serial numbers from the database
  Future<void> loadScans(PhysicalStockTakeDetailsModal physicalStockTakeDetailsModal) async {
    
    print("Loading scans for stock count number: ${physicalStockTakeDetailsModal.stockCountNumber}");

    // Clear the existing scanned serials
    var scHeader = await _dbHelper.getOrCreatePhysicalStockCount(
      physicalStockTakeDetailsModal.stockCountNumber,
      physicalStockTakeDetailsModal.createdBy,
      physicalStockTakeDetailsModal.createdByName,
      physicalStockTakeDetailsModal.physicalStockCountTypeName,
      physicalStockTakeDetailsModal.showroomName,
      physicalStockTakeDetailsModal.warehouseName,
      physicalStockTakeDetailsModal.warehouseCode,
      physicalStockTakeDetailsModal.physicalStockCountTypeName,
    );

    print("Stock count header ID: $scHeader");
    // Initialize the stock count number
    stockCountNumber.value = physicalStockTakeDetailsModal.stockCountNumber;
    stockCountId.value = scHeader;
    warehouseCode.value = physicalStockTakeDetailsModal.warehouseCode;

    isLoading.value = true;


    // update the UI to show loading state
    update();
    
    var stockCountProducts = await _dbHelper.getPhysicalStockCountProducts(scHeader);

    print("Stock count products: $stockCountProducts");

    // If there are no products, return early
    if (stockCountProducts.isEmpty) {
      isLoading.value = false;
      update();
      return;
    }

    // Clear the scanned serials map
    scannedSerials.clear();
    scannedProducts.clear();
    

    // Populate the scanned serials map with existing data
    for (var product in stockCountProducts) {
      // Add the product to the scanned products map
      var productResults = await fetchProduct(product['barcode']);

      print("Fetched product: $productResults");

      if (productResults == null) {
        // If the product is not found, skip it
        continue;
      }
      
      // Use item_code as the key and a set of serial numbers as the value
      scannedSerials.putIfAbsent(product['barcode'], () => <String>{}.obs);

      print("Scanned serials for ${product['barcode']}: ${scannedSerials[product['barcode']]}");

      scannedProducts[productResults] = scannedSerials[product['barcode']]!;

      print("Scanned product: ${productResults.barcode} with item code: ${productResults.itemCode}");

      // get the serial number for the product
      var productSerialNumbers = await _dbHelper.getStockTakeProductSerialNumbers(product['id']);

      if (productSerialNumbers.isNotEmpty) {
        // Add each serial number to the set for that item code
        for (var serial in productSerialNumbers) {
          print("Adding serial number ${serial['serial_number']} for product ${product['barcode']}");
          scannedSerials[product['barcode']]!.add(serial['serial_number']);

          // add the serial number to the scanned products map
          if (scannedProducts.containsKey(productResults)) {
            scannedProducts[productResults]!.add(serial['serial_number']);
          } else {
            scannedProducts[productResults] = <String>{serial['serial_number']};
          }

          print("Scanned serials after adding: ${scannedSerials[product['barcode']]}");
        }
      }
    }

    isLoading.value = false;

    // Update the UI
    update();
  }

  Future<Map<String, dynamic>> addProduct(ProductModal product) async{
    Map<String, dynamic> output = {};
    // Check if stock count number is set
    if (stockCountNumber.value.isEmpty) {
      return output = {
        'success': false,
        'message': 'Stock count number is not set'
      };
    }

    // Check if the product is already scanned
    if (scannedSerials.containsKey(product.barcode)) {
      return output = {
        'success': false,
        'message': 'Product already scanned'
      };
    }
    // Create a new stock count product entry
    var scProduct = await _dbHelper.getOrCreateStockTakeProduct(
      stockCountId.value,
      product.barcode,
      product.itemCode,
      product.itemName,
      product.itemGroup,
      product.brand,
      product.picturName,
      product.modelNo
    );

    // Check if the product was created successfully
    if (scProduct.isEmpty) {
      return output = {
        'success': false,
        'message': 'Failed to create stock count product'
      };
    }

    // Add the product to the scanned serials map
    scannedSerials.putIfAbsent(product.barcode, () => <String>{}.obs);

    // Add the product to the scanned products map
    scannedProducts[product] = scannedSerials[product.barcode]!;

    output = {
      'success': true,
      'message': 'Product added successfully',
    };

    // Update the UI
    update();

    return output;
  }

  // Add a serial number to a product
  Future<Map<String, dynamic>> addSerialNumber(String barcode, String serialNumber) async {
    Map<String, dynamic> output = {};

    // validate the serial number
    if (!isValidSerialNumber(serialNumber)) {
      // Update the UI
      update();
      return output = {
        'success': false,
        'message': 'Serial number $serialNumber is invalid'
      };
    }

    // Check if the item code exists in scannedSerials
    if (!scannedSerials.containsKey(barcode)) {
      // Update the UI
      update();
      return output = {
        'success': false,
        'message': 'Item code not found'
      };
    }

    // Check if the serial number is already scanned for this item code
    if (scannedSerials[barcode]!.contains(serialNumber)) {
      // Update the UI
      update();
      return output = {
        'success': false,
        'message': 'Serial number already scanned'
      };
    }

    // check if serial numberis available globally
    for (var item in scannedSerials.entries) {
      if (item.value.contains(serialNumber) && item.key != barcode) {
        return output = {
          'success': false,
          'message': 'Serial number already exists for another item'
        };
      }
    }

    // Add the serial number to the set for this item code
    scannedSerials[barcode]!.add(serialNumber);

    // Insert the serial number into the database
    var scProduct = await _dbHelper.getPhysicalStockCountProduct(stockCountId.value, barcode);

    if (scProduct.isEmpty) {
      // Update the UI
      update();
      return output = {
        'success': false,
        'message': 'Product not found in stock count'
      };
    }

    // Insert the serial number into the database
    _dbHelper.insertStockTakeProductSerialNumber(
      scProduct[0]['id'],
      serialNumber
    );

    output = {
      'success': true,
      'message': 'Serial number added successfully',
    };

    // Update the UI
    update();

    return output;
  }

  bool isValidSerialNumber(String serialNumber) {
    //check if the serial number is a http link
    if (serialNumber.startsWith('http://') || serialNumber.startsWith('https://')) {
      return false; // Invalid serial number if it starts with http or https
    }

    // Check if the serial number is empty or contains only whitespace
    if (serialNumber.trim().isEmpty) {
      return false; // Invalid serial number if it's empty or whitespace
    }

    return true; // Valid serial number
  }

  // Remove a serial number from a product
  Future<Map<String, dynamic>> removeSerialNumber(String barcode, String serialNumber) async {
    Map<String, dynamic> output = {};

    // Check if the item code exists in scannedSerials
    if (!scannedSerials.containsKey(barcode)) {
      return output = {
        'success': false,
        'message': 'Item code not found'
      };
    }

    // Check if the serial number is scanned for this item code
    if (!scannedSerials[barcode]!.contains(serialNumber)) {
      return output = {
        'success': false,
        'message': 'Serial number not found for this item'
      };
    }

    // Remove the serial number from the set for this item code
    scannedSerials[barcode]!.remove(serialNumber);

    // Remove the serial number from the database
    var scProduct = await _dbHelper.getPhysicalStockCountProduct(stockCountId.value, barcode);

    if (scProduct.isEmpty) {
      return output = {
        'success': false,
        'message': 'Product not found in stock count'
      };
    }

    // Delete the serial number from the database
    _dbHelper.deleteStockTakeProductSerialNumber(scProduct[0]['id'], serialNumber);

    output = {
      'success': true,
      'message': 'Serial number removed successfully',
    };

    // Update the UI
    update();

    return output;
  }

  Future<ProductModal?> fetchProduct(String barcode) async {
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        return null;
      }

      var response = await apiService.fecthProductDetails(token, {"barcode": barcode});

      if(response["status"] == "success"){
        ProductModal product = productModalFromJson(jsonEncode(response["data"][0]));

        return product;

      }else{
        return null;
      }

    } catch (e) {
        return null;
    }
  }

  Future<Map<String, dynamic>> fetchStocTakeDetails() async {

    // check if products are scanned
    if (scannedProducts.isEmpty) {
      return {
        'success': false,
        'message': 'No products scanned'
      };
    }

    // check is we have serial numbers for each product
    for (var product in scannedProducts.keys) {
      if (scannedProducts[product]!.isEmpty) {
        return {
          'success': false,
          'message': 'No serial numbers scanned for product ${product.modelNo}'
        };
      }
    }

    // Create a stock take details entry
    Map<String, dynamic> stockTakeDetails = {
      'success': true,
    };
    for (var product in scannedProducts.keys) {
      stockTakeDetails[product.itemCode] = scannedProducts[product]!.toList();
    }

    return stockTakeDetails;

  }

  // clear all scans
  Future<void> clearScans() async {
    scannedProducts.clear();
    scannedSerials.clear();
    
    // Clear the stock count products from the database
    await _dbHelper.clearPhysicalStockCountProducts(stockCountId.value);
  }

  // Trigger scanner restart (used when returning from navigation)
  void triggerScannerRestart() {
    // Use a reactive variable to trigger scanner restart
    debugPrint("StockCountController: triggering scanner restart");
    // Force an update by modifying an observable
    // This will cause any listening widgets to rebuild
    update(); // This triggers GetBuilder widgets to rebuild
  }

  // Remove a product and all its scanned serials from the stock count
  Future<Map<String, dynamic>> removeProduct(String barcode) async {
    try {
      // Remove from in-memory maps
      if (scannedSerials.containsKey(barcode)) {
        scannedSerials.remove(barcode);
      }
      scannedProducts.removeWhere((key, value) => key.barcode == barcode);
      
      // Remove from database
      await _dbHelper.removePhysicalStockCountProduct(stockCountId.value, barcode);
      
      debugPrint("Product with barcode $barcode removed from stock count");
      return {"success": true, "message": "Product removed successfully"};
    } catch (e) {
      debugPrint("Error removing product: $e");
      return {"success": false, "message": "Failed to remove product: $e"};
    }
  }

}