import 'package:flutter/material.dart';

import 'components/product_details_body.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String barcode;
  const ProductDetailsScreen({super.key, required this.barcode});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProductDetailsBody(barcode: widget.barcode),
    );
  }
}