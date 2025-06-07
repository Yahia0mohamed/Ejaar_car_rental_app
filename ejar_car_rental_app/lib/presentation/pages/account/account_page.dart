import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/drawer.dart';
import '../../../api/account_api.dart';
import '../../../api/transaction_api.dart';
import '../../../models/account.dart';
import '../../../models/car.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Account? _account;
  Car? _latestCar;
  bool _isLoading = true;
  final TransactionAPI _transactionAPI = TransactionAPI();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      print('Loading data for user: ${user.uid}');

      // Get account data
      final acc = await AccountAPI().getAccount();
      print('Account loaded: ${acc?.username}');

      // Debug: print latest transaction
      await _transactionAPI.printLatestTransaction(user.uid);

      // Get latest rented car using the new method
      final latestCar = await _transactionAPI.getLatestRentedCar(user.uid);
      print('Latest car loaded: ${latestCar?.carModel}');

      if (mounted) {
        setState(() {
          _account = acc;
          _latestCar = latestCar;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _account == null
          ? const Center(child: Text('No account data found.'))
          : RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: _account!.imageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(_account!.imageBase64))
                    : null,
                child: _account!.imageBase64.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                _account!.username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                _account!.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Latest Car Rented',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              if (_latestCar != null)
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        if (_latestCar!.imageBase64s.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_latestCar!.imageBase64s.first),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.car_rental, size: 60),
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _latestCar!.carModel,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text('Type: ${_latestCar!.carType}'),
                              const SizedBox(height: 5),
                              Text(
                                  'Rate: \$${_latestCar!.hourlyRate.toStringAsFixed(2)}/hr'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No rented car found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}