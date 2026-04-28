import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Section header with spaced uppercase text and horizontal line
class SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionHeader({
    super.key,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.textSecondary;

    return Row(
      children: [
        Text(
          title.split('').join(' '),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: color != null ? textColor.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
      ],
    );
  }
}
