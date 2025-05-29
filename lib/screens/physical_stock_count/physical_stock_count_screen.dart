import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/physical_stock_count_body.dart';

class PhysicalStockCountScreen extends StatefulWidget {
  const PhysicalStockCountScreen({super.key});

  @override
  State<PhysicalStockCountScreen> createState() => _PhysicalStockCountScreenState();
}

class _PhysicalStockCountScreenState extends State<PhysicalStockCountScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: dynamicMaster.applicationBar(theme, context),
      body: const PhysicalStockCountBody(),
    );
  }
}