import 'package:flutter/material.dart';
import '../../../modals/stock_transfer_details_modal.dart';
import 'goods_issue_create_product_body.dart';

class GoodsIssueCreateProductScreen extends StatefulWidget {
  final StockTransferProduct product;
  const GoodsIssueCreateProductScreen({super.key, required this.product});

  @override
  State<GoodsIssueCreateProductScreen> createState() => _GoodsIssueCreateProductScreenState();
}

class _GoodsIssueCreateProductScreenState extends State<GoodsIssueCreateProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoodsIssueCreateProductBody(product: widget.product),
    );
  }
}