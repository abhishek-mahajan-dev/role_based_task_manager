import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManagerSignup extends StatefulWidget {
  @override
  _ManagerSignupState createState() => _ManagerSignupState();
}

class _ManagerSignupState extends State<ManagerSignup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  Future<void> _signup() async {
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('people')
            .doc(user.uid)
            .set({
              'role': 'manager',
              'email': user.email,
              'name': nameController.text.trim(),
              'phone': phoneController.text.trim(),
              'dob': dobController.text.trim(),
              'teams': [],
            });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup successful! Redirecting to login...")),
        );

        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacementNamed(context, '/managerLogin');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup Failed: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manager Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: dobController,
                decoration: InputDecoration(
                  labelText: "Date of Birth (DD/MM/YYYY)",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _signup, child: Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
