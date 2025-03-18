import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';
import 'package:showroom_manager/constant/constants.dart';
import '../../../providers/session_provider.dart';
import '../../../components/dynamic_widgets.dart';
import '../../../services/api_service.dart';
import 'package:provider/provider.dart';

import '../../../components/filter_params.dart';
import 'filter_sales_order_dialog.dart';
import '../../../modals/sales_order_modal.dart';
import 'dart:convert';

class SalesOrderScreenBody extends StatefulWidget {
  const SalesOrderScreenBody({super.key});

  @override
  State<SalesOrderScreenBody> createState() => _SalesOrderScreenBodyState();
}

class _SalesOrderScreenBodyState extends State<SalesOrderScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;
  List<SalesOrderModal> salesOrderList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getSalesOrder(filters: {});
  }

  Future<void> filterSalesOrder() async {
    // show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FilterSalesOrderDialog(
          onSubmit: (FilterSalesOrderParams filterParams) {
            applyFilters(filterParams);
          },
        );
      },
    );
  }

  Future<void> applyFilters(FilterSalesOrderParams filterParams) async {
    // TODO: implement applyFilters
    Map<String, dynamic> filters = {};
    if (filterParams.customerName.isNotEmpty) filters["customerName"] = filterParams.customerName;
    if (filterParams.phoneNumber.isNotEmpty) filters["customerPhoneNo"] = filterParams.phoneNumber;
    if (filterParams.fromDate.isNotEmpty) filters["salesOrderFromDate"] = filterParams.fromDate;
    if (filterParams.toDate.isNotEmpty) filters["salesOrderToDate"] = filterParams.toDate;
    if (filterParams.salesOrderNo.isNotEmpty) filters["salesOrderNo"] = filterParams.salesOrderNo;

    await getSalesOrder(filters: filters);  
  }

  Future<void> getSalesOrder({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; });
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.filterSalesOrders(token, filters);

      if (response["status"] == "success") {
        var data = response["data"];
        List<SalesOrderModal> min_sales_order_list = [];
        for(var item in data){
          min_sales_order_list.add(salesOrderModalFromJson(jsonEncode(item)));
        }
        setState(() {
          salesOrderList = min_sales_order_list;
        });
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      print('Error fetching sales orders: $e');
      dynamicMaster.displayError(context, "Error", "An error occurred while fetching sales orders.");
    }
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        children: [
          const Text('Sales Order Screen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          SizedBox(height: size.height * 0.02,),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  filterSalesOrder();
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.filter_list),
                    SizedBox(width: size.width * 0.02,),
                    const Text('Filter')
                  ],
                )
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01,),
          SizedBox(
            width: size.width * 0.9,
            height: size.height * 0.63,
            child: isLoading ?
            const Center(child: CircularProgressIndicator()) :
            salesOrderList.isEmpty ?
            const Center(child: Text("No sales order found.")) :
            ListView.builder(
              itemCount: salesOrderList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(salesOrderList[index].saleOrderNumber.toString()),
                      subtitle: Text(salesOrderList[index].customerName),
                      trailing: Column(
                        children: [
                          Text(NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(double.parse(salesOrderList[index].docTotal.toString()))),
                          const SizedBox(height: 5),
                          Text(DateFormat("d/MM/y").format(DateTime.parse(salesOrderList[index].documentDate.toString()))),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/sales_order_details', arguments: salesOrderList[index].saleOrderNumber.toString());
                      },
                    ),
                  ),
                );
              },
            )
          ),
          SizedBox(height: size.height * 0.02,),
          RoundedButton(
            btnText: 'Add Sales Order', 
            press: () {
              Navigator.pushNamed(context, '/sales_order_form');
            }, 
            btnColor: kSecondaryColor, 
            textColor: Colors.white
          )
        ],
      ),

    );
  }
}