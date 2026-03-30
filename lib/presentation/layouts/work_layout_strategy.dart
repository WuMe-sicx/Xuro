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

  /// 将作品列表分组为行
  List<List<Work>> groupWorksIntoRows(List<Work> works, int columnsCount) {
    final List<List<Work>> rows = [];
    for (var i = 0; i < works.length; i += columnsCount) {
      final end = i + columnsCount;
      rows.add(works.sublist(i, end > works.length ? works.length : end));
    }
    return rows;
  }
}
