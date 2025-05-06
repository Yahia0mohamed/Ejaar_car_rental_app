import 'package:flutter/material.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/signup/signup_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
  };
}
