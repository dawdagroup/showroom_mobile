import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/tier_card_widget.dart';
import '../../../services/api_service.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';
import '../../../constant/constants.dart';
import '../../../components/labeled_text_field.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../../components/rounded_buttons.dart';
import '../../../components/labeled_date_field.dart';
import 'package:intl/intl.dart';
import '../../../modals/customer_modal.dart';

class LoyaltyProgramBody extends StatefulWidget {
  const LoyaltyProgramBody({super.key});

  @override
  State<LoyaltyProgramBody> createState() => _LoyaltyProgramBodyState();
}

class _LoyaltyProgramBodyState extends State<LoyaltyProgramBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  Future<void> addCustomerBottomSheet() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    TextEditingController customerFirstNameInputController = TextEditingController();
    TextEditingController customerMiddleNameInputController = TextEditingController();
    TextEditingController customerLastNameInputController = TextEditingController();
    TextEditingController phoneNumberInputController = TextEditingController();
    TextEditingController customerEmailInputController = TextEditingController();
    TextEditingController customerAddressInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: size.width,
          height: size.height * 0.8,
          color: Colors.grey.shade100,
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
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
              const Text("Add New Customer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              const Divider(height: 10, thickness: 1,),
              SizedBox(height: size.height * 0.02,),
              SizedBox(
                height: size.height * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LabeledTextField(
                        label: "Customer First Name:",
                        hint: "Enter Customer First Name",
                        controller: customerFirstNameInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      LabeledTextField(
                        label: "Customer Middle Name:",
                        hint: "Enter Customer Middle Name",
                        controller: customerMiddleNameInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),  
                      LabeledTextField(
                        label: "Customer Last Name:",
                        hint: "Enter Customer Last Name",
                        controller: customerLastNameInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      // Phone Number Field
                      const Row(
                        children: [
                          Text("Customer Phone Number:", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Text("*", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Customer Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'KE',
                        controller: phoneNumberInputController,
                        onChanged: (phone) {},
                        disableLengthCheck: true,
                        validator: (PhoneNumber? value) {

                          if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                            return 'Please enter a valid Kenyan phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      LabeledTextField(
                        label: "Customer Email:",
                        hint: "Enter Customer Email",
                        controller: customerEmailInputController,
                        validator: (value) {
                          if (value != null && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      LabeledTextField(
                        label: "Customer Address:",
                        hint: "Enter Customer Address",
                        controller: customerAddressInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                    ],
                  ),
                )
              ),
              SizedBox(height: size.height * 0.04,),
              RoundedButton(
                btnText: "Add Customer",
                press: () {
                  // Add customer logic here
                  if (customerFirstNameInputController.text.isEmpty || customerMiddleNameInputController.text.isEmpty || customerLastNameInputController.text.isEmpty || phoneNumberInputController.text.isEmpty || customerEmailInputController.text.isEmpty || customerAddressInputController.text.isEmpty) {
                    dynamicMaster.displayError(context, "Error", "Please fill in all fields");
                  } else {
                    Navigator.of(context).pop();
                    submitCustomer(customerFirstNameInputController.text, customerMiddleNameInputController.text, customerLastNameInputController.text, phoneNumberInputController.text, customerEmailInputController.text, customerAddressInputController.text);
                    
                  }
                },
                btnColor: kSecondaryColor,
                textColor: kPrimaryLightColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitCustomer(String firstName, String middleName, String lastName, String phoneNumber, String email, String address) async {

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      dynamicMaster.displayError(context, "Error", "Please enter a valid email address");
      return;
    }

    // Add customer logic here
    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return;
      }

      Map<String, dynamic> data = {
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "phone_number": phoneNumber,
        "email": email,
        "address": address,
        "longitude": "0",
        "latitude": "0",
        "loyalty_id": "1",
      };

      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.addCustomer(token, data);

      Navigator.pop(context);

      if (response["status"] == "success") {
        dynamicMaster.displaySuccessMessage(context, response["message"]);
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "An error occurred while adding customer");
    }
  }

  Future<void> filterCustomerBottomSheet() async {
    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    TextEditingController customerFirstNameInputController = TextEditingController();
    TextEditingController customerLastNameInputController = TextEditingController();
    TextEditingController phoneNumberInputController = TextEditingController();
    TextEditingController customerEmailInputController = TextEditingController();
    TextEditingController fromDateInputController = TextEditingController();
    TextEditingController toDateInputController = TextEditingController();

    
    DateTime selectedFromDate = DateTime.now();
    DateTime selectedToDate = DateTime.now();

    void selectFromDate() async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != selectedFromDate) {
        setState(() {
          selectedFromDate = pickedDate;
          fromDateInputController.text = DateFormat('yyyy-MM-dd').format(selectedFromDate);
        });
      }
    }

    void selectToDate() async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null && pickedDate != selectedToDate) {
        setState(() {
          selectedToDate = pickedDate;
          toDateInputController.text = DateFormat('yyyy-MM-dd').format(selectedToDate);
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: size.width,
          height: size.height * 0.8,
          color: Colors.grey.shade100,
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
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
              const Text("Filter Customer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              const Divider(height: 10, thickness: 1,),
              SizedBox(height: size.height * 0.02,),
              SizedBox(
                height: size.height * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // From Date Field
                      LabeledDateField(
                        label: "From Date:",
                        hint: "Select From Date",
                        controller: fromDateInputController,
                        selectedDate: selectedFromDate,
                        onDateSelected: selectFromDate,
                        validator: (value) {
                          if(value != null && toDateInputController.text.isNotEmpty){
                            DateFormat formatter = DateFormat('yyyy-MM-dd');
                            DateTime fromDateParsed = formatter.parseStrict(fromDateInputController.text);
                            DateTime toDateParsed = formatter.parseStrict(toDateInputController.text);

                            if(fromDateParsed.isAfter(toDateParsed)){
                              return 'From date cannot be greater than to date';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
                      // To Date Field
                      LabeledDateField(
                        label: "To Date:",
                        hint: "Select To Date",
                        controller: toDateInputController,
                        selectedDate: selectedToDate,
                        onDateSelected: selectToDate,
                        validator: (value) {
                          if(value != null && fromDateInputController.text.isNotEmpty){
                            DateFormat formatter = DateFormat('yyyy-MM-dd');
                            DateTime fromDateParsed = formatter.parseStrict(fromDateInputController.text);
                            DateTime toDateParsed = formatter.parseStrict(toDateInputController.text);

                            if(toDateParsed.isBefore(fromDateParsed)){
                              return 'To date cannot be less than from date';
                            }
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02),
                      LabeledTextField(
                        label: "Customer First Name:",
                        hint: "Enter Customer First Name",
                        controller: customerFirstNameInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      LabeledTextField(
                        label: "Customer Last Name:",
                        hint: "Enter Customer Last Name",
                        controller: customerLastNameInputController,
                        validator: (value) {
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      const Row(
                        children: [
                          Text("Customer Phone Number:", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Text("*", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'Customer Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: 'KE',
                        controller: phoneNumberInputController,
                        onChanged: (phone) {},
                        disableLengthCheck: true,
                        validator: (PhoneNumber? value) {
                          if (value != null && value.completeNumber.isNotEmpty && !RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                            return 'Please enter a valid Kenyan phone number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02,),
                      LabeledTextField(
                        label: "Customer Email:",
                        hint: "Enter Customer Email",
                        controller: customerEmailInputController,
                        validator: (value) {
                          if (value != null && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04,),
              RoundedButton(
                btnText: "Filter Customer",
                press: () async {
                  // Add filter customer logic here
                  Map<String, dynamic> filters = {};

                  if (toDateInputController.text.isNotEmpty) filters["created_to"] = toDateInputController.text;
                  if (fromDateInputController.text.isNotEmpty) filters["created_from"] = fromDateInputController.text;
                  if (customerFirstNameInputController.text.isNotEmpty) filters["first_name"] = customerFirstNameInputController.text;
                  if (customerLastNameInputController.text.isNotEmpty) filters["last_name"] = customerLastNameInputController.text;
                  if (phoneNumberInputController.text.isNotEmpty) filters["phone_number"] = phoneNumberInputController.text;
                  if (customerEmailInputController.text.isNotEmpty) filters["email"] = customerEmailInputController.text;

                  if (filters.isEmpty) {
                    dynamicMaster.displayError(context, "Error", "Please select at least one filter");
                    return;
                  }

                  Map<String, dynamic> response = await filterCustomer(filters);  

                  if (response["status"] == "success" && response["data"].isNotEmpty) {
                    Navigator.pop(context);

                    List<CustomerModal> customerList = [];

                    for (var customer in response["data"]) {
                      customerList.add(customerModalFromJson(jsonEncode(customer)));
                    }

                    customerListBottomSheet(customerList);

                  } else {
                    dynamicMaster.displayError(context, "Error", response["message"]);
                  }
                },
                btnColor: kSecondaryColor,
                textColor: kPrimaryLightColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> customerListBottomSheet(List<CustomerModal> customerList) async {

    Size size = MediaQuery.of(context).size;
    Widget closeButtonWidget = IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: size.width,
          height: size.height * 0.8,
          color: Colors.grey.shade100,
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.02),
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
              const Text("Filtered Customers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              const Divider(height: 10, thickness: 1,),
              SizedBox(height: size.height * 0.02,),
              Expanded(
                child: ListView.builder(
                  itemCount: customerList.length,
                  itemBuilder: (BuildContext context, int index) {
                    // return CustomerCard(customer: customerList[index]);
                    return InkWell(
                      onTap: () {
                        // Add customer details logic here
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/customer_details', arguments: customerList[index].id.toString());
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(customerList[index].firstName.toString()),
                          subtitle: Text(customerList[index].lastName.toString()),
                          trailing: Text(customerList[index].phoneNumber.toString()),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> filterCustomer(Map<String, dynamic> filters) async {
    Map<String, dynamic> output = {};

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return output;
      }

      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.filterCustomers(token, filters);

      Navigator.pop(context);

      if (response["status"] == "success" && response["data"].isNotEmpty) {
        output["status"] = "success";
        output["data"] = response["data"];
      } else {
        output["status"] = "failed";
        output["message"] = response["message"];
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }

    return output;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Main Content
        SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                // Bronze Tier
                const TierCard(
                  title: 'Bronze Tier',
                  maxPoints: '1000',
                  discount: '1%',
                  minPoints: '0',
                  bgColor: kBronzeColor,
                ),
                SizedBox(height: size.height * 0.02),
                // Silver Tier
                const TierCard(
                  title: 'Silver Tier',
                  maxPoints: '5000',
                  discount: '1.5%',
                  minPoints: '1000',
                  bgColor: kSilverColor,
                ),
                SizedBox(height: size.height * 0.02),
                // Gold Tier
                const TierCard(
                  title: 'Gold Tier',
                  maxPoints: '10000',
                  discount: '2%',
                  minPoints: '5000',
                  bgColor: kGoldColor2,
                ),
                SizedBox(height: size.height * 0.02),
                // Platinum Tier
                const TierCard(
                  title: 'Platinum Tier',
                  maxPoints: 'unlimited',
                  discount: '2.5%',
                  minPoints: '10000',
                  bgColor: kPlatinumColor,
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
        // Floating Action Buttons
        Positioned(
          bottom: 90,
          right: 16,
          child: FloatingActionButton(
            heroTag: "filterButton",
            onPressed: () {
              // Add filter customer logic here
              filterCustomerBottomSheet();
            },
            backgroundColor: kSecondaryColor,
            child: const Icon(Icons.search_off_outlined, color: kPrimaryLightColor,),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: "addButton",
            onPressed: () {
              // Add add customer logic here
              addCustomerBottomSheet();
            },
            backgroundColor: kPrimaryColor,
            child: const Icon(Icons.add, color: kPrimaryLightColor,),
          ),
        ),
      ],
    );
  }
}
