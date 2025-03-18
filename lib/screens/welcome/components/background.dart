import 'package:flutter/material.dart';

class WelcomeScreenBackground extends StatefulWidget {
  final Widget child;
  const WelcomeScreenBackground({super.key, required this.child});

  @override
  State<WelcomeScreenBackground> createState() => _WelcomeScreenBackgroundState();
}

class _WelcomeScreenBackgroundState extends State<WelcomeScreenBackground> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height,
      width: size.width,
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