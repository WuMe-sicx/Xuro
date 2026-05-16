import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';

/// 圆角搜索框（首页 / 浏览页通用）。规范 §2.2。
///
/// Full 圆角 + Surface L2 中性底（不随配色变化），无可见描边。
/// API 是 `BrowseSearchBar` 的超集，Phase D 可平滑替换后者。
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// 只读 + [onTap]：搜索框作为导航触发器（点击跳转到搜索页），
  /// 不在原地编辑。用于首页（对齐参考图）。
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      readOnly: readOnly,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceL2(brightness),
        hintText: hintText,
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space12,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.fullAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.fullAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.fullAll,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
