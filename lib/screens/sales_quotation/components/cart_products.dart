import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/cart_controller.dart';

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
            return ListTile(
              title: Text(widget.controller.products.keys.elementAt(index).itemName),
              subtitle: Text('Quantity: ${widget.controller.products.values.elementAt(index)}'),
              trailing: IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  widget.controller.removeProduct(widget.controller.products.keys.elementAt(index));
                },
              ),
            );
          },
        ),
      )
    );
  }
}