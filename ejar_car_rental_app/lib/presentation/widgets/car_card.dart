import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CarCard extends StatelessWidget {
  final String text;

  const CarCard({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        child: Row(
          children: [
            Lottie.asset(
              'assets/images/car_item.json',
              width: 200,
              height: 200,
              repeat: false,
              fit: BoxFit.contain,
              
            ),
            Text(text),
          ],
        ),
      ),
    );
  }
}
