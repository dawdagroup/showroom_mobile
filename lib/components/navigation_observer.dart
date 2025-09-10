import 'package:flutter/material.dart';

/// A global observer that you can import wherever you need it.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// add observer for stock count details
final RouteObserver<ModalRoute<void>> stockCountDetailsObserver = RouteObserver<ModalRoute<void>>();