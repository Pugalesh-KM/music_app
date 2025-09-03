
import 'package:flutter/material.dart';
import 'package:music_app/shared/config/dimens.dart';
import 'package:music_app/shared/theme/app_colors.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(
        strokeWidth: Dimens.standard_4,
        valueColor: AlwaysStoppedAnimation(AppColors.success),
      ),
    );
  }
}
