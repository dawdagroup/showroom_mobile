import 'dart:convert';

import '../../../components/dynamic_widgets.dart';
import '../../../components/rounded_buttons.dart';
import '../../../components/rounded_input_field.dart';
import '../../../components/rounded_password_field.dart';
import '../../../constant/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../screens/login/components/backgroud.dart';
import '../../../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../db/database_helper.dart';
import '../../../modals/user_modal.dart';
import '../../../providers/user_provider.dart';


class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  TextEditingController _usernameFieldController = TextEditingController();
  TextEditingController _passwordFieldController = TextEditingController();
  DynamicMaster dynamicMaster = DynamicMaster();
  ApiService apiService = ApiService();
  final AuthProvider authProvider = AuthProvider();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String appVersion = "";

  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  Future<void> getAccountDetails(String sessionToken) async{
    var response = await apiService.fetchUserAccountInfo(sessionToken);

    print(response);

    if(response["status"] == "success"){

      // save the data into the showroom details
      await _dbHelper.insertShowroom(response["data"]["showroom"]);

      // save the data into the warehouse details
      await _dbHelper.insertWarehouse(response["data"]["showroom_warehouse"]);

      // save the data into the business partners details
      await _dbHelper.insertBusinessPartners(response["data"]["showroom_business_partners"]);

    }
  }

  Future<void> submitLoginData(String username, String password) async{
    dynamicMaster.displayLoadingModal(context);

    try {
      await authProvider.login(username, password);
      Navigator.pop(context);
      if(await authProvider.isAuthenticated){
        FlutterSecureStorage storage = authProvider.storage;
        final userEmail = await storage.read(key: 'userEmail');
        final userFirstName = await storage.read(key: 'userFirstName');
        final userLastName = await storage.read(key: 'userLastName');
        final userPhoneNumber = await storage.read(key: 'userPhoneNumber');
        final userStatus = await storage.read(key: 'userStatus');
        final userId = await storage.read(key: 'userId');
        
        Map<String, dynamic> sortedUserData = {};

        sortedUserData["email"] = userEmail;
        sortedUserData["username"] = userEmail;
        sortedUserData["first_name"] = userFirstName;
        sortedUserData["middle_name"] = "";
        sortedUserData["last_name"] = userLastName;
        sortedUserData["is_active"] = true;
        sortedUserData["phone_number"] = userPhoneNumber;
        sortedUserData["status"] = userStatus;
        sortedUserData["id"] = int.parse(userId!);

        Provider.of<UserProvider>(context, listen: false).setUser(userModalFromJson(jsonEncode(sortedUserData)));
        Provider.of<SessionProvider>(context, listen: false).setAuthProvider(authProvider);
        Provider.of<SessionProvider>(context, listen: false).setUserProvider(Provider.of<UserProvider>(context, listen: false));

        var token = await authProvider.token;

        if (token != null){
          getAccountDetails(token);
        }

        Navigator.pushReplacementNamed(context, '/home');
      }else{
        dynamicMaster.displayError(context, "Error", "Invalid username or password");
      }
    } catch (e) {
      Navigator.pop(context);
      dynamicMaster.displayError(context, "Error", e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return LoginScreenBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "LOGIN",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: size.height * 0.01,),
          Image.asset(
            "assets/images/azone.png",
            width: size.width * 0.5,
          ),
          SizedBox(height: size.height * 0.03,),
          RoundedInputField(
            hintText: 'Username', 
            icon: Icons.person, 
            onChanged: (value) { 
              if(value.isNotEmpty){
                setState(() {
                  _usernameFieldController.text = value;
                });
              }else{
                setState(() {
                  _usernameFieldController.text = '';
                });
              }
            },
          ),
          RoundedPasswordField(
            onChanged: (value){
              if(value.isNotEmpty){
                setState(() {
                  _passwordFieldController.text = value;
                });
              }else{
                setState(() {
                  _usernameFieldController.text = '';
                });

              }
            },
          ),
          SizedBox(height: size.height * 0.03,),
          RoundedButton(
            btnText: "LOGIN", 
            press: () {
              if(_usernameFieldController.text.isEmpty || _passwordFieldController.text.isEmpty){
                dynamicMaster.displayError(context, "Error", "Please fill in all fields");
                return;
              }
              submitLoginData(_usernameFieldController.text, _passwordFieldController.text);
            }, 
            btnColor: kPrimaryColor, 
            textColor: Colors.white
          ),
          SizedBox(height: size.height * 0.03,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Forgot Your Password ? ", style: TextStyle(color: kSecondaryColor),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, '/reset-password');
                },
                child: const Text(
                  "Reset Password",
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