import 'package:flutter/material.dart';

import '../../components/dynamic_widgets.dart';
import 'components/invoice_screen_body.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(Theme.of(context), context, _scaffoldKey),
      body: const InvoiceScreenBody(),
    );
  }
}