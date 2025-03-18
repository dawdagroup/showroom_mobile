import 'package:get/get.dart';
import '../db/database_helper.dart';

class InvoiceController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, Set<String>> scannedSerials = <String, Set<String>>{}.obs;

  /// Observable invoice number.
  var invoiceNumber = ''.obs;

  // load existing serial numbers form the database
  Future<void> loadScans() async {
    // check if invoice number is set
    if (invoiceNumber.value.isEmpty) {
      return;
    }

    var invoiceHeader = await _dbHelper.getOrCreateInvoiceDeliveryScan(invoiceNumber.value);

    var invoiceProducutsSerialNumbers = await _dbHelper.getInvoiceDeliveryProducts(invoiceHeader);

    if (invoiceProducutsSerialNumbers.isNotEmpty) {
      scannedSerials.clear();
      for (var product in invoiceProducutsSerialNumbers) {
        scannedSerials.putIfAbsent(product['item_code'], () => <String>{});
        scannedSerials[product['item_code']]!.add(product['serial_number']);
      }
    }

    update();
  }

  // adds serial numbers
  Future<bool> addProductSerialNumber(String itemCode, String serialNumber) async {
    // check if invoice number is set
    if (invoiceNumber.value.isEmpty) {
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

    var invoiceHeader = await _dbHelper.getOrCreateInvoiceDeliveryScan(invoiceNumber.value);

    await _dbHelper.insertInvoiceDeliveryProduct(invoiceHeader, itemCode, serialNumber);

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
    if (invoiceNumber.value.isEmpty) {
      return;
    }

    var invoiceHeader = await _dbHelper.getOrCreateInvoiceDeliveryScan(invoiceNumber.value);

    await _dbHelper.deleteInvoiceDeliveryProduct(invoiceHeader, itemCode, serialNumber);

    scannedSerials[itemCode]!.remove(serialNumber);

    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();
    update();
  }

  Future<Map<String, List<String>>> getCartDetails() async {
    // Check if invoice number is set
    if (invoiceNumber.value.isEmpty) {
      return {};
    }

    // Get or create the invoice header
    var invoiceHeader = await _dbHelper.getOrCreateInvoiceDeliveryScan(invoiceNumber.value);

    // Retrieve the scanned products from the database
    var invoiceProductsSerialNumbers = await _dbHelper.getInvoiceDeliveryProducts(invoiceHeader);

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
    if (invoiceNumber.value.isEmpty) {
      return;
    }

    // Get or create the invoice header
    var invoiceHeader = await _dbHelper.getOrCreateInvoiceDeliveryScan(invoiceNumber.value);

    // Clear the scanned products from the database
    await _dbHelper.deleteInvoiceDelivery(invoiceHeader);

    // Clear the scanned products from the in-memory map
    scannedSerials.clear();
    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();
    update();
  }


}
