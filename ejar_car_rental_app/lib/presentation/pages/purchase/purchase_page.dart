import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import '../../../api/transaction_api.dart';
import '../../../models/car.dart';
import '../../../models/transaction.dart';
import '../../widgets/drawer.dart';

import 'package:flutter/services.dart';

class MonthInputFormatter extends TextInputFormatter {
  final RegExp _digitOnly = RegExp(r'^\d{0,2}$'); // Only allow 0–2 digits

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    // Allow deleting everything
    if (text.isEmpty) return newValue;

    // Allow only digits, max 2
    if (!_digitOnly.hasMatch(text)) return oldValue;

    // Allow partial input: "0", "1", "01", "12"
    if (text.length == 1) {
      return newValue;
    }

    // At 2 digits, check valid month
    final value = int.tryParse(text);
    if (value != null && value >= 1 && value <= 12) {
      return newValue;
    }

    return oldValue; // Reject invalid like "00", "13"
  }
}

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

  final List<TextEditingController> _cardControllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();


  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String _previousValidMonth = '';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    cardHolderName = (currentUser?.displayName ?? 'Card Holder').toUpperCase();

    for (var controller in _cardControllers) {
      controller.addListener(_updateCardNumber);
    }

    _monthController.addListener(() {
      final text = _monthController.text;

      final validMonthRegex = RegExp(r'^(0?[1-9]|1[0-2])$');

      if (text.isEmpty) {
        _previousValidMonth = '';
        return;
      }

      if (!validMonthRegex.hasMatch(text)) {
        // Revert to previous valid month input
        _monthController.text = _previousValidMonth;
        _monthController.selection = TextSelection.fromPosition(
          TextPosition(offset: _previousValidMonth.length),
        );
      } else {
        _previousValidMonth = text;
      }
    });
  }
  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _updateCardNumber() {
    final parts = _cardControllers.map((c) => c.text.padRight(4, ' ')).toList();
    setState(() {
      cardNumber = parts.join(' ');
    });
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
        print('Transaction to be added:');
        print('  userId: ${transaction.userId}');
        print('  carId: ${transaction.carId}');
        print('  startDate: ${transaction.startDate}');
        print('  endDate: ${transaction.endDate}');
        print('  timestamp: ${transaction.timestamp}');

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
            Container(
              padding: const EdgeInsets.all(4),  // padding inside the container
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Summary',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Car: ${widget.car.carModel}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                  Text('Start Date: ${widget.startDate.toString().split(' ')[0]}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  Text('End Date: ${widget.endDate.toString().split(' ')[0]}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  Text('Total Days: ${widget.totalDays}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),
                  Text('Total Amount: ${widget.totalAmount} EGP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
              height: 1, // thickness of the line
              color: Colors.grey, // color of the line
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
              height: 250,
            ),
            const SizedBox(height: 24),

            // Payment Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Inside the Form widget
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8.0 : 0),
                          child: TextFormField(
                            controller: _cardControllers[index],
                            focusNode: _focusNodes[index],
                            decoration: InputDecoration(
                              labelText: index == 0 ? 'Card Number' : null,
                              border: const OutlineInputBorder(),
                              hintText: 'XXXX',
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            validator: (value) {
                              if (value == null || value.length != 4) {
                                return '';
                              }
                              return null;
                            },

                            // 👇 Replace these two with the updated versions
                            onChanged: (value) {
                              if (value.length == 4 && index < 3) {
                                _focusNodes[index + 1].requestFocus();
                              }

                              setState(() {
                                cardNumber = _cardControllers.map((c) => c.text.padRight(4, ' ')).join(' ');
                              });

                              print('Updated card number: $cardNumber');
                            },
                            onSaved: (value) {
                              if (index == 3) {
                                cardNumber = _cardControllers.map((c) => c.text.padRight(4, ' ')).join(' ');
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _monthController,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            hintText: 'MM',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            MonthInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter MM';
                            }
                            final intVal = int.tryParse(value);
                            if (intVal == null || intVal < 1 || intVal > 12) {
                              return 'Invalid MM';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.length == 2) {
                              FocusScope.of(context).nextFocus();
                            }
                            setState(() {
                              expiryDate =
                              '${_monthController.text.padLeft(2, '0')}/${_yearController.text.padLeft(2, '0')}';
                            });
                          },
                          onSaved: (_) {
                            expiryDate =
                            '${_monthController.text.padLeft(2, '0')}/${_yearController.text.padLeft(2, '0')}';
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            hintText: 'YY',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length != 2) {
                              return 'Enter YY';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              expiryDate =
                              '${_monthController.text.padLeft(2, '0')}/${_yearController.text.padLeft(2, '0')}';
                            });
                          },
                          onSaved: (_) {
                            expiryDate =
                            '${_monthController.text.padLeft(2, '0')}/${_yearController.text.padLeft(2, '0')}';
                          },
                        ),
                      ),
                    ],
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
                'Pay ${widget.totalAmount} EGP',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}