import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/constant/constants.dart';
import 'package:showroom_manager/modals/warehouse_modal.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../db/database_helper.dart';
import '../../../modals/physical_stock_count_modal.dart';
import '../../../modals/physical_stock_take_type_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class PhysicalStockCountBody extends StatefulWidget {
  const PhysicalStockCountBody({super.key});

  @override
  State<PhysicalStockCountBody> createState() => _PhysicalStockCountBodyState();
}

class _PhysicalStockCountBodyState extends State<PhysicalStockCountBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool isLoading = true;

  List<PhysicalStockCountModal> physicalStockCountList = [];
  List<PhysicalStockTakeTypeModal> physicalStockTakeTypeList = [];
  List<WarehouseModal> warehouseList = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    _getPhysicalStockCount(filters: {});
    _getPhysicalStockCountType();

  }

  Future<void> _getPhysicalStockCount({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; physicalStockCountList = []; warehouseList = []; });
    try{

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var fetchedWarehouseList = await _dbHelper.getWarehouses();

      if (fetchedWarehouseList.isEmpty) {
        dynamicMaster.displayError(context, "Error", "No warehouses found.");
        setState(() { isLoading = false; });
        return;
      }

      setState(() { warehouseList = fetchedWarehouseList; });
      

      if(filters.isEmpty) {
        filters["created_at"] = DateFormat("yyyy-MM-dd").format(DateTime.now());
      }

      filters["warehouse_code_list"] = [for (var item in fetchedWarehouseList) item.code].join(",");

      var response = await  apiService.filterDailyStockTake(token, filters);

      if (response["status"] == "success") {
        List<PhysicalStockCountModal> minPhysicalStockCountList = [];
        for (var data in response["data"]) {
          minPhysicalStockCountList.add(physicalStockCountModalFromJson(jsonEncode(data)));
        }
        setState(() {
          physicalStockCountList = minPhysicalStockCountList;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch(e){
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false;});
  }

  
  Future<void> _getPhysicalStockCountType() async {
    setState(() { isLoading = true; physicalStockCountList = []; });
    try{

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      final filters = {"status": "active"};

      var response = await  apiService.filterDailyStockTakeType(token, filters);

      if (response["status"] == "success") {
        List<PhysicalStockTakeTypeModal> minPhysicalStockTakeTypeList = [];
        for (var data in response["data"]) {
          minPhysicalStockTakeTypeList.add(physicalStockTakeTypeModalFromJson(jsonEncode(data)));
        }
        setState(() {
          physicalStockTakeTypeList = minPhysicalStockTakeTypeList;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch(e){
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false;});
  }

  void _displayStockCountCreatDialoge(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    bool physicalStockTakeTypeHasErrors = false;
    TextEditingController physicalStockTakeTypeController = TextEditingController();

    bool isWarehouseHasErrors = false;
    TextEditingController warehouseController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Container(
                height: size.height * 0.45,
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/images/azone.png", height: 50, width: 50,),
                        closeButtonWidget
                      ],
                    ),
                    SizedBox(height: size.height * 0.02,),
                    const Text("Create Physical Stock Count", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    const Divider(height: 10, thickness: 1,),
                    SizedBox(height: size.height * 0.02,),
                    Column(
                      children: [
                        SizedBox(height: size.height * 0.02),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: physicalStockTakeTypeHasErrors ? Colors.red : Colors.grey,
                              width: 1.0
                            ),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: DropdownButton<String>(
                            items: physicalStockTakeTypeList.map((PhysicalStockTakeTypeModal value) {
                              return DropdownMenuItem<String>(
                                value: value.id.toString(),
                                child: Text(value.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if(value != null){
                                setState(() {
                                  physicalStockTakeTypeHasErrors = false;
                                  physicalStockTakeTypeController.text = value;
                                });
                              }
                            },
                            value: physicalStockTakeTypeController.text.isEmpty ? null : physicalStockTakeTypeController.text,
                            isExpanded: true,
                            hint: const Text("Select Physical Stock Count Type"),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                            padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                            underline: Container(),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isWarehouseHasErrors ? Colors.red : Colors.grey,
                              width: 1.0
                            ),
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: DropdownButton<String>(
                            items: warehouseList.map((WarehouseModal value) {
                              return DropdownMenuItem<String>(
                                value: value.code,
                                child: Text(value.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if(value != null){
                                setState(() {
                                  isWarehouseHasErrors = false;
                                  warehouseController.text = value;
                                });
                              }
                            },
                            value: warehouseController.text.isEmpty ? null : warehouseController.text,
                            isExpanded: true,
                            hint: const Text("Select Warehouse"),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                            ),
                            padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                            underline: Container(),
                          ),
                        ),
                      ],
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
                          ),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (physicalStockTakeTypeController.text.isEmpty) {
                              setState(() {
                                physicalStockTakeTypeHasErrors = true;
                              });
                              dynamicMaster.displayError(context, "Error", "Please select a physical stock count type.");
                            } else if (warehouseController.text.isEmpty) {
                              setState(() {
                                isWarehouseHasErrors = true;
                              });
                              dynamicMaster.displayError(context, "Error", "Please select a warehouse.");
                            } else {
                              Navigator.pop(context);
                              _createPhysicalStockCount(physicalStockTakeTypeController.text, warehouseController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                          ),
                          child: const Text("Create", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createPhysicalStockCount(String physicalStockCountTypeId, String warehouseCode) async {
    try {
      dynamicMaster.displayLoadingModal(context);

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        Navigator.pop(context); // Close the loading modal
        return;
      }

      final queryParameters = {
        "physicalStockCountTypeId": physicalStockCountTypeId,
        "warehouseCode": warehouseCode,
      };

      var response = await apiService.createPhysicalStockCount(token, queryParameters);

      Navigator.pop(context); // Close the loading modal

      if (response["status"] == "success") {
        dynamicMaster.displaySuccessMessage(context, "Physical Stock Count created successfully.");
        _getPhysicalStockCount(filters: {});
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading modal
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          const Text('Physical Stock Count', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,),),
          SizedBox(height: size.height * 0.01,),
          SizedBox(
            height: size.height * 0.7,
            width: size.width,
            child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : physicalStockCountList.isEmpty
              ? const Center(child: Text("No Physical Stock Count found."))
              : ListView.builder(
                itemCount: physicalStockCountList.length,
                itemBuilder: (context, index) {
                  var item = physicalStockCountList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        // Navigate to details page or perform any action
                        print("Tapped on item: ${item.stockCountNumber}");
                        Navigator.pushNamed(context, '/physical_stock_count_details', arguments: item.id.toString());
                      },
                      child: Card(
                        elevation: 3,
                        child: SizedBox(
                          height: size.height * 0.23,
                          width: size.width * 0.9,
                          child: Column(
                            children: [
                              Text("# ${item.stockCountNumber}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("${item.warehouseName} (${item.warehouseCode})", style: const TextStyle(fontSize: 16)),
                              Text("Type: ${item.physicalStockCountTypeName}", style: const TextStyle(fontSize: 16)),
                              Text("Date: ${DateFormat('yyyy-MM-dd').format(item.stockCountDate)}", style: const TextStyle(fontSize: 16)),
                              Text("Status: ${item.status}", style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        )
                      ),
                    ),
                  );
                },
              )
          ),
          SizedBox(height: size.height * 0.02,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Refresh the list
                    _getPhysicalStockCount(filters: {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      Text("Refresh", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _displayStockCountCreatDialoge(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      Text("Create New", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}