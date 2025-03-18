import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/sales_quotation_screen_body.dart';

class SalesQuotationScreen extends StatefulWidget {
  const SalesQuotationScreen({super.key});

  @override
  State<SalesQuotationScreen> createState() => _SalesQuotationScreenState();
}

class _SalesQuotationScreenState extends State<SalesQuotationScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const SalesQuotationScreenBody(),
    );
  }
}