import 'components/sales_quotation_details_body.dart';
import 'package:flutter/material.dart';

class SalesQuotationDetailsScreen extends StatefulWidget {
  final String salesQuotationNo;
  const SalesQuotationDetailsScreen({super.key, required this.salesQuotationNo});

  @override
  State<SalesQuotationDetailsScreen> createState() => _SalesQuotationDetailsScreenState();
}

class _SalesQuotationDetailsScreenState extends State<SalesQuotationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SalesQuotationDetailsBody(salesQuotationNo: widget.salesQuotationNo),
    );
  }
}