import 'package:flutter/material.dart';
import '../../config/config.dart';
import 'components/loyalty_program_body.dart';
import '../../components/dynamic_widgets.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({super.key});

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: dynamicMaster.applicationBar(Theme.of(context), context, _scaffoldKey),
      body:  Config.releaseRegion == "KENYA" ? const LoyaltyProgramBody() : const SizedBox(
        child: Column(
          children: [
            Center(
              child: Text('Loyalty Program is not available in your region.', style: TextStyle(color: Colors.red),),
            )
          ],
        ),
      )
    );
  }
}