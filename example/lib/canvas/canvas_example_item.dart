import 'package:flutter/widgets.dart';

/// 单个 Canvas 学习示例的元数据与页面构建器。
///
/// 在 [canvas_examples_registry.dart] 中登记新条目即可出现在「Canvas 学习」列表中。
class CanvasExampleItem {
  const CanvasExampleItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.builder,
  });

  /// 稳定标识，便于测试或深链接（可选）。
  final String id;

  /// 列表与 AppBar 上显示的标题。
  final String title;

  final String? subtitle;

  final WidgetBuilder builder;
}
