import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';
import '../../../constant/constants.dart';

import '../../../modals/aftersale_request_modal.dart';
import '../../../components/filter_complaint_params.dart';
import '../../../components/filter_complaint_dialog.dart';


class ComplaintBodyScreen extends StatefulWidget {
  const ComplaintBodyScreen({super.key});

  @override
  State<ComplaintBodyScreen> createState() => _ComplaintBodyScreenState();
}

class _ComplaintBodyScreenState extends State<ComplaintBodyScreen> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  
  List<AftersaleRequestModal> listOfAftersaleRequestModal = [];
  bool isLoading = false;

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
    getAfterSaleRegister(filters: {});
  }

  Future<void> getAfterSaleRegister({required Map<String, dynamic> filters}) async {

    setState(() { isLoading = true; listOfAftersaleRequestModal = []; });

    try {
      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      Map<String, dynamic> response = await apiService.getAfterSaleRegister(token, filters);

      if (response["status"] == "success") {
        for(var item in response["data"]){
          try{
            listOfAftersaleRequestModal.add(aftersaleRequestModalFromJson(jsonEncode(item)));
          }catch(e){
            print(e);
          }
        }
      }else{
        dynamicMaster.displayError(context, "Error", response["message"]);
      }
    } catch (e) {
      dynamicMaster.displayError(context, "Error", e.toString());
    }

    setState(() { isLoading = false; });
  }

  Future<void> showFilterDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FilterComplaintDialog(
          onSubmit: (FilterComplaintParams filterParams) {
            applyFilters(filterParams);
          },
        );
      },
    );
  }
  
  Future<void> applyFilters(FilterComplaintParams filterParams) async {
    Map<String, dynamic> filters = {};
    if (filterParams.consumerName.isNotEmpty) filters["consumerName"] = filterParams.consumerName;
    if (filterParams.consumerPhoneNo.isNotEmpty) filters["consumerPhoneNo"] = filterParams.consumerPhoneNo; 
    if (filterParams.fromDate.isNotEmpty) filters["dateOfComplaintFrom"] = filterParams.fromDate;
    if (filterParams.toDate.isNotEmpty) filters["dateOfComplaintTo"] = filterParams.toDate;
    if (filterParams.complaintNo.isNotEmpty) filters["complaintNo"] = filterParams.complaintNo;

    await getAfterSaleRegister(filters: filters);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02,),
            const Text("Aftersale Register", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),),
            SizedBox(height: size.height * 0.02,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/aftersale_register');
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add),
                      SizedBox(width: size.width * 0.02,),
                      const Text("Add New")
                    ],
                  )
                ),
                ElevatedButton(
                  onPressed: () {showFilterDialog();}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      SizedBox(width: size.width * 0.02,),
                      const Text("Search")
                    ],
                  )
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02,),
            SizedBox(
              height: size.height * 0.78,
              child: isLoading ? const Center(child: CircularProgressIndicator()) :
              listOfAftersaleRequestModal.isEmpty ? const Center(child: Text("No data found")) :
              ListView.builder(
                itemCount: listOfAftersaleRequestModal.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/complaint_details', arguments: listOfAftersaleRequestModal[index].complaintNo);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            offset: const Offset(-10.0, 10.0),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.02, vertical: size.height * 0.01),
                        child: Column(
                          children: [
                            Text("Complaint No: ${listOfAftersaleRequestModal[index].complaintNo}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Text("Complaint No IAL: ${listOfAftersaleRequestModal[index].complaintNoIal}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Text("Date of Complaint: ${DateFormat("dd-MMMM-yyyy").format(listOfAftersaleRequestModal[index].dateOfComplaint)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Text("Consumer Name: ${listOfAftersaleRequestModal[index].consumerName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Text("Consumer Phone No: ${listOfAftersaleRequestModal[index].consumerPhoneNo}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            Text("Consumer Email: ${listOfAftersaleRequestModal[index].consumerEmail}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Status:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),),
                                  dynamicMaster.showBadge(listOfAftersaleRequestModal[index].status == "O" ? "Open" : listOfAftersaleRequestModal[index].status == "L" ? "Cancelled" : "Closed", listOfAftersaleRequestModal[index].status == "O" ? Colors.yellowAccent : listOfAftersaleRequestModal[index].status == "L" ? Colors.red : Colors.green),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            )
          ],
        ),
      ),
    );
  }
}