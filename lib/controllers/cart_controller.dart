// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../db/database_helper.dart';
import '../modals/product_modal.dart';
import '../providers/session_provider.dart';

class CartController extends GetxController{
  // dict to store the products in the cart
  final _products = {}.obs;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late bool isVATable = true;
  late SessionProvider sessionProvider;

  get products => _products;

  get cartBarcodes => _products.entries.map((product) => product.key.barcode).toList();
  get cartQuantity => _products.entries.map((product) => product.key.barcode).toList();

  get productSubTotal => _products.entries.map((product) => product.key.price * product.value).toList();

  get vatAmount {
    if (_products.isEmpty) {
      return 0.0; // Cart is empty, so no VAT.
    }

    double totalVAT = 0.0;

    _products.forEach((product, quantity) {

      double vatRate = product.selectedTaxGroup != null ? product.selectedTaxGroup!.rate / 100 : 0.16;
      
      double productVAT = product.price * quantity * vatRate;
      totalVAT += productVAT;

    });

    return totalVAT;
  }

  get subTotal => _products.entries.isEmpty ? 0 : _products.entries.map((product) => product.key.price * product.value).toList().reduce((value, element) => value + element);
  get total => vatAmount + subTotal;
  
  CartController(BuildContext context) {
    _initializeController(context);
  }

  // Initialize the controller
  void _initializeController(BuildContext context) {
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    _loadProductsFromDb();
  }
  
  void _incrementProductCount(ProductModal product) {
    _products[product] = (_products[product] ?? 0) + 1;
    update();
  }

  void addProduct(ProductModal product) {
    _getOrCreateProductId(product);
    _incrementProductCount(product);
  }

  void toggleVat(bool state){
    isVATable = state;
    if(_products.isNotEmpty){
      _products.forEach((key, value) {
          _products[key] = value + 1;
          _products[key] = value - 1;
          // break;
      });
      _products[0] += 1;
      _products[0] -= 1;
    }

  }

  void removeProduct(ProductModal product){
    if(_products.containsKey(product) && _products[product] == 1){
      _products.removeWhere((key, value) => key == product);
      _removeProduct(product);
    }else{
      _products[product] -= 1;
      _decreaseQuantity(product);
    }
  }

  void clearCart(){
    clearProducts();
    _products.clear();
  }

  void printProducts(){
    _products.entries.map((product) => product.key.barcode).toList();
  }

  double getProductPrice(ProductModal product){
    double price = 0;
    if(_products.isNotEmpty) {
      _products.forEach((key, value) {
        if(key.barcode == product.barcode){
          price = key.price * value;
        }
      });
    }
    return price;

  }

  bool needsApproval(){
    bool needsApproval = false;
    if(_products.isNotEmpty){
      _products.forEach((key, value) async {
        int productId = await _getOrCreateProductId(key);
        var productDetails =  await _dbHelper.queryRaw('SELECT * FROM cart_products WHERE id = ?', [productId]);

        var cartProductRequest = await _dbHelper.queryRaw('SELECT * FROM cart_product_request WHERE cart_products_id = ?', [productId]);
        

        if(cartProductRequest.isNotEmpty){

          var taxtGroup = cartProductRequest.first['tax_group'];
          var discount = cartProductRequest.first['discount'];

          try {
            if(taxtGroup != null && double.parse(taxtGroup) <= 16){
              needsApproval = true;
            }else if(discount != null && discount > 3){
              if(productDetails.isNotEmpty){
                if(productDetails.first['initial_discount'] < discount){
                  needsApproval = true;
                }
              }
            }
          } on Exception catch (e) {
            needsApproval = false;
            print(e);
          }
        }
      });
    }

    return needsApproval;
  }

  Future<void> _removeProduct(ProductModal product) async {
    final productId = await _getOrCreateProductId(product);
    await _dbHelper.deleteRaw('DELETE FROM cart_products WHERE id = ?', [productId]);
  }

  Future<void> clearProducts() async {
    _products.clear();
    await _dbHelper.executeSql('DELETE FROM cart_products WHERE 1=1');
  }

  Future<void> _decreaseQuantity(ProductModal product) async {
    final productId = await _getOrCreateProductId(product);
    await _dbHelper.executeSql('UPDATE cart_products SET quantity = quantity - 1 WHERE id = ?', [productId]);
  }

