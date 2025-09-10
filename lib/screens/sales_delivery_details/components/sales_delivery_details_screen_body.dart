import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../config/config.dart';
import '../../../modals/delivery_details_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'sales_delivery_product_card.dart';

class SalesDeliveryDetailsScreenBody extends StatefulWidget {
  final String deliveryNumber;
  const SalesDeliveryDetailsScreenBody({super.key, required this.deliveryNumber});

  @override
  State<SalesDeliveryDetailsScreenBody> createState() => _SalesDeliveryDetailsScreenBodyState();
}

class _SalesDeliveryDetailsScreenBodyState extends State<SalesDeliveryDetailsScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  DeliveryDetailsModal? deliveryDetailsModal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getSaledDeliveryDetails();
  }

  Future<void> getSaledDeliveryDetails() async {
    setState(() { isLoading = true; });

    var token = await sessionProvider.authProvider.token;

    // Ensure token is not null
    if (token == null) {
      dynamicMaster.displayError(context, "Error", "No valid session token.");
      setState(() { isLoading = false; });
      return;
    }

    try {

      var response = await apiService.getSalesDeliveryDetails(token, widget.deliveryNumber);

      setState(() { isLoading = false; });

      if (response["status"] == 'success' && response["data"] != null) {
        setState(() {
          deliveryDetailsModal = deliveryDetailsModalFromJson(jsonEncode(response["data"][0]));
        });
      } else {
        dynamicMaster.displayError(context, "Error", "Failed to fetch delivery details.");
      }
    } catch (e) {
      print("Error fetching delivery details: $e");
      dynamicMaster.displayError(context, "Error", "An unexpected error occurred.");
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: isLoading 
      ? const Center(child: CircularProgressIndicator()) 
      : deliveryDetailsModal == null 
      ? const Center(child: Text("No delivery details available.")) 
      : SingleChildScrollView(
        child: Column(
          children: [
            // Display delivery details here
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
                padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.01,),
                                Text("Delivery No: ${deliveryDetailsModal!.deliveryNumber.toString()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(DateFormat('dd-MMMM-yyyy').format(deliveryDetailsModal!.docDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                // SizedBox(height: size.height * 0.01,),
                                Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(deliveryDetailsModal!.totalAmount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.1,
                              width: size.width * 0.1,
                              child: deliveryDetailsModal!.documentStatus == "C" ?
                              Image.asset("assets/icons/padlock.png") :
                              Image.asset("assets/icons/open-lock43.png"),
                            ),
                          ],
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
                              child: Text(
                                "Created By: ${deliveryDetailsModal!.createdBy}", 
                                softWrap: true, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
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
                                  child: Text(deliveryDetailsModal!.customerName.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                                SizedBox(
                                  width: size.width * 0.4,
                                  child: Text(deliveryDetailsModal!.customerPhoneNo.toString(), softWrap: true, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                ),
                              ],
                            )
                            
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ),
            SizedBox(
              height: size.height * 0.6,
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {}, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add),
                            Text("Add Item"),
                          ],
                        )
                      ),
                      ElevatedButton(
                        onPressed: () { 
                          // printSalesDelivery(); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.print),
                            Text("Print Delivery"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deliveryDetailsModal!.documentLines.length,
                      itemBuilder: (context, index) {
                        return SalesDeliveryProductCard(deliveryLineItem: deliveryDetailsModal!.documentLines[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}