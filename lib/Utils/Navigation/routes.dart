import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/View/Authentication/login.dart';
import 'package:social_media/View/Authentication/sign_up.dart';
import 'package:social_media/View/Interface/home_page.dart';
import 'package:social_media/View/Splash/splash_screen.dart';
import 'package:social_media/View/welcome_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return CupertinoPageRoute(builder: (context) => SplashScreen());
      case '/welcome_page':
        return CupertinoPageRoute(builder: (context) => WelcomePage());
      case '/login':
        return CupertinoPageRoute(builder: (context) => LoginPage());
      case '/sign_up':
        return CupertinoPageRoute(builder: (context) => SignUp());
      case '/home':
        return CupertinoPageRoute(builder: (context) => HomePage());
      default:
        return CupertinoPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Text("No route Defined for ${settings.name}"),
                ),
              ),
        );
    }
  }
}
