import 'package:flutter_mind_map_example/canvas/canvas_example_item.dart';
import 'package:flutter_mind_map_example/canvas/demo1.dart';
import 'package:flutter_mind_map_example/canvas/multi_card_canvas.dart';

/// 在此追加 Canvas 学习示例；保存文件后首页「Canvas 学习」列表会自动出现新条目。
List<CanvasExampleItem> get registeredCanvasExamples => <CanvasExampleItem>[
  CanvasExampleItem(
    id: 'canvas_basic_circle',
    title: '基础绘制：圆',
    subtitle: 'CustomPaint、CustomPainter 与简单 stroke',
    builder: (context) => const CanvasDemo1Page(),
  ),
  CanvasExampleItem(
    id: 'multi_card_canvas',
    title: '多卡片画布',
    subtitle: 'InteractiveViewer 缩放（以鼠标为中心） + 长按拖拽卡片',
    builder: (context) => const MultiCardCanvasPage(),
  ),
  // 新建 demo 文件后在此添加一项，例如：
  // CanvasExampleItem(
  //   id: 'canvas_path_xxx',
  //   title: '路径与贝塞尔',
  //   subtitle: '...',
  //   builder: (context) => const CanvasDemoXxxPage(),
  // ),
];
