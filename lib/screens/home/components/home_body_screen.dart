import 'dart:convert';

import '../../../components/dynamic_widgets.dart';
import '../../../components/navigation_observer.dart';
import '../../../db/database_helper.dart';
import '../../../modals/showroom_sales_summary_modal.dart';
import '../../../providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../components/dashboard_buttons.dart';
import '../../../components/statistic_card.dart';
import '../../../services/api_service.dart';

class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});

  @override
  State<HomeBodyScreen> createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends State<HomeBodyScreen> with RouteAware {
  ApiService apiService = ApiService();
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _Pagecontroller = PageController();
  bool isLoading = false;
  ShowroomSalesSummaryModal? showroomSalesSummary;

  @override
  void initState() {
    super.initState();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    fetchShowroomSalesSummary();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe this State object to be notified
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // don't forget to unsubscribe!
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when you come back to this screen (e.g. you popped off another route)
    fetchShowroomSalesSummary();
  }


  Future<void> fetchShowroomSalesSummary() async {
    setState(() { isLoading = true; showroomSalesSummary = null; });
    try {

      var token = await sessionProvider.authProvider.token;

      // Ensure token is not null
      if (token == null) {
        dynamicMaster.displayError(context, "Error", "No valid session token.");
        setState(() { isLoading = false; });
        // logout user or redirect to login
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        return;
      }

      var showroomDetails = await _dbHelper.getShowroom();

      if (showroomDetails == null) {
        dynamicMaster.displayError(context, "Error", "No showroom details found.");
        setState(() { isLoading = false; });
        // logout user or redirect to login
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
        return;
      }

      var response = await apiService.getSalesSummary(token, showroomDetails.showroom_id.toString());

      if (response["status"] == "success") {
        showroomSalesSummary = showroomSalesSummaryModalFromJson(jsonEncode(response["data"][0]));
        setState(() { isLoading = false; });
      } else {
        // dynamicMaster.displayError(context, "Error", response["message"]);
        print("Error fetching showroom sales summary: ${response["message"]}");
        setState(() { isLoading = false; });
      }

    } catch (e) {
      setState(() { isLoading = false; });
      // Handle error
      print("Error fetching showroom sales summary: $e");
    }
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Logged in as : ${sessionProvider.user?.fullName.toUpperCase() ?? 'User'}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            SizedBox(height: size.height * 0.01),
            SizedBox(
              height: size.height * 0.21,
              child: PageView(
                controller: _Pagecontroller,
                children: [
                  Statistics(
                    statsIcon: Icons.arrow_forward,
                    cardName: "My Sales Today",
                    balance: showroomSalesSummary?.salesAgentsSalesToday ?? 0.0,
                    color: Colors.indigo,
                    isLoading: isLoading,
                  ),
                  Statistics(
                    statsIcon: Icons.arrow_forward,
                    cardName: "Showroom Sales Today",
                    balance: showroomSalesSummary?.showroomSalesToday ?? 0.0,
                    color: Colors.deepPurple,
                    isLoading: isLoading,
                  ),
                  Statistics(
                    statsIcon: Icons.arrow_forward,
                    cardName: "Showroom Current Month Sales To date",
                    balance: showroomSalesSummary?.showroomSalesToDate ?? 0.0,
                    color: Colors.green,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.01),
            SmoothPageIndicator(
              controller: _Pagecontroller,
              count: 3,
              effect: const ExpandingDotsEffect(),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBtns(iconImagePath: "assets/icons/invoice.png", buttonText: "Sales Quotation", pageRoute: "/sales_quotation"),
                  DashboardBtns(iconImagePath: "assets/icons/receipt.png", buttonText: "Sales Invoices", pageRoute: "/sales_invoices"),
                  DashboardBtns(iconImagePath: "assets/icons/completed-task.png", buttonText: "Sales Order", pageRoute: "/sales_order"),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBtns(iconImagePath: "assets/icons/fast-delivery.png", buttonText: "Sales Deliveries", pageRoute: "/sales_deliveries"),
                  DashboardBtns(iconImagePath: "assets/icons/checklist.png", buttonText: "Receive Goods", pageRoute: "/receive_goods"),
                  DashboardBtns(iconImagePath: "assets/icons/return.png", buttonText: "Sales Returns", pageRoute: "/sales_returns"),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBtns(iconImagePath: "assets/icons/bill.png", buttonText: "Stock Transfer", pageRoute: "/stock_transfer"),
                  DashboardBtns(iconImagePath: "assets/icons/count.png", buttonText: "Stock Count", pageRoute: "/physical_stock_count"),
                  DashboardBtns(iconImagePath: "assets/icons/complain.png", buttonText: "Complaints", pageRoute: "/complaints"),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardBtns(iconImagePath: "assets/icons/loyalty-program.png", buttonText: "Loyalty Program", pageRoute: "/loyalty_program"),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }
}