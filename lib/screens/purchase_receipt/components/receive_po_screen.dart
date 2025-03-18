import 'package:flutter/material.dart';

import '../../../modals/purchase_order_details_modal.dart';
import 'receive_po_body.dart';

class ReceivePoScreen extends StatefulWidget {
  final PurchaseOrderDetailsModal purchaseOrderDetailsObj;
  const ReceivePoScreen({super.key, required this.purchaseOrderDetailsObj});

  @override
  State<ReceivePoScreen> createState() => _ReceivePoScreenState();
}

class _ReceivePoScreenState extends State<ReceivePoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReceivePoBody(purchaseOrderDetailsObj: widget.purchaseOrderDetailsObj),
    );
  }
}