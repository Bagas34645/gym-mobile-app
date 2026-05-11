import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkin_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FaceRegisterView extends GetView<CheckinController> {
  const FaceRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text('Daftar Wajah', style: AppTextStyles.headingSmall),
        centerTitle: true,
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (controller.isUploadingFace.value) {
      return _buildUploadingState();
    }
    if (controller.captureStep.value >= CheckinController.totalCaptureSteps) {
      return _buildPreviewState();
    }
    return _buildCaptureState();
  }

  // ── Capture Mode ─────────────────────────────────────────────
  Widget _buildCaptureState() {
    final step = controller.captureStep.value;
    final instruction = controller.captureInstructions[step];
    final icon = controller.captureIcons[step];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            // ── Progress bar
            _buildProgressBar(step),
            const SizedBox(height: 32),

            // ── Face preview area
            Expanded(
              child: _buildFacePreviewArea(step, icon, instruction),
            ),
            const SizedBox(height: 32),

            // ── Captured thumbnails
            if (controller.capturedImages.isNotEmpty)
              _buildCapturedThumbnails(),

            const SizedBox(height: 24),

            // ── Capture button
            _buildCaptureButton(step),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Foto ${step + 1} dari ${CheckinController.totalCaptureSteps}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${((step / CheckinController.totalCaptureSteps) * 100).toInt()}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: step / CheckinController.totalCaptureSteps,
            backgroundColor: AppColors.surface2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        // Step indicators
        Row(
          children: List.generate(
            CheckinController.totalCaptureSteps,
            (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 4,
                decoration: BoxDecoration(
                  color: i < step
                      ? AppColors.success
                      : i == step
                          ? AppColors.accent
                          : AppColors.surface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacePreviewArea(int step, IconData icon, String instruction) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera viewfinder simulation
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface2,
              border: Border.all(
                color: AppColors.accent.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corner brackets
                ..._buildCornerBrackets(),
                // Icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Icon(
                    icon,
                    key: ValueKey(step),
                    size: 80,
                    color: AppColors.accent.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Instruction
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              instruction,
              key: ValueKey(step),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan wajah terlihat jelas dan pencahayaan cukup',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 20.0;
    const thickness = 2.0;
    const color = AppColors.accent;
    const offset = 15.0;

    return [
      // Top-left
      Positioned(
        top: offset,
        left: offset,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        top: offset,
        right: offset,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: offset,
        left: offset,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: offset,
        right: offset,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildCapturedThumbnails() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.capturedImages.length,
        separatorBuilder: (_, _s) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success, width: 2),
              image: DecorationImage(
                image: FileImage(controller.capturedImages[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.check_circle, color: AppColors.success, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptureButton(int step) {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.isCapturing.value ? null : controller.captureNextImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.isCapturing.value
                  ? AppColors.surface2
                  : AppColors.accent,
              boxShadow: controller.isCapturing.value
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
            ),
            child: controller.isCapturing.value
                ? const CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  )
                : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tekan untuk mengambil foto',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  // ── Preview Mode (all 5 captured) ────────────────────────────
  Widget _buildPreviewState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5 Foto Berhasil Diambil!',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          'Tinjau foto sebelum mendaftar',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Hasil Foto', style: AppTextStyles.headingSmall),
            const SizedBox(height: 16),

            // 5 photo grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: controller.capturedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          controller.capturedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Label overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            'Foto ${index + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.retakeImages,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Ulangi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize: const Size(0, 56),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: controller.uploadFaceImages,
                    icon: const Icon(Icons.upload, size: 18, color: Colors.white),
                    label: Text(
                      'Daftarkan Wajah',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minimumSize: const Size(0, 56),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Uploading State ──────────────────────────────────────────
  Widget _buildUploadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Mendaftarkan Wajah...',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Sistem sedang memproses data wajah Anda.\nMohon tunggu sebentar.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
