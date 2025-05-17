import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  @override
  void dispose() {
    _carTypeController.dispose();
    _carModelController.dispose();
    _hourlyRateController.dispose();
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool get _canUpload =>
      _selectedImages.isNotEmpty &&
          _carTypeController.text.trim().isNotEmpty &&
          _carModelController.text.trim().isNotEmpty &&
          _hourlyRateController.text.trim().isNotEmpty;

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

          _buildInputField(
            controller: _hourlyRateController,
            label: 'Hourly Rate (EGP)',
            prefixText: 'EGP ',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Uploading ${_carTypeController.text.trim()} - ${_carModelController.text.trim()} at EGP ${_hourlyRateController.text.trim()}/hr...',
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
