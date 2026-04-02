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
  bool _canMoveMap = true;
  bool _canMoveRoots = true;
  int _doubleTapCount = 0;
  int _mapTapCount = 0;
  int _pointerDownCount = 0;

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

    widget.mindMap.addOnDoubleTapListeners((node) {
      setState(() {
        _doubleTapCount++;
      });
      debugPrint("双击节点: title=${node.getTitle()}, id=${node.getID()}");
    });
    widget.mindMap.addOnTapListeners(() {
      setState(() {
        _mapTapCount++;
      });
      debugPrint("[multi_root_page] mindMap onTap");
    });

    // 2. 创建第一个根节点 (Root 1) 及子树
    MindMapNode root1 = MindMapNode()
      ..setTitle("核心概念")
      ..setBackgroundColor(Colors.blue.shade100)
      ..setPadding(const EdgeInsets.symmetric(horizontal: 20, vertical: 10));

    MindMapNode child1_Right = MindMapNode()..setTitle("分支 A1");
    root1.addRightItem(child1_Right);

    MindMapNode child1_Left = MindMapNode()..setTitle("分支 A2");
    root1.addRightItem(child1_Left);

    widget.mindMap.addRootNode(root1, canvasOffset: const Offset(300, 200));

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
    widget.mindMap.setCanMove(_canMoveMap);
    widget.mindMap.setCanMoveRootNodes(_canMoveRoots);
    widget.mindMap.setHasTextField(false);
    widget.mindMap.setHasEditButton(true);
    widget.mindMap.setShowRecycle(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Material(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("画布可移动"),
                      Switch(
                        value: _canMoveMap,
                        onChanged: (v) {
                          setState(() {
                            _canMoveMap = v;
                          });
                          widget.mindMap.setCanMove(v);
                          debugPrint("测试开关: setCanMove($v)");
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("根节点可拖拽"),
                      Switch(
                        value: _canMoveRoots,
                        onChanged: (v) {
                          setState(() {
                            _canMoveRoots = v;
                          });
                          widget.mindMap.setCanMoveRootNodes(v);
                          debugPrint("测试开关: setCanMoveRootNodes($v)");
                        },
                      ),
                    ],
                  ),
                  Text("doubleTap触发次数: $_doubleTapCount"),
                  Text("map onTap触发次数: $_mapTapCount"),
                  Text("pointerDown次数: $_pointerDownCount"),
                ],
              ),
            ),
          ),
          Expanded(
            child: Listener(
              onPointerDown: (event) {
                setState(() {
                  _pointerDownCount++;
                });
                debugPrint(
                  "[multi_root_page] pointerDown local=${event.localPosition}",
                );
              },
              child: Container(color: Colors.white, child: widget.mindMap),
            ),
          ),
        ],
      ),
    );
  }
}
