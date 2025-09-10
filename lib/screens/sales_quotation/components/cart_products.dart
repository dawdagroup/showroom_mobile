import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';
import '../../../modals/product_modal.dart';
import 'cart_product_card.dart';

class CardProducts extends StatefulWidget {
  final CartController controller = Get.find();
  
  CardProducts({super.key});

  @override
  State<CardProducts> createState() => _CardProductsState();
}

class _CardProductsState extends State<CardProducts> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(() => 
      SizedBox(
        height: size.height * 0.655,
        child: ListView.builder(
          itemCount: widget.controller.products.length,
          itemBuilder: (context, index) {
            ProductModal productModal = widget.controller.products.keys.toList()[index];

            return CartProductCard(product: productModal,);
          },
        ),
      )
    );
  }
}