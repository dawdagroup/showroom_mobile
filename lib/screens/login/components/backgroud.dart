import 'package:flutter/material.dart';

class LoginScreenBackground extends StatefulWidget {
  final Widget child;
  const LoginScreenBackground({super.key, required this.child});

  @override
  State<LoginScreenBackground> createState() => _LoginScreenBackgroundState();
}

class _LoginScreenBackgroundState extends State<LoginScreenBackground> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget> [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_top.png",
              width: size.width * 0.3,
              
            )
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "assets/images/main_bottom.png",
              width: size.width * 0.2,
            )
          ),
          widget.child,
        ],
      ),
    );
  }
}