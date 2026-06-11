import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_mobile_flutter/firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('id_ID', null);

  runApp(
    GetMaterialApp(
      title: "CoreGym",
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    ),
  );
}
