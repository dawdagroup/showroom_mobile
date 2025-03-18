import 'package:flutter/material.dart';

import 'components/password_reset_body.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PasswordResetBody(),
    );
  }
}