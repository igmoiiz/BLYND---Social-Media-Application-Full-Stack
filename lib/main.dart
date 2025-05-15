import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media/Utils/Navigation/routes.dart';
import 'package:social_media/Utils/Theme/theme.dart';
import 'package:social_media/View/Authentication/login.dart';
import 'package:social_media/View/Splash/splash_screen.dart';
import 'package:social_media/View/welcome_screen.dart';
import 'package:social_media/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // debugShowMaterialGrid: true,
      theme: lightMode,
      darkTheme: darkMode,
      title: "BLYND",
      onGenerateRoute: Routes.generateRoute,
      home: SplashScreen(),
    );
  }
}
