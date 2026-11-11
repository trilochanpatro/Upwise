import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class UpwiseLogo extends StatelessWidget {
  const UpwiseLogo({
    super.key,
    this.size = 32,
    this.borderRadius = 9,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/images/upwise_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
