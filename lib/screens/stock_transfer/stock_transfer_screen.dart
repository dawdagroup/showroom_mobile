import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/stock_transfer_screen_body.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const StockTransferScreenBody(),
    );
  }
}