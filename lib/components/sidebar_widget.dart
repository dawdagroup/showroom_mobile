import 'rounded_buttons.dart';
import '../constant/constants.dart';
import 'package:flutter/material.dart';



class SidebarWidget extends StatefulWidget {
  // Replace these values with your own user profile data
  final String userName;
  final String userEmail;
  final String userToken;
  final String userProfilePicture = 'assets/images/user_profile.png';
  const SidebarWidget({super.key, required this.userName, required this.userEmail, required this.userToken});

  @override
  _SidebarWidgetState createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  bool _isPasswordUpdateVisible = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorText;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }
  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _errorText = _currentPasswordController.text.isEmpty && !_focusNode.hasFocus ? 'Password is required' : null;
    });
  }

  void _togglePasswordUpdate() {
    setState(() {
      _isPasswordUpdateVisible = !_isPasswordUpdateVisible;
    });
  }

  Map<String, dynamic>  _passwordValidator() {
    String currentPassword = _currentPasswordController.text;
    String passwordOne = _newPasswordController.text;
    String passwordTwo = _confirmPasswordController.text;
    Map<String, dynamic> output = {};

    if(currentPassword.isEmpty){
      output["status"] = "failed";
      output["message"] = "Current password should not be blank.";
    }else if(passwordOne.isEmpty){
      output["status"] = "failed";
      output["message"] = "New password should not be blank.";
    }else if(passwordOne.length < 8){
      output["status"] = "failed";
      output["message"] = "New password should be more than 8 characters.";

    }else if(passwordOne != passwordTwo){
      output["status"] = "failed";
      output["message"] = "Password confirmation failed.";
    }else{
      output["status"] = "success";
    }
    return output;
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error:',),
          content: Text(errorMessage, style: const TextStyle(color: Colors.red),),
          actions: <Widget>[
            TextButton(
              child: const Text('Close',),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(widget.userProfilePicture),
                  radius: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: (){
              _togglePasswordUpdate();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const SettingsPage(),
              //   ),
              // );
            },
          ),
          if (_isPasswordUpdateVisible) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        errorText: _errorText,
                      ),
                      obscureText: true,
                      focusNode: _focusNode,
                      onEditingComplete: () {
                        setState(() {
                          _errorText = _currentPasswordController.text.isEmpty ? 'Password is required' : null;
                        });
                      },
                    ),
                    TextField(
                      controller: _newPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    RoundedButton(
                      btnText: 'Update Password',
                      press: () async {
                        var validationResults = _passwordValidator();
                        if(validationResults["status"] == "success"){
                          // var passwordUpdateResults = await ApiService().passwordUpdateRequest(widget.userToken, _currentPasswordController.text, _newPasswordController.text);

                          // if(passwordUpdateResults["status"] == "success"){
                          //   setState(() {
                          //     _currentPasswordController.text = '';
                          //     _newPasswordController.text = '';
                          //     _confirmPasswordController.text = '';
                          //   });
                          //   showDialog(
                          //       context: context,
                          //       builder: (context){
                          //         return AlertDialog(
                          //           content: SizedBox(
                          //             height: 170,
                          //             child: Column(
                          //               children: [
                          //                 SizedBox(
                          //                   height: 130,
                          //                   child: Center(
                          //                     child: Lottie.asset(
                          //                         "assets/animations/success.zip"
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                   passwordUpdateResults["message"],
                          //                 )
                          //               ],
                          //             ),
                          //           ),
                          //           actions: <Widget>[
                          //             TextButton(
                          //               child: const Text('Close',),
                          //               onPressed: () {
                          //                 Navigator.of(context).pop();
                          //               },
                          //             ),
                          //           ],
                          //         );
                          //       }
                          //   );
                          // }else{
                          //   showDialog(
                          //       context: context,
                          //       builder: (context){
                          //         return AlertDialog(
                          //           content: SizedBox(
                          //             height: 200,
                          //             child: Column(
                          //               children: [
                          //                 SizedBox(
                          //                   height: 100,
                          //                   child: Center(
                          //                     child: Lottie.asset(
                          //                     "assets/animations/failed.zip"
                          //                     ),
                          //                   ),
                          //                 ),
                          //                 Text(
                          //                     passwordUpdateResults["message"],
                          //                     style: const TextStyle(color: Colors.red),
                          //                 )
                          //               ],
                          //             ),
                          //           ),
                          //           actions: <Widget>[
                          //             TextButton(
                          //               child: const Text('Close',),
                          //               onPressed: () {
                          //                 Navigator.of(context).pop();
                          //               },
                          //             ),
                          //           ],
                          //         );
                          //       }
                          //   );
                          // }

                        }else{
                          showErrorDialog(context, validationResults["message"]);
                        }
                      }, 
                      btnColor: kSecondaryColor, 
                      textColor: kPrimaryLightColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/auth').then((_) => false);
            },
          ),
        ],
      ),
    );
  }
}
