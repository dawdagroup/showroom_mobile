import 'package:flutter/material.dart';
import '../../components/dynamic_widgets.dart';
import 'components/customer_details_body.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: CustomerDetailsBody(customerId: widget.customerId,)
    );
  }
}

