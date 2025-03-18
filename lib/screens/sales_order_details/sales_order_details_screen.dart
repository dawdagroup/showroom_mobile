import 'package:flutter/material.dart';

import 'components/sales_order_details_body.dart';

class SalesOrderDetailsScreen extends StatefulWidget {
  final String salesOrderNumber;
  const SalesOrderDetailsScreen({super.key, required this.salesOrderNumber});

  @override
  State<SalesOrderDetailsScreen> createState() => _SalesOrderDetailsScreenState();
}

class _SalesOrderDetailsScreenState extends State<SalesOrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SalesOrderDetailsBody(salesOrderNumber: widget.salesOrderNumber),
    );
  }
}