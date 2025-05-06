import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      // Navigate to the next page, e.g., HomePage
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/images/ejar_animation.json',
              width: 400,
              height: 400,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            const Text(
              'EJAAR',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
