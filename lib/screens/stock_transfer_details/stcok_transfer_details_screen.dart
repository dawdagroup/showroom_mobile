import 'package:flutter/material.dart';

import 'components/stock_transfer_details_body.dart';

class StcokTransferDetailsScreen extends StatefulWidget {
  final String strockTransferNumber;
  const StcokTransferDetailsScreen({super.key, required this.strockTransferNumber});

  @override
  State<StcokTransferDetailsScreen> createState() => _StcokTransferDetailsScreenState();
}

class _StcokTransferDetailsScreenState extends State<StcokTransferDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StockTransferDetailsBody(stockTransferNumber: widget.strockTransferNumber,),
    );
  }
}