import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Wait for auth state to be determined
    if (authService.isLoading) {
      return null; // Don't redirect while loading
    }
    
    if (route == AppRoutes.login) {
      // If already logged in and is admin, redirect to dashboard
      if (authService.user != null && authService.isAdmin) {
        return RouteSettings(name: AppRoutes.dashboard);
      }
      return null;
    } else {
      // For protected routes, check if user is authenticated and is admin
      if (authService.user == null || !authService.isAdmin) {
        return RouteSettings(name: AppRoutes.login);
      }
      return null;
    }
  }
}

