import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:showroom_manager/constant/constants.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/filter_params.dart';
import '../../../config/config.dart';
import '../../../modals/delivery_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'sales_delivery_filter_dialog.dart';

class SalesDeliveryScreenBody extends StatefulWidget {
  const SalesDeliveryScreenBody({super.key});

  @override
  State<SalesDeliveryScreenBody> createState() => _SalesDeliveryScreenBodyState();
}

class _SalesDeliveryScreenBodyState extends State<SalesDeliveryScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  List<DeliveryModal> deliveryList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    filterSalesDelivery({});
  }

  Future<void> filterSalesDelivery(Map<String, dynamic> filters) async {
      var token = await sessionProvider.authProvider.token;

      if (token == null) {  
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      try {
        setState(() {
          isLoading = true;
          deliveryList.clear();
        });

        var response = await apiService.filterSalesDelivery(token, filters);

        setState(() {
          isLoading = false;
        });

        if(response["status"] == "success" && response["data"] != null){
          for (var item in response["data"]) {
            deliveryList.add(deliveryModalFromJson(jsonEncode(item)));
          }
        }
        else {
          dynamicMaster.displayError(context, "Error", response["message"] ?? "Failed to filter sales delivery.");
        }
      } catch (e) {
        dynamicMaster.displayError(context, "Error", "Failed to filter sales delivery.");
      }
  }
  
  Future<void> showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SalesDeliveryFilterDialog(
          onSubmit: (FilterParams filterParams) {
            applyFilters(filterParams);
          },
        );
      },
    );
  }

  
  Future<void> applyFilters(FilterParams filterParams) async {
    Map<String, dynamic> filters = {};
    if (filterParams.customerName.isNotEmpty) filters["customerName"] = filterParams.customerName;
    if (filterParams.phoneNumber.isNotEmpty) filters["customerPhoneNo"] = filterParams.phoneNumber;
    if (filterParams.fromDate.isNotEmpty) filters["fromDate"] = filterParams.fromDate;
    if (filterParams.toDate.isNotEmpty) filters["toDate"] = filterParams.toDate;
    if (filterParams.quotationNo.isNotEmpty) filters["delivery_number"] = filterParams.quotationNo;

    await filterSalesDelivery(filters);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          const Text("Sales Delivery List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            height: size.height * 0.68,
            child: isLoading ? const Center(child: CircularProgressIndicator()) 
            : deliveryList.isEmpty ?
            const Center(child: Text("No Deliveries Found"))
            : ListView.builder(
              itemCount: deliveryList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, '/delivery_details', arguments: deliveryList[index].deliveryNumber.toString());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        height: size.height * 0.22,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text("Date: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(DateFormat('dd-MM-yyyy').format(DateTime.parse(deliveryList[index].docDate.toString()))),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Quote No: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(deliveryList[index].deliveryNumber.toString()),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Customer Name: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(deliveryList[index].customerName ?? "N/A"),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Phone No: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(deliveryList[index].customerPhoneNo ?? "N/A"),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Amount: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(double.parse(deliveryList[index].totalAmount.toString()))),
                              ],
                            )
                          ],
                        ),
                      )
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/sales_delivery_create');
                  }, 
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text("Add New Delivery"),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    showFilterDialog();
                  }, 
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: kSecondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text("Filter"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}