import 'package:flutter/material.dart';

import '../../../modals/sales_order_details_modal.dart';
import 'sales_order_delivery_body.dart';

class SalesOrderDeliveryScreen extends StatefulWidget {
  final SalesOrderDetailsModal salesOrderDetailsObj;
  const SalesOrderDeliveryScreen({super.key, required this.salesOrderDetailsObj});

  @override
  State<SalesOrderDeliveryScreen> createState() => _SalesOrderDeliveryScreenState();
}

class _SalesOrderDeliveryScreenState extends State<SalesOrderDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SalesOrderDeliveryBody(salesOrderDetailsObj: widget.salesOrderDetailsObj),
    );
  }
}