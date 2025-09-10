
import 'dart:convert';

import '../modals/product_modal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../modals/showroom_modal.dart';
import '../modals/warehouse_modal.dart';
import 'sql_commands.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if not already initialized
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database directory.
    final databasePath = await getDatabasesPath();
    
    // Retrieve the current release version using package_info_plus.
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    // Optional: sanitize the version string (replace dots with underscores) if needed.
    final sanitizedVersion = version.replaceAll('.', '_');

    // Build the database file name including the version.
    final path = join(databasePath, 'azone_$sanitizedVersion.db');

    // Open (or create) the database.
    return await openDatabase(
      path,
      version: 1, // Schema version. This can be incremented independently.
      onCreate: _onCreate,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For instance, if newVersion is 2, add any new tables:
    if (oldVersion < 2) {
      // Assuming that you want to add a table that wasn't there before.
      await db.execute('''
        CREATE TABLE new_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      // If you added new tables in your list, you can execute them here.
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    for (var table in tablesCreationCommands) {
      await db.execute(table);
    }
  }

  // Method to execute custom SQL commands
  Future<void> executeSql(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  Future<void> initializeDB() async {
    await database; // Force database initialization
  }

  Future<int> insertRaw(String sql, List<Object?>? arguments) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> deleteRaw(String sql, List<Object?>? arguments) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<List<Map<String, dynamic>>> queryRaw(String sql, List<Object?>? arguments) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }

  //get showrooms
  Future<ShowroomModal?> getShowroom() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM showroom');

    if(results.isNotEmpty){
      return showroomModalFromJson(jsonEncode(results[0]));
    }

    return null;
  }
  
  // insert showroom
  Future<void> insertShowroom(Map<String, dynamic> showroom) async {
    final db = await database;
    // delete all the data in the showroom table

    await db.rawDelete('DELETE FROM showroom WHERE 1=1');

    // insert the data into the showroom table
    await insertRaw('INSERT INTO showroom (showroom_id, name, region) VALUES (?, ?, ?)', [showroom["id"], showroom["name"], showroom["region_id"].toString()],);
  }

  // get warehouse
  Future<List<WarehouseModal>> getWarehouses() async {
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM warehouse');

    List<WarehouseModal> warehouses = [];

    if(results.isNotEmpty){
      for (var warehouse in results) {
        warehouses.add(warehouseModalFromJson(jsonEncode(warehouse)));
      }
    }

    return warehouses;
  }

  // insert warehouse
  Future<void> insertWarehouse(List<dynamic> warehouseList) async {
    final db = await database;
    // delete all the data in the warehouse table
    await db.rawDelete('DELETE FROM warehouse WHERE 1=1');

    // insert the data into the warehouse table
    for (var warehouse in warehouseList) {
      await insertRaw('INSERT INTO warehouse (code, name, region, is_display,is_store,is_virtual,is_sellable,is_hq_store) VALUES (?,?,?,?,?,?,?,?)', [
        warehouse["code"], warehouse["name"], warehouse["id"].toString(),
        warehouse["is_display"], warehouse["is_store"], warehouse["is_virtual"],
        warehouse["is_salleble_display"], warehouse["is_hq_warehouse"]
      ],);
    }
  }

  // get business partners
  Future<List<Map<String, dynamic>>> getBusinessPartners() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM business_partners');
  }

  // insert business partners
  Future<void> insertBusinessPartners(List<dynamic> businessPartnersList) async {
    final db = await database;
    // delete all the data in the business_partners table
    await db.rawDelete('DELETE FROM business_partners WHERE 1=1');
    
    // insert the data into the business_partners table
    for (var businessPartner in businessPartnersList) {
      await insertRaw('INSERT INTO business_partners (name, code, requires_customer_id, requires_full_payment, auto_print_receipt, status, requires_partial_payment, eligile_for_loyalty, is_glovo) VALUES (?,?,?,?,?,?,?,?,?)', [
        businessPartner["name"], businessPartner["code"], businessPartner["requires_customer_id"],
        businessPartner["requires_full_payment"], businessPartner["auto_print_receipt"], businessPartner["status"],
        businessPartner["requires_partial_payment"], businessPartner["eligile_for_loyalty"], businessPartner["is_glovo"]
      ],);
    }
  }

  // save product changes
  Future<void> saveCartProductRequest(ProductModal product, String taxtGroup, String warehouseCode, String pickupLocation, String discount) async {
    final db = await database;

    // get the product id
    var results = await db.rawQuery('SELECT id FROM cart_products WHERE item_code = ?', [product.itemCode]);

    if(results.isNotEmpty){
      // delete all the cart_product_request for the product
      await db.rawDelete('DELETE FROM cart_product_request WHERE cart_products_id = ?', [results[0]["id"]]);

      // insert the data into the cart_product_request table
      await insertRaw('INSERT INTO cart_product_request (cart_products_id, tax_group, warehouse_code, pickup_location, discount) VALUES (?,?,?,?,?)', [
        results[0]["id"], taxtGroup, warehouseCode, pickupLocation, discount
      ],);
    }
    
  }

  //get cart products request
  Future<List<Map<String, dynamic>>> getCartProductsRequest() async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM cart_product_request');
  }

  // insert cart product serial number
  Future<void> insertCartProductSerialNumber(int cartProductsId, String serialNumber) async {
    // check if the serial number already exists
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM cart_product_serial_number WHERE cart_products_id = ? AND serial_number = ?', [cartProductsId, serialNumber]);

    if(results.isNotEmpty){
      return;
    }
    // insert the data into the cart_product_serial_number table
    await insertRaw('INSERT INTO cart_product_serial_number (cart_products_id, serial_number) VALUES (?,?)', [
      cartProductsId, serialNumber
    ],);
  }

  // get cart product serial number
  Future<List<Map<String, dynamic>>> getCartProductSerialNumber(int cartProductsId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM cart_product_serial_number WHERE cart_products_id = ?', [cartProductsId]);
  }

  // Helper methods
  Future<int> getOrCreateProductId(ProductModal product) async {
    final existingProduct = await queryRaw('SELECT id, quantity FROM cart_products WHERE item_code = ?',[product.itemCode], );

    if (existingProduct.isNotEmpty) {
      return existingProduct.first['id'];
    } else {
      return await insertRaw('INSERT INTO cart_products (item_code, quantity, price, initial_discount) VALUES (?, ?, ?, ?)', [product.itemCode, 1, product.price, product.discount],);
    }
  }

  Future<int> getOrCreateInvoiceDeliveryScan(String invoiceNumber) async {
    final existingData = await queryRaw('SELECT * FROM invoice_delivery_scan WHERE invoice_number = ?', [invoiceNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }
    return await insertRaw('INSERT INTO invoice_delivery_scan (invoice_number) VALUES (?)', [invoiceNumber]);
  }

  Future<List<Map<String, dynamic>>> getInvoiceDeliveryProducts(int invoiceDeliveryId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM invoice_delivery_products WHERE invoice_delivery_id = ?', [invoiceDeliveryId]);
  }

  Future<List<Map<String, dynamic>>> getInvoiceDeliveryProductSerialNumbers(int invoiceDeliveryId, String itemCode) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM invoice_delivery_products WHERE invoice_delivery_id = ? AND item_code = ?', [invoiceDeliveryId, itemCode]);
  }

  Future<void> insertInvoiceDeliveryProduct(int invoiceDeliveryId, String itemCode, String serialNumber) async {
    await insertRaw('INSERT INTO invoice_delivery_products (invoice_delivery_id, item_code, serial_number) VALUES (?, ?, ?)', [invoiceDeliveryId, itemCode, serialNumber],);
  }

  Future<void> deleteInvoiceDeliveryProduct(int invoiceDeliveryId, String itemCode, String serialNumber) async {
    await deleteRaw('DELETE FROM invoice_delivery_products WHERE invoice_delivery_id = ? AND item_code = ? AND serial_number = ?', [invoiceDeliveryId, itemCode, serialNumber]);
  }

  Future<void> deleteInvoiceDelivery(int invoiceDeliveryId) async {
    // Delete products first (child records)
    await deleteRaw('DELETE FROM invoice_delivery_products WHERE invoice_delivery_id = ?', [invoiceDeliveryId]);
    
    // Delete the main invoice delivery record last
    await deleteRaw('DELETE FROM invoice_delivery_scan WHERE id = ?', [invoiceDeliveryId]);
  }
  
  Future<int> getOrCreatePurchaseOrderScan(String purchaseOrderNumber) async {
    final existingData = await queryRaw('SELECT * FROM purchase_order_receipt WHERE po_number = ?', [purchaseOrderNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }
    return await insertRaw('INSERT INTO purchase_order_receipt (po_number) VALUES (?)', [purchaseOrderNumber]);
  }

  Future<List<Map<String, dynamic>>> getOrCreatePurchaseOrderProducts (int goodsIssueId, String itemCode) async {
    final existingData = await queryRaw('SELECT * FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ? AND item_code = ?', [goodsIssueId, itemCode]);

    if (existingData.isNotEmpty) {
      return existingData;
    } else {
      // Insert a new goods issue product record
      await insertRaw('INSERT INTO purchase_order_receipt_products (purchase_order_receipt_id, item_code) VALUES (?, ?)', [goodsIssueId, itemCode]);

      // Return the newly inserted product
      return await queryRaw('SELECT * FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ? AND item_code = ?', [goodsIssueId, itemCode]);
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseOrderReceiptProducts(int purchaseOrderReceiptId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ?', [purchaseOrderReceiptId]);
  }

  Future<List<Map<String, dynamic>>> getPurchaseOrderProduct(int purchaseOrderReceiptId, String itemCode) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ? AND item_code = ?', [purchaseOrderReceiptId, itemCode]);
  }

  // get po product serial numbers
  Future<List<Map<String, dynamic>>>  getPurchaseOrderProductSerialNumbers(int productId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM purchase_order_receipt_serial_numbers WHERE purchase_order_receipt_product_id = ?', [productId]);
  }

  Future<List<Map<String, dynamic>>> getPurchaseOrderProducts(int purchaseOrderReceiptId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ?', [purchaseOrderReceiptId]);
  }

  Future<void> insertPurchaseOrderProductSerialNumber(int productId, String serialNumber) async {
    // check if the serial number already exists
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM purchase_order_receipt_serial_numbers WHERE purchase_order_receipt_product_id = ? AND serial_number = ?', [productId, serialNumber]);

    if(results.isNotEmpty){
      return;
    }
    // insert the data into the purchase_order_receipt_serial_numbers table
    await insertRaw('INSERT INTO purchase_order_receipt_serial_numbers (purchase_order_receipt_product_id, serial_number) VALUES (?,?)', [
      productId, serialNumber
    ],);
  }

  Future<void> deletePurchaseOrderProductSerialNumber(int productId, String serialNumber) async {
    await deleteRaw('DELETE FROM purchase_order_receipt_serial_numbers WHERE purchase_order_receipt_product_id = ? AND serial_number = ?', [productId, serialNumber]);
  }

  Future<void> deletePurchaseOrder(int purchaseOrderReceiptId) async {
    // Delete serial numbers first (must be done before deleting products due to foreign key constraints)
    await deleteRaw('DELETE FROM purchase_order_receipt_serial_numbers WHERE purchase_order_receipt_product_id IN (SELECT id FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ?)', [purchaseOrderReceiptId]);
    
    // Delete products second
    await deleteRaw('DELETE FROM purchase_order_receipt_products WHERE purchase_order_receipt_id = ?', [purchaseOrderReceiptId]);
    
    // Delete the main purchase order record last
    await deleteRaw('DELETE FROM purchase_order_receipt WHERE id = ?', [purchaseOrderReceiptId]);
  }

  Future<int> getOrCreateSalesOrderDeliveryScan(String salesOrderNumber) async {
    final existingData = await queryRaw('SELECT * FROM sales_order_delivery_scan WHERE sales_order_number = ?', [salesOrderNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }
    return await insertRaw('INSERT INTO sales_order_delivery_scan (sales_order_number) VALUES (?)', [salesOrderNumber]);
  }

  Future<List<Map<String, dynamic>>> getSalesOrderDeliveryProducts(int salesOrderDeliveryId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM sales_order_delivery_products WHERE sales_order_delivery_id = ?', [salesOrderDeliveryId]);
  }

  Future<List<Map<String, dynamic>>> getSalesOrderDeliveryProductSerialNumbers(int salesOrderDeliveryId, String itemCode) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM sales_order_delivery_products WHERE sales_order_delivery_id = ? AND item_code = ?', [salesOrderDeliveryId, itemCode]);
  }

  Future<void> insertSalesOrderDeliveryProduct(int salesOrderDeliveryId, String itemCode, String serialNumber) async {
    await insertRaw('INSERT INTO sales_order_delivery_products (sales_order_delivery_id, item_code, serial_number) VALUES (?, ?, ?)', [salesOrderDeliveryId, itemCode, serialNumber],);
  }

  Future<void> deleteSalesOrderDeliveryProduct(int salesOrderDeliveryId, String itemCode, String serialNumber) async {
    await deleteRaw('DELETE FROM sales_order_delivery_products WHERE sales_order_delivery_id = ? AND item_code = ? AND serial_number = ?', [salesOrderDeliveryId, itemCode, serialNumber]);
  }

  Future<void> deleteSalesOrderDelivery(int salesOrderDeliveryId) async {
    // Delete products first (child records)
    await deleteRaw('DELETE FROM sales_order_delivery_products WHERE sales_order_delivery_id = ?', [salesOrderDeliveryId]);
    
    // Delete the main sales order delivery record last
    await deleteRaw('DELETE FROM sales_order_delivery_scan WHERE id = ?', [salesOrderDeliveryId]);
  }

  Future<int> getOrCreateGoodsIssueScan(String goodsIssueNumber) async {
    final existingData = await queryRaw('SELECT * FROM goods_issue_scan WHERE goods_issue_number = ?', [goodsIssueNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }
    return await insertRaw('INSERT INTO goods_issue_scan (goods_issue_number) VALUES (?)', [goodsIssueNumber]);
  }

  Future<List<Map<String, dynamic>>> getOrCreateGoodsIssueProducts(int goodsIssueId, String itemCode, String modelNumber) async {
    final existingData = await queryRaw('SELECT * FROM goods_issue_products WHERE goods_issue_id = ? AND item_code = ? ', [goodsIssueId, itemCode]);

    if (existingData.isNotEmpty) {
      return existingData;
    } else {
      // Insert a new goods issue product record
      await insertRaw('INSERT INTO goods_issue_products (goods_issue_id, item_code, model_number) VALUES (?, ?, ?)', [goodsIssueId, itemCode, modelNumber]);

      // Return the newly inserted product
      return await queryRaw('SELECT * FROM goods_issue_products WHERE goods_issue_id = ? AND item_code = ?', [goodsIssueId, itemCode]);
    }
  }

  Future<List<Map<String, dynamic>>> getGoodsIssueProducts(int goodsIssueId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM goods_issue_products WHERE goods_issue_id = ?', [goodsIssueId]);
  }

  Future<List<Map<String, dynamic>>> getGoodsIssueProduct(int goodsIssueId, String itemCode) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM goods_issue_products WHERE goods_issue_id = ? AND item_code = ?', [goodsIssueId, itemCode]);
  }

  Future<List<Map<String, dynamic>>> getGoodsIssueProductSerialNumbers(int goodsIssueProductId) async {
    final results = await queryRaw('SELECT * FROM goods_issue_product_serial_numbers WHERE goods_issue_product_id = ?', [goodsIssueProductId]);

    if (results.isNotEmpty) {
      return results;
    } else {
      return [];
    }
  }

  Future<void> insertGoodsIssueProduct(int goodsIssueId, String itemCode, String serialNumber) async {
    await insertRaw('INSERT INTO goods_issue_products (goods_issue_id, item_code, serial_number) VALUES (?, ?, ?)', [goodsIssueId, itemCode, serialNumber],);
  }

  Future<void> insertGoodsIssueProductSerialNumber(int goodsIssueProductId, String serialNumber) async {
    // check if the serial number already exists
    final db = await database;
    var results = await db.rawQuery('SELECT * FROM goods_issue_product_serial_numbers WHERE goods_issue_product_id = ? AND serial_number = ?', [goodsIssueProductId, serialNumber]);

    if(results.isNotEmpty){
      return;
    }
    // insert the data into the goods_issue_product_serial_numbers table
    await insertRaw('INSERT INTO goods_issue_product_serial_numbers (goods_issue_product_id, serial_number) VALUES (?,?)', [
      goodsIssueProductId, serialNumber
    ],);
  }

  Future<void> deleteGoodsIssueProductSerialNumber(int goodsIssueProductId, String serialNumber) async {
    await deleteRaw('DELETE FROM goods_issue_product_serial_numbers WHERE goods_issue_product_id = ? AND serial_number = ?', [goodsIssueProductId, serialNumber]);
  }

  Future<void> deleteGoodsIssue(int goodsIssueId) async {
    // Delete serial numbers first (must be done before deleting products due to foreign key constraints)
    await deleteRaw('DELETE FROM goods_issue_product_serial_numbers WHERE goods_issue_product_id IN (SELECT id FROM goods_issue_products WHERE goods_issue_id = ?)', [goodsIssueId]);
    
    // Delete products second
    await deleteRaw('DELETE FROM goods_issue_products WHERE goods_issue_id = ?', [goodsIssueId]);
    
    // Delete the main goods issue record last
    await deleteRaw('DELETE FROM goods_issue_scan WHERE id = ?', [goodsIssueId]);
  }

  Future<int> getOrCreateStockTransferScan(String stockTransferNumber) async {
    final existingData = await queryRaw('SELECT * FROM stock_transfer_scan WHERE stock_transfer_number = ?', [stockTransferNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }
    return await insertRaw('INSERT INTO stock_transfer_scan (stock_transfer_number) VALUES (?)', [stockTransferNumber]);
  }

  Future<List<Map<String, dynamic>>> getStockTransferProducts(int stockTransferId) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM stock_transfer_products WHERE stock_transfer_id = ?', [stockTransferId]);
  }

  Future<List<Map<String, dynamic>>> getStockTransferProductSerialNumbers(int stockTransferId, String itemCode) async {
    final db = await database;
    return await db.rawQuery('SELECT * FROM stock_transfer_products WHERE stock_transfer_id = ? AND item_code = ?', [stockTransferId, itemCode]);
  }

  Future<void> insertStockTransferProduct(int stockTransferId, String itemCode, String serialNumber) async {
    await insertRaw('INSERT INTO stock_transfer_products (stock_transfer_id, item_code, serial_number) VALUES (?, ?, ?)', [stockTransferId, itemCode, serialNumber],);
  }

  Future<void> deleteStockTransferProduct(int stockTransferId, String itemCode, String serialNumber) async {
    await deleteRaw('DELETE FROM stock_transfer_products WHERE stock_transfer_id = ? AND item_code = ? AND serial_number = ?', [stockTransferId, itemCode, serialNumber]);
  }

  Future<void> deleteStockTransfer(int stockTransferId) async {
    // Delete products first (child records)
    await deleteRaw('DELETE FROM stock_transfer_products WHERE stock_transfer_id = ?', [stockTransferId]);
    
    // Delete the main stock transfer record last
    await deleteRaw('DELETE FROM stock_transfer_scan WHERE id = ?', [stockTransferId]);
  }
  
  Future<int?> getPhysicalStockCount(String stockCountNumber) async {
    final existingData = await queryRaw('SELECT * FROM physical_stock_take WHERE stock_count_number = ?', [stockCountNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }

    return null;
  }

  Future<int> getOrCreatePhysicalStockCount(String stockCountNumber, int createdBy, String createdByName, String stockCountType, String showroomName, String warehouseName, String warehouseCode, String physicalStockCountTypeName) async {
    final existingData = await queryRaw('SELECT * FROM physical_stock_take WHERE stock_count_number = ?', [stockCountNumber]);

    if (existingData.isNotEmpty) {
      return existingData.first['id'];
    }

    // Insert a new physical stock count record
    return await insertRaw('INSERT INTO physical_stock_take (stock_count_number, created_by, created_by_name, stock_count_type, showroom_name, warehouse_name, warehouse_code, physical_stock_count_type_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', 
    [
      stockCountNumber, createdBy, createdByName, stockCountType, showroomName, warehouseName, warehouseCode, physicalStockCountTypeName
    ]);
  }

  Future<List<Map<String, dynamic>>> getPhysicalStockCountProducts(int physicalStockCountId) async {
    final results = await queryRaw('SELECT * FROM physical_stock_take_products WHERE physical_stock_count_id = ?', [physicalStockCountId]);

    if (results.isNotEmpty) {
      return results;
    } else {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getPhysicalStockCountProduct(int physicalStockCountId, String barcode) async {
    final results = await queryRaw('SELECT * FROM physical_stock_take_products WHERE physical_stock_count_id = ? AND barcode = ?', [physicalStockCountId, barcode]);

    if (results.isNotEmpty) {
      return results;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getOrCreateStockTakeProduct(int physicalStockCountId, String barcode, String itemCode, String itemName, String itemGroup, String itemBrand, String itemPictureName, String modelNumber) async {
    final results = await queryRaw('SELECT * FROM physical_stock_take_products WHERE physical_stock_count_id = ? AND item_code = ?', [physicalStockCountId, itemCode]);

    if (results.isNotEmpty) {
      return results;
    } else {
      // Insert a new stock take product record
      await insertRaw('INSERT INTO physical_stock_take_products (physical_stock_count_id, barcode, item_code, item_name, item_group, item_brand, item_picture_name, model_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', 
      [
        physicalStockCountId, barcode, itemCode, itemName, itemGroup, itemBrand, itemPictureName, modelNumber
      ]);
      return await queryRaw('SELECT * FROM physical_stock_take_products WHERE physical_stock_count_id = ? AND item_code = ?', [physicalStockCountId, itemCode]);
    }
  }

  Future<void> insertStockTakeProductSerialNumber(int physicalStockCountProductId, String serialNumber) async {
    await insertRaw('INSERT INTO physical_stock_take_serial_numbers (physical_stock_count_product_id, serial_number) VALUES (?, ?)', [physicalStockCountProductId, serialNumber],);
  }

  Future<List<Map<String, dynamic>>> getStockTakeProductSerialNumbers(int physicalStockCountProductId) async {
    return await queryRaw('SELECT * FROM physical_stock_take_serial_numbers WHERE physical_stock_count_product_id = ?', [physicalStockCountProductId]);
  }

  Future<void> deleteStockTakeProductSerialNumber(int physicalStockCountProductId, String serialNumber) async {
    await deleteRaw('DELETE FROM physical_stock_take_serial_numbers WHERE physical_stock_count_product_id = ? AND serial_number = ?', [physicalStockCountProductId, serialNumber]);
  }

  Future<void> clearPhysicalStockCountProducts(int physicalStockCountId) async {
    // Delete serial numbers first (must be done before deleting products due to foreign key constraints)
    await deleteRaw('DELETE FROM physical_stock_take_serial_numbers WHERE physical_stock_count_product_id IN (SELECT id FROM physical_stock_take_products WHERE physical_stock_count_id = ?)', [physicalStockCountId]);
    
    // Delete products second
    await deleteRaw('DELETE FROM physical_stock_take_products WHERE physical_stock_count_id = ?', [physicalStockCountId]);
    
    // Delete the main physical stock take record last
    await deleteRaw('DELETE FROM physical_stock_take WHERE id = ?', [physicalStockCountId]);
  }

  Future<void> removePhysicalStockCountProduct(int physicalStockCountId, String barcode) async {
    // First get the product ID
    var productResult = await queryRaw(
      'SELECT id FROM physical_stock_take_products WHERE physical_stock_count_id = ? AND barcode = ?',
      [physicalStockCountId, barcode]
    );
    
    if (productResult.isNotEmpty) {
      int productId = productResult.first['id'];
      
      // Delete all serial numbers for this product
      await deleteRaw('DELETE FROM physical_stock_take_serial_numbers WHERE physical_stock_count_product_id = ?', [productId]);
      
      // Delete the product record
      await deleteRaw('DELETE FROM physical_stock_take_products WHERE id = ?', [productId]);
    }
  }

}