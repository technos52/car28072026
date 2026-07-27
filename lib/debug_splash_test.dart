import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_routes.dart';

class DebugSplashTest extends StatefulWidget {
  const DebugSplashTest({super.key});

  @override
  State<DebugSplashTest> createState() => _DebugSplashTestState();
}

class _DebugSplashTestState extends State<DebugSplashTest> {
  @override
  void initState() {
    super.initState();
    // Navigate after 2 seconds for testing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAllNamed(AppRoutes.auth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.car_rental, size: 100, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'Car Dealer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }
}
