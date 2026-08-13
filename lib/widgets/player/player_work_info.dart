import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/core/audio/models/playback_context.dart';
import 'package:xuro/core/theme/app_spacing.dart';
import 'package:xuro/core/theme/app_text_styles.dart';

/// 播放器「副标」区：作品名（跑马灯）+ 声优名。Modernist 三段式曲目信息
/// （kicker/曲名/副标）里最不显眼的一层，前两段（社团名 kicker、曲目大标题）
/// 由 `PlayerScreen` 直接渲染在这个组件上方。
class PlayerWorkInfo extends StatelessWidget {
  final PlaybackContext? context;

  const PlayerWorkInfo({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        0,
        AppSpacing.space16,
        AppSpacing.space8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppTextStyles.bodyMedium.fontSize! * 1.5,
            child: Marquee(
              text: this.context?.work.title ?? Strings.unknownWork,
              style: AppTextStyles.bodyMedium.copyWith(color: mutedColor),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 50.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            this
                    .context
                    ?.work
                    .vas
                    ?.map((va) => va['name'] as String?)
                    .where((name) => name != null)
                    .join('、') ??
                Strings.unknownArtist,
            style: AppTextStyles.caption.copyWith(color: mutedColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
