import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../db/database_helper.dart';
import '../../../providers/session_provider.dart';
import '../../../services/api_service.dart';

class PhysicalStockCountBody extends StatefulWidget {
  const PhysicalStockCountBody({super.key});

  @override
  State<PhysicalStockCountBody> createState() => _PhysicalStockCountBodyState();
}

class _PhysicalStockCountBodyState extends State<PhysicalStockCountBody> {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool isLoading = true;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  Future<void> _getPhysicalStockCount() async {
    setState(() { isLoading = true;});
    try{

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        return;
      }

      // var response = await  apiService.filterSalesQuotations(filters, token);

      // if (response["status"] == "success") {
      //   // for (var data in response["data"]) {
      //   //   SalesQuotationModal salesQuotation = salesQuotationModalFromJson(jsonEncode(data));
      //   //   salesQuotationList.add(salesQuotation);
      //   // }
      // } else {
      //   dynamicMaster.displayError(context, "Error", response["message"]);
      // }

    } catch(e){
      dynamicMaster.displayError(context, "Error", e.toString());
    }
    setState(() { isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: size.width,
      child: Column(
        children: [
          const Text('Physical Stock Count', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,),),
          SizedBox(height: size.height * 0.01,),
          SizedBox(
            height: size.height * 0.8,
            width: size.width,
            child: RefreshIndicator(
              onRefresh: _getPhysicalStockCount,
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(

                )
            ),
          ),
        ],
      ),
    );
  }
}