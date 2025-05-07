import 'package:flutter/material.dart';
import '../../../app/router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputField(context),
            _forgotPassword(context),
            _signup(context),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "EJAAR",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
        ),
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credentials to login"),
      ],
    );
  }

  Widget _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Username",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color.fromARGB((0.1 * 255).toInt(), 0, 0, 0),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color.fromARGB((0.1 * 255).toInt(), 0, 0, 0),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.black,
          ),
          child: const Text("Login", style: TextStyle( color: Colors.white)),
        ),
      ],
    );
  }

  Widget _forgotPassword(context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.forgetpassword);
      },
      child: const Text("Forgot password?",
          style: TextStyle(color: Colors.black, fontSize: 18)),
    );
  }

  Widget _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? " , style: TextStyle(fontSize: 18),),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
          },
          child: const Text("Sign Up", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ],
    );
  }
}
