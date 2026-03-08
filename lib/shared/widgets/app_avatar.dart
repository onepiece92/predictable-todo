import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String avatar;
  final double size;
  final double fontSize;

  const AppAvatar({
    super.key,
    required this.avatar,
    this.size = 40,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isUrl = avatar.startsWith('http');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: isUrl
            ? Image.network(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.person,
                    size: size * 0.6, color: AppColors.subtle),
              )
            : Text(
                avatar,
                style: TextStyle(fontSize: fontSize),
              ),
      ),
    );
  }
}
