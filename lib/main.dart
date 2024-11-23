import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'deep_linking.dart' as deep_linking;
import 'firebase_options.dart';
import 'imports.dart';
import 'screens/notifications_screen.dart';
import 'services/FCMService.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService.initialize();
  await FCMService.storeInitialToken();

  // Handle message interaction
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _firebaseMessagingBackgroundHandler(initialMessage);
  }

  // Branch SDK initialization
  await FlutterBranchSdk.init(enableLogging: false, disableTracking: false);
  BranchService().initSession().listen(
    (data) {
      if (data.containsKey('+clicked_branch_link') &&
          data['+clicked_branch_link'] == true) {
        deep_linking.handleLink(data['~referring_link']);
        debugPrint('DeepLink Data: $data');
      }
    },
    onError: (error) => print('Branch SDK session error: $error'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CulinectNotificationService>(
          create: (context) => CulinectNotificationService()..initialize(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FCMService.onForegroundMessage((RemoteMessage message) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
    });

    final User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CuliNect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: user != null ? '/splash' : '/',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthGate(),
        '/notifications': (context) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name!.startsWith('/users/')) {
          final userId = settings.name!.substring(7);
          return MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: userId),
          );
        }
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.deepOrange,
          strokeWidth: 4.0,
        ),
      ),
    );
  }
}
