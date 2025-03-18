import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';
import 'package:provider/provider.dart';

import 'package:honeywell_scanner/honeywell_scanner.dart';

import '../../../modals/product_modal.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../modals/tax_group_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../modals/product_stock_modal.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SalesOrderForm extends StatefulWidget {
  const SalesOrderForm({super.key});

  @override
  State<SalesOrderForm> createState() => _SalesOrderFormState();
}

class _SalesOrderFormState extends State<SalesOrderForm> with WidgetsBindingObserver {
  late final CartController cartController;
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool isLoading = false;

  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  List<TaxGroupModal> taxGroups = [];
  List<WarehouseModal> warehouseList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    cartController = Get.put(CartController(context));
    init();
  }

  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      honeywellScanner.startScanner();
    } else if (state == AppLifecycleState.paused) {
      honeywellScanner.stopScanner();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    honeywellScanner.stopScanner();
    super.dispose();
  }

  Future<void> init() async {
    updateScanProperties();
    isDeviceSupported = await honeywellScanner.isSupported();
    honeywellScanner.onScannerDecodeCallback = onDecoded;
    honeywellScanner.onScannerErrorCallback = onError;
    await honeywellScanner.startScanner();
  
    if (mounted) setState(() { });

    _getWarehouses();


  }

  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();

    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        warehouseList = fetchedWarehouseList;
      });
    }
  }

  
  // @override
  void onError(Exception error) { }

  void updateScanProperties() {
    List<CodeFormat> codeFormats = [];
    if (scan1DFormats) codeFormats.addAll(CodeFormatUtils.ALL_1D_FORMATS);
    if (scan2DFormats) codeFormats.addAll(CodeFormatUtils.ALL_2D_FORMATS);
    Map<String, dynamic> properties = {
      ...CodeFormatUtils.getAsPropertiesComplement(codeFormats),
      'DEC_CODABAR_START_STOP_TRANSMIT': true,
      'DEC_EAN13_CHECK_DIGIT_TRANSMIT': true,
    };
    honeywellScanner.setProperties(properties);
  }
  
  // @override
  void onDecoded(ScannedData? scannedData) {
    setState(() {
      this.scannedData = scannedData;
      // _scanBarcode = scannedData?.code as String;
      fetchProduct(scannedData?.code as String);
      // getData();
    });
    // TODO: implement onDecoded
  }
  
  Future<void> fetchProduct(String barcode) async {
    dynamicMaster.displayLoadingModal(context);

    try {
      var token = await sessionProvider.authProvider.token;
      // String token = sessionProvider.authProvider.token!;

      if(token == null){
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }
      var response = await apiService.fecthProductDetails(token, {"barcode": barcode});

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        ProductModal product = productModalFromJson(jsonEncode(response["data"][0]));
        setState(() {
          cartController.addProduct(product);
        });

      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

  Future<void> showProductPreferenceDialog(BuildContext context, ProductModal product) async {
    
    IconButton closeButtonWidget = IconButton(
      onPressed: (){
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.clear,
        size: 30,
      )
    );
    
    TextEditingController discountController = TextEditingController();
    TextEditingController warehouseController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController taxGroupController = TextEditingController();

    Size size = MediaQuery.of(context).size;

    if(warehouseList.isEmpty){
      dynamicMaster.displayError(context, "Error", "No warehouse found, kindly login again");
      return;
    }

    var token = await sessionProvider.authProvider.token;

    // fecth tax groups
    if(token == null){
      dynamicMaster.displayError(context, "Error", "You are not logged in");
      return;
    }
    Map<String, dynamic> filters = {"status": "N"};
    var response = await apiService.filterTaxGroups(token, filters);

    if(response["status"] == "success"){
      setState(() {
        taxGroups.clear();
      });
      // save the data into the warehouse details
      for(var data in response["data"]){
        setState(() {
          taxGroups.add(taxGroupModalFromJson(jsonEncode(data)));
        });
      }
    }

    // get the product requests
    final cartProductResults = await _dbHelper.queryRaw('SELECT id FROM cart_products WHERE item_code = ?',[product.itemCode]);

    if(cartProductResults.isEmpty){
      dynamicMaster.displayError(context, "Error", "Product not found in the cart");
      return;
    }

    final productRequest = await _dbHelper.queryRaw('SELECT * FROM cart_product_request WHERE cart_products_id = ?',[cartProductResults.first['id']]);

    if(productRequest.isNotEmpty){
      // get the product request details
      discountController.text = productRequest.first['discount'].toString();
      warehouseController.text = productRequest.first['warehouse_code'];

      if(productRequest.first['tax_group'] != null || productRequest.first['tax_group'] != ''){
        // get the default tax group
        for(var tax in taxGroups){
          try {
            if(tax.rate == double.parse(productRequest.first['tax_group'])) {
              taxGroupController.text = tax.code;
              break;
            }
          } on Exception catch (e) {
            print(e);
            // TODO
          }
        }
      }
    }
    
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return Dialog(
              child: Container(
                height: size.height * 0.6,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/images/azone.png",
                            height: 50,
                            width: 50,
                          ),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        product.modelNo,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        height: size.height * 0.3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Price: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(product.price)}",
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  Text(
                                    "Discount (%): ${product.discount}",
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              TextField(
                                controller: discountController, 
                                decoration: const InputDecoration(labelText: 'Add Discount (%)'), 
                                keyboardType: TextInputType.number,
                                onChanged: (value){
                                },
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  const Text("Warehouse Name:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.01,),
                                  const Text("*", style: TextStyle(color: Colors.red),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              SizedBox(
                                width: size.width * 0.8,
                                child: DropdownButton<String>(
                                  value: warehouseController.text.isEmpty ? null : warehouseController.text,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  hint: const Text("Select Warehouse"),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.deepPurple),
                                  isExpanded: true,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      warehouseController.text = newValue!;
                                    });
                                  },
                                  items: warehouseList.map<DropdownMenuItem<String>>((WarehouseModal value) {
                                    return DropdownMenuItem<String>(
                                      value: value.code,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                ),
                              ),
                              
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  const Text("Pick Up Location", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.01,),
                                  const Text("*", style: TextStyle(color: Colors.red),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Row(
                                children: [
                                  ToggleSwitch(
                                    minWidth: 100.0,
                                    initialLabelIndex: 0,
                                    cornerRadius: 20.0,
                                    activeFgColor: Colors.white,
                                    inactiveBgColor: Colors.grey,
                                    inactiveFgColor: Colors.white,
                                    totalSwitches: 2,
                                    labels: const ['Showroom', 'Warehouse'],
                                    // icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
                                    activeBgColors: const [[Colors.blue],[Colors.pink]],
                                    onToggle: (index) {
                                      setState(() {
                                        if(index == 0){
                                          locationController.text = "Showroom";
                                        }else{
                                          locationController.text = "Warehouse";
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              
                              Row(
                                children: [
                                  const Text("Tax Group", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.01,),
                                  const Text("*", style: TextStyle(color: Colors.red),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              SizedBox(
                                width: size.width * 0.8,
                                child: DropdownButton<String>(
                                  value: taxGroupController.text.isEmpty ? null : taxGroupController.text,
                                  hint: const Text("Select Tax Group"),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(color: Colors.deepPurple),
                                  isExpanded: true,
                                  underline: Container(
                                    height: 2,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      taxGroupController.text = newValue!;
                                    });
                                  },
                                  items: taxGroups.map<DropdownMenuItem<String>>((TaxGroupModal value) {
                                    return DropdownMenuItem<String>(
                                      value: value.code,
                                      child: Text(value.name),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            }, 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            child: const Row(
                              children: [
                                Icon(Icons.clear, color: Colors.white,),
                                Text("Cancel", style: TextStyle(color: Colors.white),)
                              ],
                            )
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // save the product details
                              Navigator.of(context).pop();
                              await saveProductRef(product, discountController.text, warehouseController.text, locationController.text, taxGroupController.text);
                            }, 
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Row(
                              children: [
                                Icon(Icons.save, color: Colors.white,),
                                Text("Save", style: TextStyle(color: Colors.white),)
                              ],
                            )
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Future<void> saveProductRef(ProductModal product, String discount, String warehouse, String location, String taxGroup) async{

    if(discount.isNotEmpty) {
      if(product.discount > 0 && double.parse(discount) < product.discount) {
        dynamicMaster.displayError(context, "Error", "Discount applied cannot be less than the product discount");
        return;
      }
      
      if(double.parse(discount) > 100) {
        dynamicMaster.displayError(context, "Error", "Discount applied cannot be more than 100%");
        return;
      }

      // Recalculate the original price before applying any discounts
      double originalPrice = product.price / (1 - (product.discount / 100));

      // Calculate the new price with the new discount
      double newDiscount = double.parse(discount);
      double discountAmount = originalPrice * (newDiscount / 100);

      // Apply the new discount to get the final price
      product.price = originalPrice - discountAmount;
      product.discount = newDiscount;
    }

    String newTaxGroup = '';

    if(taxGroup.isNotEmpty){
      // get the default tax group
      for(var tax in taxGroups){
        if(tax.code == taxGroup){
          newTaxGroup = tax.rate.toString();
          product.selectedTaxGroup = tax;
          break;
        }
      }
    }


    await _dbHelper.saveCartProductRequest(product, newTaxGroup, warehouse, location, discount);

    //update the cart
    setState(() { });
  }

  Future<bool> validateProductsStock() async{
    var token = await sessionProvider.authProvider.token;

    if(token == null){
      dynamicMaster.displayError(context, "Error", "You are not logged in");
      return false;
    }

    // for each product, check the stock
    for (var product in cartController.products.keys.toList()) {
      WarehouseModal? warehouse;

      final productRequest = await _dbHelper.queryRaw('SELECT a.*, b.item_code FROM cart_product_request a LEFT JOIN cart_products b ON (a.cart_products_id = b.id) WHERE b.item_code = ?',[product.itemCode]);
      
      if(productRequest.isNotEmpty){
        if(productRequest.first['warehouse_code'] != null){
          // check the warehouse if its a virtual warehouse
          for (var warehouseObj in warehouseList) {
            if(warehouseObj.code.toString() == productRequest.first['warehouse_code']){
              warehouse = warehouseObj;
              break;
            }
          }
        }else{
          // get the default store warehouse
          for (var warehouseObj in warehouseList) {
            if(warehouseObj.isStore.toString() == "1"){
              warehouse = warehouseObj;
              break;
            }
          }
        }
      }else{
        // get the default store warehouse
        for (var warehouseObj in warehouseList) {
          if(warehouseObj.isStore.toString() == "1"){
            warehouse = warehouseObj;
            break;
          }
        }
      }
      
      if(warehouse != null && warehouse.isVirtual.toString() == "0"){
        Map<String, dynamic> filters = {
          "warehouseCode": warehouse.code,
          "itemCode": product.itemCode,
        };

        var token = await sessionProvider.authProvider.token;

        if(token == null){
          dynamicMaster.displayError(context, "Error", "Session Expired! Please login to continue.");
          return false;
        }

        // check the stock of the product
        var response = await apiService.filterProductStock(token, filters);

        if(response["status"] == "success"){
          ProductStockModal productStock = productStockModalFromJson(jsonEncode(response["data"][0]));

          if(cartController.products[product] > productStock.onHand){
            dynamicMaster.displayError(context, "Error", "Insufficient stock for ${product.itemCode}. Available stock is ${productStock.onHand}. Please reduce the quantity or select a different warehouse");
            return false;
          }else{
            return true;
          }
        }else{
          return true;
        }
      }else{
        return true;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: dynamicMaster.applicationBar(theme, context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.655, 
              child: ListView.builder(
                itemCount: cartController.products.length,
                itemBuilder: (context, index){
                  ProductModal product = cartController.products.keys.toList()[index];
                  
                  return Container(
                    height: size.height * 0.4,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow:  [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.3),
                          offset: const Offset(-10.0, 10.0),
                          blurRadius: 20.0,
                          spreadRadius: 4.0
                        )
                      ]
                    ),
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: size.height * 0.01),
                    child: Stack(
                      children: [
                        Positioned(
                          child: Container(
                            height: size.height * 0.3,
                            width: size.width * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: NetworkImage(product.userText ?? ""),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                        ),
                        Positioned(
                          left: size.width * 0.35,
                          child: SizedBox(
                            height: size.height * 0.3,
                            width: size.width * 0.6,
                            child: Column(
                              children: [
                                Text(
                                  product.modelNo,
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryLightColor
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  product.itemCode,
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryLightColor
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  product.brand,
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryLightColor
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  'Price: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(product.price)}',
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryLightColor
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      onPressed: (){
                                        setState(() {
                                          cartController.removeProduct(product);
                                        });
                                      },
                                      iconSize: size.height * 0.06,
                                      color: kPrimaryLightColor
                                    ),
                                    SizedBox(width: size.width * 0.01),
                                    Text(
                                      '${cartController.products.values.toList()[index]}',
                                      style: TextStyle(
                                        fontSize: size.height * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryLightColor
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.01),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      onPressed: (){
                                        setState(() {
                                          cartController.addProduct(product);
                                        });
                                      },
                                      iconSize: size.height * 0.06,
                                      color: kPrimaryLightColor
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.pushNamed(context, '/product_details', arguments: product.barcode);
                                  }, 
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.remove_red_eye_outlined, color: Colors.white,),
                                      Text("View Details", style: TextStyle(color: Colors.white),)
                                    ],
                                  )
                                ),
                                ElevatedButton(
                                  onPressed: (){
                                    showProductPreferenceDialog(context, product);
                                  }, 
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.settings, color: Colors.white,),
                                      Text("Preference", style: TextStyle(color: Colors.white),)
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(50.0),
                  // topLeft: Radius.circular(50.0),
                  // topLeft: Radius.circular(50)
                ),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF363f93).withOpacity(0.3),
                      offset: const Offset(-10.0, 0.0),
                      blurRadius: 20.0,
                      spreadRadius: 4.0
                  )
                ]
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                    child: Row(
                      children: [
                        Text(
                          'Sub-Total: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(cartController.subTotal)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                    child: Row(
                      children: [
                        Text(
                          'VAT: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(cartController.vatAmount)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.01, left: size.width * 0.05, right: size.width * 0.05),
                    child: Row(
                      children: [
                        Text(
                          'Total: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(cartController.subTotal + cartController.vatAmount)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),

                  RoundedButton(
                    btnText: "Proceed to Checkout", 
                    press: () async {
                      // dynamicMaster.displayLoadingModal(context);
                      if(await validateProductsStock()){
                        // Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/checkout-sales-order');
                      }else{
                        // Navigator.of(context).pop();
                      }
                    }, 
                    btnColor: kPrimaryColor, 
                    textColor: kPrimaryLightColor
                  ),

                  SizedBox(height: size.height * 0.01),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}