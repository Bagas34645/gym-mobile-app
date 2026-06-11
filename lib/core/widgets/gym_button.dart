import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, danger }

class GymButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;

  const GymButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    switch (type) {
      case ButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = AppColors.accent;
        borderSide = const BorderSide(color: AppColors.accent);
        break;
      case ButtonType.danger:
        backgroundColor = Colors.transparent;
        textColor = AppColors.error;
        borderSide = const BorderSide(color: AppColors.error);
        break;
      case ButtonType.primary:
        backgroundColor = AppColors.accent;
        textColor = Colors.white;
        borderSide = BorderSide.none;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: borderSide,
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.button.copyWith(color: textColor),
              ),
      ),
    );
  }
}
