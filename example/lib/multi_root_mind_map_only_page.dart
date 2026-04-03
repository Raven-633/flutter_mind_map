import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/mind_map_node.dart';

/// 多根节点示例：仅 [MapType.mind]（思维导图），全屏画布、无调试工具条。
class MultiRootMindMapOnlyPage extends StatefulWidget {
  const MultiRootMindMapOnlyPage({super.key});

  @override
  State<MultiRootMindMapOnlyPage> createState() =>
      _MultiRootMindMapOnlyPageState();
}

class _MultiRootMindMapOnlyPageState extends State<MultiRootMindMapOnlyPage> {
  final MindMap _mindMap = MindMap();

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  void _initMap() {
    _mindMap.setMapType(MapType.mind);
    _mindMap.setMindMapPadding(0);

    for (final node in _mindMap.getRootNodes().toList()) {
      _mindMap.removeRootNode(node);
    }

    final MindMapNode rootA = MindMapNode()
      ..setTitle('主题 A')
      ..setBackgroundColor(Colors.blue.shade50)
      ..setPadding(const EdgeInsets.symmetric(horizontal: 18, vertical: 10));

    rootA.addRightItem(MindMapNode()..setTitle('要点 A1'));
    rootA.addRightItem(MindMapNode()..setTitle('要点 A2'));
    rootA.addLeftItem(MindMapNode()..setTitle('要点 A−1'));

    final MindMapNode rootB = MindMapNode()
      ..setTitle('主题 B')
      ..setBackgroundColor(Colors.green.shade50)
      ..setPadding(const EdgeInsets.symmetric(horizontal: 18, vertical: 10));

    rootB.addRightItem(MindMapNode()..setTitle('要点 B1'));
    rootB.addRightItem(MindMapNode()..setTitle('要点 B2'));

    // 多根且未 setOffset：原点在视口中心，偏移为各根子树包围盒中心。
    _mindMap.addRootNode(rootA, canvasOffset: const Offset(-120, -40));
    _mindMap.addRootNode(rootB, canvasOffset: const Offset(140, 60));

    _mindMap.setOffset(Offset.zero);
    _mindMap.setZoom(1.0);
    // 必须为 true，否则 MindMap.applyWheelZoom* 会直接 return，鼠标滚轮无法缩放画布。
    // 同时为 true 时允许在画布上平移/捏合缩放（InteractiveViewer）。
    _mindMap.setCanMove(true);
    _mindMap.setCanMoveRootNodes(true);
    _mindMap.setEnableNodeReparentOnDrag(true);
    _mindMap.setHasTextField(false);
    _mindMap.setHasEditButton(true);
    _mindMap.setShowRecycle(false);
    _mindMap.setReadOnly(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多根思维导图')),
      body: Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            _mindMap.applyWheelZoomAtGlobal(
              event.position,
              event.scrollDelta.dy,
            );
          }
        },
        child: ColoredBox(color: Colors.white, child: _mindMap),
      ),
    );
  }
}
