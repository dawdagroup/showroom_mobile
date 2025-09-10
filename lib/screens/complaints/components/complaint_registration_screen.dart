import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/phone_number.dart';

import 'package:dropdown_search/dropdown_search.dart';

import '../../../config/config.dart';
import '../../../services/api_service.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';

import '../../../constant/constants.dart';
import '../../../components/labeled_text_field.dart';
import '../../../modals/region_modal.dart';
import '../../../modals/zone_modal.dart';
import '../../../modals/town_modal.dart';
import '../../../modals/item_modal.dart';
import '../../../components/labeled_date_field.dart';
import '../../../modals/complaint_type_modal.dart';



import 'package:intl/intl.dart';

import 'dart:convert';



class ComplaintRegistrationScreen extends StatefulWidget {
  const ComplaintRegistrationScreen({super.key});

  @override
  State<ComplaintRegistrationScreen> createState() => _ComplaintRegistrationScreenState();
}

class _ComplaintRegistrationScreenState extends State<ComplaintRegistrationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;

  final List<String> _warrantyStatusDropDownItems = ["In Warranty", "Not In Warranty"];

  TextEditingController customerNameInputController = TextEditingController();
  TextEditingController customerContactNumberInputController = TextEditingController();
  TextEditingController regionInputController = TextEditingController();
  TextEditingController zoneInputController = TextEditingController();
  TextEditingController townNameController = TextEditingController();
  TextEditingController physicalAddressInputController = TextEditingController();
  TextEditingController modelNumberInputController = TextEditingController();
  TextEditingController serialNumberInputController = TextEditingController();
  TextEditingController dateOfPurchaseInputController = TextEditingController();
  TextEditingController warrantyStatusInputController = TextEditingController();
  TextEditingController complaintDescriptionInputController = TextEditingController();
  TextEditingController complaintTypeInputController = TextEditingController();

  DateTime dateOfPurchase = DateTime.now();

  bool regionInputHasError = false;
  bool zoneInputHasError = false;
  bool townNameHasError = false;
  bool warrantyStatusHasError = false;

  
  int _currentStep = 0;
  List<bool> stepErrors = [false, false, false];
  bool isLoading = false;
  bool isFormValid = false;

  void selectDateOfPurchase() async {
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateOfPurchase,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != dateOfPurchase) {
      setState(() {
        dateOfPurchase = pickedDate;
        dateOfPurchaseInputController.text = DateFormat('yyyy-MM-dd').format(dateOfPurchase);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  Future<List<RegionModal>> getRegionData(String? filter) async{
    Map<String, dynamic> filters = {};

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getRegionData(token, filters);

      if(output["status"] == "success"){
        List<RegionModal> minRegions = [];
        for(var item in output["data"]){
          minRegions.add(regionModalFromJson(jsonEncode(item)));
        }
        return minRegions;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _regionPopupBuilder(BuildContext context, RegionModal item, bool isSelected) {
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

  Future<List<ZoneModal>> getZoneData(String? filter) async{
    Map<String, dynamic> filters = {};
    if(filter != null){
      filters["region_id"] = regionInputController.text;
    }

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getZoneData(token, filters);

      if(output["status"] == "success"){
        List<ZoneModal> minZones = [];
        for(var item in output["data"]){
          minZones.add(zoneModalFromJson(jsonEncode(item)));
        }
        return minZones;
      }else{
        return [];  
      }
    } catch (e) {
      return [];
    }
  }

  Widget _zonePopupBuilder(BuildContext context, ZoneModal item, bool isSelected) {
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

  Future<List<TownModal>> getTownData(String? filter) async{
    Map<String, dynamic> filters = {};
    if(filter != null){
      filters["zone_id"] = zoneInputController.text;
    }

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getTownData(token, filters);

      if(output["status"] == "success"){
        List<TownModal> minTowns = [];
        for(var item in output["data"]){
          minTowns.add(townModalFromJson(jsonEncode(item)));
        }
        return minTowns;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _townPopupBuilder(BuildContext context, TownModal item, bool isSelected) {
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

  Future<List<ItemModal>> getProductData(String? filter) async{
    Map<String, dynamic> filters = {};

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.fecthProductDetails(token, filters);

      if(output["status"] == "success"){
        List<ItemModal> minProducts = [];
        for(var item in output["data"]){
          // print(item);
          try{  
            minProducts.add(itemModalFromJson(jsonEncode(item)));
          }catch(e){
            print(e);
          }
        }
        return minProducts;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _productPopupBuilder(BuildContext context, ItemModal item, bool isSelected) {
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
        title: Text(item.brand + " - " + item.modelNo),
      ),
    );
  }

  Future<List<ComplaintTypeModal>> getComplaintTypes(String? filter) async{
    Map<String, dynamic> filters = {};

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return [];
      }

      Map<String, dynamic> output = await apiService.getComplaintTypes(token, filters);

      if(output["status"] == "success"){
        List<ComplaintTypeModal> minComplaintTypes = [];
        for(var item in output["data"]){
          minComplaintTypes.add(complaintTypeModalFromJson(jsonEncode(item)));
        }
        return minComplaintTypes;
      }else{
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Widget _complaintTypePopupBuilder(BuildContext context, ComplaintTypeModal item, bool isSelected) {
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

  List<Step> getSteps(Size size){
    return [
      Step(
        state: stepErrors[0] == true ? StepState.error : _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep == 0,
        title: _currentStep == 0 ? const Text("Customer Info") : const SizedBox(),
        content: SizedBox(
          height: size.height * 0.6,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                LabeledTextField(
                  label: "Customer Name:",
                  hint: "Enter Customer Name",
                  controller: customerNameInputController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    const Text("Customer Phone Number:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  initialCountryCode: Config.releaseRegion == "UGANDA" ? 'UG' : 'KE',
                  controller: customerContactNumberInputController,
                  onChanged: (phone) {},
                  disableLengthCheck: true,
                  validator: (PhoneNumber? value) {
            
                    if(Config.releaseRegion == "UGANDA"){
                      if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+256|256)?(7\d{8}|4\d{8})$').hasMatch(value.completeNumber)) {
                        return 'Please enter a valid Ugandan phone number';
                      }
                      return null;
                    }
                    
                    if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid Kenyan phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.01),
                SizedBox(height: size.height * 0.01),
                Row(
                  children: [
                    const Text("Region:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                DropdownSearch<RegionModal>(
                  asyncItems: (String? filter) => getRegionData(filter),
                  popupProps: PopupPropsMultiSelection.modalBottomSheet(
                    showSelectedItems: true,
                    itemBuilder: _regionPopupBuilder,
                    showSearchBox: true,
                  ),
                  compareFn: (item, sItem) => item.name == sItem.name,
                  dropdownDecoratorProps:  DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Region',
                      labelStyle: const TextStyle(color: kPrimaryColor),
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: regionInputHasError ? Colors.red : Colors.grey,
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
                        regionInputHasError = false;
                        regionInputController.text = value.id.toString();
                      });
                    }else{
                      setState(() {
                        regionInputHasError = true;
                        regionInputController.clear();
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.01,),
                Row(
                  children: [
                    const Text("Zone:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                AbsorbPointer(
                  absorbing: regionInputController.text.isEmpty,
                  child: DropdownSearch<ZoneModal>(
                    asyncItems: (String? filter) => getZoneData(filter),
                    popupProps: PopupPropsMultiSelection.modalBottomSheet(
                      showSelectedItems: true,
                      itemBuilder: _zonePopupBuilder,
                      showSearchBox: true,
                    ),
                    compareFn: (item, sItem) => item.name == sItem.name,
                    dropdownDecoratorProps:  DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Zone',
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        filled: true,
                        fillColor: kPrimaryLightColor,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: zoneInputHasError ? Colors.red : Colors.grey,
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
                          zoneInputHasError = false;
                          zoneInputController.text = value.id.toString();
                        });
                      }else{
                        setState(() {
                          zoneInputHasError = true;
                          zoneInputController.clear();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.01,),
                Row(
                  children: [
                    const Text("Area:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                AbsorbPointer(
                  absorbing: zoneInputController.text.isEmpty,
                  child: DropdownSearch<TownModal>(
                    asyncItems: (String? filter) => getTownData(filter),
                    popupProps: PopupPropsMultiSelection.modalBottomSheet(
                      showSelectedItems: true,
                      itemBuilder: _townPopupBuilder,
                      showSearchBox: true,
                    ),
                    compareFn: (item, sItem) => item.name == sItem.name,
                    dropdownDecoratorProps:  DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Area',
                        labelStyle: const TextStyle(color: kPrimaryColor),
                        filled: true,
                        fillColor: kPrimaryLightColor,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: townNameHasError ? Colors.red : Colors.grey,
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
                          townNameHasError = false;
                          townNameController.text = value.id.toString();
                        });
                      }else{
                        setState(() {
                          townNameHasError = true;
                          townNameController.clear();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: size.height * 0.01,),
                LabeledTextField(
                  label: "Physical Address:",
                  hint: "Enter Physical Address",
                  controller: physicalAddressInputController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.03,),
              ],
            ),
          ),
        ),
      ),
      Step(
        state: stepErrors[1] == true ? StepState.error : _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep == 1,
        title: _currentStep == 1 ? const Text("Complaint Info") : const SizedBox(),
        content: SizedBox(
          height: size.height * 0.6,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Product Model:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                DropdownSearch<ItemModal>(
                  asyncItems: (String? filter) => getProductData(filter),
                  popupProps: PopupPropsMultiSelection.modalBottomSheet(
                    showSelectedItems: true,
                    itemBuilder: _productPopupBuilder,
                    showSearchBox: true,
                  ),
                  compareFn: (item, sItem) => item.modelNo == sItem.modelNo,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Product Model',
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if(value != null){
                      setState(() {
                        modelNumberInputController.text = value.modelNo;
                      });
                    }else{
                      setState(() {
                        modelNumberInputController.clear();
                      });
                    }
                  },
                ),
                SizedBox(height: size.height * 0.01,),
                LabeledTextField(
                  label: "Serial Number:",
                  hint: "Enter Serial Number",
                  controller: serialNumberInputController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.01,),
                LabeledDateField(
                  label: "Date of Purchase:",
                  hint: "Select Date of Purchase",
                  controller: dateOfPurchaseInputController,
                  selectedDate: dateOfPurchase,
                  onDateSelected: selectDateOfPurchase,
                ),
                Row(
                  children: [
                    const Text("Warranty Status:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: warrantyStatusHasError ? Colors.red : Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownButton<String>(
                    items: _warrantyStatusDropDownItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if(value!.isNotEmpty){
                        setState(() {
                          warrantyStatusHasError = false;
                          warrantyStatusInputController.text = value;
                        });
                      }else{
                        warrantyStatusHasError = true;
                        warrantyStatusInputController.clear();
                      }
                    },
                    value: warrantyStatusInputController.text.isEmpty ? null : warrantyStatusInputController.text,
                    isExpanded: true,
                    hint: const Text('Select Status of Warranty', style: TextStyle(color: kPrimaryColor),),
                    style: const TextStyle( //te
                        color: Colors.black, //Font color
                        fontSize: 15 //font size on dropdown button
                    ),
                    padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                    underline: Container()
                  ),
                ),
                SizedBox(height: size.height * 0.01,),
                LabeledTextField(
                  label: "Complaint Description:",
                  hint: "Enter Complaint Description",
                  controller: complaintDescriptionInputController,
                  validator: (value) {
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.03,),
              ],
            ),
          ),
        ),
      ),
      Step(
        state: stepErrors[2] == true ? StepState.error : _currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: _currentStep == 2,
        title: _currentStep == 2 ? const Text("Complaint Submission") : const SizedBox(),
        content: SizedBox(
          height: size.height * 0.6,
          width: size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Complaint Type:", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(width: size.width * 0.009,),
                    const Text("*", style: TextStyle(color: kRedColor),),
                  ],
                ),
                SizedBox(height: size.height * 0.005,),
                DropdownSearch<ComplaintTypeModal>(
                  asyncItems: (String? filter) => getComplaintTypes(filter),
                  popupProps: PopupPropsMultiSelection.modalBottomSheet(
                    showSelectedItems: true,
                    itemBuilder: _complaintTypePopupBuilder,
                    showSearchBox: true,
                  ),
                  compareFn: (item, sItem) => item.name == sItem.name,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Select Complaint Type',
                      filled: true,
                      fillColor: kPrimaryLightColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: kPrimaryColor
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if(value != null){
                      setState(() {
                        complaintTypeInputController.text = value.name;
                      });
                    }else{
                      setState(() {
                        complaintTypeInputController.clear();
                      });
                    }
                  },
                ),

              ],
            ),
          ),
        ),
      )

    ];
  }

  Future<void> submitForm() async {
    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return;
      }

      Map<String, dynamic> data = {
        "consumerName": customerNameInputController.text,
        "consumerPhoneNo": customerContactNumberInputController.text,
        "region": regionInputController.text,
        "zone": zoneInputController.text,
        "town": townNameController.text,
        "location": physicalAddressInputController.text,
        "itemModelNo": modelNumberInputController.text,
        "serialNo": serialNumberInputController.text,
        "dateOfPurchase": dateOfPurchaseInputController.text,
        "warrantyStatus": warrantyStatusInputController.text,
        "complaintDesc": complaintDescriptionInputController.text,
        "complaintOrigin": complaintTypeInputController.text,
      };

      dynamicMaster.displayLoadingModal(context);

      Map<String, dynamic> response = await apiService.registerComplaint(token, data);

      Navigator.pop(context);

      if(response["status"] == "success"){
        dynamicMaster.displaySuccessMessage(context, response["message"]);

        // Clear all input fields
        customerNameInputController.clear();
        customerContactNumberInputController.clear();
        regionInputController.clear();
        zoneInputController.clear();
        townNameController.clear();
        physicalAddressInputController.clear();
        modelNumberInputController.clear();
        serialNumberInputController.clear();
        dateOfPurchaseInputController.clear();
        warrantyStatusInputController.clear();
        complaintDescriptionInputController.clear();
        complaintTypeInputController.clear();

        // wait for 3 seconds and navigate to the next page
        await Future.delayed(const Duration(seconds: 3));

        Navigator.pushNamed(context, "/complaints");

        // setState(() {
        //   _currentStep = 0;
        // });
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
        return;
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
      return;
    }
  }
  
  Future<void> validateStep() async{
    Size size = MediaQuery.of(context).size;

    setState(() { isFormValid = false; });

    if(_currentStep == 0){
      if(customerNameInputController.text.isEmpty || customerContactNumberInputController.text.isEmpty || regionInputController.text.isEmpty || zoneInputController.text.isEmpty || townNameController.text.isEmpty || physicalAddressInputController.text.isEmpty){
        dynamicMaster.displayError(context, "Error", "Please fill all required fields");
        setState(() { isFormValid = false; stepErrors[0] = true; });
        return;
      }else{
        setState(() {
          isFormValid = true; stepErrors[0] = false; 
          if(_currentStep < getSteps(size).length - 1){
            _currentStep++;
          }
        });
      }
    }else if(_currentStep == 1){
      if(modelNumberInputController.text.isEmpty || serialNumberInputController.text.isEmpty || dateOfPurchaseInputController.text.isEmpty || warrantyStatusInputController.text.isEmpty || complaintDescriptionInputController.text.isEmpty){
        dynamicMaster.displayError(context, "Error", "Please fill all required fields");
        setState(() { isFormValid = false; stepErrors[1] = true; });
        return;
      }else{
        setState(() {
          isFormValid = true; stepErrors[1] = false; 
          if(_currentStep < getSteps(size).length - 1){
            _currentStep++;
          }
        });
      }
    }else if(_currentStep == getSteps(size).length - 1){
      if(complaintTypeInputController.text.isEmpty){
        dynamicMaster.displayError(context, "Error", "Please select a complaint type");
        setState(() { isFormValid = false; stepErrors[2] = true; });
        return;
      }else{
        setState(() {
          isFormValid = true; stepErrors[2] = false; 
          if(_currentStep < getSteps(size).length - 1){
            _currentStep++;
          }
        });
        submitForm();
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(theme, context, _scaffoldKey),
      body: Container(
        height: size.height,
        width: size.width,
        // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Complaint Registration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(
                width: size.width,
                height: size.height * 0.83,
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepTapped: (int index){
                    if(index > _currentStep){
                      return;
                    }
                    validateStep();
                  },
                  onStepContinue: (){
                    validateStep();
                  },
                  onStepCancel: (){
                    setState(() {
                      if (_currentStep > 0) {
                        _currentStep--;
                      } else {
                        _currentStep = 0;
                      }
                    });
                  },
                  steps: getSteps(size),
                  controlsBuilder: (context, details) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.blue),
                          ),
                          child: Text(_currentStep == getSteps(size).length - 1 ? "Submit" : "Next", style: const TextStyle(color: Colors.white),),
                        ),
                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          style: ButtonStyle(backgroundColor: WidgetStateProperty.all(kSecondaryColor),),
                          child: const Text("Previous", style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}