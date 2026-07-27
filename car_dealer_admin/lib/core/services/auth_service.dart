import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'admin_service.dart';

class AuthService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AdminService _adminService = AdminService();

  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isAdmin = false.obs;
  final RxBool _isLoading = true.obs;

  User? get user => _user.value;
  bool get isAdmin => _isAdmin.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) async {
      _user.value = user;
      if (user != null) {
        _isAdmin.value = await _adminService.isAdmin(user.uid);
      } else {
        _isAdmin.value = false;
      }
      _isLoading.value = false;
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('DEBUG: [AuthService] Starting sign in for: $email');
      String normalizedEmail = email.trim();
      if (!normalizedEmail.contains('@')) {
        normalizedEmail = '$normalizedEmail@admin.local';
        print('DEBUG: [AuthService] Normalized email to: $normalizedEmail');
      }

      print('DEBUG: [AuthService] Calling Firebase Auth...');
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      print('DEBUG: [AuthService] Firebase Auth Success. UID: ${credential.user?.uid}');
      
      if (credential.user != null) {
        print('DEBUG: [AuthService] Checking Firestore for admin status...');
        _isAdmin.value = await _adminService.isAdmin(credential.user!.uid);
        print('DEBUG: [AuthService] Firestore Admin Check Result: ${_isAdmin.value}');
        
        if (!_isAdmin.value) {
          print('DEBUG: [AuthService] ACCESS DENIED: User is not in the admins collection.');
          print('DEBUG: [AuthService] Please add document ID "${credential.user!.uid}" to the "admins" collection.');
          
          await _auth.signOut();
          _user.value = null;
          
          _showError('Access Denied', 'You are not an admin. Your UID: ${credential.user!.uid}');
          return false;
        }
        print('DEBUG: [AuthService] LOGIN SUCCESSFUL. Proceeding to Dashboard.');
        return true;
      }
      return false;
    } catch (e) {
      print('DEBUG: [AuthService] FIREBASE ERROR: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains('user-not-found')) {
        errorMessage = 'No account found with this email.';
      } else if (errorMessage.contains('wrong-password')) {
        errorMessage = 'Incorrect password.';
      } else if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Invalid email format.';
      } else if (errorMessage.contains('user-disabled')) {
        errorMessage = 'This account has been disabled.';
      }
      
      _showError('Login Failed', errorMessage);
      return false;
    }
  }

  void _showError(String title, String message) {
    try {
      if (Get.context != null) {
        // Use a slight delay to ensure the framework is ready
        Future.delayed(Duration.zero, () {
          if (Get.overlayContext != null) {
            Get.snackbar(
              title,
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 10),
            );
          } else {
            print('DEBUG: [AuthService] No Overlay found. Message: $title - $message');
          }
        });
      } else {
        print('DEBUG: [AuthService] Context null. Message: $title - $message');
      }
    } catch (e) {
      print('DEBUG: [AuthService] Error showing snackbar: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin.value = false;
  }
}

