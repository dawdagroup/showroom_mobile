import 'package:flutter/material.dart';

import '../../../modals/invoice_details_modal.dart';
import 'invoice_delivery_body.dart';

class InvoiceDeliveryScreen extends StatefulWidget {
  final InvoiceDetailsModal invoiceDetailsObj;
  const InvoiceDeliveryScreen({super.key, required this.invoiceDetailsObj});

  @override
  State<InvoiceDeliveryScreen> createState() => _InvoiceDeliveryScreenState();
}

class _InvoiceDeliveryScreenState extends State<InvoiceDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InvoiceDeliveryBody(invoiceDetailsObj: widget.invoiceDetailsObj),
    );
  }
}