import 'package:flutter/material.dart';
import 'package:showroom_manager/components/rounded_buttons.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_confirm_password_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constant/constants.dart';
import '../../../services/api_service.dart';
import 'backgroud.dart';

class PasswordUpdateScreen extends StatefulWidget {
  final String username;
  final int userId;
  final int otp;
  final String expiresAt;
  final bool verified;
  final String verifiedOtp;
  const PasswordUpdateScreen({super.key, required this.username, required this.userId, required this.otp, required this.expiresAt, required this.verified, required this.verifiedOtp});

  @override
  State<PasswordUpdateScreen> createState() => _PasswordUpdateScreenState();
}

class _PasswordUpdateScreenState extends State<PasswordUpdateScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();

  TextEditingController passwordFieldController = TextEditingController();
  TextEditingController confirmPasswordFieldController = TextEditingController();

  Future<void> processPasswordUpdate() async {
    if(passwordFieldController.text.isEmpty || confirmPasswordFieldController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Password fields cannot be empty");
      return;
    }

    if(passwordFieldController.text != confirmPasswordFieldController.text){
      dynamicMaster.displayError(context, "Error", "Passwords do not match");
      return;
    }

    dynamicMaster.displayLoadingModal(context);

    Map<String, dynamic> queryParameters = {
      "username": widget.username,
      "otp": widget.otp.toString(),
      "password": passwordFieldController.text,
      "confirm_password": confirmPasswordFieldController.text
    };

    var response = await apiService.updatePassword(queryParameters);

    Navigator.pop(context);

    if(response["status"] != "success"){
      dynamicMaster.displayError(context, "Error", response["message"]);
      return;
    }

    dynamicMaster.displaySuccessMessage(context, "Password Updated Successfully");

    // wait 2 second then navigate to login screen
    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
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
                "Update Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              SizedBox(height: size.height * 0.03,),
              RoundedPasswordField(
                onChanged: (value){
                  if(value.isNotEmpty){
                    setState(() {
                      passwordFieldController.text = value;
                    });
                  }else{
                    setState(() {
                      passwordFieldController.text = '';
                    });

                  }
                },
              ),
              RoundedConfirmPasswordField(
                onChanged: (value){
                  if(value.isNotEmpty){
                    setState(() {
                      confirmPasswordFieldController.text = value;
                    });
                  }else{
                    setState(() {
                      confirmPasswordFieldController.text = '';
                    });

                  }
                },
              ),

              SizedBox(height: size.height * 0.03,),

              RoundedButton(
                btnText: "Update Password", 
                press: (){
                  processPasswordUpdate();
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