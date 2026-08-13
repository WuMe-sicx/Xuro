/// home_greeting_test.dart：HomeGreeting 纯逻辑——四个时段边界 + 日期/星期
/// kicker 格式化，锁定分支不被后续改动误改。
///
/// @author  Elvis Juan (thanhtran0606en@gmail.com)
/// @created 2026-08-13
import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/common/constants/strings.dart';
import 'package:xuro/widgets/home/home_greeting.dart';

void main() {
  group('四个时段边界', () {
    final cases = <(DateTime, DayPeriod, String)>[
      (DateTime(2026, 8, 13, 0), DayPeriod.lateNight, Strings.greetingLateNight),
      (DateTime(2026, 8, 13, 4, 59), DayPeriod.lateNight, Strings.greetingLateNight),
      (DateTime(2026, 8, 13, 5), DayPeriod.morning, Strings.greetingMorning),
      (DateTime(2026, 8, 13, 10, 59), DayPeriod.morning, Strings.greetingMorning),
      (DateTime(2026, 8, 13, 11), DayPeriod.afternoon, Strings.greetingAfternoon),
      (DateTime(2026, 8, 13, 17, 59), DayPeriod.afternoon, Strings.greetingAfternoon),
      (DateTime(2026, 8, 13, 18), DayPeriod.evening, Strings.greetingEvening),
      (DateTime(2026, 8, 13, 23, 59), DayPeriod.evening, Strings.greetingEvening),
    ];
    for (final (now, period, line1) in cases) {
      test('${now.hour}:${now.minute} → $period', () {
        final g = HomeGreeting.of(now);
        expect(g.period, period);
        expect(g.greetingLine1, line1);
      });
    }
  });

  test('kicker 格式：M月D日 · 周X + 时段后缀', () {
    // 2026-08-13 是周四。
    final g = HomeGreeting.of(DateTime(2026, 8, 13, 20));
    expect(g.kicker(DateTime(2026, 8, 13, 20)), '8月13日 · 周四晚');
  });

  test('深夜/凌晨的问候第二行走"睡前"文案，非默认"今天"', () {
    final g = HomeGreeting.of(DateTime(2026, 8, 13, 1));
    expect(g.greetingLine2, Strings.greetingPromptLateNight);
  });
}
