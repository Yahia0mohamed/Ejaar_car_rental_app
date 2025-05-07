import 'package:flutter/material.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/signup/signup_page.dart';
import '../presentation/pages/otppage/otppage.dart';
import '../presentation/pages/newpassword/newpassword.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetpassword = '/otppage';
  static const String newpassword = '/newpassword';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    home: (context) =>  HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    forgetpassword: (context) =>  OtpPage(),
    newpassword: (context) => const NewPasswordPage(),
  };
}
