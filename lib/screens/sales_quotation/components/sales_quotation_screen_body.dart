import 'dart:convert';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/filter_dialog.dart';
import '../../../components/filter_params.dart';
import '../../../modals/sales_quotation_modal.dart';


class SalesQuotationScreenBody extends StatefulWidget {
  const SalesQuotationScreenBody({super.key});

  @override
  State<SalesQuotationScreenBody> createState() => _SalesQuotationScreenBodyState();
}

class _SalesQuotationScreenBodyState extends State<SalesQuotationScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  List<SalesQuotationModal> salesQuotationList = [];
  late Future<void> futureSalesQuotation; // Cache the future to avoid multiple calls
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    getSalesQuotation(filters: {}); // Initiate API call once
  }

  // Function to get sales quotation
  Future<void> getSalesQuotation({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; salesQuotationList = [];});
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.filterSalesQuotations(filters, token);

      if (response["status"] == "success") {
        for (var data in response["data"]) {
          SalesQuotationModal salesQuotation = salesQuotationModalFromJson(jsonEncode(data));
          salesQuotationList.add(salesQuotation);
        }
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
    }
    setState(() {
      isLoading = false;
    });
  }


  Future<void> submitFilters( String customerName, String phoneNumber, String fromDate, String toDate, String quotationNo) async {
    // validate the date fields
    if(fromDate.isNotEmpty || toDate.isNotEmpty){
      if(fromDate.isEmpty){
        dynamicMaster.displayError(context, "Error", "Please select a from date");
        return;
      }
      if(toDate.isEmpty){
        dynamicMaster.displayError(context, "Error", "Please select a to date");
        return;
      }
      if(!DateTime.parse(fromDate).isBefore(DateTime.parse(toDate))){
        dynamicMaster.displayError(context, "Error", "From date cannot be greater than to date");
        return;
      }
    }

    setState(() { isLoading = true; salesQuotationList = [];});
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.filterSalesQuotations({
        "customerName": customerName,
        "customerPhoneNo": phoneNumber,
        "salesOrderFromDate": fromDate,
        "salesOrderToDate": toDate,
        "salesOrderRef": quotationNo
      }, token);

      if (response["status"] == "success") {
        for (var data in response["data"]) {
          SalesQuotationModal salesQuotation = salesQuotationModalFromJson(jsonEncode(data));
          salesQuotationList.add(salesQuotation);
        }
      } else {
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "We are unable to connect to the server at the moment. Please check your internet connection and try again.");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterDialog(
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
    if (filterParams.fromDate.isNotEmpty) filters["salesOrderFromDate"] = filterParams.fromDate;
    if (filterParams.toDate.isNotEmpty) filters["salesOrderToDate"] = filterParams.toDate;
    if (filterParams.quotationNo.isNotEmpty) filters["salesOrderRef"] = filterParams.quotationNo;

    await getSalesQuotation(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      width: size.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sales Quotation",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    ],
                  )
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: (){
                    showFilterDialog();
                  }, 
                  child: const Icon(Icons.filter_alt_outlined),
                ),
              ],
            ), 
            SizedBox(height: size.height * 0.01),
            SizedBox(
              height: size.height * 0.7,
              child: isLoading ? 
              const Center(child: CircularProgressIndicator()) :
              salesQuotationList.isEmpty ?
              const Center(child: Text("No sales quotation found")) :
              ListView.builder(
                itemCount: salesQuotationList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/sales_quotation_details', arguments: salesQuotationList[index].salesOrderRef.toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          leading: Text("${index + 1}"),
                          title: Text(salesQuotationList[index].customerName),
                          subtitle: Text(salesQuotationList[index].salesOrderRef.toString()),
                          trailing: Text(NumberFormat.simpleCurrency(name: "Ksh ", decimalDigits: 2).format(double.parse(salesQuotationList[index].docTotal))),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            RoundedButton(
              btnText: "Generate Sales Quotation",
              press: (){
                Navigator.pushNamed(context, '/sales_quotation_form');
              }, 
              btnColor: kSecondaryColor, 
              textColor: kPrimaryLightColor
            )
          ],
        ),
      ),
    );
  }
}
