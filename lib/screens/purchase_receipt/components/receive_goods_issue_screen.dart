import 'package:flutter/material.dart';

import '../../../modals/goods_issue_details_modal.dart';
import 'receive_goods_issue_body.dart';

class ReceiveGoodsIssueScreen extends StatefulWidget {
  final GoodsIssueDetailsModal goodsIssueDetailsObj;
  const ReceiveGoodsIssueScreen({super.key, required this.goodsIssueDetailsObj});

  @override
  State<ReceiveGoodsIssueScreen> createState() => _ReceiveGoodsIssueScreenState();
}

class _ReceiveGoodsIssueScreenState extends State<ReceiveGoodsIssueScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReceiveGoodsIssueBody(goodsIssueDetailsObj: widget.goodsIssueDetailsObj),
    );
  }
}