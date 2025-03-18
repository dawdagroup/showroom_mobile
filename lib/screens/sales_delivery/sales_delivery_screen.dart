import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/sales_delivery_screen_body.dart';

class SalesDeliveryScreen extends StatefulWidget {
  const SalesDeliveryScreen({super.key});

  @override
  State<SalesDeliveryScreen> createState() => _SalesDeliveryScreenState();
}

class _SalesDeliveryScreenState extends State<SalesDeliveryScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const SalesDeliveryScreenBody(),
    );
  }
}