import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../constant/constants.dart';
import '../../../services/api_service.dart';
import 'backgroud.dart';

class PasswordOtpVerificationScreen extends StatefulWidget {
  final String username;
  final int userId;
  final int otp;
  final String expiresAt;
  const PasswordOtpVerificationScreen({super.key, required this.username, required this.userId, required this.otp, required this.expiresAt});

  @override
  State<PasswordOtpVerificationScreen> createState() => _PasswordOtpVerificationScreenState();
}

class _PasswordOtpVerificationScreenState extends State<PasswordOtpVerificationScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();

  TextEditingController otpController = TextEditingController();

  Future<void> processOtpVerification() async {
    if(int.parse(otpController.text) != widget.otp){
      dynamicMaster.displayError(context, "Error", "Invalid OTP");
      return;
    }

    dynamicMaster.displaySuccessMessage(context, "OTP Verified. You are being redirected to reset your password"); 

    // wait 2 second then navigate to password update screen
    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/password_update', arguments: {
        "username": widget.username, "userId": widget.userId, "otp": widget.otp, "expires_at": widget.expiresAt, "verified": true, "verified_otp": otpController.text
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: PasswordResetScreenBackground(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter OTP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              SizedBox(height: size.height * 0.03,),
              Image.asset(
                "assets/images/azone.png",
                width: size.width * 0.5,
              ),
              SizedBox(height: size.height * 0.015,),
              const Text("Enter the OTP sent to your phone number"),
              SizedBox(height: size.height * 0.015,),
              OtpTextField(
                mainAxisAlignment: MainAxisAlignment.center,
                numberOfFields: 4,
                fillColor: Colors.black.withOpacity(0.1),
                showFieldAsBox: true,
                filled: true,
                onSubmit: (code){
                  otpController.text = code;
                }
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedButton(
                btnText: "Verify OTP", 
                press: (){
                  processOtpVerification();
                }, 
                btnColor: kSecondaryColor, 
                textColor: kPrimaryLightColor
              ),
            ],
          ),
        ),
      ),
    );
  }
}