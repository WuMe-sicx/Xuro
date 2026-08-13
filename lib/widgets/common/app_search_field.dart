import 'package:flutter/material.dart';
import 'package:xuro/core/theme/app_colors.dart';
import 'package:xuro/core/theme/app_radius.dart';
import 'package:xuro/core/theme/app_spacing.dart';

/// 圆角搜索框（首页 / 浏览页通用）。规范 §2.2。
///
/// Full 圆角 + Surface L2 中性底（不随配色变化），无可见描边。
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.onClear,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// 只读 + [onTap]：搜索框作为导航触发器（点击跳转到搜索页），
  /// 不在原地编辑。用于首页（对齐参考图）。
  final bool readOnly;
  final VoidCallback? onTap;

  /// 非空时，输入非空才显示尾部清除按钮；点击后清空输入并回调。
  final VoidCallback? onClear;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  // 调用方未传 controller 时才自建：TextField 内部编辑状态需要一个
  // Listenable 驱动清除按钮的显隐，StatelessWidget 拿不到这个通知。
  TextEditingController? _ownedController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceL2(brightness),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
        suffixIcon: widget.onClear == null
            ? null
            : ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                    onPressed: () {
                      // controller.clear() 只更新文本、不会触发 onChanged
                      // （Flutter 该回调只在用户输入时触发），显式回调
                      // onClear 让调用方同步重置自己的过滤状态。
                      _controller.clear();
                      widget.onClear!();
                    },
                  );
                },
              ),
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
