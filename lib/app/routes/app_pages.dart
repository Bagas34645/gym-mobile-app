import 'package:get/get.dart';
import 'app_routes.dart';

import '../modules/splash/views/splash_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';

import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/register_otp_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/bindings/auth_binding.dart';

import '../modules/home/views/home_view.dart';
import '../modules/home/bindings/home_binding.dart';

import '../modules/membership/views/membership_status_view.dart';
import '../modules/membership/views/packages_view.dart';
import '../modules/membership/views/renewal_view.dart';
import '../modules/membership/views/midtrans_payment_view.dart';
import '../modules/membership/views/membership_history_view.dart';
import '../modules/membership/bindings/membership_binding.dart';

import '../modules/trainer/views/trainer_list_view.dart';
import '../modules/trainer/views/trainer_detail_view.dart';
import '../modules/trainer/views/workout_plan_view.dart';
import '../modules/trainer/views/workout_tracking_view.dart';
import '../modules/trainer/bindings/trainer_binding.dart';
import '../modules/trainer/bindings/workout_binding.dart';

import '../modules/checkin/views/checkin_view.dart';
import '../modules/checkin/views/face_register_view.dart';
import '../modules/checkin/bindings/checkin_binding.dart';

import '../modules/chat/views/chat_view.dart';
import '../modules/chat/views/chat_detail_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/notification/views/notification_list_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/feedback/views/feedback_view.dart';
import '../modules/feedback/bindings/feedback_binding.dart';
import '../modules/progress/views/progress_view.dart';
import '../modules/progress/bindings/progress_binding.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER_OTP,
      page: () => const RegisterOtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.MEMBERSHIP,
      page: () => const MembershipStatusView(),
      binding: MembershipBinding(),
    ),
    GetPage(
      name: Routes.PACKAGES,
      page: () => const PackagesView(),
      binding: MembershipBinding(),
    ),
    GetPage(
      name: Routes.RENEWAL,
      page: () => const RenewalView(),
      binding: MembershipBinding(),
    ),
    GetPage(
      name: Routes.MIDTRANS_PAYMENT,
      page: () => const MidtransPaymentView(),
    ),
    GetPage(
      name: Routes.MEMBERSHIP_HISTORY,
      page: () => const MembershipHistoryView(),
      binding: MembershipBinding(),
    ),
    GetPage(
      name: Routes.CHECKIN,
      page: () => const CheckinView(),
      binding: CheckinBinding(),
    ),
    GetPage(
      name: Routes.FACE_REGISTER,
      page: () => const FaceRegisterView(),
      binding: CheckinBinding(),
    ),
    GetPage(
      name: Routes.TRAINER,
      page: () => const TrainerListView(),
      binding: TrainerBinding(),
    ),
    GetPage(
      name: Routes.TRAINER_DETAIL,
      page: () => const TrainerDetailView(),
      binding: TrainerBinding(),
    ),
    GetPage(
      name: Routes.WORKOUT_PLAN,
      page: () => const WorkoutPlanView(),
      binding: WorkoutBinding(),
    ),
    GetPage(
      name: Routes.WORKOUT_TRACKING,
      page: () => const WorkoutTrackingView(),
      binding: WorkoutBinding(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.CHAT_DETAIL,
      page: () => ChatDetailView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationListView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.FEEDBACK,
      page: () => const FeedbackView(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: Routes.PROGRESS,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
    ),
  ];
}
