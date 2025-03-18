import '../../../components/dynamic_widgets.dart';
import '../../../providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../components/dashboard_buttons.dart';
import '../../../components/statistic_card.dart';

class HomeBodyScreen extends StatefulWidget {
  const HomeBodyScreen({super.key});

  @override
  State<HomeBodyScreen> createState() => _HomeBodyScreenState();
}

class _HomeBodyScreenState extends State<HomeBodyScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  late SessionProvider sessionProvider;
  final _Pagecontroller = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
                    balance: double.parse("1000"),
                    color: Colors.indigo,
                  ),
                  Statistics(
                    statsIcon: Icons.arrow_forward,
                    cardName: "Showroom Sales Today",
                    balance: double.parse("1000"),
                    color: Colors.deepPurple,
                  ),
                  Statistics(
                    statsIcon: Icons.arrow_forward,
                    cardName: "Showroom Current Month Sales To date",
                    balance: double.parse("1000"),
                    color: Colors.green,
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