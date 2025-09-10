import 'package:get/get.dart';
import '../db/database_helper.dart';
import '../modals/goods_issue_details_modal.dart';

class GoodsIssueController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.  
  RxMap<String, RxSet<String>> scannedSerials = <String, RxSet<String>>{}.obs;

  /// Observable goods issue number.
  /// This is the goods issue number that is being received.
  var goodsIssueNumber = ''.obs;
  var goodsIssueId = 0.obs;

  GoodsIssueController(GoodsIssueDetailsModal goodsIssueDetailsObj) {
    // Initialize the controller by loading existing scans.
    loadScans(goodsIssueDetailsObj);
  }

  // load existing serial numbers form the database
  Future<void> loadScans(GoodsIssueDetailsModal goodsIssueDetailsObj) async {
    // Clear any existing data first to ensure clean state
    scannedSerials.clear();

    // Set the goods issue number from the provided object.
    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueDetailsObj.documentNumber.toString());

    print("Goods Issue Header ID: $giHeader");

    goodsIssueNumber.value = goodsIssueDetailsObj.documentNumber.toString();
    goodsIssueId.value = giHeader;

    // load all the products
    for (var product in goodsIssueDetailsObj.lineItems) {
      // add the product to the db
      var productExists = await _dbHelper.getOrCreateGoodsIssueProducts(giHeader, product.itemCode, product.itemModelNo);

      print("Product Exists: $productExists");

      // Initialize the set for the item code.
      scannedSerials.putIfAbsent(product.itemCode, () =>  <String>{}.obs);

      // Fetch the serial numbers for the item code.
      var serialNumbers = await _dbHelper.getGoodsIssueProductSerialNumbers(productExists[0]['id'] as int);

      print("Serial Numbers for ${product.itemCode}: $serialNumbers");

      if (serialNumbers.isNotEmpty) {
        // Add the serial numbers to the set.
        for (var serial in serialNumbers) {
          scannedSerials[product.itemCode]!.add(serial['serial_number'] as String);
        }
      }
    }

    update();
  }

  // adds serial numbers
  Future<bool> addProductSerialNumber(String itemCode, String modelNumber, String serialNumber) async {
    // check if goods issue number is set
    if (goodsIssueNumber.value.isEmpty) {
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

    var productExists = await _dbHelper.getGoodsIssueProduct(goodsIssueId.value, itemCode);

    if (productExists.isEmpty) {
      // If the product does not exist, create it.
      productExists = await _dbHelper.getOrCreateGoodsIssueProducts(goodsIssueId.value, itemCode, modelNumber);
    }

    // If the product exists, we can proceed to add the serial number.
    if (productExists.isEmpty) {
      print("Product does not exist in the database.");
      return false;
    }

    var productId = productExists[0]['id'] as int;

    await _dbHelper.insertGoodsIssueProductSerialNumber(productId, serialNumber);

    scannedSerials.putIfAbsent(itemCode, () => <String>{}.obs);
    scannedSerials[itemCode]!.add(serialNumber);

    update();

    return true;
  }

  // removes serial numbers
  Future<bool> removeProductSerialNumber(String itemCode, String serialNumber) async {
    // check if goods issue number is set
    if (goodsIssueNumber.value.isEmpty) {
      return false;
    }

    // check if the product is already scanned
    if (!scannedSerials.containsKey(itemCode) || !scannedSerials[itemCode]!.contains(serialNumber)) {
      return false;
    }

    
    var productExists = await _dbHelper.getGoodsIssueProduct(goodsIssueId.value, itemCode);

    if (productExists.isEmpty) {
      print("Product does not exist in the database.");
      return false;
    }

    var productId = productExists[0]['id'] as int;

    // Remove the serial number from the database.
    await _dbHelper.deleteGoodsIssueProductSerialNumber(productId, serialNumber);

    scannedSerials[itemCode]!.remove(serialNumber);

    update();

    return true;
  }

  // clear all serial numbers
  Future<void> clearScans() async {
    // check if goods issue number is set
    if (goodsIssueNumber.value.isEmpty) {
      return;
    }

    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueNumber.value);

    await _dbHelper.deleteGoodsIssue(giHeader);

    scannedSerials.clear();

    update();
  }

  // get cart details
  Future<Map<String, List<String>>> getCartDetails() async {
    // check if goods issue number is set
    if (goodsIssueNumber.value.isEmpty || scannedSerials.isEmpty) {
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

}