import '../../../components/dynamic_widgets.dart';
import 'package:flutter/material.dart';

import 'components/home_body_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DynamicMaster dynamicMaster = DynamicMaster();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: dynamicMaster.buildSideBar(context),
      appBar: dynamicMaster.applicationBar(theme, context, _scaffoldKey),
      body: const HomeBodyScreen(),
    );
  }
}