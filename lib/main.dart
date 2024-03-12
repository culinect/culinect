import 'dart:async';
import 'package:culinect/user/UserProfile_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:culinect/auth/auth_gate.dart';
import 'package:culinect/app.dart'; // Update import statement for app.dart
import 'package:culinect/theme/theme.dart'; // Import your theme file
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:culinect/user/users.dart';

//import 'package:url_strategy/url_strategy.dart';
import 'deep_linking.dart' as deep_linking; // Import your deep_linking.dart file
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'deep_linking/branch_service.dart';
import 'package:universal_io/io.dart';

import 'home.dart';
// Import your branch_service.dart file


// Declare the navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy(); // Add this line to enable clean URL paths
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  // Initialize Firebase Authentication persistence
  //await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  // Check if the user is already authenticated
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  await FlutterBranchSdk.init(
    useTestKey: false,
    enableLogging: true,
    disableTracking: false,
  );

  // Initialize Branch SDK session to handle initial deep link when the app starts
  BranchService().initSession().listen((data) {
    if (data.containsKey('+clicked_branch_link') &&
        data['+clicked_branch_link'] == true) {
      // Handle the deep link data
      deep_linking.handleLink(data['~referring_link']);
      print('DeepLink Data: $data');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use the navigatorKey in your MaterialApp
      navigatorKey: navigatorKey,
      title: 'CuliNect',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: user != null ? '/splash' :  '/', // Navigate to HomeScreen if user is authenticated, otherwise show SignInScreen

      // Define your routes here
      routes: {
        '/splash' : (context) => const SplashScreen(),
        '/': (context) => const AuthGate(),
        '/users': (context) => UsersScreen(),

        // Add more static routes as needed
      },

      // Handle dynamic routes
      onGenerateRoute: (settings) {
        // If you push the PassArguments route
        if (settings.name!.startsWith('/users/')) {
          final userId = settings.name!.substring(7);

          // Then, extract the required data from the arguments and
          // pass the data to the correct screen.
          return MaterialPageRoute(
            builder: (context) {
              return UserProfileScreen(userId: userId);
              print(userId);
            },
          );
        }
        // The code only supports UserProfileScreen.routeName right now.
        // Other values need to be implemented if we add them.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Navigate to AuthGate after splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(backgroundColor: Colors.deepOrange,strokeWidth: 4.0),
      ),
    );
  }
}
