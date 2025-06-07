import 'package:flutter/material.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/signup/signup_page.dart';
import '../presentation/pages/otppage/otppage.dart';
import '../presentation/pages/newpassword/newpassword.dart';
import '../presentation/pages/account/account_page.dart';
import '../presentation/pages/purchase/purchase_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetpassword = '/otppage';
  static const String newpassword = '/newpassword';
  static const String account = '/account';
  static const String purchase = '/purchase';



  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashPage(),
    home: (context) =>  HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    forgetpassword: (context) =>  OtpPage(),
    newpassword: (context) => const NewPasswordPage(),
    account : (context) => const AccountPage(),
    // purchase : (context) => const PurchasePage(),
  };
}
