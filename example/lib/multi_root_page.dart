import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/mind_map.dart';
import 'package:flutter_mind_map/mind_map_node.dart';

class MultiRootPage extends StatefulWidget {
  MultiRootPage({super.key});
  final MindMap mindMap = MindMap();

  @override
  State<MultiRootPage> createState() => _MultiRootPageState();
}

class _MultiRootPageState extends State<MultiRootPage> {
  @override
  void initState() {
    super.initState();
    _initMultiRootMindMap();
  }

  void _initMultiRootMindMap() {
    // 1. 清理掉组件默认创建的隐含根节点（如果存在的话）
    List<IMindMapNode> existingRoots = widget.mindMap.getRootNodes().toList();
    for (var node in existingRoots) {
      widget.mindMap.removeRootNode(node);
    }

    // 2. 创建第一个根节点 (Root 1) 及子树
    MindMapNode root1 = MindMapNode()
      ..setTitle("核心概念")
      ..setBackgroundColor(Colors.blue.shade100)
      ..setPadding(const EdgeInsets.symmetric(horizontal: 20, vertical: 10));

    MindMapNode child1_Right = MindMapNode()..setTitle("分支 A1");
    root1.addRightItem(child1_Right);

    MindMapNode child1_Left = MindMapNode()..setTitle("分支 A2");
    root1.addLeftItem(child1_Left);

    widget.mindMap.addRootNode(root1, canvasOffset: const Offset(-200, -100));

    // 3. 创建第二个根节点 (Root 2) 及子树
    MindMapNode root2 = MindMapNode()
      ..setTitle("核心概念")
      ..setBackgroundColor(Colors.green.shade100)
      ..setPadding(const EdgeInsets.symmetric(horizontal: 20, vertical: 10));

    MindMapNode child2_1 = MindMapNode()..setTitle("子模块 B1");
    root2.addRightItem(child2_1);

    MindMapNode child2_2 = MindMapNode()..setTitle("子模块 B2");
    root2.addRightItem(child2_2);

    widget.mindMap.addRootNode(root2, canvasOffset: const Offset(200, 150));

    // 4. 配置 MindMap 组件的一些常用交互属性
    widget.mindMap.setZoom(1.0);
    widget.mindMap.setCanMove(true);
    widget.mindMap.setHasTextField(false);
    widget.mindMap.setHasEditButton(true);
    widget.mindMap.setShowRecycle(false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white, child: widget.mindMap);
  }
}
