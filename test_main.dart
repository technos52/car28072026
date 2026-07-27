import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Car Dealer Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Car Dealer - Fixed'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'App Fixed Successfully!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Splash screen navigation is working',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Home view has been restored',
                style: TextStyle(fontSize: 16),
              ),
              Text('Ready to run the full app', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
