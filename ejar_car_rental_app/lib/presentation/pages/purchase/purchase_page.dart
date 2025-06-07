import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import '../../../api/transaction_api.dart';
import '../../../models/car.dart';
import '../../../models/transaction.dart';
import '../../widgets/drawer.dart';

class PurchasePage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int totalAmount;
  final Car car;

  const PurchasePage({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalAmount,
    required this.car,
  }) : super(key: key);

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final TransactionAPI _transactionAPI = TransactionAPI();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    cardHolderName = currentUser?.displayName ?? 'Card Holder';
  }

  void _onPay() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Get current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception("User not logged in");
        }

        // Create transaction object
        final transaction = RentalTransaction(
          id: "",
          userId: user.uid,
          carId: widget.car.id!,
          timestamp: DateTime.now(),
          startDate: widget.startDate,
          endDate: widget.endDate,
        );

        await _transactionAPI.addTransaction(transaction);

        if (mounted) {
          Navigator.of(context).pop(); // close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Successful and Transaction Saved!')),
          );

          // Navigate back to home or another appropriate screen
          Navigator.of(context).pushReplacementNamed('/home');
        }

      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'EJAAR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rental Summary Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Car: ${widget.car.carModel}'),
                    Text('Start Date: ${widget.startDate.toString().split(' ')[0]}'),
                    Text('End Date: ${widget.endDate.toString().split(' ')[0]}'),
                    Text('Total Days: ${widget.totalDays}'),
                    Text('Total Amount: \$${widget.totalAmount}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            CreditCard(
              cardNumber: cardNumber.isEmpty ? 'XXXX XXXX XXXX XXXX' : cardNumber,
              cardExpiry: expiryDate.isEmpty ? 'MM/YY' : expiryDate,
              cardHolderName: cardHolderName.isEmpty ? 'Card Holder' : cardHolderName,
              bankName: 'Axis Bank',
              cardType: CardType.masterCard,
              frontBackground: CardBackgrounds.black,
              backBackground: CardBackgrounds.white,
              showShadow: true,
              textName: 'Name',
              textExpiry: 'MM/YY',
              height: 200,
            ),
            const SizedBox(height: 24),

            // Payment Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      hintText: 'XXXX XXXX XXXX XXXX',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (value.replaceAll(' ', '').length != 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                    onSaved: (value) => cardNumber = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(),
                      hintText: 'MM/YY',
                    ),
                    keyboardType: TextInputType.text,
                    maxLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry date';
                      }
                      final regex = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
                      if (!regex.hasMatch(value)) {
                        return 'Invalid expiry date';
                      }
                      return null;
                    },
                    onSaved: (value) => expiryDate = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                      hintText: 'XXX',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CVV';
                      }
                      if (value.length != 3) {
                        return 'CVV must be 3 digits';
                      }
                      return null;
                    },
                    onSaved: (value) => cvvCode = value ?? '',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Pay \$${widget.totalAmount}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}