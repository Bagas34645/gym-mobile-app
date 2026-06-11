import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = FirebaseAuth.instance.currentUser;

    // JIKA BELUM LOGIN
    if (user == null) {
      log('Unauthorized Access Attempt', name: 'SECURITY');

      return const RouteSettings(name: Routes.LOGIN);
    }
    log('Authorized User Access', name: 'SECURITY');

    // JIKA SUDAH LOGIN
    return null;
  }
}
