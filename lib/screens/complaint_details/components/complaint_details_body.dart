import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../services/api_service.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';
import '../../../modals/aftersale_detailed_modal.dart';

import '../../../constant/constants.dart';
import '../../../modals/aftersale_movement_type_modal.dart';
import '../../../modals/printer_layout_modal.dart';

import 'dart:convert';

import '../../../components/labeled_text_field.dart';
import 'movement_list_item.dart';

class ComplaintDetailsBody extends StatefulWidget {
  final String complaintNo;
  const ComplaintDetailsBody({super.key, required this.complaintNo});

  @override
  State<ComplaintDetailsBody> createState() => _ComplaintDetailsBodyState();
}

class _ComplaintDetailsBodyState extends State<ComplaintDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  AftersaleDetailedModal? aftersaleDetailedModal;

  List<AftersalesMovementTypeModal> movementTypeDropDownItems = [];
  List<PrinterLayoutModal> afterSalesLayouts = [];
  List<String> damageTypeList = ["Yes", "No"];
  List<String> packagingMissingList = ["Yes", "No"];
  List<String> accessoriesMissingList = ["Yes", "No"];

  TextEditingController packagingMissingController = TextEditingController();
  TextEditingController packagingMissingDetailsController = TextEditingController();
  TextEditingController damageTypeController = TextEditingController();
  TextEditingController damageTypeDetailsController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController selectedMovementTypeController = TextEditingController();
  TextEditingController accessoriesMissingController = TextEditingController();
  TextEditingController accessoriesMissingDetailsController = TextEditingController();

  bool movementTypeHasError = false;
  bool accessoriesMissingHasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getComplaintDetails();
    getAfterSalesLayoutsData();
  }

  Future<void> getComplaintDetails() async {
    setState(() {isLoading = true; });

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await apiService.getComplaintDetails(token, widget.complaintNo);

      if(response["status"] == "success"){
        aftersaleDetailedModal = aftersaleDetailedModalFromJson(jsonEncode(response["data"][0]));
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      print(e);
      dynamicMaster.displayError(context, "Error", "An error occurred while fetching complaint details");
    }
    setState(() { isLoading = false; });
  }

  Future<List<AftersalesMovementTypeModal>> getAftersalesMovementTypes(String? filter) async{
    Map<String, dynamic> filters = {};

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getMovementTypes(token, filters);

      if(output["status"] == "success"){
        List<AftersalesMovementTypeModal> minRegions = [];
        for(var item in output["data"]){
          minRegions.add(aftersalesMovementTypeModalFromJson(jsonEncode(item)));
        }
        return minRegions;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  Future<void> getAfterSalesLayoutsData() async {
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return;
      }

      Map<String, dynamic> output = await apiService.getAfterSalesLayouts(token);

      print("Layout API Response:");
      print(output);

      if(output["status"] == "success"){
        List<PrinterLayoutModal> layouts = [];
        for(var item in output["data"]){
          layouts.add(printerLayoutModalFromJson(jsonEncode(item)));
        }
        print("Parsed layouts:");
        for(var layout in layouts) {
          print("Layout ID: ${layout.id}, Name: ${layout.name}");
        }
        setState(() {
          afterSalesLayouts = layouts;
        });
      }else{
        dynamicMaster.displayError(context, "Error", output["message"]);
      }
    } catch (e) {
      print(e);
      dynamicMaster.displayError(context, "Error", "An error occurred while fetching after sales layouts");
    }
  }
  
  Widget _aftersalesMovementTypePopupBuilder(BuildContext context, AftersalesMovementTypeModal item, bool isSelected) {
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

  Widget _aftersalesLayoutPopupBuilder(BuildContext context, PrinterLayoutModal item, bool isSelected) {
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

  Future<void> collectItemDialog(BuildContext context) async { 
    IconButton closeButtonWidget = IconButton(
        onPressed: (){
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.clear,
        size: 30,
      )
    );

    Size size = MediaQuery.of(context).size;

    return showDialog(
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return Dialog(
              insetPadding: EdgeInsets.zero,
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
                          Image.asset("assets/images/azone.png", height: 50, width: 50,),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Update Aftersale Movement", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      SizedBox(
                        height: size.height * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                            children: [
                              Row(
                                children: [
                                  const Text("Movement Type:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.009,),
                                  const Text("*", style: TextStyle(color: Colors.red),), // Assuming kRedColor is Colors.red
                                ],
                              ),
                              SizedBox(height: size.height * 0.005,),
                              DropdownSearch<AftersalesMovementTypeModal>(
                                asyncItems: (String? filter) => getAftersalesMovementTypes(filter),
                                popupProps: PopupPropsMultiSelection.modalBottomSheet(
                                  showSelectedItems: true,
                                  itemBuilder: _aftersalesMovementTypePopupBuilder,
                                  showSearchBox: true,
                                ),
                                compareFn: (item, sItem) => item.id == sItem.id,
                                dropdownDecoratorProps:  DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Select Movement Type',
                                    labelStyle: const TextStyle(color: kPrimaryColor),
                                    filled: true,
                                    fillColor: kPrimaryLightColor,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: movementTypeHasError ? Colors.red : Colors.grey,
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
                                      movementTypeHasError = false;
                                      selectedMovementTypeController.text = value.id.toString();
                                    });
                                  }else{
                                    setState(() {
                                      movementTypeHasError = true;
                                      selectedMovementTypeController.clear();
                                    });
                                  }
                                },
                              ),
                              if (movementTypeHasError)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Please select a movement type',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                              SizedBox(height: size.height * 0.02,),
                              Row(
                                children: [
                                  const Text("Packaging Missing:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.009,),
                                  const Text("*", style: TextStyle(color: Colors.red),), // Assuming kRedColor is Colors.red
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: movementTypeHasError ? Colors.red : Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for better UI
                                child: DropdownButton<String>(
                                  value: packagingMissingController.text.isEmpty ? null : packagingMissingController.text,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  hint: const Text("Select Packaging Missing"),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  isExpanded: true,
                                  underline: Container(
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      packagingMissingController.text = newValue!;
                                    });
                                  },
                                  items: packagingMissingList.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02,),
                              LabeledTextField(
                                label: "Packaging Missing Details",
                                hint: "Enter Packaging Missing Details",
                                controller: packagingMissingDetailsController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02,),
                              Row(
                                children: [
                                  const Text("Damage Type:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.009,),
                                  const Text("*", style: TextStyle(color: Colors.red),), // Assuming kRedColor is Colors.red
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: movementTypeHasError ? Colors.red : Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for better UI
                                child: DropdownButton<String>(
                                  value: damageTypeController.text.isEmpty ? null : damageTypeController.text,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  hint: const Text("Select Damage Type"),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  isExpanded: true,
                                  underline: Container(
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      damageTypeController.text = newValue!;
                                    });
                                  },
                                  items: damageTypeList.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02,),
                              LabeledTextField(
                                label: "Damage Type Details",
                                hint: "Enter Damage Type Details",
                                controller: damageTypeDetailsController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02,),
                              Row(
                                children: [
                                  const Text("Accessories Missing:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.009,),
                                  const Text("*", style: TextStyle(color: Colors.red),), // Assuming kRedColor is Colors.red
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: accessoriesMissingHasError ? Colors.red : Colors.grey,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding for better UI
                                child: DropdownButton<String>(
                                  value: accessoriesMissingController.text.isEmpty ? null : accessoriesMissingController.text,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  hint: const Text("Select Accessories Missing"),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  isExpanded: true,
                                  underline: Container(
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      accessoriesMissingController.text = newValue!;
                                    });
                                  },
                                  items: accessoriesMissingList.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02,),
                              LabeledTextField(
                                label: "Missing Accessories Details",
                                hint: "Enter Missing Accessories Details",
                                controller: accessoriesMissingDetailsController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02,),
                              LabeledTextField(
                                label: "Remarks",
                                hint: "Enter Remarks",
                                controller: remarksController,
                                validator: (value) {
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.02,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if(selectedMovementTypeController.text.isEmpty){
                                        setState(() {
                                          movementTypeHasError = true;
                                        });
                                        return;
                                      }else if(accessoriesMissingController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please select accessories missing");
                                        setState(() {
                                          accessoriesMissingHasError = true;
                                        });
                                        return;
                                      } else if(packagingMissingController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please select packaging missing");
                                        return;
                                      } else if(damageTypeController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please select damage type");
                                        return;
                                      }else if(accessoriesMissingController.text == "Yes" && accessoriesMissingDetailsController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please enter missing accessories details");
                                        return;
                                      } else if(packagingMissingController.text == "Yes" && packagingMissingDetailsController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please enter packaging missing details");
                                        return;
                                      } else if(damageTypeController.text == "Yes" && damageTypeDetailsController.text.isEmpty){
                                        dynamicMaster.displayError(context, "Error", "Please enter damage type details");
                                        return;
                                      }
                                      
                                      Navigator.of(context).pop();
                                      confirmCollectItemDialog(context);
                                      
                                    }, 
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kSecondaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Submit")
                                  ),
                                  ElevatedButton(
                                    onPressed: () {}, 
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Cancel")
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.1,),
                            ],
                          ),
                        ),
                      ),
                      // Add action buttons (e.g., Submit, Cancel) if needed
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

  Future<void> printLayoutSelectionDialog(BuildContext context) async {
    // Use the layouts from API if available, otherwise fallback to hardcoded values

    TextEditingController selectedLayoutController = TextEditingController();
    bool selectedLayoutHasError = false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Size size = MediaQuery.of(context).size;
            
            return Dialog(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.6,
                  minHeight: size.height * 0.3,
                ),
                width: size.width,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset("assets/images/azone.png", height: 50, width: 50),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.clear, size: 30),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      const Text(
                        "Select Print Layout",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 10, thickness: 1),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          const Text("Print Layout:", style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(width: size.width * 0.009,),
                          const Text("*", style: TextStyle(color: Colors.red),),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      
                      DropdownSearch<PrinterLayoutModal>(
                        items: afterSalesLayouts,
                        popupProps: PopupPropsMultiSelection.modalBottomSheet(
                          showSelectedItems: true,
                          itemBuilder: _aftersalesLayoutPopupBuilder,
                          showSearchBox: true,
                        ),
                        compareFn: (item, sItem) => item.id == sItem.id,
                        dropdownDecoratorProps:  DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Print Layout',
                            labelStyle: const TextStyle(color: kPrimaryColor),
                            filled: true,
                            fillColor: kPrimaryLightColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: selectedLayoutHasError ? Colors.red : Colors.grey,
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
                            print("Selected layout: ID=${value.id}, Name=${value.name}");
                            setState(() {
                              selectedLayoutHasError = false;
                              selectedLayoutController.text = value.id.toString();
                            });
                          }else{
                            setState(() {
                              selectedLayoutHasError = true;
                              selectedLayoutController.clear();
                            });
                          }
                        },
                      ),
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: selectedLayoutHasError == false && selectedLayoutController.text.isNotEmpty
                                  ? () {
                                      Navigator.of(context).pop();
                                      printActionDialog(selectedLayoutController.text);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Print"),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Cancel"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> printActionDialog(String layoutType) async {
    // Close the dialog first to avoid context issues
    
    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }

      print("Selected layout ID: $layoutType");

      // Show loading modal after dialog is closed
      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.printItemCollection(token, widget.complaintNo, layoutType);

      print("Response from print API:");
      print(response);

      // Dismiss loading modal
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, "Document sent to printer");
      }else{
        print("Error response:");
        print(response);
        String errorMessage = response["message"] ?? "An error occurred while printing";
        dynamicMaster.displayError(context, "Error", errorMessage);
      }
    } catch (e) {
      print("Exception in printActionDialog:");
      print(e);
      // Dismiss loading modal in case of error
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      dynamicMaster.displayError(context, "Error", "An error occurred while printing");
    }
    
  }

  Future<void> submitCollectioinData() async {

    try {
      var token = await sessionProvider.authProvider.token;

      if(token == null){
        dynamicMaster.displayError(context, "Error", "You are not logged in");
        return;
      }

      Map<String, dynamic> data = {
        "complaintNo": aftersaleDetailedModal!.complaintNo,
        "movementType": selectedMovementTypeController.text,
        "packagingMissing": packagingMissingController.text,
        "packagingMissingDetails": packagingMissingDetailsController.text,
        "damageType": damageTypeController.text,
        "damageDetails": damageTypeDetailsController.text,
        "accessoriesMissing": accessoriesMissingController.text,
        "accessoriesMissingDetails": accessoriesMissingDetailsController.text,
        "remarks": remarksController.text,
      };

      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.submitCollectItem(token, data);

      Navigator.of(context).pop();

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, "Collection item submitted successfully");
        getComplaintDetails();
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      dynamicMaster.displayError(context, "Error", "An error occurred while submitting collection item");
    }

  }

  Future<void> confirmCollectItemDialog(BuildContext context) async {
    Size size = MediaQuery.of(context).size;

    IconButton closeButtonWidget = IconButton(
      onPressed: (){
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.clear, size: 30,),
    );

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            child: Container(
              height: size.height * 0.43,
              width: size.width,
              margin: const EdgeInsets.all(20),
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
                  const Text("Confirm Collect Item", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
                  const Divider(height: 10, thickness: 1,),
                  SizedBox(height: size.height * 0.02,),
                  Column(
                    children: [
                      const Text("Are you sure you want to collect the item?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Please note that this action cannot be undone.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),),
                      SizedBox(height: size.height * 0.02,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              submitCollectioinData();
                            }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSecondaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Yes")
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            }, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("No")
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      )
    );

  }

  Future<void> displayMovementDetails(MovementsLine movementDetails) async{
    IconButton closeButtonWidget = IconButton(
        onPressed: (){
        Navigator.of(context).pop();
      },
      icon: const Icon(
        Icons.clear,
        size: 30,
      )
    );

    Size size = MediaQuery.of(context).size;

    return showDialog(
      context: context,
      builder: (context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return Dialog(
              insetPadding: EdgeInsets.zero,
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
                          Image.asset("assets/images/azone.png", height: 50, width: 50,),
                          closeButtonWidget
                        ],
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Text("Aftersale Movement Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
                      const Divider(height: 10, thickness: 1,),
                      SizedBox(height: size.height * 0.02,),
                      SizedBox(
                        height: size.height * 0.5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                            children: [
                              Text("ASCN No: ${movementDetails.aftersalesCollectionNo}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                              Text("Movement Type: ${movementDetails.aftersalesMoveType}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                              Text("Packaging Missing: ${movementDetails.aftersalesPackagingType ?? "N/A"}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                              Text("Packaging Details: ${movementDetails.aftersalesPackagingDetails ?? "N/A"}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                              Text("Damage Type: ${movementDetails.aftersalesDamageType ?? "N/A"}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                              Text("Damage Details: ${movementDetails.aftersalesDamageDetails ?? "N/A"}", style: const TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(height: size.height * 0.01,),
                            ],
                          ),
                        ),
                      ),
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


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: isLoading ? const Center(child: CircularProgressIndicator())
      : aftersaleDetailedModal == null ? 
      const Center(child: Text("No data found"))
      : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.3,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE5CCB8), 
                    Color(0xFFD1B299), 
                    Color(0xFFF3D4B3)
                  ]
                )
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            Text("Doc No: ${aftersaleDetailedModal!.complaintNo}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                            Text("Date: ${DateFormat('dd-MM-yyyy').format(aftersaleDetailedModal!.dateOfComplaint)}"),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.1,
                          width: size.width * 0.1,
                          child: aftersaleDetailedModal!.status == "C" ?
                          Image.asset("assets/icons/padlock.png") :
                          Image.asset("assets/icons/open-lock43.png"),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.01,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: size.width * 0.35,
                              child: Text("Created By: ${aftersaleDetailedModal!.createdBy}"),
                            ),
                            Column(
                              children: [
                                const Text(
                                  "Customer Info",
                                  style: TextStyle(letterSpacing: sqrt1_2, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: size.height * 0.01,),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text("${aftersaleDetailedModal!.consumerName}")),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text("${aftersaleDetailedModal!.consumerPhoneNo}")),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text("${aftersaleDetailedModal!.consumerEmail}")
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              // height: size.height * 0.7,
              child: SingleChildScrollView(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(child: Text("Complaint Details")),
                          Tab(child: Text("Complaint Progress")),
                          Tab(child: Text("Product Movement")),
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.7,
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: size.width,
                                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
                                  decoration: BoxDecoration(
                                    color: kSecondaryLightColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
                                    child:  Column(
                                      children: [
                                        Text("Model No: ${aftersaleDetailedModal!.itemModelNo}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                        Text("Brand: ${aftersaleDetailedModal!.brand}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                        Text("Item Group: ${aftersaleDetailedModal!.itemGroup}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                        Text("Serial No: ${aftersaleDetailedModal!.serialNo}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Date of Purchase:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text(aftersaleDetailedModal!.dateOfPurchase != null ? DateFormat('dd-MM-yyyy').format(aftersaleDetailedModal!.dateOfPurchase) : "N/A", softWrap: true,),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Type of Return:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text("${aftersaleDetailedModal!.typeOfReturn ?? "N/A"}", softWrap: true,),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Description:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text("${aftersaleDetailedModal!.complaintDesc ?? "N/A"}", softWrap: true,),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Customer Location:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text("${aftersaleDetailedModal!.location ?? "N/A"}", softWrap: true,),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Warranty Card No:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text("${aftersaleDetailedModal!.warrantyCardNo ?? "N/A"}", softWrap: true,),
                                    ),
                                    SizedBox(height: size.height * 0.01,),
                                    const Text("Remarks:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, ),),
                                    SizedBox(height: size.height * 0.01,),
                                    SizedBox(
                                      width: size.width * 0.9,
                                      child: Text("${aftersaleDetailedModal!.ourRemarks ?? "N/A"}", softWrap: true,),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: size.width,
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.01,),
                                  Expanded(
                                    child: Container(
                                      child: aftersaleDetailedModal!.progressLines.isEmpty   
                                      ? const Center(child: Text("No progress found")) 
                                      : ListView.builder(
                                        itemCount: aftersaleDetailedModal!.progressLines.length,
                                        itemBuilder: (context, index) {
                                          return Card(
                                            child: ListTile(
                                              title: Text(aftersaleDetailedModal!.progressLines[index].progressStatus),
                                              subtitle: Text(aftersaleDetailedModal!.progressLines[index].progressUpdatedBy),
                                              trailing: Text(DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(aftersaleDetailedModal!.progressLines[index].progressDate))),
                                            ),
                                          );
                                        },
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          collectItemDialog(context);
                                        }, 
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.delivery_dining_outlined),
                                            Text("Update Movement"),
                                          ],
                                        )
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          printLayoutSelectionDialog(context);
                                        }, 
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.print),
                                            Text("Print Action"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01,),
                                  Expanded(
                                    child: Container(
                                      child: aftersaleDetailedModal!.movementsLines.isEmpty   
                                      ? const Center(child: Text("No movement found")) 
                                      : ListView.builder(
                                        itemCount: aftersaleDetailedModal!.movementsLines.length,
                                        itemBuilder: (context, index) {
                                          return MovementListItem(
                                            movementLine: aftersaleDetailedModal!.movementsLines[index],
                                            onTap: () {
                                              displayMovementDetails(aftersaleDetailedModal!.movementsLines[index]);
                                            },
                                          );
                                        },
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}