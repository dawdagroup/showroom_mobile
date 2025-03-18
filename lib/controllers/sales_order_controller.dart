import 'package:get/get.dart';
import '../db/database_helper.dart';

class SalesOrderController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, Set<String>> scannedSerials = <String, Set<String>>{}.obs;

  /// Observable sales order number.
  var salesOrderNumber = ''.obs;

  // load existing serial numbers form the database
  Future<void> loadScans() async {
    // check if sales order number is set
    if (salesOrderNumber.value.isEmpty) {
      return;
    }

    var salesOrderHeader = await _dbHelper.getOrCreateSalesOrderDeliveryScan(salesOrderNumber.value);

    var salesOrderProducutsSerialNumbers = await _dbHelper.getSalesOrderDeliveryProducts(salesOrderHeader);

    if (salesOrderProducutsSerialNumbers.isNotEmpty) {
      scannedSerials.clear();
      for (var product in salesOrderProducutsSerialNumbers) {
        scannedSerials.putIfAbsent(product['item_code'], () => <String>{});
        scannedSerials[product['item_code']]!.add(product['serial_number']);
      }
    }

    update();
  }

  // adds serial numbers
  Future<bool> addProductSerialNumber(String itemCode, String serialNumber) async {
    // check if sales order number is set
    if (salesOrderNumber.value.isEmpty) {
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

    var salesOrderHeader = await _dbHelper.getOrCreateSalesOrderDeliveryScan(salesOrderNumber.value);

    await _dbHelper.insertSalesOrderDeliveryProduct(salesOrderHeader, itemCode, serialNumber);

    scannedSerials.putIfAbsent(itemCode, () => <String>{});
    scannedSerials[itemCode]!.add(serialNumber);

    update();

    return true;
  }

  // removes serial numbers
  Future<bool> removeProductSerialNumber(String itemCode, String serialNumber) async {
    // check if sales order number is set
    if (salesOrderNumber.value.isEmpty) {
      return false;
    }

    // check if the product is already scanned
    if (!scannedSerials.containsKey(itemCode) || !scannedSerials[itemCode]!.contains(serialNumber)) {
      return false;
    }

    var salesOrderHeader = await _dbHelper.getOrCreateSalesOrderDeliveryScan(salesOrderNumber.value);

    await _dbHelper.deleteSalesOrderDeliveryProduct(salesOrderHeader, itemCode, serialNumber);

    scannedSerials[itemCode]!.remove(serialNumber);

    if (scannedSerials[itemCode]!.isEmpty) {
      scannedSerials.remove(itemCode);
    }

    update();

    return true;
  }

  // clear all serial numbers
  Future<void> clearScans() async {
    // check if sales order number is set
    if (salesOrderNumber.value.isEmpty) {
      return;
    }

    var salesOrderHeader = await _dbHelper.getOrCreateSalesOrderDeliveryScan(salesOrderNumber.value);

    await _dbHelper.deleteSalesOrderDelivery(salesOrderHeader);

    scannedSerials.clear();

    update();
  }

  // get cart details
  Future<Map<String, List<String>>> getCartDetails() async {
    // Check if invoice number is set
    if (salesOrderNumber.value.isEmpty) {
      return {};
    }

    // Get or create the invoice header
    var salesOrderHeader = await _dbHelper.getOrCreateSalesOrderDeliveryScan(salesOrderNumber.value);

    // Retrieve the scanned products from the database
    var salesOrderProductsSerialNumbers = await _dbHelper.getSalesOrderDeliveryProducts(salesOrderHeader);

    // Prepare the output map
    Map<String, List<String>> cartDetails = {};

    for (var product in salesOrderProductsSerialNumbers) {
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

}