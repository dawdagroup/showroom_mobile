import 'package:get/get.dart';
import '../db/database_helper.dart';

class PurchaseOderController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, Set<String>> scannedSerials = <String, Set<String>>{}.obs;

  
  /// Observable po number.
  var purchaseOrderNumber = ''.obs;

  
  // load existing serial numbers form the database
  Future<void> loadScans() async {
    // check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return;
    }

    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    var purchaseOrderProductSerialNumbers = await _dbHelper.getInvoiceDeliveryProducts(poHeader);

    if (purchaseOrderProductSerialNumbers.isNotEmpty) {
      scannedSerials.clear();
      for (var product in purchaseOrderProductSerialNumbers) {
        scannedSerials.putIfAbsent(product['item_code'], () => <String>{});
        scannedSerials[product['item_code']]!.add(product['serial_number']);
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

    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    await _dbHelper.insertPurchaseOrderProduct(poHeader, itemCode, serialNumber);

    scannedSerials.putIfAbsent(itemCode, () => <String>{});
    scannedSerials[itemCode]!.add(serialNumber);

    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();

    update();

    return true;
  }

  
  // remove serial number
  Future<void> removeProductSerialNumber(String itemCode, String serialNumber) async {
    // check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return;
    }

    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    await _dbHelper.deletePurchaseOrderProduct(poHeader, itemCode, serialNumber);

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

    // Get or create the invoice header
    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    // Retrieve the scanned products from the database
    var invoiceProductsSerialNumbers = await _dbHelper.getPurchaseOrderProducts(poHeader);

    // Prepare the output map
    Map<String, List<String>> cartDetails = {};

    for (var product in invoiceProductsSerialNumbers) {
      // Extract the barcode and serial number from each product record
      String itemCode = product['item_code'];

      // If the barcode already exists as a key, append to the list; otherwise, create a new list.
      if (cartDetails.containsKey(itemCode)) {
        cartDetails[itemCode]!.add(product['serial_number']);
      } else {
        cartDetails[itemCode] = [product['serial_number']];
      }
    }

    return cartDetails;
  }

  Future<void> clearCart() async{
    // Check if invoice number is set
    if (purchaseOrderNumber.value.isEmpty) {
      return;
    }

    // Get or create the invoice header
    var poHeader = await _dbHelper.getOrCreatePurchaseOrderScan(purchaseOrderNumber.value);

    // Clear the scanned products from the database
    await _dbHelper.deletePurchaseOrder(poHeader);

    // Clear the scanned products from the in-memory map
    scannedSerials.clear();
    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();
    update();
  }



}