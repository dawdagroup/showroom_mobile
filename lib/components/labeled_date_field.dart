import 'package:flutter/material.dart';

import '../constant/constants.dart';
// Reusable Labeled Date Field Widget
class LabeledDateField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final DateTime selectedDate;
  final VoidCallback onDateSelected;
  final String? Function(String?)? validator;

  const LabeledDateField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Text("*", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              readOnly: true,
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                suffixIcon: IconButton(
                  onPressed: onDateSelected,
                  icon: const Icon(Icons.calendar_month_outlined, color: kSecondaryColor),
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}

