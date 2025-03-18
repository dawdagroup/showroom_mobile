
import 'text_field_container.dart';
import '../constant/constants.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key? key, required this.hintText, required this.icon, required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(icon, color: kSecondaryColor,),
          hintText: hintText,
          border: InputBorder.none
        ),
        onChanged: onChanged,
      ),
    );
  }
}