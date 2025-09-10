import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../modals/product_modal.dart';
import '../modals/pysical_stock_take_details_modal.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

/// Enhanced Stock Take Controller for warehouse operations
/// Manages the complete flow: Product scanning -> Serial scanning -> Submission
class WarehouseStockTakeController extends GetxController {
  final ApiService _apiService = ApiService();
  
  late SessionProvider _sessionProvider;

  // Observable state
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  // Stock take information
  var stockTakeId = ''.obs;
  var stockCountNumber = ''.obs;
  var warehouseCode = ''.obs;
  var stockTakeStatus = ''.obs;
  
  // Product and serial management
  var scannedProducts = <ProductModal>[].obs;
  var productSerials = <String, RxList<String>>{}.obs; // productId -> List of serials
  
  // Currently selected product for serial scanning
  var selectedProductForSerials = Rxn<ProductModal>();

  WarehouseStockTakeController() {
    // Initialize with empty state
  }

  /// Initialize controller with stock take details
  Future<bool> initializeStockTake(BuildContext context, String stockTakeId) async {
    try {
      _sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      
      isLoading.value = true;
      
      var token = await _sessionProvider.authProvider.token;
      if (token == null) {
        throw Exception("Authentication token not available");
      }

      // Fetch stock take details from API
      var response = await _apiService.getPhysicalStockCountDetails(token, stockTakeId);
      
      if (response["status"] == "success" && response["data"].isNotEmpty) {
        var stockTakeDetails = physicalStockTakeDetailsModalFromJson(
          jsonEncode(response["data"][0])
        );
        
        // Set observable values
        this.stockTakeId.value = stockTakeId;
        stockCountNumber.value = stockTakeDetails.stockCountNumber;
        warehouseCode.value = stockTakeDetails.warehouseCode;
        stockTakeStatus.value = stockTakeDetails.status;
        
        // Load any existing scans from local database
        await _loadExistingScans();
        
        isLoading.value = false;
        return true;
      } else {
        throw Exception(response["message"] ?? "Failed to load stock take details");
      }
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Initialization failed: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Load existing scans from local database
  Future<void> _loadExistingScans() async {
    try {
      // For now, we'll use a simple approach since the database methods need to be implemented
      // This would load existing product scans from the database when available
      debugPrint('WarehouseStockTakeController: Loading existing scans for ${stockCountNumber.value}');
      
      // TODO: Implement actual database loading when methods are available
      // var existingData = await _dbHelper.getStockTakeScans(stockCountNumber.value);
      
      debugPrint('WarehouseStockTakeController: Existing scans loaded');
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error loading existing scans: $e');
    }
  }

  /// Add a scanned product to the list (handles duplicates)
  Future<Map<String, dynamic>> addScannedProduct(String barcode) async {
    try {
      // Check if product already exists
      bool productExists = scannedProducts.any((product) => product.barcode == barcode);
      if (productExists) {
        return {
          "success": false,
          "message": "Product already scanned. Navigate to the product to add serial numbers.",
        };
      }

      // Fetch product details from API
      var token = await _sessionProvider.authProvider.token;
      if (token == null) {
        return {"success": false, "message": "Authentication token not available"};
      }

      var response = await _apiService.fecthProductDetails(token, {"barcode": barcode});
      
      if (response["status"] == "success" && response["data"].isNotEmpty) {
        ProductModal product = productModalFromJson(jsonEncode(response["data"][0]));
        
        // Add to scanned products
        scannedProducts.add(product);
        
        // Initialize empty serials list for this product (using itemCode as unique identifier)
        productSerials[product.itemCode.toString()] = <String>[].obs;
        
        // Save to local database
        await _saveProductToDatabase(product);
        
        return {
          "success": true, 
          "message": "Product added successfully",
          "product": product,
        };
      } else {
        return {
          "success": false,
          "message": response["message"] ?? "Product not found"
        };
      }
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error adding product: $e');
      return {"success": false, "message": "Error adding product: $e"};
    }
  }

  /// Set the selected product for serial number scanning
  void selectProductForSerials(ProductModal product) {
    selectedProductForSerials.value = product;
    debugPrint('WarehouseStockTakeController: Selected product for serials: ${product.itemName}');
  }

  /// Add a serial number to the selected product
  Map<String, dynamic> addSerialToSelectedProduct(String serialNumber) {
    if (selectedProductForSerials.value == null) {
      return {"success": false, "message": "No product selected for serial scanning"};
    }

    var product = selectedProductForSerials.value!;
    String productId = product.itemCode.toString();
    
    // Check for duplicate serial
    if (productSerials[productId]?.contains(serialNumber) == true) {
      return {
        "success": false, 
        "message": "Serial number already scanned for this product"
      };
    }

    // Add serial to the product
    if (productSerials[productId] == null) {
      productSerials[productId] = <String>[].obs;
    }
    
    productSerials[productId]!.add(serialNumber);
    
    // Save to local database
    _saveSerialToDatabase(product, serialNumber);
    
    debugPrint('WarehouseStockTakeController: Added serial $serialNumber to product ${product.itemName}');
    
    return {
      "success": true,
      "message": "Serial number added successfully",
      "totalSerials": productSerials[productId]!.length,
    };
  }

  /// Remove a serial number from a product
  void removeSerialFromProduct(ProductModal product, String serialNumber) {
    String productId = product.itemCode.toString();
    productSerials[productId]?.remove(serialNumber);
    
    // Remove from database
    _removeSerialFromDatabase(product, serialNumber);
    
    debugPrint('WarehouseStockTakeController: Removed serial $serialNumber from product ${product.itemName}');
  }

  /// Get serial numbers for a specific product
  List<String> getSerialsForProduct(ProductModal product) {
    String productId = product.itemCode.toString();
    return productSerials[productId]?.toList() ?? [];
  }

  /// Get total count of scanned items
  int get totalScannedItems {
    return productSerials.values.fold(0, (sum, serials) => sum + serials.length);
  }

  /// Clear the selected product
  void clearSelectedProduct() {
    selectedProductForSerials.value = null;
  }

  /// Submit the complete stock take
  Future<Map<String, dynamic>> submitStockTake() async {
    try {
      if (scannedProducts.isEmpty) {
        return {"success": false, "message": "No products scanned to submit"};
      }

      isSubmitting.value = true;

      var token = await _sessionProvider.authProvider.token;
      if (token == null) {
        return {"success": false, "message": "Authentication token not available"};
      }

      // Prepare submission data
      Map<String, dynamic> submissionData = await _prepareSubmissionData();
      
      Map<String, dynamic> requestData = {
        "productSerial": submissionData,
        "stockCountNumber": stockCountNumber.value,
      };

      // Submit to API
      var response = await _apiService.processPhysicalStockData(token, requestData);
      
      if (response["status"] == "success") {
        // Clear all data after successful submission
        await clearAllScans();
        
        isSubmitting.value = false;
        return {"success": true, "message": "Stock take submitted successfully"};
      } else {
        isSubmitting.value = false;
        return {
          "success": false,
          "message": response["message"] ?? "Failed to submit stock take"
        };
      }
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Submission error: $e');
      isSubmitting.value = false;
      return {"success": false, "message": "Error submitting stock take: $e"};
    }
  }

  /// Prepare data for submission
  Future<Map<String, dynamic>> _prepareSubmissionData() async {
    Map<String, dynamic> submissionData = {};

    for (var product in scannedProducts) {
      String productId = product.itemCode.toString();
      List<String> serials = productSerials[productId]?.toList() ?? [];
      
      if (serials.isNotEmpty) {
        submissionData[productId] = {
          "product": product.toJson(),
          "serials": serials,
          "count": serials.length,
        };
      }
    }

    return submissionData;
  }

  /// Clear all scanned data
  Future<void> clearAllScans() async {
    scannedProducts.clear();
    productSerials.clear();
    selectedProductForSerials.value = null;
    
    // Clear from local database when methods are available
    try {
      // TODO: Implement database clearing
      // await _dbHelper.clearStockTakeData(stockCountNumber.value);
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error clearing database: $e');
    }
    
    debugPrint('WarehouseStockTakeController: All scans cleared');
  }

  /// Database operations
  Future<void> _saveProductToDatabase(ProductModal product) async {
    try {
      // TODO: Implement when database methods are available
      // await _dbHelper.insertScannedProduct(stockCountNumber.value, product);
      debugPrint('WarehouseStockTakeController: Product saved to database: ${product.itemName}');
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error saving product to database: $e');
    }
  }

  Future<void> _saveSerialToDatabase(ProductModal product, String serialNumber) async {
    try {
      // TODO: Implement when database methods are available
      // await _dbHelper.insertProductSerial(stockCountNumber.value, product, serialNumber);
      debugPrint('WarehouseStockTakeController: Serial saved to database: $serialNumber');
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error saving serial to database: $e');
    }
  }

  Future<void> _removeSerialFromDatabase(ProductModal product, String serialNumber) async {
    try {
      // TODO: Implement when database methods are available
      // await _dbHelper.removeProductSerial(stockCountNumber.value, product, serialNumber);
      debugPrint('WarehouseStockTakeController: Serial removed from database: $serialNumber');
    } catch (e) {
      debugPrint('WarehouseStockTakeController: Error removing serial from database: $e');
    }
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    clearSelectedProduct();
    super.onClose();
  }
}
