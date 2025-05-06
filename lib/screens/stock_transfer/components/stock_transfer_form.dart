import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';
import 'package:showroom_manager/constant/constants.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../modals/product_modal.dart';
import '../../../modals/stock_transfer_type_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class StockTransferForm extends StatefulWidget {
  const StockTransferForm({super.key});

  @override
  State<StockTransferForm> createState() => _StockTransferFormState();
}

class _StockTransferFormState extends State<StockTransferForm> with WidgetsBindingObserver {
  late final CartController cartController;
  
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool isLoading = false;

  List<WarehouseModal> showroomWarehouseList = [];
  List<StockTransferTypeModal> stockTransferTypeList = [];
  TextEditingController fromWarehouseInputController = TextEditingController();
  TextEditingController toWarehouseInputController = TextEditingController();
  TextEditingController stockTransferTypeInputController = TextEditingController();
  bool warehouseInputHasError = false;

  HoneywellScanner honeywellScanner = HoneywellScanner();
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cartController = Get.put(CartController(context));
    
    init();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
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
    getStockTransferTypes();
  }

  Future<void> getStockTransferTypes() async {
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        return;
      }

      Map<String, dynamic> output = await apiService.getStockTransferTypes(token, {});

      if(output["status"] == "success"){
        List<StockTransferTypeModal> minStockTransferType = [];
        for(var item in output["data"]){
          minStockTransferType.add(stockTransferTypeModalFromJson(jsonEncode(item)));
        }
        setState(() {
          stockTransferTypeList = minStockTransferType;
        });
      }else{
        dynamicMaster.displayError(context, "Error", output["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

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

  // @override
  void onError(Exception error) { }

  Future<void> fetchProduct(String barcode) async {
    dynamicMaster.displayLoadingModal(context);

    try {
      var token = await sessionProvider.authProvider.token;

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

  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();

    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        showroomWarehouseList = fetchedWarehouseList;
      });
    }
  }

  Future<List<WarehouseModal>> getWarehouseData(String? filter) async{
    Map<String, dynamic> filters = {};

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getWarehouse(token, filters);

      if(output["status"] == "success"){
        List<WarehouseModal> minWarehouse = [];
        for(var item in output["data"]){

          minWarehouse.add(warehouseModalFromJson(jsonEncode(item)));
        }
        return minWarehouse;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _warehousePopupBuilder(BuildContext context, WarehouseModal item, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.name),
      ),  
    );
  }

  Future<void> displayTransferDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));
    
    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                height: size.height * 0.55,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/azone.png", height: 50, width: 50,),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Stock Transfer Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          Row(
                            children: [
                              const Text("Select Transfer Type:", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: size.width * 0.01,),
                              const Text("*", style: TextStyle(color: Colors.red),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          SizedBox(
                            width: size.width * 0.8,
                            child: DropdownButton<StockTransferTypeModal>(
                              value: stockTransferTypeList.firstWhereOrNull(
                                (element) => element.id.toString() == stockTransferTypeInputController.text,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              hint: const Text("Select Transfer Type"),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (StockTransferTypeModal? newValue) {
                                setState(() {
                                  stockTransferTypeInputController.text = newValue?.id.toString() ?? '';
                                });
                              },
                              items: stockTransferTypeList.map((value) {
                                return DropdownMenuItem<StockTransferTypeModal>(
                                  value: value,
                                  child: Text(value.name),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02,),
                          Row(
                            children: [
                              const Text("Select From Warehouse:", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: size.width * 0.01,),
                              const Text("*", style: TextStyle(color: Colors.red),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.005,),
                          DropdownSearch<WarehouseModal>(
                            asyncItems: (String? filter) => getWarehouseData(filter),
                            popupProps: PopupPropsMultiSelection.modalBottomSheet(
                              showSelectedItems: true,
                              itemBuilder: _warehousePopupBuilder,
                              showSearchBox: true,
                            ),
                            compareFn: (item, sItem) => item.name == sItem.name,
                            dropdownDecoratorProps:  DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: 'Select Showroom Warehouse',
                                labelStyle: const TextStyle(color: kPrimaryColor),
                                filled: true,
                                fillColor: kPrimaryLightColor,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: warehouseInputHasError ? Colors.red : Colors.grey,
                                  ),
                                  // borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                ),
                                iconColor: kPrimaryColor,
                                prefixIconColor: kPrimaryColor
                              ),
                              baseStyle: const TextStyle(
                                color: kPrimaryColor
                              )
                            ),
                            onChanged: (value) {
                              if(value != null){
                                setState(() {
                                  warehouseInputHasError = false;
                                  fromWarehouseInputController.text = value.code.toString();
                                });
                              }else{
                                setState(() {
                                  warehouseInputHasError = true;
                                  fromWarehouseInputController.clear();
                                });
                              }
                            },
                          ),
                          SizedBox(height: size.height * 0.02,),
                          Row(
                            children: [
                              const Text("Select Destination Warehouse:", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: size.width * 0.01,),
                              const Text("*", style: TextStyle(color: Colors.red),),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          SizedBox(
                            width: size.width * 0.8,
                            child: DropdownButton<WarehouseModal>(
                              value: showroomWarehouseList.firstWhereOrNull(
                                (element) => element.code.toString() == toWarehouseInputController.text,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              hint: const Text("Select Destination Warehouse"),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.deepPurple),
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (WarehouseModal? newValue) {
                                setState(() {
                                  toWarehouseInputController.text = newValue?.code.toString() ?? '';
                                });
                              },
                              items: showroomWarehouseList.map((value) {
                                return DropdownMenuItem<WarehouseModal>(
                                  value: value,
                                  child: Text(value.name),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ), 
                                child: const Text("Cancel", style: TextStyle(color: kPrimaryLightColor),)
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if(fromWarehouseInputController.text.isEmpty || toWarehouseInputController.text.isEmpty) {
                                    setState(() {
                                      warehouseInputHasError = true;
                                    });
                                    dynamicMaster.displayError(context, "Error", "Please select both warehouses.");
                                    return;
                                  }
                                  Navigator.pop(context);
                                  displayTransferConfirmationDialog(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kSecondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ), 
                                child: const Text("Submit", style: TextStyle(color: kPrimaryLightColor),)
                              )
                            ],
                          ),
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

  Future<void> displayTransferConfirmationDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));
    
    return showDialog(
      context: context, 
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                height: size.height * 0.35,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/azone.png", height: 50, width: 50,),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Stock Transfer Confirmation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      Column(
                        children: [
                          const Text("Are you sure you want to transfer the selected products?", style: TextStyle(fontSize: 16, color: Colors.redAccent),),
                          SizedBox(height: size.height * 0.02,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ), 
                                child: const Text("Cancel", style: TextStyle(color: kPrimaryLightColor),),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  processTransferRequest();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kSecondaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ), 
                                child: const Text("Confirm", style: TextStyle(color: kPrimaryLightColor),)
                              )
                            ],
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

  Future<void> processTransferRequest() async {
    dynamicMaster.displayLoadingModal(context);
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        Navigator.of(context).pop();
        dynamicMaster.displayError(context, "Error", "Session expired. Kindly login again.");
        return;
      }

      List<dynamic> productList = await cartController.getCartDetails();

      var response = await apiService.processStockTransferRequest(token, {
        "stock_transfer_type": stockTransferTypeInputController.text,
        "from_warehouse": fromWarehouseInputController.text,
        "to_warehouse": toWarehouseInputController.text,
        "products": productList
      });

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        cartController.clearProducts();
        dynamicMaster.displaySuccessMessage(context, response["message"]);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(context, '/stock_transfer', (route) => false);
        });
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Stock Transfer From", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(
                height: size.height * 0.75,
                width: size.width,
                child: cartController.products.isEmpty ?
                const Center(
                  child: Text("No Product Found! Kindly scan atleast one product barcode.", style: TextStyle(color: Colors.red),),
                ) : 
                ListView.builder(
                  itemCount: cartController.products.length,
                  itemBuilder: (context, index) {
                    
                    ProductModal product = cartController.products.keys.toList()[index];
                    
                    return Container(
                      height: size.height * 0.43,
                      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                                  image: NetworkImage(product.userText == null ? "" : product.userText!),
                                  fit: BoxFit.cover
                                )
                              ),
                            ),
                          ),
                          Positioned(
                            left: size.width * 0.35,
                            child: SizedBox(
                              height: size.height * 0.34,
                              width: size.width * 0.6,
                              child: Column(
                                children: [
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
                                    product.modelNo,
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryLightColor
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    'RRP: ${NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(product.priceInclusiveVat)}',
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryLightColor
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "Strength: ${product.productStrength}",
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryLightColor
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Text(
                                    "Status: ${product.productStatus}",
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
                            child: SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoundedButton(
                                    btnText: "View Details", 
                                    press: (){
                                      Navigator.pushNamed(context, '/product_details', arguments: product.barcode);
                                    }, 
                                    btnColor: kSecondaryColor, 
                                    textColor: kPrimaryLightColor
                                  )
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
              SizedBox(height: size.height * 0.01,),
              RoundedButton(
                btnText: "Submit", 
                press: (){
                  if(cartController.products.isEmpty){
                    dynamicMaster.displayError(context, "Error", "No product found for transfer.");
                    return;
                  }
                  displayTransferDialog(context);
                }, 
                btnColor: kPrimaryColor, 
                textColor: kPrimaryLightColor
              )
            ],
          ),
        ),
      ),
    );
  }
}