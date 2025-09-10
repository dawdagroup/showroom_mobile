import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/filter_params.dart';
import '../../../components/rounded_buttons.dart';
import '../../../config/config.dart';
import '../../../constant/constants.dart';
import '../../../modals/invoice_modal.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import 'invoice_filter_dialog.dart';

class InvoiceScreenBody extends StatefulWidget {
  const InvoiceScreenBody({super.key});

  @override
  State<InvoiceScreenBody> createState() => _InvoiceScreenBodyState();
}

class _InvoiceScreenBodyState extends State<InvoiceScreenBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  bool isLoading = false;

  List<InvoiceModal> invoiceList = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    fetchInvoices(filters: {}); // Initiate API call once
  }

  Future<void> fetchInvoices({required Map<String, dynamic> filters}) async {
    setState(() { isLoading = true; invoiceList = [];});
    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      var response = await  apiService.filterInvoices(filters, token);
      if (response["status"] == "success") {
        for (var data in response["data"]) {
          InvoiceModal salesQuotation = invoiceModalFromJson(jsonEncode(data));
          invoiceList.add(salesQuotation);
        }
      } else {
        dynamicMaster.displayError(context, "Error", response["message"] ?? "Error occurred while fetching sales invoices.");
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", "Error occurred while fetching sales invoices.");
    }
    setState(() { isLoading = false; });
  }
  
  Future<void> showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return InvoiceFilterDialog(
          onSubmit: (FilterInvoiceParams filterParams) {
            applyFilters(filterParams);
          },
        );
      },
    );
  }
  
  Future<void> applyFilters(FilterInvoiceParams filterParams) async {
    Map<String, dynamic> filters = {};
    if (filterParams.customerName.isNotEmpty) filters["customerName"] = filterParams.customerName;
    if (filterParams.phoneNumber.isNotEmpty) filters["customerPhoneNo"] = filterParams.phoneNumber;
    if (filterParams.fromDate.isNotEmpty) filters["invoiceFromDate"] = filterParams.fromDate;
    if (filterParams.toDate.isNotEmpty) filters["invoiceToDate"] = filterParams.toDate;
    if (filterParams.invoiceNumber.isNotEmpty) filters["invoiceNumber"] = filterParams.invoiceNumber;

    await fetchInvoices(filters: filters);
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
            SizedBox(
              width: size.width * 0.8,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("List of Invoices",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              )
            ),
            SizedBox(height: size.height * 0.01),
            SizedBox(
              height: size.height * 0.7,
              child: isLoading ?
              const Center(child: CircularProgressIndicator()) :
              invoiceList.isEmpty ?
              const Center(child: Text("No invoices found.")) :
              ListView.builder(
                itemCount: invoiceList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/invoice_details', arguments: invoiceList[index].invoiceNumber.toString());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text("Invoice Date: ", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                                  Text(DateFormat("d-MM-y").format(DateTime.parse(invoiceList[index].invoiceDate.toString())), style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Invoice Number: ", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                                  Text(invoiceList[index].invoiceNumber.toString(), style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Customer Name: ", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                                  Text(invoiceList[index].customerName, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Phone Number: ", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                                  Text(invoiceList[index].customerPhoneNo, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text("Amount: ", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),),
                                  Text(NumberFormat.simpleCurrency(name: "${Config.defaultCurrency} ", decimalDigits: 2).format(double.parse(invoiceList[index].invoiceTotal.toString())), style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ),
                    ),
                  );
                },
              )
            ),
            RoundedButton(
              btnText: "Filter Invoices",
              press: (){
                showFilterDialog();
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