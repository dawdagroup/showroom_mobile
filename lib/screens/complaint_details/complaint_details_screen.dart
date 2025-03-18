import 'package:flutter/material.dart';
import 'components/complaint_details_body.dart';
class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintNo;
  const ComplaintDetailsScreen({super.key, required this.complaintNo});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComplaintDetailsBody(complaintNo: widget.complaintNo),
    );
  }
}
