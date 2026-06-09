import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onMore;

  const SectionHeader({super.key, required this.title, this.subtitle, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (onMore != null)
            TextButton(
              onPressed: onMore,
              child: const Text('عرض الكل ←', style: TextStyle(fontFamily: 'Cairo', color: AppColors.gold, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}
