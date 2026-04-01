import 'package:flutter_mind_map_example/canvas/canvas_example_item.dart';
import 'package:flutter_mind_map_example/canvas/demo1.dart';

/// 在此追加 Canvas 学习示例；保存文件后首页「Canvas 学习」列表会自动出现新条目。
List<CanvasExampleItem> get registeredCanvasExamples => <CanvasExampleItem>[
  CanvasExampleItem(
    id: 'canvas_basic_circle',
    title: '基础绘制：圆',
    subtitle: 'CustomPaint、CustomPainter 与简单 stroke',
    builder: (context) => const CanvasDemo1Page(),
  ),
  // 新建 demo 文件后在此添加一项，例如：
  // CanvasExampleItem(
  //   id: 'canvas_path_xxx',
  //   title: '路径与贝塞尔',
  //   subtitle: '...',
  //   builder: (context) => const CanvasDemoXxxPage(),
  // ),
];
