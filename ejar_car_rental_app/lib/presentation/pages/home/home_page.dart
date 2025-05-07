import 'package:flutter/material.dart';
import '../../widgets/car_card.dart';  // Make sure the import path is correct

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EJAAR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color.fromARGB(25, 0, 0, 0),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: const [
                    CarCard(text: 'Car Model 1'),
                    CarCard(text: 'Car Model 2'),
                    CarCard(text: 'Car Model 3'),
                    CarCard(text: 'Car Model 4'),
                    CarCard(text: 'Car Model 5'),
                    CarCard(text: 'Car Model 6'),
                    CarCard(text: 'Car Model 7'),
                    CarCard(text: 'Car Model 8'),
                    CarCard(text: 'Car Model 9'),
                    CarCard(text: 'Car Model 10'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
