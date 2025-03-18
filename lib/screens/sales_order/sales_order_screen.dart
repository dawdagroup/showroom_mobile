import 'package:flutter/material.dart';
import 'components/sales_order_screen_body.dart';
import '../../../components/dynamic_widgets.dart';

class SalesOrderScreen extends StatefulWidget {
  const SalesOrderScreen({super.key});

  @override
  State<SalesOrderScreen> createState() => _SalesOrderScreenState();
}

class _SalesOrderScreenState extends State<SalesOrderScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const SalesOrderScreenBody()
    );
  }
}


