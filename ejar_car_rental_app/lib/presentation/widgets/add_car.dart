import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import '../../../models/car.dart';
import '../../../api/car_api.dart';


class ImageUploadModal extends StatefulWidget {
  const ImageUploadModal({Key? key}) : super(key: key);

  @override
  State<ImageUploadModal> createState() => _ImageUploadModalState();
}

class _ImageUploadModalState extends State<ImageUploadModal> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _carTypeController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _carPlateCharactersController = TextEditingController();
  final TextEditingController _carPlateNumbersController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _locationFetched = false;

  final CarApi _carApi = CarApi();

  @override
  void dispose() {
    _carTypeController.dispose();
    _carModelController.dispose();
    _hourlyRateController.dispose();
    _carPlateCharactersController.dispose();
    _carPlateNumbersController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  // Future<void> _getCurrentLocation() async {
  //
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Location permissions are denied. Please allow access.')),
  //       );
  //       return;
  //     }
  //   }
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Location services are disabled. Please enable them in settings.'),
  //         action: SnackBarAction(
  //           label: 'Open Settings',
  //           onPressed: () async {
  //             await Geolocator.openLocationSettings();
  //           },
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text('Permissions permanently denied. Please enable them in app settings.'),
  //         action: SnackBarAction(
  //           label: 'Open Settings',
  //           onPressed: () async {
  //             await Geolocator.openAppSettings();
  //           },
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.best,
  //   );
  //
  //   setState(() {
  //     _latitude = position.latitude;
  //     _longitude = position.longitude;
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Location set: ($_latitude, $_longitude)')),
  //   );
  // }


  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationFetched = true;
      });
    } catch (e) {
      print('Error fetching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location: $e')),
      );
    }
  }



  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool get _canUpload =>
      _selectedImages.isNotEmpty &&
          _carTypeController.text.trim().isNotEmpty &&
          _carModelController.text.trim().isNotEmpty &&
          _hourlyRateController.text.trim().isNotEmpty &&
          _carPlateCharactersController.text.trim().isNotEmpty &&
          _carPlateNumbersController.text.trim().isNotEmpty &&
          _locationFetched;


  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Car Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          _buildInputField(controller: _carTypeController, label: 'Car Type'),
          const SizedBox(height: 15),

          _buildInputField(controller: _carModelController, label: 'Car Model'),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _carPlateNumbersController,
                  label: 'Plate Numbers',
                ),
              ),
              const SizedBox(width: 16), // Space between inputs
              Expanded(
                child: _buildInputField(
                  controller: _carPlateCharactersController,
                  label: 'Plate Characters',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInputField(
            controller: _hourlyRateController,
            label: 'Hourly Rate (EGP)',
            prefixText: 'EGP ',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildButton(Icons.my_location, 'Use Current Location', _getCurrentLocation),
              const SizedBox(height: 8),
              _latitude != null && _longitude != null
                  ? Text(
                'Selected Location: (${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)})',
                style: const TextStyle(color: Colors.black87),
              )
                  : const Text(
                'No location selected yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildButton(Icons.photo_library, 'Gallery', _pickImages),
              _buildButton(Icons.camera_alt, 'Camera', _takePhoto),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Selected Images (${_selectedImages.length}):',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _selectedImages.isEmpty
                ? const Center(
              child: Text('No images selected', style: TextStyle(color: Colors.grey)),
            )
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canUpload
                  ? () async {
                List<String> base64Images = [];
                for (File imgFile in _selectedImages) {
                  String base64Str = await _fileToBase64(imgFile);
                  base64Images.add(base64Str);
                }
                double hourlyRate = double.tryParse(_hourlyRateController.text.trim()) ?? 0.0;
                Car newCar = Car(
                  carType: _carTypeController.text.trim(),
                  carModel: _carModelController.text.trim(),
                  hourlyRate: hourlyRate,
                  imageBase64s: base64Images,
                  plateCharacters: _carPlateCharactersController.text.trim(),
                  plateNumbers: _carPlateNumbersController.text.trim(),
                  latitude: _latitude!,
                  longitude: _longitude!,
                );

                await _carApi.addCar(newCar);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Uploaded ${newCar.carType} - ${newCar.carModel} at EGP ${newCar.hourlyRate}/hr',
                    ),
                  ),
                );

                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.black87,
              ),
              child: const Text(
                'Upload',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixText: prefixText,
        prefixStyle: const TextStyle(color: Colors.black87),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
