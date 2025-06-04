import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import '../../widgets/drawer.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = 'Yahia Mohamed'; // put the user name here
  String cvvCode = '';

  // Helpers to split card number for display (if needed)
  // But awesome_card expects full string with spaces, e.g. "1234 5678 9012 3456"

  void _onPay() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );
      // Here, add your payment logic.
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
            ),
            const SizedBox(height: 24),

            // Simple form to input card details
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
                    keyboardType: TextInputType.text,
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
                    onSaved: (value) {
                      // format with spaces automatically or expect user input spaced
                      cardNumber = value ?? '';
                    },
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
                      // Basic format check MM/YY
                      final regex = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
                      if (!regex.hasMatch(value)) {
                        return 'Invalid expiry date';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      expiryDate = value ?? '';
                    },
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
                    onSaved: (value) {
                      cvvCode = value ?? '';
                    },
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
              child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
