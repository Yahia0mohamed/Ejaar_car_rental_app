import 'package:cloud_firestore/cloud_firestore.dart';

class RentalTransaction {
  final String id;
  final String userId;
  final String carId;
  final DateTime timestamp;
  final DateTime startDate;
  final DateTime endDate;

  RentalTransaction({
    required this.id,
    required this.userId,
    required this.carId,
    required this.timestamp,
    required this.startDate,
    required this.endDate,
  });

  factory RentalTransaction.fromMap(String id, Map<String, dynamic> data) {
    return RentalTransaction(
      id: id,
      userId: data['userId'],
      carId: data['carId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'carId': carId,
      'timestamp': timestamp,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
