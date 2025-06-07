import 'dart:convert';
import 'package:flutter/material.dart';
import 'car_details.dart';

class CarCard extends StatelessWidget {
  final String carId;
  final String model;
  final String type;
  final double rate;
  final String base64Image;
  final List<String> images;
  final String plateCharacters;
  final String plateNumbers;
  final double latitude;
  final double longitude;

  const CarCard({
    super.key,
    required this.carId,
    required this.model,
    required this.type,
    required this.rate,
    required this.base64Image,
    required this.images,
    required this.plateCharacters,
    required this.plateNumbers,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = base64Decode(base64Image);

    return SizedBox(
      height: 250,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        shadowColor: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Type: $type'),
                        Text('Rate: \$${rate.toStringAsFixed(2)}/hr'),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) => CarDetailsModal(
                                carId: carId,
                                model: model,
                                type: type,
                                rate: rate,
                                images: images,
                                plateCharacters: plateCharacters,
                                plateNumbers: plateNumbers,
                                latitude: latitude,
                                longitude: longitude,
                                onRent: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('You rented $model!')),
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7.5),
                              backgroundColor: Colors.black,
                              disabledBackgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              )
                          ),
                          child: const Text('Preview Details', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
