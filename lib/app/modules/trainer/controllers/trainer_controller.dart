import 'package:get/get.dart';

class TrainerController extends GetxController {
  // --- Trainer List & Detail ---
  var selectedTrainer = Rxn<Map<String, dynamic>>();

  final List<Map<String, dynamic>> trainers = [
    {
      'id': 1,
      'name': 'Bima Satria',
      'specialty': 'Bodybuilding & Strength',
      'experience': '5 Tahun',
      'rating': 4.9,
      'reviews': 124,
      'image': 'https://via.placeholder.com/150', // placeholder
      'about': 'Bima adalah pelatih bersertifikat dengan fokus pada hipertrofi otot dan pembentukan kekuatan inti. Ia telah membantu lebih dari 100 klien mencapai target fisik mereka.',
      'availableSchedules': ['08:00', '10:00', '15:00', '18:00'],
    },
    {
      'id': 2,
      'name': 'Siti Anisa',
      'specialty': 'Yoga & Flexibility',
      'experience': '3 Tahun',
      'rating': 4.8,
      'reviews': 89,
      'image': 'https://via.placeholder.com/150',
      'about': 'Siti merupakan instruktur Yoga dengan pendekatan mindfulness. Spesialisasinya mencakup perbaikan postur, fleksibilitas, dan pemulihan cedera ringan.',
      'availableSchedules': ['07:00', '09:00', '16:00'],
    },
    {
      'id': 3,
      'name': 'Reza Pratama',
      'specialty': 'CrossFit & Cardio',
      'experience': '7 Tahun',
      'rating': 4.9,
      'reviews': 210,
      'image': 'https://via.placeholder.com/150',
      'about': 'Reza fokus pada latihan intensitas tinggi (HIIT) dan fungsional. Sangat cocok bagi yang ingin menurunkan berat badan dengan cepat namun tetap bugar.',
      'availableSchedules': ['06:00', '17:00', '19:00'],
    }
  ];

  void selectTrainer(Map<String, dynamic> trainer) {
    selectedTrainer.value = trainer;
  }

  void bookSession(String time) {
    Get.snackbar(
      'Booking Berhasil',
      'Sesi dengan ${selectedTrainer.value!['name']} pada jam $time telah dipesan.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.back(); // kembali ke list
  }

  // --- Workout Plan ---
  final List<Map<String, dynamic>> workoutPlans = [
    {
      'day': 'Senin',
      'focus': 'Chest & Triceps',
      'exercises': [
        {'name': 'Bench Press', 'sets': '4', 'reps': '10'},
        {'name': 'Incline Dumbbell Press', 'sets': '3', 'reps': '12'},
        {'name': 'Tricep Pushdown', 'sets': '3', 'reps': '15'},
      ],
      'isCompleted': false,
    },
    {
      'day': 'Selasa',
      'focus': 'Back & Biceps',
      'exercises': [
        {'name': 'Lat Pulldown', 'sets': '4', 'reps': '12'},
        {'name': 'Barbell Row', 'sets': '3', 'reps': '10'},
        {'name': 'Bicep Curl', 'sets': '3', 'reps': '15'},
      ],
      'isCompleted': false,
    },
    {
      'day': 'Rabu',
      'focus': 'Rest',
      'exercises': [],
      'isCompleted': true,
    },
  ];

  // --- Workout Tracking ---
  var currentExerciseIndex = 0.obs;
  var currentSet = 1.obs;

  void logSet(String weight, String reps) {
    if (weight.isEmpty || reps.isEmpty) {
      Get.snackbar('Error', 'Berat dan repetisi harus diisi');
      return;
    }
    
    // Asumsi selesai set ini
    if (currentSet.value < 3) {
      currentSet.value++;
      Get.snackbar('Berhasil', 'Set ${currentSet.value - 1} dicatat!', snackPosition: SnackPosition.BOTTOM);
    } else {
      currentSet.value = 1;
      Get.snackbar('Selesai', 'Latihan ini selesai!', snackPosition: SnackPosition.BOTTOM);
      Get.back(); // Kembali setelah selesai 1 exercise
    }
  }
}
