import '../components/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'components/navigation_observer.dart';
import 'config/config.dart';
import 'db/database_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/session_provider.dart';
import 'providers/user_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initializeDB();

  // initialize sentry only in production
  if (Config.environment == 'production') {
    await _initializeSentry();
  }
  runApp(const MyApp());
}

Future<void> _initializeSentry() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = Config.sentryDsn;
      options.environment = Config.environment;
      options.tracesSampleRate = 1.0; // Adjust the sample rate as needed
      options.experimental.replay.sessionSampleRate = 1.0;
      options.experimental.replay.onErrorSampleRate = 1.0;
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SessionProvider>(
          create: (context) => SessionProvider(
            authProvider: Provider.of<AuthProvider>(context, listen: false),
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, auth, session) => session!..authProvider = auth,
        ),
      ],
      child: Consumer<SessionProvider>(
        builder: (context, session, _) {
          session.startIdleCheck(context);
          return FutureBuilder<bool>(
            future: session.authProvider.isAuthenticated,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return MaterialApp(
                  title: 'Azone Showroom App',
                  theme: ThemeData(primarySwatch: Colors.blue,),
                  initialRoute: snapshot.data == true ? '/home' : '/login',
                  navigatorObservers: [ routeObserver, stockCountDetailsObserver ],    // ← register it here
                  onGenerateRoute: RouteGenerator.generateRoute,
                );
              }
            },
          );
        },
      ),
    );
  }
}

