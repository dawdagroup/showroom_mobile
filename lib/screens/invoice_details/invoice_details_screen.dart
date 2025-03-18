import 'package:flutter/material.dart';

import 'components/invoice_details_body.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceNumber;
  const InvoiceDetailsScreen({super.key, required this.invoiceNumber});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: InvoiceDetailsBody(invoiceNumber: widget.invoiceNumber)
    );
  }
}