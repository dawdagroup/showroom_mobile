import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/sales_delivery_screen_body.dart';

class SalesDeliveryScreen extends StatefulWidget {
  const SalesDeliveryScreen({super.key});

  @override
  State<SalesDeliveryScreen> createState() => _SalesDeliveryScreenState();
}

class _SalesDeliveryScreenState extends State<SalesDeliveryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(Theme.of(context), context, _scaffoldKey),
      body: const SalesDeliveryScreenBody(),
    );
  }
}