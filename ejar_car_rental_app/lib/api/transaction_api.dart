import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/transaction.dart';

class TransactionAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new transaction
  Future<void> addTransaction(RentalTransaction transaction) async {
    try {
      await _firestore.collection('transaction').add({
        'userId': transaction.userId,
        'carId': transaction.carId,
        'timestamp': transaction.timestamp,
        'startDate': transaction.startDate,
        'endDate': transaction.endDate,
      });
      print('Transaction added successfully');
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
    }
  }

  // Get latest rented car for a user
  Future<Car?> getLatestRentedCar(String userId) async {
    try {
      print('Fetching latest transaction for user: $userId');

      // First get the latest transaction for the user
      final querySnapshot = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get()
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Index might still be building. Please try again in a moment.');
        },
      );

      if (querySnapshot.docs.isEmpty) {
        print('No transactions found for user: $userId');
        return null;
      }

      // Get the carId from the latest transaction
      final latestTransaction = querySnapshot.docs.first;
      final carId = latestTransaction.data()['carId'];
      print('Found latest transaction with carId: $carId');

      if (carId == null) {
        print('CarId is null in the transaction');
        return null;
      }

      // Get the car details using carId
      final carDoc = await _firestore
          .collection('cars')
          .doc(carId)
          .get();

      if (!carDoc.exists) {
        print('No car found with ID: $carId');
        return null;
      }

      print('Successfully found car details');
      return Car.fromMap(carDoc.data()!, carDoc.id);

    } catch (e) {
      if (e.toString().contains('failed-precondition')) {
        print('Index is still being created. Please wait a few minutes and try again.');
      } else {
        print('Error getting latest rented car: $e');
      }
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Debug method to print transaction details
  Future<void> printLatestTransaction(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transaction')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No transactions found');
        return;
      }

      final latestTransaction = querySnapshot.docs.first;
      print('Latest transaction data: ${latestTransaction.data()}');
    } catch (e) {
      print('Error printing latest transaction: $e');
    }
  }
}