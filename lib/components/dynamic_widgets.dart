import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../constant/constants.dart';
import '../providers/session_provider.dart';


enum _TopMenuOption { home, settings, logout }

class DynamicMaster {
  
  Future<dynamic> displayError(BuildContext context, String errorHeader, String message) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: SizedBox(
            height: size.height * 0.5,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  // height: 50,
                  child: Lottie.asset(
                      "assets/animations/failed.zip"
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(errorHeader, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: Text(message))
              ],
            ),
          ),
        );
      }
    );
  }

  Future<dynamic> displaySuccessModal(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        return  Center(
          child: Lottie.asset(
              "assets/animations/success.zip"
          ),
        );
      }
    );
  }
  
  Future<dynamic> displayLoadingModal(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: SizedBox(
            height: 200,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                      "assets/animations/loading_v2.zip"
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Please wait...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ],
            ),
          ),
        );
      }
    );
  }

  badges.Badge showBadge(String status, Color badgeColor) {
    return badges.Badge(
      badgeContent: Text(
        status,
      ),
      badgeStyle: badges.BadgeStyle(
          badgeColor: badgeColor,
          shape: badges.BadgeShape.square,
          borderRadius: const BorderRadius.all(
              Radius.circular(20)
          )
      ),
    );
  }

  Future<dynamic> displaySuccessMessage(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: SizedBox(
            height: 200,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                      "assets/animations/success.zip"
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Success", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                const SizedBox(
                  height: 10,
                ),
                Text(message)
              ],
            ),
          ),
        );
      }
    );
  }
  
  Future<dynamic> displayLoadingModalWithMessage(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: SizedBox(
            height: 200,
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Lottie.asset(
                      "assets/animations/loading_v2.zip"
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Please wait...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
              ],
            ),
          ),
        );
      }
    );
  }

  
  AppBar applicationBarBk(ThemeData theme, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    Future<bool> goToLogin(BuildContext context) {

      Provider.of<SessionProvider>(context, listen: false).authProvider.logout();

      return Navigator.of(context).pushReplacementNamed('/login').then((_) => false);
    }
    
    final menuBtn = IconButton(
      color: theme.colorScheme.primary,
      icon: const Icon(FontAwesomeIcons.bars),
      onPressed: () => scaffoldKey.currentState!.openDrawer(),
    );
    // final menuBtn = IconButton(
    //   color: theme.colorScheme.primary,
    //   icon: const Icon(FontAwesomeIcons.bars),
    //   onPressed: () {
    //     scaffoldKey.currentState!.openDrawer();
    //     // Scaffold.of(context).openDrawer();
    //   },
    // );
    final signOutBtn = IconButton(
      icon: const Icon(FontAwesomeIcons.rightFromBracket),
      color: theme.colorScheme.primary,
      onPressed: () => goToLogin(context),
    );
    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Hero(
              tag: Constants.logoTag,
              child: Image.asset(
                'assets/images/azone.png',
                filterQuality: FilterQuality.high,
                height: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );

    return AppBar(
      leading: menuBtn,
      actions: <Widget>[
        signOutBtn,
      ],
      title: title,
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  AppBar applicationBar(ThemeData theme, BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {

    Future<bool> goToLogin(BuildContext context) {

      Provider.of<SessionProvider>(context, listen: false).authProvider.logout();

      return Navigator.of(context).pushReplacementNamed('/login').then((_) => false);
    }

    final title = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Hero(
              tag: Constants.logoTag,
              child: Image.asset(
                'assets/images/azone.png',
                filterQuality: FilterQuality.high,
                height: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );

    final signOutBtn = IconButton(
      icon: const Icon(FontAwesomeIcons.rightFromBracket),
      color: theme.colorScheme.primary,
      onPressed: () => goToLogin(context),
    );
    
    return AppBar(
      leading: PopupMenuButton<_TopMenuOption>(
        icon: Icon(FontAwesomeIcons.bars, color: theme.colorScheme.primary),
        onSelected: (opt) {
          switch (opt) {
            case _TopMenuOption.home:
              Navigator.pushNamed(context, '/home');
              break;
            case _TopMenuOption.settings:
              Navigator.pushNamed(context, '/settings');
              break;
            case _TopMenuOption.logout:
              Provider.of<SessionProvider>(context, listen: false)
                  .authProvider
                  .logout();
              Navigator.pushReplacementNamed(context, '/login');
              break;
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: _TopMenuOption.home,
            child: Text('Home'),
          ),
          const PopupMenuItem(
            value: _TopMenuOption.settings,
            child: Text('Settings'),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: _TopMenuOption.logout,
            child: Text('Sign Out'),
          ),
        ],
      ),
      title: title,
      actions: [ signOutBtn],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget buildSideBar(BuildContext context,) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text("Menu")),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.pushNamed(context, '/home'),
          ),
          // … more items …
        ],
      ),
    );
  }


}