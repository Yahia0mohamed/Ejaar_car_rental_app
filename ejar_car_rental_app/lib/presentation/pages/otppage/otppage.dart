import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../app/router.dart';

class OtpPage extends StatelessWidget {
  OtpPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> showOtpField = ValueNotifier(false);
    final ValueNotifier<bool> isLoading = ValueNotifier(false);

    Future<void> sendOtp() async {
      if (emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
        return;
      }
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      isLoading.value = false;
      showOtpField.value = true;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to ${emailController.text}')),
        );
      }
    }

    void verifyOtp() {
      if (otpController.text.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the 4-digit OTP')),
        );
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.newpassword);
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            _header(),
            const SizedBox(height: 40),
            ValueListenableBuilder(
              valueListenable: showOtpField,
              builder: (context, showOtp, _) {
                return ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, loading, _) {
                    return _inputField(context, showOtp, loading, sendOtp, verifyOtp);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "EJAAR",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Text(
          "Please enter your email to receive an OTP",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _inputField(
      BuildContext context,
      bool showOtpField,
      bool isLoading,
      VoidCallback sendOtp,
      VoidCallback verifyOtp,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.black.withOpacity(0.1), // fixed to avoid .withValues
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: isLoading ? null : sendOtp,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.black,
          ),
          child: isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text("Email & Send OTP", style: TextStyle( color: Colors.white)),

        ),

        if (showOtpField) ...[
          const SizedBox(height: 24),
          const Text(
            'Enter the 4-digit OTP sent to your email',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PinCodeTextField(
            appContext: context,
            length: 4,
            controller: otpController,
            onChanged: (value) {},
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 50,
              fieldWidth: 50,
              activeFillColor: Colors.white,
              selectedColor: Colors.blue,
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: verifyOtp,
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.black,
            ),
            child: const Text('Confirm OTP', style: TextStyle( color: Colors.white)),
          ),


        ],
      ],
    );
  }
}
