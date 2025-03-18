import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/session_provider.dart';

class BaseScreen extends StatefulWidget {
  final Widget child;
  const BaseScreen({super.key, required this.child});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    // final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    // Check if the user is authenticated

    // var isAuthenticated = sessionProvider.authProvider.isAuthenticated;
        
    // if (!isAuthenticated) {
    //   // Navigate to login if not authenticated
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.pushReplacementNamed(context, "/login");
    //   });
    //   return const SizedBox(); // Return an empty widget while waiting for navigation
    // }

    return widget.child;
  }
}