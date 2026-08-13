/// home_greeting.dart：发现首页顶部的时段问候语与日期 kicker——纯客户端计算，
/// 不依赖任何网络/本地数据源（设计稿 01 要求「按时段切换问候语」）。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:xuro/common/constants/strings.dart';

/// 一天中的四个时段——早（5-11 点）/ 午（11-18 点）/ 晚（18-24 点）/
/// 深夜（0-5 点），边界为业务约定值，非接口/协议给定。
enum DayPeriod { morning, afternoon, evening, lateNight }

/// 某一时刻对应的问候文案组合。用工厂方法而非直接读 `DateTime.now()`，
/// 便于单测按固定时间覆盖四个时段边界。
class HomeGreeting {
  final DayPeriod period;

  /// 拼进日期 kicker 的时段后缀，如「晚」（例：「8月13日 · 周四晚」）。
  final String kickerSuffix;

  /// 问候语第一行，如「晚上好，」。
  final String greetingLine1;

  /// 问候语第二行，如「今晚想听点什么？」。
  final String greetingLine2;

  const HomeGreeting._({
    required this.period,
    required this.kickerSuffix,
    required this.greetingLine1,
    required this.greetingLine2,
  });

  static const _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

  factory HomeGreeting.of(DateTime now) {
    switch (_periodOf(now.hour)) {
      case DayPeriod.lateNight:
        return const HomeGreeting._(
          period: DayPeriod.lateNight,
          kickerSuffix: Strings.dayPeriodLateNight,
          greetingLine1: Strings.greetingLateNight,
          greetingLine2: Strings.greetingPromptLateNight,
        );
      case DayPeriod.morning:
        return const HomeGreeting._(
          period: DayPeriod.morning,
          kickerSuffix: Strings.dayPeriodMorning,
          greetingLine1: Strings.greetingMorning,
          greetingLine2: Strings.greetingPromptDefault,
        );
      case DayPeriod.afternoon:
        return const HomeGreeting._(
          period: DayPeriod.afternoon,
          kickerSuffix: Strings.dayPeriodAfternoon,
          greetingLine1: Strings.greetingAfternoon,
          greetingLine2: Strings.greetingPromptDefault,
        );
      case DayPeriod.evening:
        return const HomeGreeting._(
          period: DayPeriod.evening,
          kickerSuffix: Strings.dayPeriodEvening,
          greetingLine1: Strings.greetingEvening,
          greetingLine2: Strings.greetingPromptEvening,
        );
    }
  }

  static DayPeriod _periodOf(int hour) {
    if (hour < 5) return DayPeriod.lateNight;
    if (hour < 11) return DayPeriod.morning;
    if (hour < 18) return DayPeriod.afternoon;
    return DayPeriod.evening;
  }

  /// 「8月13日 · 周四晚」。不引入 intl 依赖——纯数字拼接足够，且项目未声明该包。
  String kicker(DateTime now) {
    final weekday = _weekdays[now.weekday - 1];
    return '${now.month}月${now.day}日 · 周$weekday$kickerSuffix';
  }
}
