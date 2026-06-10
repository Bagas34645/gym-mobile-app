import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/data/services/session_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  Get.put<SessionService>(SessionService(), permanent: true);
  runApp(
    GetMaterialApp(
      title: "GYMFLOW",
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    ),
  );
}
