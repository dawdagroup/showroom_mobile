import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../components/rounded_input_field.dart';
import '../../../constant/constants.dart';
import '../../../services/api_service.dart';
import 'backgroud.dart';

class PasswordResetBody extends StatefulWidget {
  const PasswordResetBody({super.key});

  @override
  State<PasswordResetBody> createState() => _PasswordResetBodyState();
}

class _PasswordResetBodyState extends State<PasswordResetBody> {
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();

  String appVersion = '';

  TextEditingController usernameFieldController = TextEditingController();
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkForUpdate();
  }
  
  Future<void> checkForUpdate() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  Future<void> sendResetLink() async {
    if(usernameFieldController.text.isEmpty){
      dynamicMaster.displayError(context, "Error", "Please enter your username");
      return;
    }
    dynamicMaster.displayLoadingModal(context);

    Map<String, dynamic> queryParameters = {
      "username": usernameFieldController.text
    };
    var response = await apiService.generatePasswordResetOtp(queryParameters);

    Navigator.pop(context);

    if(response["status"] == "success"){
      dynamicMaster.displaySuccessModal(context);

      // wait 2 second then navigate to password update screen
      await Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacementNamed('/password-otp-verification', arguments: {
          "username": usernameFieldController.text, "userId": response["data"][0]["user_id"], "otp": response["data"][0]["otp"], "expires_at": response["data"][0]["expires_at"]
        });
      });
    }else{
      dynamicMaster.displayError(context, "Error", response["message"]);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PasswordResetScreenBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "FORGOT PASSWORD",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: size.height * 0.03,),
          Image.asset(
            "assets/images/azone.png",
            width: size.width * 0.5,
          ),
          SizedBox(height: size.height * 0.015,),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text("Enter your username and instructions will be sent to you!")
          ),
          SizedBox(height: size.height * 0.015,),
          RoundedInputField(
            hintText: 'Username', 
            icon: Icons.person, 
            onChanged: (value) { 
              if(value.isNotEmpty){
                setState(() {
                  usernameFieldController.text = value;
                });
              }else{
                setState(() {
                  usernameFieldController.text = '';
                });
              }
            },
          ),
          SizedBox(height: size.height * 0.03,),
          RoundedButton(
            btnText: "Send Reset Link", 
            press: (){
              sendResetLink();
            }, 
            btnColor: kPrimaryColor, 
            textColor: kPrimaryLightColor
          ),
          SizedBox(height: size.height * 0.03,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Wait, I remember my password... ", style: TextStyle(color: kSecondaryColor),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text(
                  "Click here",
                  style: TextStyle(
                    color: kSecondaryColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: size.height * 0.03,),
          Text("Version: $appVersion")
          
        ],
      ),
    );
  }
}