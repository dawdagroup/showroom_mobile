import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../modals/purchase_order_details_modal.dart';

class PurchaseOderController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, RxSet<String>> scannedSerials = <String, RxSet<String>>{}.obs;

  /// Observable po number.
  var purchaseOrderNumber = ''.obs;
  var purchaseOrderId = 0.obs;

  PurchaseOderController(PurchaseOrderDetailsModal purchaseOrderDetailsObj) {
    loadScans(purchaseOrderDetailsObj);
  }

  
  // load existing serial numbers form the database
  Future<void> loadScans(PurchaseOrderDetailsModal purchaseOrderDetailsObj) async {
    // Clear any existing data first to ensure clean state
    scannedSerials.clear();
    
    // Set the purchase order number from the provided object.
    purchaseOrderNumber.value = purchaseOrderDetailsObj.documentNumber.toString();

    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    print("Purchase Order Header ID: $poHeader");

    purchaseOrderId.value = poHeader;

    // load all the products
    for (var product in purchaseOrderDetailsObj.lineItems) {
      // add the product to the db
      var productExists = await _dbHelper.getOrCreatePurchaseOrderProducts(poHeader, product.itemCode);

      print("Product Exists: $productExists");

      if (productExists.isEmpty) {
        print("No product found for item code ${product.itemCode}. Skipping.");
        continue; // Skip if no product exists for the item code.
      }

      int productId = productExists[0]['id'] as int;

      // Initialize the set for the item code.
      scannedSerials.putIfAbsent(product.itemCode, () => <String>{}.obs);

      // Check if the product has a model number and update the item code accordingly.
      var productSerialNumbers = await _dbHelper.getPurchaseOrderProductSerialNumbers(productId);

      if(productSerialNumbers.isEmpty) {
        print("No serial numbers found for item code ${product.itemCode}. Skipping.");
        continue; // Skip if no serial numbers exist for the product.
      }

      // add the product serial numbers to the set.
      for (var serial in productSerialNumbers) {
        scannedSerials[product.itemCode]!.add(serial['serial_number'] as String);
      }
    }

    update();
  }

  
  // adds serial numbers
  Future<bool> addProductSerialNumber(String itemCode, String serialNumber) async {
    // check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return false;
    }

    // check if the product is already scanned
    if (scannedSerials.containsKey(itemCode) && scannedSerials[itemCode]!.contains(serialNumber)) {
      return false;
    }

    for (var key in scannedSerials.keys) {
      if (scannedSerials[key]!.contains(serialNumber)) {
        return false;
      }
    }
      // add the product to the db
    var productExists = await _dbHelper.getPurchaseOrderProduct(purchaseOrderId.toInt(), itemCode);

    if (productExists.isEmpty) {
      // If the product does not exist, create it.
      productExists = await _dbHelper.getOrCreatePurchaseOrderProducts(purchaseOrderId.toInt(), itemCode);
    }

    int productId = productExists[0]['id'] as int;

    // proceed to add the serial number.
    await _dbHelper.insertPurchaseOrderProductSerialNumber(productId, serialNumber);

    scannedSerials.putIfAbsent(itemCode, () => <String>{}.obs);
    scannedSerials[itemCode]!.add(serialNumber);

    update();

    return true;
  }

  
  // remove serial number
  Future<void> removeProductSerialNumber(String itemCode, String serialNumber) async {
    // check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty || !scannedSerials.containsKey(itemCode) || !scannedSerials[itemCode]!.contains(serialNumber)) {
      return;
    }

      // add the product to the db
    var productExists = await _dbHelper.getPurchaseOrderProduct(purchaseOrderId.toInt(), itemCode);

    int productId = productExists[0]['id'] as int;

    await _dbHelper.deletePurchaseOrderProductSerialNumber(productId, serialNumber);

    scannedSerials[itemCode]!.remove(serialNumber);

    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();
    update();
  }

  Future<Map<String, List<String>>> getCartDetails() async {
    // Check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return {};
    }

    
    Map<String, List<String>> cartDetails = {};

    for (var itemCode in scannedSerials.keys) {
      if (scannedSerials[itemCode]!.isNotEmpty) {
        cartDetails[itemCode] = scannedSerials[itemCode]!.toList();
      }
    }

    return cartDetails;

  }

  Future<void> clearCart() async{
    // Check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return;
    }

    // Clear the scanned products from the database
    await _dbHelper.deletePurchaseOrder(purchaseOrderId.toInt());

    // Clear the scanned products from the in-memory map
    scannedSerials.clear();
    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();
    update();
  }





}