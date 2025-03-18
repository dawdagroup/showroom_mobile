import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import 'background.dart';
import 'package:flutter/material.dart';


class WelcomeScreenBody extends StatefulWidget {
  const WelcomeScreenBody({super.key});

  @override
  State<WelcomeScreenBody> createState() => _WelcomeScreenBodyState();
}

class _WelcomeScreenBodyState extends State<WelcomeScreenBody> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WelcomeScreenBackground(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "WELCOME TO AZONE SHOWROOM!", 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03,),
            // SvgPicture.asset(
            //   "assets/icons/chat.svg",
            //   height: size.height * 0.45,
            // ),
            Image.asset(
              "assets/images/azone.png",
              height: size.height * 0.3,
              width: size.width * 0.5,
              
            ),
            SizedBox(height: size.height * 0.1,),
            RoundedButton(
              btnColor: kPrimaryColor, 
              btnText: 'LOGIN',
              press: () {
                Navigator.of(context).pushNamed('/login');
              },
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}