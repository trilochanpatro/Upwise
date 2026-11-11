import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class UpwiseCard extends StatelessWidget {
  const UpwiseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: borderColor, width: 1),
    );

    final inner = Padding(
      padding: padding,
      child: child,
    );

    return Material(
      color: backgroundColor,
      shape: borderShape,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              customBorder: borderShape,
              onTap: onTap,
              child: inner,
            )
          : inner,
    );
  }
}
