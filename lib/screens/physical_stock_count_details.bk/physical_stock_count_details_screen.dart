import 'package:flutter/material.dart';

import 'components/physical_stock_count_details_body.dart';

class PhysicalStockCountDetailsScreen extends StatefulWidget {
  final String physicalStockCountId;
  const PhysicalStockCountDetailsScreen({super.key, required this.physicalStockCountId});

  @override
  State<PhysicalStockCountDetailsScreen> createState() => _PhysicalStockCountDetailsScreenState();
}

class _PhysicalStockCountDetailsScreenState extends State<PhysicalStockCountDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhysicalStockCountDetailsBody(
        physicalStockCountId: widget.physicalStockCountId,
      ),
    );
  }
}