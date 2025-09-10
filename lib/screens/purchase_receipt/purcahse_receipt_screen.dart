import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/purchase_screen_body.dart';

class PurcahseReceiptScreen extends StatefulWidget {
  const PurcahseReceiptScreen({super.key});

  @override
  State<PurcahseReceiptScreen> createState() => _PurcahseReceiptScreenState();
}

class _PurcahseReceiptScreenState extends State<PurcahseReceiptScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(Theme.of(context), context, _scaffoldKey),
      body: const PurchaseScreenBody(),
    );
  }
}