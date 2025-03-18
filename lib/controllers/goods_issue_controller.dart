import 'package:get/get.dart';
import '../db/database_helper.dart';

class GoodsIssueController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// In‑memory map for quick duplicate checks.
  /// Key: product/item identifier; Value: set of scanned serial numbers.
  RxMap<String, Set<String>> scannedSerials = <String, Set<String>>{}.obs;

  /// Observable goods issue number.
  /// This is the goods issue number that is being received.
  var goodsIssueNumber = ''.obs;

  // load existing serial numbers form the database
  Future<void> loadScans() async {
    // check if goods issue number is set
    if (goodsIssueNumber.value.isEmpty) {
      return;
    }

    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueNumber.value);

    var goodsIssueProductSerialNumbers = await _dbHelper.getGoodsIssueProducts(giHeader);

    if (goodsIssueProductSerialNumbers.isNotEmpty) {
      scannedSerials.clear();
      for (var product in goodsIssueProductSerialNumbers) {
        scannedSerials.putIfAbsent(product['item_code'], () => <String>{});
        scannedSerials[product['item_code']]!.add(product['serial_number']);
      }
    }

    update();
  }

  // adds serial numbers
  Future<bool> addProductSerialNumber(String itemCode, String serialNumber) async {
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

    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueNumber.value);

    await _dbHelper.insertGoodsIssueProduct(giHeader, itemCode, serialNumber);

    scannedSerials.putIfAbsent(itemCode, () => <String>{});
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

    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueNumber.value);

    await _dbHelper.deleteGoodsIssueProduct(giHeader, itemCode, serialNumber);

    scannedSerials[itemCode]!.remove(serialNumber);

    // Notify Obx listeners that the map has changed:
    scannedSerials.refresh();

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
    if (goodsIssueNumber.value.isEmpty) {
      return {};
    }

    // get or create goods issue header
    var giHeader = await _dbHelper.getOrCreateGoodsIssueScan(goodsIssueNumber.value);

    var goodsIssueProductSerialNumbers = await _dbHelper.getGoodsIssueProducts(giHeader);

    Map<String, List<String>> cartDetails = {};

    if (goodsIssueProductSerialNumbers.isNotEmpty) {
      for (var product in goodsIssueProductSerialNumbers) {

        cartDetails.putIfAbsent(product['item_code'], () => <String>[]);
        cartDetails[product['item_code']]!.add(product['serial_number']);
      }
    }

    return cartDetails;

  }

}