import 'package:flutter/material.dart';


class RoundedPillButton extends StatelessWidget {
  final void Function() onPressed;
  final String buttonText;
  final Color buttonColor;
  final Icon btnIcon;
  final TextStyle btnStyle;
  const RoundedPillButton({
    Key? key, required this.onPressed, required this.buttonText, required this.buttonColor, required this.btnIcon, required this.btnStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      color: buttonColor,
      splashColor: Colors.white.withAlpha(100),
      highlightColor: buttonColor,
      onPressed: onPressed,
      child: Row(
        children: [
          btnIcon,
          Text(
            buttonText,
            style: btnStyle,
          ),
        ],
      ),
    );
  }
}