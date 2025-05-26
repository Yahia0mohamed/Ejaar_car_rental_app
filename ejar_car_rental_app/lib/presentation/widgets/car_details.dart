import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class CarDetailsModal extends StatelessWidget {
  final String model;
  final String type;
  final double rate;
  final List<String> images;
  final double latitude;
  final double longitude;
  final VoidCallback? onRent;
  final String plateCharacters;
  final String plateNumbers;

  const CarDetailsModal({
    super.key,
    required this.model,
    required this.type,
    required this.rate,
    required this.images,
    required this.plateCharacters,
    required this.plateNumbers,
    required this.latitude,
    required this.longitude,
    this.onRent,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(20),
      height: 900, // increased to fit the map
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final imageBytes = base64Decode(images[index]);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes,
                    width: 200,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Description:', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          Text('Type: $type', style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text('Rate: \$${rate.toStringAsFixed(2)}/hr', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          _platePreview(plateCharacters, plateNumbers),
          const SizedBox(height: 20),
          Text('Location:', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          // Map section with explicit dimensions
          Container(
            width: 400,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 15.0, // Increased zoom for better detail
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Optional: Add a marker to show the exact location
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Center(
            child: ElevatedButton(
              onPressed: onRent ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Rent This Car', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _platePreview(String plateCharacters, String plateNumbers) {
  return Container(
    height: 60,
    width: 140,
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          height: 30,
          color: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Egypt', style: TextStyle(color: Colors.white, fontSize: 16)),
              Text('مصر', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
        Container(
          height: 30,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(plateNumbers, style: const TextStyle(fontSize: 16)),
              ),
              Container(
                height: 20,
                width: 1,
                color: Colors.grey,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Text(plateCharacters, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}