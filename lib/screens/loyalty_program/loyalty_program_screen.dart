import 'package:flutter/material.dart';
import 'components/loyalty_program_body.dart';
import '../../components/dynamic_widgets.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: dynamicMaster.applicationBar(Theme.of(context), context),
      body: const LoyaltyProgramBody()
    );
  }
}