import 'package:flutter/material.dart';

import 'components/sales_delivery_details_screen_body.dart';

class SalesDeliveryDetailsScreen extends StatefulWidget {
  final String deliveryNumber;
  const SalesDeliveryDetailsScreen({super.key, required this.deliveryNumber});

  @override
  State<SalesDeliveryDetailsScreen> createState() => _SalesDeliveryDetailsScreenState();
}

class _SalesDeliveryDetailsScreenState extends State<SalesDeliveryDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SalesDeliveryDetailsScreenBody(deliveryNumber: widget.deliveryNumber),
    );
  }
}