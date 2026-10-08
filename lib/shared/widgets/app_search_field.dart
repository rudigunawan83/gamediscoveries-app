import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.onChanged,
    this.onTap,
    this.onClear,
    this.readOnly = false,
    this.autofocus = false,
    this.hint = 'Search games...',
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool autofocus;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final clear = onClear;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        suffixIcon: clear == null
            ? const Icon(Icons.tune_rounded, color: AppColors.textSecondary)
            : IconButton(
                tooltip: 'Clear search',
                onPressed: clear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}
