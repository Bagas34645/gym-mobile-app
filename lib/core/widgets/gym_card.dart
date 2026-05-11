import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GymCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  const GymCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: highlighted
            ? const Border(
                left: BorderSide(color: AppColors.accent, width: 4),
              )
            : null,
      ),
      child: child,
    );
  }
}
