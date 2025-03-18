import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';

import '../../../modals/customer_modal.dart';
import '../../../constant/constants.dart';

import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../modals/business_partner_modal.dart';

class CheckoutSalesOrderScreen extends StatefulWidget {
  const CheckoutSalesOrderScreen({super.key});

  @override
  State<CheckoutSalesOrderScreen> createState() => _CheckoutSalesOrderScreenState();
}

class _CheckoutSalesOrderScreenState extends State<CheckoutSalesOrderScreen> {
  final CartController controller = Get.find();
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  TextEditingController customerPhoneController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController customerEmailController = TextEditingController();
  TextEditingController customerAddressController = TextEditingController();
  TextEditingController customerIDController = TextEditingController();
  TextEditingController customerKraPinController = TextEditingController();
  TextEditingController customerBusinessPartnerController = TextEditingController();
  final focusNode = FocusNode();

  List<BusinessPartnerModal> businessPartnersList = [];
  bool isBusinessPartnerrHasErrors = false;

  CustomerModal? customer;

  @override
  void initState() {
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    initScreen();
  }

  Future<void> initScreen() async {
    focusNode.addListener(() async {
      if (!focusNode.hasFocus) {
        if(customerPhoneController.text.isNotEmpty){
          var token = await sessionProvider.authProvider.token;
          if(token == null){
            dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
            return;
          }
          Map<String, dynamic> filters = {
            'phone_number': "+254${customerPhoneController.text}",
          };
          var response = await apiService.filterCustomers(token, filters);
          try {
            if(response.isNotEmpty && response["status"] == "success"){
              var data = response["data"];
              setState(() {
                customer = customerModalFromJson(jsonEncode(data[0]));
              });
              customerNameController.text = data[0]["first_name"] + " " + data[0]["last_name"];
              customerEmailController.text = data[0]["email"];
              customerAddressController.text = data[0]["address"];

            }else{
              dynamicMaster.displayError(context, "Error", response["message"]);
            }
          } catch (e) {
            dynamicMaster.displayError(context, "Error", "An error occurred while fetching customer details");
          }
        }
      }
    });

    var businessPartner = await _dbHelper.getBusinessPartners();

    if(businessPartner.isNotEmpty){
      List<BusinessPartnerModal> newBusinessPartnersList = businessPartner.map((e) => businessPartnerModalFromJson(jsonEncode(e))).toList();
      setState(() {
        businessPartnersList = newBusinessPartnersList;
      });
    }else{
      dynamicMaster.displayError(context, "Error", "No business partners found");
    }
    
  }

  Future<void> submitSalesOrder() async {
    if(customerPhoneController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter customer phone number");
      return;
    }

    if(customerNameController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter customer name");
      return;
    }

    if(customerEmailController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter customer email");
      return;
    }

    if(customerAddressController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter customer address");
      return;
    }

    if(customerBusinessPartnerController.text.isEmpty){
      setState(() {
        isBusinessPartnerrHasErrors = true;
      });
      dynamicMaster.displayError(context, "Error", "Please select business partner");
      return;
    }

    var token = await sessionProvider.authProvider.token;

    if(token == null){
      dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
      return;
    }
    
    List<dynamic> productList = await controller.getCartDetails();

    Map<String, dynamic> customerData = {
      "customerPhone": "+254${customerPhoneController.text}",
      "customerName": customerNameController.text,
      "customerEmail": customerEmailController.text,
      "customerAddress": customerAddressController.text,
      "customerID": customerIDController.text,
      "customerKraPin": customerKraPinController.text,
      "customerBusinessPartner": customerBusinessPartnerController.text,
      "products": productList
    };

    var response = await apiService.postSalesOrder(token, customerData);

    if(response.isNotEmpty && response["status"] == "success"){
      dynamicMaster.displaySuccessMessage(context, response["message"]);
      controller.clearCart();
      
      showDialog(
        context: context,
        builder: (context){
          Future.delayed(
            const Duration(seconds: 4),(){
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/sales_order', // Name of the route
                (Route<dynamic> route) => false, // This clears the stack
              );
            }
          );
          return Center(
            child: Lottie.asset(
                "assets/animations/success.zip"
            ),
          );
        }
      );
    }else{
      dynamicMaster.displayError(context, "Error", response["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: dynamicMaster.applicationBar(theme, context),
      body: Container(
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02,),
                const Text("Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                SizedBox(height: size.height * 0.02,),
                IntlPhoneField(
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(),
                      ),
                  ),
                  initialCountryCode: 'KE',
                  controller: customerPhoneController,
                  onChanged: (phone) {
                  },
                  disableLengthCheck: true,
                  validator: (PhoneNumber? value) {
                    if (value == null || value.completeNumber.isEmpty) {
                      return 'Please enter a phone number';
                    }

                    if (!RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid Kenyan phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02,),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (required)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelStyle: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: kPrimaryColor
                      )
                    )
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  controller: customerNameController,
                ),
                SizedBox(height: size.height * 0.02,),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Email Address (required)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelStyle: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: kPrimaryColor
                      )
                    )
                  ),
                  controller: customerEmailController,
                ),
                SizedBox(height: size.height * 0.02,),
                TextField(
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Address (required)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelStyle: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: kPrimaryColor
                      )
                    )
                  ),
                  controller: customerAddressController,
                ),
                SizedBox(height: size.height * 0.02,),
                TextField(
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Customer ID (optional)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelStyle: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: kPrimaryColor
                      )
                    )
                  ),
                  controller: customerIDController,
                ),
                SizedBox(height: size.height * 0.02,),
                TextField(
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Customer KRA PIN (optional)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    labelStyle: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: Colors.grey
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5,
                        color: kPrimaryColor
                      )
                    )
                  ),
                  controller: customerKraPinController,
                ),
                SizedBox(height: size.height * 0.02,),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isBusinessPartnerrHasErrors ? Colors.red : Colors.grey,
                      width: 1.0
                    ),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: DropdownButton<String>(
                    items: businessPartnersList.map((BusinessPartnerModal value) {
                      return DropdownMenuItem<String>(
                        value: value.code,
                        child: Text(value.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if(value != null){
                        setState(() {
                          isBusinessPartnerrHasErrors = false;
                          customerBusinessPartnerController.text = value;
                        });
                      }
                    },
                    value: customerBusinessPartnerController.text.isEmpty ? null : customerBusinessPartnerController.text,
                    isExpanded: true,
                    hint: const Text("Select Business Partner"),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
                    padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                    underline: Container(),
                  ),
                ),
                SizedBox(height: size.height * 0.03,),

                RoundedButton(
                  btnText: "Submit", 
                  press: () {
                    submitSalesOrder();
                  }, 
                  btnColor: kPrimaryColor, 
                  textColor: kPrimaryLightColor
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
