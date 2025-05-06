import 'package:flutter/material.dart';
import 'app/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Awesome App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
