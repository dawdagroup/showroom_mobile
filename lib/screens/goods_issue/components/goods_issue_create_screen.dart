import 'package:flutter/material.dart';

import '../../../components/dynamic_widgets.dart';
import 'goods_issue_create_body.dart';

class GoodsIssueCreateScreen extends StatefulWidget {
  final String transferNumber;
  const GoodsIssueCreateScreen({super.key, required this.transferNumber});

  @override
  State<GoodsIssueCreateScreen> createState() => _GoodsIssueCreateScreenState();
}

class _GoodsIssueCreateScreenState extends State<GoodsIssueCreateScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: GoodsIssueCreateBody(transferNumber: widget.transferNumber),
    );
  }
}