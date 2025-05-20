import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CarCard extends StatelessWidget {
  final String model;
  final String type;
  final double rate;
  final String base64Image;

  const CarCard({
    Key? key,
    required this.model,
    required this.type,
    required this.rate,
    required this.base64Image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(base64Image);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.memory(
            imageBytes,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Type: $type'),
                Text('Rate: \$${rate.toStringAsFixed(2)}/hr'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// class CarCard extends StatelessWidget {
//   final String text;
//
//   const CarCard({Key? key, required this.text}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Container(
//         child: Row(
//           children: [
//             Lottie.asset(
//               'assets/images/car_item.json',
//               width: 200,
//               height: 200,
//               repeat: false,
//               fit: BoxFit.contain,
//
//             ),
//             Text(text),
//           ],
//         ),
//       ),
//     );
//   }
// }
