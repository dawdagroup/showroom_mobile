import 'package:flutter/material.dart';
import 'components/complaint_body_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ComplaintBodyScreen(),
    );
  }
}