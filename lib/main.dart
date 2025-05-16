import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/Controller/Services/Authentication/auth_services.dart';
import 'package:social_media/Utils/Navigation/routes.dart';
import 'package:social_media/Utils/Theme/theme.dart';
import 'package:social_media/Utils/consts.dart';
// import 'package:social_media/View/Splash/splash_screen.dart';
import 'package:social_media/View/welcome_screen.dart';
import 'package:social_media/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => log("Firebase Initialized: $value"));
  await Supabase.initialize(
    url: supabase_url,
    anonKey: supabase_anonKey,
  ).then((value) => log("Supabase Initialized: $value"));
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthServices())],
      builder: (context, child) => const MainApp(),
    ),
  );
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
      home: WelcomePage(),
    );
  }
}
