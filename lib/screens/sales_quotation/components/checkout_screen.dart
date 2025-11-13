import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../modals/coupon_modal.dart';
import '../../../modals/customer_modal.dart';
import '../../../constant/constants.dart';

import '../../../controllers/cart_controller.dart';
import '../../../db/database_helper.dart';
import '../../../modals/business_partner_modal.dart';
import '../../../modals/customer_points_modal.dart';
import '../../../modals/events_modal.dart';
import '../../../modals/product_stock_modal.dart';
import '../../../modals/transaction_modal.dart';
import '../../../modals/warehouse_modal.dart';
import '../../../modals/loyalty_class_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../components/labeled_text_field.dart';
import 'product_serial_number_confirmation.dart';
import '../../../config/config.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  bool convertToInvoice = false;
  TextEditingController mpesaRefNumberController = TextEditingController();
  TextEditingController mpesaAmountPaidController = TextEditingController();
  TextEditingController creditCardAmountPaidController = TextEditingController();
  TextEditingController creditCardOptionController = TextEditingController();
  TextEditingController cashPaymentAmountPaidController = TextEditingController();
  TextEditingController pointsAmountPaidController = TextEditingController();
  TextEditingController couponController = TextEditingController();


  TextEditingController installationChargesController = TextEditingController();
  TextEditingController extraMaterialsController = TextEditingController();
  TextEditingController shippingChargesController = TextEditingController();
  TextEditingController couponOtpController = TextEditingController();
  TextEditingController eventCodeController = TextEditingController();
  TextEditingController eventCouponController = TextEditingController();
  
  TextEditingController pointsRedemptionOTPController = TextEditingController();

  bool isBusinessPartnerrHasErrors = false;
  bool isPaymentOptionHasErrors = false;
  bool submitFormState = false;
  bool isPointsRedemptionOTPValidated = false;
  bool isCouponOTPValidated = false;

  double amountPaid = 0;
  double paymentBalance = 0;
  double totalAmount = 0;
  double discountAmount = 0;

  int _currentStep = 0;
  List<bool> stepErrors = [false, false, false];

  bool isSubmitting = false;

  final focusNode = FocusNode();
  List<BusinessPartnerModal> businessPartnersList = [];
  List<WarehouseModal> warehouseList = [];
  List<EventsModal> eventsList = [];
  BusinessPartnerModal? selectedBusinessPartner;
  
  List<FocusNode> listFocusNodes = List.generate(10,(index) => FocusNode(),);
  
  List<String> creditCardPaymentOptions = ["Credit Card","Pesapal"];
  
  List<TransactionModal> transactionList = [];
  CustomerPointsModal? customerPoints;

  CustomerModal? customer;

  CouponModal? coupon;
  LoyaltyClassModal? loyaltyClass;

  String selectedImage = "";
  
  String? _cachedToken;
  DateTime? lastPressed;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    initScreen();
    _getWarehouses();
    _cacheToken();
  }

  Future<void> _cacheToken() async {
    _cachedToken = await sessionProvider.authProvider.token;
  }

  Future<void> initScreen() async {
    try {
      focusNode.addListener(() async {
        if (!focusNode.hasFocus) {
          if(customerPhoneController.text.isNotEmpty){
            var token = await sessionProvider.authProvider.token;
            if(token == null){
              dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
              return;
            }
            Map<String, dynamic> filters = {
              'phone_number': "${Config.regionPhonePrefix}${customerPhoneController.text}",
              'status': "active",
            };
            setState(() {
              customer = null;
              customerNameController.clear();
              customerEmailController.clear();
              customerAddressController.clear();
            });
            var response = await apiService.filterCustomers(token, filters);
            try {
              if(response.isNotEmpty && response["status"] == "success"){
                var data = response["data"];
                setState(() { customer = customerModalFromJson(jsonEncode(data[0])); });

                customerNameController.text = data[0]["first_name"] + " " + data[0]["last_name"];
                customerEmailController.text = data[0]["email"];
                customerAddressController.text = data[0]["address"];

                fetchCustomerHistory(customer!);
              }else{
                // dynamicMaster.displayError(context, "Error", response["message"]);
              }
            } catch (e) {
              // dynamicMaster.displayError(context, "Error", "An error occurred while fetching customer details");
            }
          }
        }
      });

      var businessPartner = await _dbHelper.getBusinessPartners();

      if(businessPartner.isNotEmpty){
        // print("Business Partners: ${businessPartner}");  
        List<BusinessPartnerModal> newBusinessPartnersList = [];
        for (var element in businessPartner) {
          try {
            newBusinessPartnersList.add(businessPartnerModalFromJson(jsonEncode(element)));
          } catch (e) {
            print("Error: ${e}");
          }
        }
        setState(() {
          businessPartnersList = newBusinessPartnersList;
        });
      }else{
        dynamicMaster.displayError(context, "Error", "No business partners found");
      }

      setState(() {
        totalAmount = controller.total;
      });
    } catch (e) {
      print("Error fetching token: $e");
    }
  }

  Future<void> fetchCustomerHistory(CustomerModal customer) async {
    dynamicMaster.displayLoadingModal(context);

    var token = await sessionProvider.authProvider.token;
    if(token == null){
      dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
      return;
    }

    var response = await apiService.filterCustomerHistory(token, customer.id.toString());
    
    Navigator.pop(context);

    if(response.isNotEmpty && response["status"] == "success"){
      if(response["data"]["transactions"] != null && response["data"]["transactions"].isNotEmpty){
        List<TransactionModal> newTransactionList = [];

        for (var transaction in response["data"]["transactions"]) {
          newTransactionList.add(transactionModalFromJson(jsonEncode(transaction)));
        }

        setState(() {
          transactionList = newTransactionList;
        });
      }

      if(response["data"]["loyalty_points"] != null && response["data"]["loyalty_points"].isNotEmpty){
        setState(() {
          customerPoints = customerPointsModalFromJson(jsonEncode(response["data"]["loyalty_points"]));
        });
      }

      if(response["data"]["loyalty_class"] != null && response["data"]["loyalty_class"].isNotEmpty){
        setState(() {
          loyaltyClass = loyaltyClassModalFromJson(jsonEncode(response["data"]["loyalty_class"]));
          
          selectedImage = loyaltyClass!.name.replaceAll(" ", "").toLowerCase() == "bronze" ? "assets/images/bronze_medal.png" :
          loyaltyClass!.name.replaceAll(" ", "").toLowerCase() == "silver" ? "assets/images/silver_medal.png" :
          loyaltyClass!.name.replaceAll(" ", "").toLowerCase() == "gold" ? "assets/images/gold_medal.png" :
          loyaltyClass!.name.replaceAll(" ", "").toLowerCase() == "platinum" ? "assets/images/platinum_medal.jpg" :
          "";
        });

        calculatePaymentBalance();
      }
      // dynamicMaster.displaySuccessMessage(context, response["message"]);

    }

  }

  void calculatePaymentBalance() {
    
    double mpesaAmountPaid = mpesaAmountPaidController.text.isEmpty ? 0.0 : double.tryParse(mpesaAmountPaidController.text) ?? 0.0;
    double creditCardAmountPaid = creditCardAmountPaidController.text.isEmpty ? 0.0 : double.tryParse(creditCardAmountPaidController.text) ?? 0.0;
    double cashPaymentAmountPaid = cashPaymentAmountPaidController.text.isEmpty ? 0.0 : double.tryParse(cashPaymentAmountPaidController.text) ?? 0.0;
    double pointsAmountPaid = pointsAmountPaidController.text.isEmpty ? 0.0 : double.tryParse(pointsAmountPaidController.text) ?? 0.0;

    double installationCharges = installationChargesController.text.isEmpty ? 0.0 : double.tryParse(installationChargesController.text) ?? 0.0;
    double extraMaterials = extraMaterialsController.text.isEmpty ? 0.0 : double.tryParse(extraMaterialsController.text) ?? 0.0;
    double shippingCharges = shippingChargesController.text.isEmpty ? 0.0 : double.tryParse(shippingChargesController.text) ?? 0.0;

    double totalAmountPaid = mpesaAmountPaid + creditCardAmountPaid + cashPaymentAmountPaid;

    if(isPointsRedemptionOTPValidated){
      totalAmountPaid += pointsAmountPaid;
    }

    discountAmount = 0.0;
    double totalDiscountPercentage = 0.0;

    // check if coupon is applied
    if(coupon != null && isCouponOTPValidated){
      totalDiscountPercentage += coupon!.discountPercentage;
    }
    
    if(loyaltyClass != null && selectedBusinessPartner != null && selectedBusinessPartner!.eligileForLoyalty == 1){
      totalDiscountPercentage += loyaltyClass!.discountPercentage;
    }

    double newVatAmount  = 0;
    double newCartSubTotal = 0;

    if(totalDiscountPercentage > 0){
      for (var product in controller.products.keys.toList()) {
        double vatRate = product.selectedTaxGroup != null ? product.selectedTaxGroup!.rate / 100 : Config.defaultVatRate;

        double newProductDicountPecentage = product.discount + totalDiscountPercentage;

        double unitPriceExcVatBefDisc = product.price / (1 - (product.discount / 100));

        double unitPriceExcVatAfterDisc = unitPriceExcVatBefDisc - (unitPriceExcVatBefDisc * (newProductDicountPecentage / 100));

        discountAmount += (unitPriceExcVatBefDisc - unitPriceExcVatAfterDisc) * controller.products[product];

        newCartSubTotal += unitPriceExcVatAfterDisc * controller.products[product];

        double productVatAmount = unitPriceExcVatAfterDisc * controller.products[product] * vatRate;

        newVatAmount += productVatAmount;
      }
    }else{
      newCartSubTotal = controller.subTotal;
      newVatAmount = controller.vatAmount;
    }

    double totalCharges = installationCharges + extraMaterials + shippingCharges + newCartSubTotal + newVatAmount;

    setState(() {
      totalAmount = totalCharges;
      amountPaid = totalAmountPaid;
      paymentBalance = totalCharges - totalAmountPaid;
    });

  }
  
  Future<void> _getWarehouses() async {
    var fetchedWarehouseList = await _dbHelper.getWarehouses();

    if (fetchedWarehouseList.isNotEmpty) {
      setState(() {
        warehouseList = fetchedWarehouseList;
      });
    }
  }

  Future<void> validateCouponOtp() async{
    if(couponOtpController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter a coupon OTP");
      return;
    }

    dynamicMaster.displayLoadingModal(context);

    var token = await sessionProvider.authProvider.token;
    if(token == null){
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
      return;
    }

    var response = await apiService.validateCouponOtp(token, couponController.text, couponOtpController.text);

    Navigator.pop(context);

    if(response.isNotEmpty && response["status"] == "success"){
      dynamicMaster.displaySuccessMessage(context, response["message"]);

      setState(() {
        coupon = couponModalFromJson(jsonEncode(response["data"]["coupon"]));
        isCouponOTPValidated = true;
      });

      calculatePaymentBalance();
      
    }else{
      dynamicMaster.displayError(context, "Error", response["message"]);
    }
  }

  Future<void> redeemCoupons() async{

    if(_cachedToken == null){
      dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
      return;
    }

    if(eventCodeController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please select an event type");
      return;
    }

    if(eventCouponController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter a coupon code");
      return;
    }

    dynamicMaster.displayLoadingModal(context);

    final Map<String, dynamic> queryParameters = {
      "event_code": eventCodeController.text,
      "coupon_code": eventCouponController.text,
    };

    var response = await apiService.processEventCouponValidation(_cachedToken!, queryParameters);

    Navigator.pop(context);

    if(response.isNotEmpty && response["status"] == "success"){
      dynamicMaster.displaySuccessMessage(context, response["message"]);

      setState(() {
        coupon = couponModalFromJson(jsonEncode(response["data"][0]["coupon"]));
        isCouponOTPValidated = true;
        couponOtpController.text = "${eventCodeController.text}-${eventCouponController.text}";
        couponController.text = "${eventCodeController.text}-${eventCouponController.text}";
      });

      calculatePaymentBalance();
    }else{
      dynamicMaster.displayError(context, "Error", response["message"]);
    }

  }

  Future<void> couponDialogue() async {
    dynamicMaster.displayLoadingModal(context);

    if(_cachedToken == null){
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Session Expired!", "Please login to continue.");
      return;
    }

    // get coupon events
    final filters = {
      "status": "active"
    };

    var response = await apiService.filterEvents(_cachedToken!, filters);
    Navigator.pop(context);

    if(response.isNotEmpty && response["status"] == "success"){
      List<EventsModal> newEventsList = [];

      for (var event in response["data"]) {
        newEventsList.add(eventsModalFromJson(jsonEncode(event)));
      }
      setState(() {
        eventsList = newEventsList;
      });
      
    }else{
      dynamicMaster.displayError(context, "Error", response["message"]);
      return;
    }
    
    Size size = MediaQuery.of(context).size;

    IconButton closeButtonWidget = IconButton( onPressed: (){ Navigator.of(context).pop();},icon: const Icon(Icons.clear, size: 30,));

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState){
            return Dialog(
              child:  Container(
                padding: const EdgeInsets.all(20),
                height: size.height * 0.6,
                width: size.width * 0.5,
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
                      const Text(
                        "Process Coupon Redemption",
                        style: TextStyle(
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
                                  const Text("Select Event Type:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.01,),
                                  const Text("*", style: TextStyle(color: Colors.red),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Container(
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.0
                                  ),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: DropdownButton<String>(
                                  items: eventsList.map<DropdownMenuItem<String>>((EventsModal value) {
                                    return DropdownMenuItem<String>(
                                      value: value.eventCode,
                                      child: Text(value.eventName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if(value != null){
                                      setState(() {
                                        eventCodeController.text = value;
                                      });
                                    }
                                  },
                                  value: eventCodeController.text.isEmpty ? null : eventCodeController.text,
                                  isExpanded: true,
                                  hint: const Text("Select Event Type"),
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
                              Row(
                                children: [
                                  const Text("Enter Coupon Code:", style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(width: size.width * 0.01,),
                                  const Text("*", style: TextStyle(color: Colors.red),),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Coupon Code',
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
                                controller: eventCouponController,
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
                              redeemCoupons();
                            }, 
                            style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor),
                            child: const Row(
                              children: [
                                Icon(Icons.save, color: Colors.white,),
                                Text("Apply", style: TextStyle(color: Colors.white),)
                              ],
                            )
                          )
                        ],
                      )
                    ]
                  )
                )
              )
            );
          }
        );
      }
    );

  }

  Future<void> validateStep() async {
    Size  size = MediaQuery.of(context).size;
    if(_currentStep == 0){
      if(customerPhoneController.text.isEmpty || customerNameController.text.isEmpty || customerEmailController.text.isEmpty || customerAddressController.text.isEmpty || customerBusinessPartnerController.text.isEmpty){
        setState(() {
          stepErrors[0] = true;
          submitFormState = false;
        });
        dynamicMaster.displayError(context, "Error", "Please fill in all the required fields");
        return;
      }
      if (!RegExp(r'^(\+254|254)?(11\d{7}|7\d{8})$').hasMatch(customerPhoneController.text) && Config.releaseRegion == "KENYA") {
        setState(() {
          stepErrors[0] = true;
          submitFormState = false;
        });
        dynamicMaster.displayError(context, "Error", "Please enter a valid Kenyan phone number");
        return;
      }
      if (Config.releaseRegion == "UGANDA" && !RegExp(r'^(\+256|256)?(7\d{8}|4\d{8})$').hasMatch(customerPhoneController.text)) {
        setState(() {
          stepErrors[0] = true;
          submitFormState = false;
        });
        dynamicMaster.displayError(context, "Error", "Please enter a valid Ugandan phone number");
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(customerEmailController.text)) {
        setState(() {
          stepErrors[0] = true;
          submitFormState = false;
        });
        dynamicMaster.displayError(context, "Error", "Please enter a valid email address");
        return;
      }
      if(businessPartnersList.where((element) => element.code == customerBusinessPartnerController.text).isEmpty){
        setState(() {
          isBusinessPartnerrHasErrors = true;
        });
        dynamicMaster.displayError(context, "Error", "Please select a valid business partner");
        return;
      }
      BusinessPartnerModal businessPartner = businessPartnersList.firstWhere((element) => element.code == customerBusinessPartnerController.text);

      if(businessPartner.requiresCustomerId == 1 && customerIDController.text.isEmpty){
        setState(() {
          stepErrors[0] = true;
          submitFormState = false;
        });
        dynamicMaster.displayError(context, "Error", "Please enter a customer ID");
        return;
      }
      for (var i = 0; i < listFocusNodes.length; i++) {
        if(listFocusNodes[i].hasFocus){
          listFocusNodes[i].unfocus();
        }
      }
      calculatePaymentBalance();
      setState(() {
        stepErrors[0] = false;
        submitFormState = true;
        _currentStep++;
      });
    }else if(_currentStep == 1){
      if(convertToInvoice == true){
        if(mpesaRefNumberController.text.isNotEmpty && mpesaAmountPaidController.text.isEmpty){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "M-Pesa Amount Paid are required");
          return;
        }
        if(mpesaAmountPaidController.text.isNotEmpty && mpesaRefNumberController.text.isEmpty){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "M-Pesa Ref Number is required");
          return;
        }
        if(creditCardAmountPaidController.text.isNotEmpty && creditCardOptionController.text.isEmpty){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "Please select a credit card payment option");
          return;
        }
        if(creditCardOptionController.text.isNotEmpty && creditCardAmountPaidController.text.isEmpty){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "Please enter the credit card amount paid");
          return;
        }
        if(paymentBalance.toInt() > 0 && businessPartnersList.where((element) => element.code == customerBusinessPartnerController.text).first.requiresFullPayment == 1){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "Amount paid is less than the total amount. Kindly top up ${NumberFormat.currency(name: Config.defaultCurrency, decimalDigits: 2).format(paymentBalance)}");
          return;
        }
        if(paymentBalance.toInt() < 0 && paymentBalance.abs() > 1000){
          setState(() {
            stepErrors[1] = true;
            submitFormState = false;
          });
          dynamicMaster.displayError(context, "Error", "Invoice change cannot be more than ${Config.defaultCurrency} 1,000.00");
          return;
        }
      }
      for (var i = 0; i < listFocusNodes.length; i++) {
        if(listFocusNodes[i].hasFocus){
          listFocusNodes[i].unfocus();
        }
      }
      setState(() {
        stepErrors[1] = false;
        submitFormState = true;
        _currentStep++;
      });
    }else if(_currentStep == getSteps(size).length - 1){
      if(convertToInvoice == true){
        bool toSubmit = true;
        
        for (var product in controller.products.keys.toList()) {
          WarehouseModal? warehouse;

          final productRequest = await _dbHelper.queryRaw('SELECT a.*, b.item_code FROM cart_product_request a LEFT JOIN cart_products b ON (a.cart_products_id = b.id) WHERE b.item_code = ?',[product.itemCode]);
          
          int productId = await  _dbHelper.getOrCreateProductId(product);

          final productSerialNumbersList = await _dbHelper.getCartProductSerialNumber(productId);

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
                setState(() {
                  warehouse = warehouseObj;
                });

                break;
              }
            }
          }
          
          if(warehouse != null && warehouse!.isVirtual.toString() == "0"){
            Map<String, dynamic> filters = {
              "warehouseCode": warehouse!.code,
              "itemCode": product.itemCode,
            };

            var token = _cachedToken;

            if(token == null){
              dynamicMaster.displayError(context, "Error", "Session Expired! Please login to continue.");
              setState(() {
                submitFormState = false;
                stepErrors[_currentStep] = true;
              });
              return;
            }

            // check the stock of the product
            var response = await apiService.filterProductStock(token, filters);

            if(response["status"] == "success"){
              ProductStockModal productStock = productStockModalFromJson(jsonEncode(response["data"][0]));

              if(controller.products[product] > productStock.onHand){
                dynamicMaster.displayError(context, "Error", "Insufficient stock for ${product.itemCode}. Available stock is ${productStock.onHand}");
                setState(() {
                  submitFormState = false;
                  stepErrors[_currentStep] = true;
                });
                return;
              }else if(productSerialNumbersList.isEmpty){
                dynamicMaster.displayError(context, "Error", "Please scan serial numbers for ${product.itemCode} and try again");
                setState(() {
                  submitFormState = false;
                  stepErrors[_currentStep] = true;
                });
                return;
              }else if(productSerialNumbersList.length < controller.products[product]){
                dynamicMaster.displayError(context, "Error", "Please scan all serial numbers for ${product.itemCode} and try again");
                setState(() {
                  submitFormState = false;
                  stepErrors[_currentStep] = true;
                });
                return;
              }else{
                toSubmit = true;
              }
            }else{
              toSubmit = true;
            }
          }else{
            toSubmit = true;
          }
        }

        if(toSubmit){
          submitQuotationData();
        }
      }else{
        submitQuotationData();
      }
    }
  }

  Future<void> submitQuotationData() async{
    dynamicMaster.displayLoadingModal(context);

    if (isSubmitting) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "Please wait for the current process to complete");
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    List<dynamic> productList = await controller.getCartDetails();
    
    Map<String, dynamic> filtersParam = {
      "customerName": customerNameController.text,
      "customerEmail": customerEmailController.text,
      "customerPhone": "${Config.regionPhonePrefix}${customerPhoneController.text}",
      "customerAddress": customerAddressController.text,
      "customerID": customerIDController.text,
      "customerKraPin": customerKraPinController.text,
      "customerBusinessPartner": customerBusinessPartnerController.text,
      "convertToInvoice": convertToInvoice == true ? 0 : 1,
      "mpesaRefNumber": mpesaRefNumberController.text,
      "mpesaAmountPaid": mpesaAmountPaidController.text,
      "creditCardAmountPaid": creditCardAmountPaidController.text,
      "creditCardOption": creditCardOptionController.text,
      "cashPaymentAmountPaid": cashPaymentAmountPaidController.text,
      "pointsAmountPaid": pointsAmountPaidController.text,
      "couponCode": couponController.text,
      "couponOtp": couponOtpController.text,
      "installationCharges": installationChargesController.text,
      "extraMaterials": extraMaterialsController.text,
      "shippingCharges": shippingChargesController.text,
      "products": productList,
    };

    var token = _cachedToken;

    if(token == null){
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "Session Expired! Please login to continue.");
      setState(() {
        isSubmitting = false;
      });
      return;
    }

    var response = await apiService.postSalesQuotation(token, filtersParam);

    Navigator.pop(context);

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
                  '/sales_quotation', // Name of the route
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
      setState(() {
        isSubmitting = false;
      });
    }

  }

  Future<void> validatePointsRedemption() async{
      
    var token = _cachedToken;

    if(token == null){
      dynamicMaster.displayError(context, "Error", "Session Expired! Please login to continue.");
      return;
    }

    try {

      dynamicMaster.displayLoadingModal(context);

      Map<String, dynamic> filtersParam = {
        "phone_number": "${Config.regionPhonePrefix}${customerPhoneController.text}",
        "points_redeemed": pointsAmountPaidController.text,
      };

      var response = await apiService.validatePointsRedemption(token, filtersParam);

      Navigator.pop(context);

      if(response.isNotEmpty && response["status"] == "success"){
        displayCustomerValidationDialog();
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
      
    } catch (e) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
    }
  }

  Future<void> displayCustomerValidationDialog() async{
    Size size = MediaQuery.of(context).size;

    
    IconButton closeButtonWidget = IconButton(onPressed: (){ Navigator.of(context).pop(); },icon: const Icon(Icons.clear, size: 30,));


    await showDialog(
      context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
              return Dialog(
                child:  Container(
                  width: size.width * 0.9,
                  height: size.height * 0.5,
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.05),
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
                        SizedBox(height: size.height * 0.02,),
                        const Text("Customer Validation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),  
                        const Divider(height: 10, thickness: 1,),
                        SizedBox(height: size.height * 0.02,),
                        const Text("Please enter the OTP sent to the customer's phone number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                        SizedBox(height: size.height * 0.02,),
                        LabeledTextField(
                          label: "OTP",
                          controller: pointsRedemptionOTPController,
                          hint: "Enter OTP",
                          validator: (value) {
                            if(value == null || value.isEmpty){
                              return "Please enter the OTP";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.02,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: (){
                                Navigator.pop(context);
                                validatePointsRedemption();
                              }, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text("Resend OTP", style: TextStyle(color: Colors.white),)
                            ),
                            ElevatedButton(
                              onPressed: (){
                                Navigator.pop(context);
                                validatePointsRedemptionOTP(pointsRedemptionOTPController.text, "${Config.regionPhonePrefix}${customerPhoneController.text}");
                              }, 
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              child: const Text("Submit", style: TextStyle(color: Colors.white),)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              );
            }
          );
        }
    );
  }

  Future<void> validatePointsRedemptionOTP(String otp, String phoneNumber) async{

    Map<String, dynamic> filtersParam = {
      "phone_number": phoneNumber,
      "otp": otp,
      "points_redeemed": pointsAmountPaidController.text,
    };

    var token = _cachedToken;

    if(token == null){
      dynamicMaster.displayError(context, "Error", "Session Expired! Please login to continue.");
      return;
    }

    try {
      dynamicMaster.displayLoadingModal(context);

      var response = await apiService.validatePointsRedemptionOTP(token, filtersParam);

      Navigator.pop(context);

      if(response.isNotEmpty && response["status"] == "success"){
        setState(() { isPointsRedemptionOTPValidated = true; });
        calculatePaymentBalance();
        dynamicMaster.displaySuccessMessage(context, response["message"]);
      }else{
        displayCustomerValidationDialog();
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      Navigator.pop(context);
      displayCustomerValidationDialog();
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
    }

  }

  List<Step> getSteps(Size size) => [
    Step(
      state: stepErrors[0] == true ? StepState.error : _currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: _currentStep == 0,
      title: _currentStep == 0 ? const Text("Customer Info") : const Text(""),
      content: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              IntlPhoneField(
                focusNode: focusNode,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(),
                    ),
                ),
                initialCountryCode: Config.releaseRegion == "UGANDA" ? 'UG' : 'KE',
                controller: customerPhoneController,
                onChanged: (phone) {
                },
                disableLengthCheck: true,
                validator: (PhoneNumber? value) {
                  if (value == null || value.completeNumber.isEmpty) {
                    return 'Please enter a phone number';
                  }

                  if(Config.releaseRegion == "KENYA"){

                    if (!RegExp(r'^(\+254|254)?(1\d{8}|7\d{8})$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid Kenyan phone number';
                    }
                  } else if(Config.releaseRegion == "TANZANIA"){

                    if (!RegExp(r'^(\+255|255)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid Tanzanian phone number';
                    }
                  } else if(Config.releaseRegion == "UGANDA"){

                    if (!RegExp(r'^(\+256|256)?(11\d{7}|7\d{8})$').hasMatch(value.completeNumber)) {
                      return 'Please enter a valid Ugandan phone number';
                    }
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
                enabled: customer != null ? false : true,
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
                enabled: customer != null ? false : true,
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
                decoration: InputDecoration(
                  labelText: 'Customer ${Config.taxPinName} (optional)',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                  labelStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: Colors.grey
                    )
                  ),
                  focusedBorder: const OutlineInputBorder(
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
                      BusinessPartnerModal businessPartner = businessPartnersList.firstWhere((element) => element.code == value);

                      setState(() {
                        isBusinessPartnerrHasErrors = false;
                        customerBusinessPartnerController.text = value;
                        selectedBusinessPartner = businessPartner;
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
            ],
          ),
        ),
      )
    ),
    Step(
      state: stepErrors[1] == true ? StepState.error : _currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: _currentStep == 1,
      title: _currentStep == 1 ? const Text("Payment") : const Text(""),
      content: SizedBox(
        child: SingleChildScrollView(
          child: controller.needsApproval() ? 
          const Column(
            children: [
              Text("This transaction requires approval", style: TextStyle(color: Colors.red)),
              SizedBox(height: 10,),
            ],
          ) :
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Convert to Invoice:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), ),
                  ToggleSwitch(
                    minWidth: 60.0,
                    cornerRadius: 20.0,
                    activeBgColors: [[Colors.green[800]!], [Colors.red[800]!]],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    initialLabelIndex: convertToInvoice == true ? 0 : 1,
                    totalSwitches: 2,
                    labels: const ['YES', 'No'],
                    radiusStyle: true,
                    changeOnTap: true,
                    onToggle: (index) {
                      setState(() {
                        convertToInvoice = index == 0 ? true : false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02,),
              convertToInvoice == false ?
              Container() :
              Column(
                children: [
                  DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(
                              child: Text(
                                "M-Pesa",
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Card",
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Cash",
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Points",
                                style: TextStyle(
                                  color: Colors.black
                                ),
                              ),
                            ),
                          ]
                        ),
                        SizedBox(
                          height: size.height * 0.25,
                          child: TabBarView(
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: size.height *0.02,),
                                  TextField(
                                    focusNode: listFocusNodes[0],
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'M-Pesa Ref Number',
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
                                      ),
                                    ),
                                    controller: mpesaRefNumberController,
                                  ),
                                  SizedBox(height: size.height * 0.02,),
                                  TextField(
                                    focusNode: listFocusNodes[1],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Amount Paid',
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
                                      ),
                                    ),
                                    controller: mpesaAmountPaidController,
                                    onChanged: (value){
                                      calculatePaymentBalance();
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: size.height *0.02,),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isPaymentOptionHasErrors ? Colors.red : Colors.grey,
                                        width: 1.0
                                      ),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: DropdownButton<String>(
                                      focusNode: listFocusNodes[2],
                                      items: creditCardPaymentOptions.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if(value != null){
                                          setState(() {
                                            isPaymentOptionHasErrors = false;
                                            creditCardOptionController.text = value;
                                          });
                                        }
                                      },
                                      value: creditCardOptionController.text.isEmpty ? null : creditCardOptionController.text,
                                      isExpanded: true,
                                      hint: const Text("Select Credit Card Option"),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                      ),
                                      padding: const EdgeInsets.only(left: 9.0, right: 9.0),
                                      underline: Container(),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02,),
                                  TextField(
                                    focusNode: listFocusNodes[3],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Amount Paid',
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
                                      ),
                                    ),
                                    controller: creditCardAmountPaidController,
                                    onChanged: (value){
                                      calculatePaymentBalance();
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: size.height *0.02,),
                                  TextField(
                                    focusNode: listFocusNodes[4],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Amount Paid',
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
                                      ),
                                    ),
                                    controller: cashPaymentAmountPaidController,
                                    onChanged: (value){
                                      calculatePaymentBalance();
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: size.height * 0.02,),
                                  TextField(
                                    focusNode: listFocusNodes[8],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Total Amount to Redeem in ${Config.defaultCurrency}.',
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.grey
                                        )
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 1.5,
                                          color: kPrimaryColor
                                        )
                                      ),
                                    ),
                                    controller: pointsAmountPaidController,
                                    onChanged: (value) {
                                      if(value.isNotEmpty){
                                        if(customerPoints == null || double.parse(value) > customerPoints!.balancePoints){
                                          dynamicMaster.displayError(context, "Error", "Amount to redeem cannot be more than ${customerPoints!.balancePoints}");
                                          pointsAmountPaidController.clear();
                                          return;
                                        }
                                      }
                                      calculatePaymentBalance();
                                    },
                                  ),
                                  SizedBox(height: size.height * 0.02,),
                                  // add validation button
                                  ElevatedButton(
                                    onPressed: () {
                                      validatePointsRedemption();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(kPrimaryColor),
                                    ),
                                    child: const Text("Validate Points Redemption", style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: size.height * 0.02,),
                  TextField(
                    focusNode: listFocusNodes[5],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Installation Charges: (Optional)',
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
                      ),
                    ),
                    controller: installationChargesController,
                    onChanged: (value) {
                      calculatePaymentBalance();
                    },
                  ),
                  SizedBox(height: size.height * 0.02,),
                  TextField(
                    focusNode: listFocusNodes[6],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Extra Materials: (Optional)',
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
                      ),
                    ),
                    controller: extraMaterialsController,
                    onChanged: (value) {
                      calculatePaymentBalance();
                    },
                  ),
                  SizedBox(height: size.height * 0.02,),
                  TextField(
                    focusNode: listFocusNodes[7],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Shipping Charges: (Optional)',
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
                      ),
                    ),
                    controller: shippingChargesController,
                    onChanged: (value) {
                      calculatePaymentBalance();
                    },
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.5,
                        child: TextField(
                          focusNode: listFocusNodes[9],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Coupon Code: (Optional)',
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
                            ),
                          ),
                          controller: couponController,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02,),
                      ElevatedButton(
                        onPressed: () {
                          // redeemCoupons();
                          couponDialogue();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(kPrimaryColor),
                        ),
                        child: const Text("Apply", style: TextStyle(color: Colors.white),),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Coupon Discount (%):", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        coupon == null ? "0.00" : coupon!.discountPercentage.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Loyalty Discount (%):", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        loyaltyClass != null && selectedBusinessPartner != null && selectedBusinessPartner!.eligileForLoyalty == 1 ? loyaltyClass!.discountPercentage.toString() : "0.00" ,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Discount Amount:", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(discountAmount), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Grand Total:", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(totalAmount), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Amount Paid:", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(amountPaid), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Balance Due:", style: TextStyle(fontWeight: FontWeight.bold), ),
                      Text(
                        NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(paymentBalance),  
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red), 
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.03,),
            ],
          ),
        ),
      )
    ),
    Step(
      state: stepErrors[2] == true ? StepState.error : _currentStep > 2 ? StepState.complete : StepState.indexed,
      isActive: _currentStep == 2,
      title: _currentStep == 2 ? const Text("Summary") : const Text(""),
      content: convertToInvoice == false ? const SizedBox() : const ProductSerialNumberConfirmation()
    )
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(theme, context, _scaffoldKey),
      body: Container(
        height: size.height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                              "Customer Form",
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "History",
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Loyalty Program",
                            style: TextStyle(
                              color: Colors.black
                            ),
                          ),
                        ),
                      ]
                    ),
                    SizedBox(
                      height: size.height * 0.75,
                      child: TabBarView(
                        children: [
                          Stepper(
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
                                    onPressed: _currentStep == getSteps(size).length - 1 && isSubmitting ? null : details.onStepContinue,
                                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue),),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.02,),
                              const Text(
                                "Transaction History",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: size.height * 0.02,),
                              SizedBox(
                                height: size.height * 0.65,
                                child: transactionList.isEmpty ? 
                                const Center(
                                  child: Text("No history found"),
                                ) :
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: transactionList.length,
                                  itemBuilder: (context, index){
                                    return Card(
                                      child: ListTile(
                                        title: Text(transactionList[index].invoiceNumber),
                                        subtitle: Text(DateFormat('dd-MMMM-yyyy').format(transactionList[index].createdAt)),
                                        trailing: Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(transactionList[index].totalAmount)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: size.height * 0.02,),
                              const Text("Loyalty Program", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                              SizedBox(height: size.height * 0.02,),
                              
                              loyaltyClass == null ? 
                              Column(
                                children: [
                                  SizedBox(height: size.height * 0.04,),
                                  const Text("Customer is not enrolled in our loyalty program"),
                                  SizedBox(height: size.height * 0.04,),

                                  RoundedButton(btnText: "Enroll in Loyalty Program", press: (){}, btnColor: kSecondaryColor, textColor: Colors.white)
                                ],
                              ) : 
                              
                              Column(
                                children: [
                                  SizedBox(
                                    height: size.height * 0.2,
                                    width: size.width * 0.5,
                                    child: selectedImage != "" ? Image.asset(selectedImage) : const SizedBox(),
                                  ),

                                  SizedBox(height: size.height * 0.02,),

                                  Text(loyaltyClass!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),

                                  SizedBox(height: size.height * 0.04,),

                                  Column( 
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Purchase Todate: ${customerPoints == null ? "0.00" : NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format((customerPoints!.pointsEarned * 100))}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                      ),
                                      Text(
                                        "Acquired Points Todate: ${customerPoints == null ? "0.00" : customerPoints!.pointsEarned}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                      ),
                                      Text(
                                        "Points Redeemed Todate: ${customerPoints == null ? "0.00" : customerPoints!.pointsRedeemed}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.03,),
                                      Text(
                                        "Available Points Todate: ${customerPoints == null ? "0.00" : customerPoints!.balancePoints}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18
                                        ),
                                      ),
                                    ]
                                  )
                                ]
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}