  // Load products from the database
  Future<void> _loadProductsFromDb() async {
  //   final productMaps = await _dbHelper.queryRaw('SELECT * FROM cart_products WHERE 1=1', []);
  //   String? _userSession = await sessionProvider.authProvider.token;

  //   for (var map in productMaps) {
  //     // print(map);

  //     // print(_userSession);
  //     // var response = await _apiService.fetchProductDetails({"token": _userSession,"customerCardCode": _outletCode,"itemCode": map['item_code'],});

  //     // if (_isResponseValid(response)) {
  //     //   Product product = productFromJson(jsonEncode(response["data"][0]));
  //     //   final serialCount = await _getSerialCountForProduct(map['id']);
  //     //   _products[product] = serialCount;
  //     // } else {
  //     //   _removeInvalidProduct(map['id']);
  //     // }
  //   }
  //   update();
  }

  Future<int> _getOrCreateProductId(ProductModal product) async {
    try {
      final existingProduct = await _dbHelper.queryRaw(
        'SELECT id FROM cart_products WHERE item_code = ?',
        [product.itemCode],
      );

      if (existingProduct.isNotEmpty) {
        return existingProduct.first['id'];
      } else {
        return await _dbHelper.insertRaw(
          'INSERT INTO cart_products (item_code, quantity, price, initial_discount) VALUES (?, ?, ?, ?)',
          [product.itemCode, 1, product.price, product.discount],
        );
      }
    } catch (error, stackTrace) {
      // Capture the exception with Sentry.
      await Sentry.captureException(error, stackTrace: stackTrace);
      // Optionally, you can rethrow the error to let higher-level error handlers deal with it.
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProductDetails(ProductModal product) async {
    final productId = await _getOrCreateProductId(product);
    final productRequest = await _dbHelper.queryRaw('SELECT * FROM cart_product_request WHERE cart_products_id = ?', [productId]);
    final productSerialNumbersList = await _dbHelper.getCartProductSerialNumber(productId);
    final productSerialNumbers = productSerialNumbersList.isNotEmpty ? productSerialNumbersList.map((e) => e['serial_number']).toList() : [];

    return {
      'barcode': product.barcode,
      'quantity': _products[product].toString(),
      'sellableWarehouse': productRequest.isNotEmpty ? productRequest.first['warehouse_code'] : '',
      'discountPerc': productRequest.isNotEmpty ? productRequest.first['discount'] : '',
      'scannedSerialNumbers': productSerialNumbers,
      'selectedPickUpLocation': productRequest.isNotEmpty ? productRequest.first['pickup_location'] : '',
      'selectedRate': productRequest.isNotEmpty ? productRequest.first['tax_group'] : '',
    };
  }

  Future<List<Map<String, dynamic>>> getCartDetails() async {
    if (_products.isNotEmpty) {
      var cartDetails = <Map<String, dynamic>>[];
      await Future.forEach(_products.entries, (entry) async {
        var key = entry.key;
        var value = entry.value;
        int productId = await _getOrCreateProductId(key);
        // get product request 
        var productRequest = await _dbHelper.queryRaw('SELECT * FROM cart_product_request WHERE cart_products_id = ?', [productId]);
        
        var productSerialNumbersList = await _dbHelper.getCartProductSerialNumber(productId);
  
        List<dynamic> productSerialNumbers = productSerialNumbersList.isNotEmpty ? productSerialNumbersList.map((e) => e['serial_number']).toList() : [];
  
        var details = {
          'barcode': key.barcode,
          'quantity': value.toString(),
          'sellableWarehouse': productRequest.isNotEmpty ? productRequest.first['warehouse_code'] : '',
          'discountPerc': productRequest.isNotEmpty && productRequest.first["discount"] != null ? productRequest.first['discount'] != '' ? productRequest.first['discount'] : 0 : 0,
          'scannedSerialNumbers': productSerialNumbers,
          'selectedPickUpLocation': productRequest.isNotEmpty ? productRequest.first['pickup_location'] : '',
          'selectedRate': productRequest.isNotEmpty ? productRequest.first['tax_group'] : '',
        };
        cartDetails.add(details);
      });
      return cartDetails;
    } else {
      return [];
    }
  }

}