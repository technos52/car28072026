import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:DealMatee/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('End-to-End App Flow and Screenshot Capture', (WidgetTester tester) async {
    // 1. Launch App
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Capture Auth Screen
    await binding.takeScreenshot('01_auth_screen');
    await Future.delayed(const Duration(seconds: 1));

    // 2. Test Phone Login Navigation
    final phoneButton = find.text('Continue with Phone');
    if (phoneButton.evaluate().isNotEmpty) {
      await tester.tap(phoneButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('02_phone_input_screen');

      // Go back to Auth
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    // 3. Test Demo Login Flow
    final demoLoginButton = find.text('Demo Login');
    if (demoLoginButton.evaluate().isNotEmpty) {
      await tester.tap(demoLoginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    // 4. Capture Home Dashboard
    await binding.takeScreenshot('03_home_dashboard');
    await Future.delayed(const Duration(seconds: 2));

    // 5. Navigate to Wishlist Tab
    final wishlistTab = find.text('Wishlist');
    if (wishlistTab.evaluate().isNotEmpty) {
      await tester.tap(wishlistTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('04_wishlist_tab');
    }

    // 6. Navigate to Add Car Tab
    final addCarTab = find.text('Add Car');
    if (addCarTab.evaluate().isNotEmpty) {
      await tester.tap(addCarTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('05_add_car_tab');
    }

    // 7. Navigate to My Car Tab
    final myCarTab = find.text('My Car');
    if (myCarTab.evaluate().isNotEmpty) {
      await tester.tap(myCarTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('06_my_cars_tab');
    }

    // 8. Navigate to Profile Tab
    final profileTab = find.text('Profile');
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await binding.takeScreenshot('07_profile_tab');
    }

    // 9. Return to Home and inspect a car detail
    final homeTab = find.text('Home');
    if (homeTab.evaluate().isNotEmpty) {
      await tester.tap(homeTab);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Tap first car if available
      final firstCar = find.textContaining('Camry');
      if (firstCar.evaluate().isNotEmpty) {
        await tester.tap(firstCar.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await binding.takeScreenshot('08_car_detail_screen');
      }
    }
  });
}
