import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/router.dart';
import '../../models/car.dart';
import '../pages/purchase/purchase_page.dart';

Future<bool?> showIdCaptureDialog(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  File? frontId;
  File? backId;

  Future<File?> _captureImage(String label) async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) return File(photo.path);
    return null;
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Capture ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final image = await _captureImage('Front ID');
                    if (image != null) setState(() => frontId = image);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal:30, vertical: 15),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.black87),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        frontId == null ? 'Capture Front of ID' : 'Front ID Captured',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      if (frontId != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final image = await _captureImage('Back ID');
                    if (image != null) setState(() => backId = image);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.black87),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        backId == null ? 'Capture Back of ID' : 'Back ID Captured',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      if (backId != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
              ),
              ElevatedButton(
                onPressed: (frontId != null && backId != null)
                    ? () {
                  Navigator.pop(context, true);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Proceed Rental', style: TextStyle(color: Colors.black87)),
              ),
            ],
          );
        },
      );
    },
  );
}

class CarDetailsModal extends StatefulWidget {
  final String carId;
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
    required this.carId,
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
  _CarDetailsModalState createState() => _CarDetailsModalState();
}

class _CarDetailsModalState extends State<CarDetailsModal> {
  DateTime? startDate;
  DateTime? endDate;
  int totalDays = 0;
  int totalAmount = 0;

  void _calculateTotal() {
    if (startDate != null && endDate != null && !endDate!.isBefore(startDate!)) {
      totalDays = endDate!.difference(startDate!).inDays + 1;
      totalAmount = (totalDays * widget.rate).toInt();
    } else {
      totalDays = 0;
      totalAmount = 0;
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
        _calculateTotal();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        _calculateTotal();
      });
    }
  }

  Future<void> _openGoogleMapsRoute(BuildContext context) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${widget.latitude},${widget.longitude}&travelmode=driving');
    try {
      final success = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to launch Google Maps')),
      );
    }
  }

  Future<void> _handleRent(BuildContext context) async {
    // Create a Car object using your existing model
    final car = Car(
      id: widget.carId,
      carType: widget.type,
      carModel: widget.model,
      hourlyRate: widget.rate,
      imageBase64s: widget.images,
      plateCharacters: widget.plateCharacters,
      plateNumbers: widget.plateNumbers,
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    // Show ID capture dialog first
    final shouldProceed = await showIdCaptureDialog(context);

    if (shouldProceed == true) {
      try {
        // Get current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("User not logged in.");
        }

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rental transaction created successfully')),
          );

          // Navigate to purchase page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchasePage(
                car: car,
                startDate: startDate!,
                endDate: endDate!,
                totalDays: totalDays,
                totalAmount: totalAmount,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating transaction: $e')),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20),
        height: 900, // increased to fit the map
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.model,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageBytes = base64Decode(widget.images[index]);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        imageBytes,
                        width: 350,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('Description:', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text('Type: ${widget.type}', style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 6),
              Text('Rate: EGP ${widget.rate.toStringAsFixed(2)}/day', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              _platePreview(widget.plateCharacters, widget.plateNumbers),
              const SizedBox(height: 20),
              const Text('Location:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              // Map section with explicit dimensions
              Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
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
                    initialCenter: LatLng(widget.latitude, widget.longitude),
                    initialZoom: 15.0, // Increased zoom for better detail
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(widget.latitude, widget.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(
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
              const SizedBox(height: 20),
              // --- Date pickers section
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectStartDate(context),
                      child: Text(
                        startDate == null
                            ? 'Select Start Date'
                            : 'Start: ${startDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: startDate == null ? null : () => _selectEndDate(context),
                      child: Text(
                        endDate == null
                            ? 'Select End Date'
                            : 'End: ${endDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // --- Total days and amount display
              if (totalDays > 0) ...[
                Center(
                  child: Text('Total Days: $totalDays', style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openGoogleMapsRoute(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  icon: const Icon(Icons.directions, color: Colors.white),
                  label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (startDate == null || endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select rental dates first')),
                      );
                      return;
                    }
                    _handleRent(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  icon: const Icon(Icons.sell, color: Colors.white),
                  label: const Text('Rent', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ));
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
}