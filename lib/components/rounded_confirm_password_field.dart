import 'package:flutter/material.dart';

import '../constant/constants.dart';
import 'text_field_container.dart';

class RoundedConfirmPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const RoundedConfirmPasswordField({super.key, required this.onChanged});

  @override
  State<RoundedConfirmPasswordField> createState() => _RoundedConfirmPasswordFieldState();
}

class _RoundedConfirmPasswordFieldState extends State<RoundedConfirmPasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: widget.onChanged,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: "Confirm Password",
          icon: Icon(Icons.lock, color: kSecondaryColor),
          suffixIcon: GestureDetector(
            onTap: _togglePasswordVisibility,
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: kSecondaryColor,
            ),
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}