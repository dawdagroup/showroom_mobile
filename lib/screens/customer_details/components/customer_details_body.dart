import 'package:flutter/material.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../services/api_service.dart';
import '../../../providers/session_provider.dart';
import 'package:provider/provider.dart';
import '../../../modals/customer_modal.dart';
import '../../../modals/transaction_modal.dart';
import '../../../modals/customer_points_modal.dart';
import '../../../modals/loyalty_class_modal.dart';
import 'dart:convert';
import '../../../components/loyalty_card_widget.dart';
import '../../../constant/constants.dart';
import 'package:intl/intl.dart';

class CustomerDetailsBody extends StatefulWidget {
  final String customerId;
  const CustomerDetailsBody({super.key, required this.customerId});

  @override
  State<CustomerDetailsBody> createState() => _CustomerDetailsBodyState();
}

class _CustomerDetailsBodyState extends State<CustomerDetailsBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  List<TransactionModal> transactionList = [];
  CustomerPointsModal? customerPoints;

  CustomerModal? customer;
  LoyaltyClassModal? loyaltyClass;
  LoyaltyClassModal? nextTier;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getCustomerDetails();
  }

  Future<void> getCustomerDetails() async {
    setState(() {isLoading = true;});

    try {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        return;
      }

      dynamicMaster.displayLoadingModal(context);

      final response = await apiService.filterCustomerHistory(token, widget.customerId);

      Navigator.pop(context);

      if (response["status"] == "success" && response["data"].isNotEmpty) {
        
        if(response["data"]["customer"] != null && response["data"]["customer"].isNotEmpty){
          setState(() {
            customer = customerModalFromJson(jsonEncode(response["data"]["customer"]));
          });
        }

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
          });
        }

        if(response["data"]["next_loyalty_class"] != null && response["data"]["next_loyalty_class"].isNotEmpty){
          setState(() {
            nextTier = loyaltyClassModalFromJson(jsonEncode(response["data"]["next_loyalty_class"]));
          });
        }

      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }

    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }

    setState(() {isLoading = false;});
  }
  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      child: isLoading ? const Center(child: CircularProgressIndicator()) :
      customer == null ? const Center(child: Text("No customer details found")) :
      Stack(
        children: [
          SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Container(
                  width: size.width,
                  height: size.height * 0.3,
                  decoration: const BoxDecoration(
                    // color: kPrimaryColor,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE5CCB8), 
                        Color(0xFFD1B299), 
                        Color(0xFFF3D4B3)
                      ]
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),
                      const Text("Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      SizedBox(height: size.height * 0.01),
                      Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        width: size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("Name: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                Text("${customer!.firstName} ${customer!.lastName}".toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Email: ", style: TextStyle(fontWeight: FontWeight.bold),),
                                Text("${customer!.email}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width,
                  height: size.height * 0.7,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.16),
                      DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(
                                  child: Text("Transaction History"), 
                                ), 
                                Tab(
                                  child: Text("Loyalty Points")
                                )
                              ]
                            ),
                            SizedBox(
                              height: size.height * 0.4685, 
                              child: TabBarView(
                                children: [
                                  SizedBox(  
                                    height: size.height * 0.4685,
                                    child: transactionList.isEmpty ? const Center(child: Text("No transaction history found")) : ListView.builder(
                                      itemCount: transactionList.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: transactionList[index].transactionType == "purchase" ? const Color.fromARGB(255, 120, 173, 122) : Colors.red,
                                              child: Text(transactionList[index].transactionType == "purchase" ? "PUR" : "RE", style: const TextStyle(color: Colors.white),),
                                            ),
                                            title: Text(transactionList[index].invoiceNumber),
                                            subtitle: Text(DateFormat("dd-MM-yyyy").format(transactionList[index].createdAt), style: const TextStyle(fontSize: 12),),
                                            trailing: Text(NumberFormat.simpleCurrency(name: "KES ", decimalDigits: 2).format(transactionList[index].totalAmount)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(  
                                    height: size.height * 0.4685,
                                    child: transactionList.isEmpty ? const Center(child: Text("No transaction history found")) : ListView.builder(
                                      itemCount: transactionList.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: transactionList[index].transactionType == "purchase" ? Colors.green : Colors.red,
                                              child: Text(transactionList[index].transactionType == "purchase" ? "PUR" : "RE", style: const TextStyle(color: Colors.white),),
                                            ),
                                            title: Text(transactionList[index].invoiceNumber),
                                            subtitle: Text(DateFormat("dd-MM-yyyy").format(transactionList[index].createdAt), style: const TextStyle(fontSize: 12),),
                                            trailing: Text(transactionList[index].transactionType == "purchase" ? transactionList[index].pointsEarned.toString() : "-${transactionList[index].pointsRedeemed.toString()}"),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ]
                              )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: size.height * 0.16,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: AzoneLoyaltyCard(
                availablePoints: customerPoints == null ? 0 : customerPoints!.balancePoints,
                membershipNumber: customer!.phoneNumber,
                nextTierPoints: nextTier == null ? 0 : double.parse(nextTier!.minPoints.toString()),
                nextTierName: nextTier == null ? loyaltyClass!.name : nextTier!.name,
                totalPoints: customerPoints == null ? 0 : customerPoints!.pointsEarned,
                logoAssetPath: "assets/images/azone.png",
                tier: loyaltyClass!.name.toLowerCase() == "bronze" ? AzoneTier.bronze : loyaltyClass!.name.toLowerCase() == "silver" ? AzoneTier.silver : loyaltyClass!.name.toLowerCase() == "gold" ? AzoneTier.gold : AzoneTier.platinum,
              ),
            ),
          ),

        ],
      ),
    );
  }
}