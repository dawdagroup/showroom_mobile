import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/purchase_screen_body.dart';

class PurcahseReceiptScreen extends StatefulWidget {
  const PurcahseReceiptScreen({super.key});

  @override
  State<PurcahseReceiptScreen> createState() => _PurcahseReceiptScreenState();
}

class _PurcahseReceiptScreenState extends State<PurcahseReceiptScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const PurchaseScreenBody(),
    );
  }
}