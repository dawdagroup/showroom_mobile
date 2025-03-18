import '../../../components/dynamic_widgets.dart';
import 'package:flutter/material.dart';

import 'components/home_body_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DynamicMaster dynamicMaster = DynamicMaster();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: dynamicMaster.applicationBar(theme, context),
      body: const HomeBodyScreen(),
    );
  }
}