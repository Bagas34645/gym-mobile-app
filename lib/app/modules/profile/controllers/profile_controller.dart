import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  var name = 'Budi Santoso'.obs;
  var email = 'budi.santoso@email.com'.obs;
  var phone = '+62 812 3456 7890'.obs;
  
  void logout() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
