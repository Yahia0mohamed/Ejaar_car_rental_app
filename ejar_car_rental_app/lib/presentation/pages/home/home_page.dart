import 'package:flutter/material.dart';
import '../../widgets/car_card.dart';
import '../../widgets/drawer.dart';
import '../../widgets/add_car.dart';
import '../../../models/car.dart';
import '../../../api/car_api.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showImageUploadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageUploadModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'EJAAR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color.fromARGB(25, 0, 0, 0),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Car>>(
                stream: CarApi().getAllCarsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No cars available.'));
                  }

                  final cars = snapshot.data!;
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      final base64Image = car.imageBase64s.isNotEmpty
                          ? car.imageBase64s[0]
                          : ''; // Default empty if none

                      return CarCard(
                        model: car.carModel,
                        type: car.carType,
                        rate: car.hourlyRate,
                        base64Image: base64Image,
                        images: car.imageBase64s,
                        plateCharacters: car.plateCharacters,
                        plateNumbers: car.plateNumbers,
                          latitude: car.latitude,
                          longitude: car.longitude
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageUploadModal(context),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }
}
