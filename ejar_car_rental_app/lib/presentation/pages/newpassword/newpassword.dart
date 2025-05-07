import 'package:flutter/material.dart';
import '../../../app/router.dart';

class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void saveNewPassword() {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // TODO: Add API call to save the new password

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated successfully')),
    );

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.only(top: 70),
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 35),
            _PassFields(passwordController, confirmPasswordController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveNewPassword,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16), // vertical padding inside button
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "Save Password",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),




          ],
        ),
      ),
    );
  }
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
        "Set New Password",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _PassFields(TextEditingController passwordController, TextEditingController confirmPasswordController) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        controller: passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'New Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.black.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.lock),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: confirmPasswordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.black.withOpacity(0.1),
          filled: true,
          prefixIcon: const Icon(Icons.lock_outline),
        ),
      ),
    ],
  );
}
