import 'package:flutter/material.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import 'goods_issue_create_product_body.dart';

class GoodsIssueCreateProductScreen extends StatefulWidget {
  final StockTransferProduct product;
  final String transferNumber;
  const GoodsIssueCreateProductScreen({super.key, required this.product, required this.transferNumber});

  @override
  State<GoodsIssueCreateProductScreen> createState() => _GoodsIssueCreateProductScreenState();
}

class _GoodsIssueCreateProductScreenState extends State<GoodsIssueCreateProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoodsIssueCreateProductBody(
        product: widget.product,
        transferNumber: widget.transferNumber,
      ),
    );
  }
}