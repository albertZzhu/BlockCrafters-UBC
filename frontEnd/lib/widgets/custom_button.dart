import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

enum ButtonStyleType {
  primary,
  white,
  orange,
  navy,
  grey,
  skyblue,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyleType styleType;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.styleType = ButtonStyleType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final Map<ButtonStyleType, Color> bgColors = {
      ButtonStyleType.primary: const Color(0xFF1E2A58),
      ButtonStyleType.white: Colors.white,
      ButtonStyleType.orange: AppColors.orange,
      ButtonStyleType.navy: AppColors.navy,
      ButtonStyleType.grey: const Color.fromARGB(32, 202, 204, 205),
      ButtonStyleType.skyblue: AppColors.skyBlue,
    };

    final Map<ButtonStyleType, Color> textColors = {
      ButtonStyleType.primary: Colors.white,
      ButtonStyleType.white: AppColors.orange,
      ButtonStyleType.orange: Colors.white,
      ButtonStyleType.navy: Colors.white,
      ButtonStyleType.grey: AppColors.orange,
      ButtonStyleType.skyblue: Colors.white,
    };

    final Color baseBg = bgColors[styleType]!;
    final Color baseFg = textColors[styleType]!;

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return baseBg.withOpacity(0.85); // Slight lighten on hover
          }
          return baseBg;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((_) => baseFg),
        overlayColor: WidgetStateProperty.all(Colors.transparent), // disable ripple
        elevation: WidgetStateProperty.all(0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
