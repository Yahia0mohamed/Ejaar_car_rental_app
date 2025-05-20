import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class CarApi {
  final CollectionReference carsCollection = FirebaseFirestore.instance.collection('cars');

  Future<void> addCar(Car car) async {
    DocumentReference docRef = await carsCollection.add(car.toMap());
    car.id = docRef.id;
  }

  Future<List<Car>> getAllCars() async {
    final querySnapshot = await carsCollection.get();
    return querySnapshot.docs
        .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }


  Stream<List<Car>> getAllCarsStream() {
    return carsCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Car.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }
}