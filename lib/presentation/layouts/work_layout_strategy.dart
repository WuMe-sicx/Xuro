import 'package:flutter/material.dart';
import 'package:xuro/data/models/works/work.dart';
import 'package:xuro/presentation/layouts/work_layout_config.dart';

/// 作品布局策略
class WorkLayoutStrategy {
  const WorkLayoutStrategy();

  /// 获取设备类型
  DeviceType _getDeviceType(BuildContext context) {
    return DeviceType.fromWidth(MediaQuery.of(context).size.width);
  }

  /// 获取每行的列数
  int getColumnsCount(BuildContext context) {
    return WorkLayoutConfig.getColumnsCount(_getDeviceType(context));
  }

  /// 获取行间距
  double getRowSpacing(BuildContext context) {
    return WorkLayoutConfig.getSpacing(_getDeviceType(context));
  }

  /// 获取列间距
  double getColumnSpacing(BuildContext context) {
    return WorkLayoutConfig.getSpacing(_getDeviceType(context));
  }

  /// 获取内边距
  EdgeInsets getPadding(BuildContext context) {
    return WorkLayoutConfig.getPadding(_getDeviceType(context));
  }

  // 最近一次输入+输出 memo（规范 §7.3）。键 = works 引用 + 列数。
  // WorkLayoutStrategy 为 const 不可有实例可变状态，故用类级单槽缓存：
  // 同一 works 实例 + 同列数的重复 build 直接复用，换页/旋转→重算。
  static List<Work>? _memoWorks;
  static int? _memoCols;
  static List<List<Work>>? _memoRows;

  /// 将作品列表分组为行
  List<List<Work>> groupWorksIntoRows(List<Work> works, int columnsCount) {
    if (identical(_memoWorks, works) &&
        _memoCols == columnsCount &&
        _memoRows != null) {
      return _memoRows!;
    }
    final List<List<Work>> rows = [];
    for (var i = 0; i < works.length; i += columnsCount) {
      final end = i + columnsCount;
      rows.add(works.sublist(i, end > works.length ? works.length : end));
    }
    _memoWorks = works;
    _memoCols = columnsCount;
    _memoRows = rows;
    return rows;
  }
}
