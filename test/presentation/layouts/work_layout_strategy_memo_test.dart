import 'package:flutter_test/flutter_test.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_strategy.dart';

/// 规范 §7.3 memo：groupWorksIntoRows 同输入(works 引用+列数)命中缓存，
/// 返回同一 List 实例（跳过重算）；输入变化则重算。
void main() {
  const s = WorkLayoutStrategy();

  test('分组正确性：按列数切行，末行可不足', () {
    final works = List.generate(5, (_) => Work());
    final rows = s.groupWorksIntoRows(works, 2);
    expect(rows.length, 3);
    expect(rows[0].length, 2);
    expect(rows[1].length, 2);
    expect(rows[2].length, 1);
  });

  test('同 works 实例 + 同列数 → memo 命中，返回同一实例', () {
    final works = List.generate(8, (_) => Work());
    final r1 = s.groupWorksIntoRows(works, 3);
    final r2 = s.groupWorksIntoRows(works, 3);
    expect(identical(r1, r2), isTrue, reason: 'memo 命中应复用同一输出实例');
  });

  test('列数变化 → 重算（非同一实例，内容正确）', () {
    final works = List.generate(6, (_) => Work());
    final r2col = s.groupWorksIntoRows(works, 2);
    final r3col = s.groupWorksIntoRows(works, 3);
    expect(identical(r2col, r3col), isFalse);
    expect(r3col.length, 2);
    expect(r3col[0].length, 3);
  });

  test('works 实例变化（换页）→ 重算', () {
    final pageA = List.generate(4, (_) => Work());
    final pageB = List.generate(4, (_) => Work());
    final ra = s.groupWorksIntoRows(pageA, 2);
    final rb = s.groupWorksIntoRows(pageB, 2);
    expect(identical(ra, rb), isFalse);
    // 回到 pageA 实例：由于单槽 memo 已被 pageB 覆盖，重算但内容仍正确
    final ra2 = s.groupWorksIntoRows(pageA, 2);
    expect(ra2.length, 2);
    expect(ra2[0].length, 2);
  });
}
