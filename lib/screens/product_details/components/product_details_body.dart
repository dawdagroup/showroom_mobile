import 'dart:convert';

import '../../../components/dynamic_widgets.dart';
import '../../../constant/constants.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../modals/product_modal.dart';
import '../../../modals/warehouse_stock_modal.dart';

class ProductDetailsBody extends StatefulWidget {
  final String barcode;
  const ProductDetailsBody({Key? key, required this.barcode}) : super(key: key);

  @override
  State<ProductDetailsBody> createState() => _ProductDetailsBodyState();
}

class _ProductDetailsBodyState extends State<ProductDetailsBody> {
  final ApiService apiService = ApiService();
  final DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  bool isSheetExpanded = false; // To manage overlay

  ProductModal? productDetails;
  List<WarehouseStockModal> warehouseStockList = [];
  List<WarehouseStockModal> supplierStockList = [];

  @override
  void initState() {
    super.initState();
    // Delay fetching data until the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      fetchProductDetails();
      fetchSupplierStocks();
    });
  }

  Future<void> fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> filters = { "barcode": widget.barcode };

      var response = await apiService.getProductDetails(token, filters);

      if (response["status"] == "success") {
        ProductModal minProduct = productModalFromJson(jsonEncode(response["data"]["product"]));
        List<WarehouseStockModal> minWarehouseStockList = (response["data"]["warehouseStocks"] as List)
            .map((data) => warehouseStockModalFromJson(jsonEncode(data)))
            .toList();

        setState(() {
          productDetails = minProduct;
          warehouseStockList = minWarehouseStockList;
          isLoading = false;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSupplierStocks() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      var response = await apiService.getProductSupplierStocks(token, widget.barcode);

      if (response["status"] == "success") {
        List<WarehouseStockModal> minSupplierStockList = (response["data"] as List)
            .map((data) => warehouseStockModalFromJson(jsonEncode(data)))
            .toList();

        setState(() {
          supplierStockList = minSupplierStockList;
          isLoading = false;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  // Main Content Builder
  Widget buildMainContent(Size size) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (productDetails == null) {
      return const Center(child: Text("No product details found."));
    } else {
      return Column(
        children: [
          SizedBox(height: size.height * 0.04,),
          const Text(
            "Product Details",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Center(
            child: productDetails!.userText == null ? Image.asset("assets/images/blank_image.png", width: size.width * 0.3) : Image.network(
              productDetails!.userText, // Replace with correct field
              height: size.height * 0.6,
              width: size.width,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
      );
    }
  }
  // First, create a helper function to build the rows.
  List<DataRow> _buildGroupedRows(List<WarehouseStockModal> stocks) {
    // Group stocks by warehouseShortName.
    final Map<String, List<WarehouseStockModal>> groupedData = {};
    for (var stock in stocks) {
      final key = stock.warehouseShortName.toString();
      if (groupedData.containsKey(key)) {
        groupedData[key]!.add(stock);
      } else {
        groupedData[key] = [stock];
      }
    }

    List<DataRow> rows = [];
    groupedData.forEach((shortName, stockList) {
      // Calculate the total for each warehouse type.
      final nonSellable = stockList
          .where((item) => item.warehouseType == "NON-SELLABLE DISPLAY")
          .fold(0.0, (sum, item) => sum + (item.stockOnHand is num ? item.stockOnHand.toDouble() : 0));
      final sellableDisplay = stockList
          .where((item) => item.warehouseType == "SELLABLE DISPLAY")
          .fold(0.0, (sum, item) => sum + (item.stockOnHand is num ? item.stockOnHand.toDouble() : 0));
      final store = stockList
          .where((item) => item.warehouseType == "STORE")
          .fold(0.0, (sum, item) => sum + (item.stockOnHand is num ? item.stockOnHand.toDouble() : 0));
      final totalSellable = sellableDisplay + store;

      rows.add(
        DataRow(cells: [
          DataCell(Text(shortName, style: const TextStyle(color: kPrimaryLightColor))),
          DataCell(Text(nonSellable.toInt().toString(), style: const TextStyle(color: kPrimaryLightColor))),
          DataCell(Text(sellableDisplay.toInt().toString(), style: const TextStyle(color: kPrimaryLightColor))),
          DataCell(Text(store.toInt().toString(), style: const TextStyle(color: kPrimaryLightColor))),
          DataCell(Text(totalSellable.toInt().toString(), style: const TextStyle(color: kPrimaryLightColor))),
        ]),
      );
    });
    return rows;
  }


  // Bottom Sheet Content Builder
  Widget buildBottomSheetContent(Size size) {
    
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (productDetails == null) {
      return const Center(child: Text("No product details found."));
    } else {
      return Container(
        height: size.height * 0.85,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: kSecondaryLightColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            SizedBox(height: size.height * 0.02,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  productDetails!.itemGroup,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryLightColor),
                ),
                // add price here
                Text(NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(double.parse(productDetails!.price.toString())), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor),),
              ],
            ),
            SizedBox(height: size.height * 0.02,),
            // add description here
            Text(productDetails!.modelNo, style: const TextStyle(fontSize: 16, color: kPrimaryLightColor),),
            SizedBox(height: size.height * 0.02,),
            // add tabs here
            SizedBox(
              height: size.height * 0.64,
              child: DefaultTabController(
                length: 3, 
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                            "Specs",
                            style: TextStyle(color: kPrimaryLightColor),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Azone Stocks",
                            style: TextStyle(color: kPrimaryLightColor),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Supplier Stocks",
                            style: TextStyle(color: kPrimaryLightColor),
                          ),
                        ),
                      ],
                      indicatorColor: kSecondaryColor,
                      labelColor: kPrimaryLightColor,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Stock Tab
                          ListView.builder(
                            itemCount: productDetails!.specList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(Icons.check_circle, color: kPrimaryLightColor),
                                title: Text(productDetails!.specList[index], style: const TextStyle(color: kPrimaryLightColor),),
                              );
                            },
                          ),

                          // Azone Stocks Tab
                          // SingleChildScrollView(
                          //   child: DataTable(
                          //     border: const TableBorder(
                          //       top: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       bottom: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       left: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       right: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       horizontalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                          //       verticalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                          //     ),
                          //     columns: const [
                          //       DataColumn(label: Text("Warehouse Name", style: TextStyle(color: kSecondaryColor))),
                          //       DataColumn(label: Text("Quantity", style: TextStyle(color: kSecondaryColor))),
                          //     ],
                          //     rows: warehouseStockList.map((data) {
                          //       return DataRow(
                          //         cells: [
                          //           DataCell(Text(data.warehouseName.toString(), style: const TextStyle(color: kPrimaryLightColor))),
                          //           DataCell(Text(data.stockOnHand.toString(), style: const TextStyle(color: kPrimaryLightColor))),
                          //         ],
                          //       );
                          //     }).toList(),
                          //   ),
                          // ),
                          // Assuming warehouseStockList is your List<WarehouseStockModal>
                          // SingleChildScrollView(
                          //   // scrollDirection: Axis.horizontal, // To allow horizontal scrolling if needed
                          //   child: DataTable(
                          //     border: const TableBorder(
                          //       top: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       bottom: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       left: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       right: BorderSide(color: kPrimaryLightColor, width: 2.0),
                          //       horizontalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                          //       verticalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                          //     ),
                          //     columns: const [
                          //       DataColumn(label: Text("Shop", style: TextStyle(color: kSecondaryColor))),
                          //       DataColumn(label: Text("NSD", style: TextStyle(color: kSecondaryColor))),
                          //       DataColumn(label: Text("SD", style: TextStyle(color: kSecondaryColor))),
                          //       DataColumn(label: Text("BS", style: TextStyle(color: kSecondaryColor))),
                          //       DataColumn(label: Text("TS", style: TextStyle(color: kSecondaryColor))),
                          //     ],
                          //     rows: _buildGroupedRows(warehouseStockList),
                          //   ),
                          // ),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: const TableBorder(
                                  top: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                  bottom: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                  left: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                  right: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                  horizontalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                                  verticalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                                ),
                                columns: const [
                                DataColumn(label: Text("Shop", style: TextStyle(color: kSecondaryColor))),
                                DataColumn(label: Text("NSD", style: TextStyle(color: kSecondaryColor))),
                                DataColumn(label: Text("SD", style: TextStyle(color: kSecondaryColor))),
                                DataColumn(label: Text("BS", style: TextStyle(color: kSecondaryColor))),
                                DataColumn(label: Text("TS", style: TextStyle(color: kSecondaryColor))),
                                ],
                                rows: _buildGroupedRows(warehouseStockList),
                              ),
                            ),
                          ),

              
                          // Supplier Stocks Tab
                          SingleChildScrollView(
                            child: DataTable(
                              border: const TableBorder(
                                top: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                bottom: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                left: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                right: BorderSide(color: kPrimaryLightColor, width: 2.0),
                                horizontalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                                verticalInside: BorderSide(color: kPrimaryLightColor, width: 1.0),
                              ),
                              columns: const [
                                DataColumn(label: Text("Warehouse Name", style: TextStyle(color: kSecondaryColor))),
                                DataColumn(label: Text("Quantity", style: TextStyle(color: kSecondaryColor))),
                              ],
                              rows: supplierStockList.map((data) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(data.warehouseName.toString(), style: const TextStyle(color: kPrimaryLightColor))),
                                    DataCell(Text(data.stockOnHand.toString(), style: const TextStyle(color: kPrimaryLightColor))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SlidingUpPanel(
      controller: PanelController(

      ),
      minHeight: size.height * 0.2,
      maxHeight: size.height * 0.85,
      body: buildMainContent(size),
      panel: buildBottomSheetContent(size),
      color: kPrimaryColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    );
  }
}
