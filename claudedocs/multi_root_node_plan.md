# 多根节点功能实现计划

> 版本：v1.0
> 日期：2026-03-31
> 基准版本：flutter_mind_map v1.1.2

---

## 一、需求确认

| 需求项 | 决策 |
|--------|------|
| 布局方式 | 自由定位：每个根节点有独立画布坐标，可拖动 |
| 根节点间连线 | 支持跨树关联线（Cross-Link） |
| 根节点删除 | 可拖入回收站，连同子树一起删除 |
| 子节点跨树拖拽 | 允许，拖入其他树的任意节点下 |
| 鱼骨图支持 | 不支持多根（鱼骨图语义不兼容），多根模式下禁用切换 |
| 向后兼容 | fromJson 同时识别旧 RootNode / 新 RootNodes 字段 |

---

## 二、架构变更总览

### 2.1 核心数据结构变化

```
旧：
  MindMap
    └── _rootNode: IMindMapNode

新：
  MindMap
    ├── _rootNodes: List<IMindMapNode>          ← 根节点列表
    ├── _rootNodeCanvasOffsets: Map<String, Offset>  ← 每个根节点的画布坐标（key=nodeID）
    └── _crossLinks: List<CrossLinkInfo>        ← 跨树关联线列表（新）
```

### 2.2 新增文件

```
lib/
└── cross_link/
    ├── cross_link_info.dart     # 跨树连线数据模型
    └── cross_link_painter.dart  # 跨树连线绘制器（CustomPainter）
```

### 2.3 修改文件

| 文件 | 修改性质 | 预计改动行数 |
|------|---------|------------|
| `lib/mind_map.dart` | 重构核心字段与方法 | ~400 行 |
| `lib/mind_map_node.dart` | 根节点拖动、NodeType判定 | ~80 行 |
| `lib/i_mind_map_node.dart` | 无需改动 | 0 |

---

## 三、分阶段任务

---

### Phase 1：数据模型重构
**目标**：将单根节点数据结构替换为根节点列表，保持向后兼容

#### Task 1.1 替换 `_rootNode` 为 `_rootNodes`

**文件**：`lib/mind_map.dart`

```dart
// 删除
IMindMapNode _rootNode = MindMapNode();

// 新增
final List<IMindMapNode> _rootNodes = [];
final Map<String, Offset> _rootNodeCanvasOffsets = {};

// 保留旧 API 兼容层（委托到第一个根节点）
IMindMapNode getRootNode() => _rootNodes.isNotEmpty
    ? _rootNodes.first
    : _createDefaultRootNode();

void setRootNode(IMindMapNode node) {
  if (_rootNodes.isEmpty) {
    addRootNode(node, canvasOffset: Offset.zero);
  } else {
    replaceRootNode(_rootNodes.first, node);
  }
}
```

#### Task 1.2 新增多根节点管理 API

**文件**：`lib/mind_map.dart`

```dart
/// 获取所有根节点
List<IMindMapNode> getRootNodes() => List.unmodifiable(_rootNodes);

/// 添加根节点，canvasOffset 为其在画布上的初始位置
void addRootNode(IMindMapNode node, {Offset canvasOffset = Offset.zero}) {
  _rootNodes.add(node);
  node.setNodeType(NodeType.root);
  node.setMindMap(this);
  _rootNodeCanvasOffsets[node.getID()] = canvasOffset;
  onRootNodeChanged();
  onChanged();
}

/// 删除根节点（连同子树）
void removeRootNode(IMindMapNode node) {
  _rootNodes.remove(node);
  _rootNodeCanvasOffsets.remove(node.getID());
  onRootNodeChanged();
  onChanged();
}

/// 获取某根节点的画布坐标
Offset getRootNodeCanvasOffset(IMindMapNode node) =>
    _rootNodeCanvasOffsets[node.getID()] ?? Offset.zero;

/// 设置某根节点的画布坐标（拖动时调用）
void setRootNodeCanvasOffset(IMindMapNode node, Offset offset) {
  _rootNodeCanvasOffsets[node.getID()] = offset;
  onChanged();
}
```

---

### Phase 2：新增 CrossLink 数据结构

**目标**：支持跨树节点间的关联连线

#### Task 2.1 创建 `CrossLinkInfo`

**文件**：`lib/cross_link/cross_link_info.dart`

```dart
class CrossLinkInfo {
  final String id;             // UUID
  final String fromNodeId;     // 起点节点 ID
  final String toNodeId;       // 终点节点 ID
  Color color;
  double width;
  String? label;               // 关联线上的文字说明（可选）

  CrossLinkInfo({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.color = Colors.grey,
    this.width = 1.5,
    this.label,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromNodeId': fromNodeId,
    'toNodeId': toNodeId,
    'color': colorToString(color),
    'width': width,
    'label': label ?? '',
  };

  factory CrossLinkInfo.fromJson(Map<String, dynamic> json) => CrossLinkInfo(
    id: json['id'],
    fromNodeId: json['fromNodeId'],
    toNodeId: json['toNodeId'],
    color: stringToColor(json['color'] ?? '#ff888888'),
    width: double.tryParse(json['width'].toString()) ?? 1.5,
    label: json['label'],
  );
}
```

#### Task 2.2 在 `MindMap` 中管理 CrossLinks

**文件**：`lib/mind_map.dart`

```dart
final List<CrossLinkInfo> _crossLinks = [];

List<CrossLinkInfo> getCrossLinks() => List.unmodifiable(_crossLinks);

void addCrossLink(CrossLinkInfo link) {
  _crossLinks.add(link);
  refresh();
  onChanged();
}

void removeCrossLink(String linkId) {
  _crossLinks.removeWhere((l) => l.id == linkId);
  refresh();
  onChanged();
}

/// 通过节点ID在所有根节点树中查找节点
IMindMapNode? findNodeById(String id) {
  for (IMindMapNode root in _rootNodes) {
    IMindMapNode? result = _findInTree(root, id);
    if (result != null) return result;
  }
  return null;
}

IMindMapNode? _findInTree(IMindMapNode node, String id) {
  if (node.getID() == id) return node;
  for (IMindMapNode child in [...node.getLeftItems(), ...node.getRightItems()]) {
    IMindMapNode? r = _findInTree(child, id);
    if (r != null) return r;
  }
  return null;
}
```

---

### Phase 3：渲染层重构

**目标**：`MindMapState.build()` 中将多个根节点分别渲染为独立的 Positioned Widget，并在 CustomPainter 中绘制跨树连线

#### Task 3.1 重构 `build()` 中根节点渲染

**文件**：`lib/mind_map.dart` → `MindMapState.build()`

**当前**：
```dart
// Stack 中只有一个根节点 Widget
child: widget.getRootNode() as Widget,
```

**修改为**：
```dart
// Stack 中为每个根节点生成独立的 Positioned
Stack(
  children: [
    // 背景 CustomPainter（负责所有连线 + 跨树关联线）
    Positioned.fill(
      child: CustomPaint(
        painter: MultiRootMindMapPainter(mindMap: widget),
      ),
    ),
    // 每个根节点独立定位
    ...widget.getRootNodes().map((rootNode) {
      Offset canvasOffset = widget.getRootNodeCanvasOffset(rootNode);
      return Positioned(
        left: canvasOffset.dx,
        top: canvasOffset.dy,
        child: _RootNodeDragWrapper(
          mindMap: widget,
          rootNode: rootNode,
          child: rootNode as Widget,
        ),
      );
    }),
    // 水印、工具栏等叠加层保持不变
    ...
  ],
)
```

#### Task 3.2 新增 `_RootNodeDragWrapper`

根节点的"画布拖动"需要与"子节点的树内拖动"**区分**：

- **子节点拖动**：通过现有的 `Draggable` 机制，改变节点在树中的位置
- **根节点画布拖动**：长按根节点本身，拖动整棵树在画布上移动

```dart
class _RootNodeDragWrapper extends StatelessWidget {
  final MindMap mindMap;
  final IMindMapNode rootNode;
  final Widget child;

  // 长按触发根节点画布拖动
  // GestureDetector.onLongPressMoveUpdate → 更新 canvasOffset
  // 普通 tap / 子节点交互透传给 child
}
```

**注意**：根节点本身的 `NodeType.root` 判定逻辑不变，只是画布坐标由 `_rootNodeCanvasOffsets` 管理。

#### Task 3.3 新增 `MultiRootMindMapPainter`

替换原 `MindMapPainter`，增加跨树连线绘制：

```dart
class MultiRootMindMapPainter extends CustomPainter {
  final MindMap mindMap;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 绘制各根节点内的树形连线（复用原有逻辑，按根节点循环）
    for (IMindMapNode root in mindMap.getRootNodes()) {
      _paintTreeLinks(canvas, root);
    }

    // 2. 绘制跨树关联线
    for (CrossLinkInfo link in mindMap.getCrossLinks()) {
      _paintCrossLink(canvas, link);
    }

    // 3. 绘制拖拽预览虚线（原 MindMapPainter 逻辑）
    _paintDragPreview(canvas);
  }

  void _paintCrossLink(Canvas canvas, CrossLinkInfo link) {
    IMindMapNode? from = mindMap.findNodeById(link.fromNodeId);
    IMindMapNode? to = mindMap.findNodeById(link.toNodeId);
    if (from == null || to == null) return;

    // 获取两个节点的全局坐标，绘制贝塞尔曲线
    // 使用虚线或实线，颜色/宽度由 CrossLinkInfo 决定
    // 如有 label，在曲线中点绘制文字
  }
}
```

#### Task 3.4 视口居中计算改为包围盒中心

**文件**：`lib/mind_map.dart` → `MindMapState.build()`

原逻辑依赖单个 `getRootNode().getOffset()` 和 `getSize()`，修改为：

```dart
// 计算所有根节点的包围盒
Rect _calcBoundingBox() {
  double minX = double.infinity, minY = double.infinity;
  double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
  for (IMindMapNode root in widget.getRootNodes()) {
    Offset canvasOff = widget.getRootNodeCanvasOffset(root);
    Size? s = root.getSize();
    if (s != null) {
      minX = min(minX, canvasOff.dx);
      minY = min(minY, canvasOff.dy);
      maxX = max(maxX, canvasOff.dx + s.width);
      maxY = max(maxY, canvasOff.dy + s.height);
    }
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}
```

---

### Phase 4：交互重构

#### Task 4.1 拖拽目标搜索从单树改为全树

**文件**：`lib/mind_map.dart` → `MindMapState`

当前 `inLeftDrag` / `inRightDrag` 只从单根节点开始递归：
```dart
// 旧
IMindMapNode? inLeftDrag(...) =>
    inLeftDragByParentNode(node, offset, widget.getRootNode());
```

修改为遍历所有根节点：
```dart
// 新
IMindMapNode? inLeftDrag(IMindMapNode node, Offset offset) {
  for (IMindMapNode root in widget.getRootNodes()) {
    IMindMapNode? result = inLeftDragByParentNode(node, offset, root);
    if (result != null) return result;
  }
  return null;
}
```

**跨树拖拽后的处理**：节点从旧树移除后加入新树，`NodeType` 需要随目标树方向重置（left/right 由插入位置决定，已由现有 `insertLeftItem`/`insertRightItem` 保证）。

#### Task 4.2 回收站支持删除根节点

**文件**：`lib/mind_map.dart` → 回收站 `onAcceptWithDetails`

```dart
// 当前：只处理 NodeType != root 的节点
// 修改：增加 NodeType.root 分支

if (dragNode.getNodeType() == NodeType.root) {
  // 确认对话框（根节点删除影响整棵树）
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Text(widget.getDeleteNodeString()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text(widget.getCancelString())),
        TextButton(
          onPressed: () {
            widget.removeRootNode(dragNode);
            Navigator.pop(context);
          },
          child: Text(widget.getOkString()),
        ),
      ],
    ),
  );
}
```

#### Task 4.3 `refresh()` 改为刷新所有根节点

**文件**：`lib/mind_map.dart` → `MindMapState.refresh()`

```dart
void refresh() {
  if (mounted) {
    setState(() {
      for (IMindMapNode root in widget.getRootNodes()) {
        root.setOffset(null);
        root.setSize(null);
      }
    });
  }
}
```

---

### Phase 5：序列化重构

#### Task 5.1 `toJson()` 输出新格式

**文件**：`lib/mind_map.dart`

```dart
Map<String, dynamic> toJson() => {
  "MapType": getMapType().name,
  "MindMapType": getMindMapType().name,
  "FishboneMapType": getFishboneMapType().name,
  "Zoom": getZoom().toString(),
  "ExpandedLevel": getExpandedLevel(),
  "BackgroundColor": colorToString(getBackgroundColor()),
  "Theme": ...,
  // 新：根节点列表
  "RootNodes": getRootNodes().map((node) {
    Offset off = getRootNodeCanvasOffset(node);
    return {
      "canvasX": off.dx.toString(),
      "canvasY": off.dy.toString(),
      node.runtimeType.toString(): node.toJson(),
    };
  }).toList(),
  // 新：跨树关联线
  "CrossLinks": _crossLinks.map((l) => l.toJson()).toList(),
};
```

#### Task 5.2 `fromJson()` 兼容新旧格式

**文件**：`lib/mind_map.dart`

```dart
// 优先读新字段 RootNodes
if (json.containsKey("RootNodes")) {
  List<dynamic> rootsJson = json["RootNodes"];
  for (Map<String, dynamic> rootJson in rootsJson) {
    double cx = double.tryParse(rootJson["canvasX"] ?? "0") ?? 0;
    double cy = double.tryParse(rootJson["canvasY"] ?? "0") ?? 0;
    // 找到节点类型 key（排除 canvasX/canvasY）
    String nodeKey = rootJson.keys.firstWhere(
        (k) => k != "canvasX" && k != "canvasY");
    IMindMapNode? node = createNode(nodeKey);
    if (node != null) {
      addRootNode(node, canvasOffset: Offset(cx, cy));
      node.fromJson(rootJson[nodeKey]);
    }
  }
}
// 兼容旧字段 RootNode（单根节点旧格式）
else if (json.containsKey("RootNode")) {
  Map<String, dynamic> map = json["RootNode"];
  if (map.isNotEmpty) {
    IMindMapNode? node = createNode(map.keys.first);
    if (node != null) {
      addRootNode(node, canvasOffset: Offset.zero);
      node.fromJson(map);
    }
  }
}

// 加载跨树连线
if (json.containsKey("CrossLinks")) {
  for (Map<String, dynamic> linkJson in json["CrossLinks"]) {
    _crossLinks.add(CrossLinkInfo.fromJson(linkJson));
  }
}
```

#### Task 5.3 `getData()` / `loadData()` 同步更新

```dart
// getData() 新格式
Map<String, dynamic> getData() => {
  "roots": getRootNodes().map((n) {
    Offset off = getRootNodeCanvasOffset(n);
    return {
      "canvasX": off.dx,
      "canvasY": off.dy,
      ...n.getData(),
    };
  }).toList(),
  "crossLinks": _crossLinks.map((l) => l.toJson()).toList(),
};

// loadData() 新格式
void loadData(Map<String, dynamic> json) {
  if (json.containsKey("roots")) {
    for (Map<String, dynamic> r in json["roots"]) {
      MindMapNode node = MindMapNode();
      double cx = (r["canvasX"] as num?)?.toDouble() ?? 0;
      double cy = (r["canvasY"] as num?)?.toDouble() ?? 0;
      addRootNode(node, canvasOffset: Offset(cx, cy));
      node.loadData(r);
    }
  }
  // 兼容旧单根格式
  else if (json.containsKey("id")) {
    MindMapNode node = MindMapNode();
    addRootNode(node, canvasOffset: Offset.zero);
    node.loadData(json);
  }
}
```

---

### Phase 6：主题与样式

#### Task 6.1 `setTheme()` 应用到所有根节点

**文件**：`lib/mind_map.dart`

```dart
void setTheme(IMindMapTheme? value) {
  // 清除所有根节点样式
  for (IMindMapNode root in getRootNodes()) {
    root.clearStyle();
  }
  _theme = value;
  refresh();
  onChanged();
}
```

---

## 四、影响范围汇总

### 需要新增的 API（公开）

| API | 说明 |
|-----|------|
| `addRootNode(node, {canvasOffset})` | 添加根节点 |
| `removeRootNode(node)` | 删除根节点 |
| `getRootNodes()` | 获取所有根节点 |
| `getRootNodeCanvasOffset(node)` | 获取根节点画布坐标 |
| `setRootNodeCanvasOffset(node, offset)` | 设置根节点画布坐标 |
| `addCrossLink(link)` | 添加跨树关联线 |
| `removeCrossLink(id)` | 删除关联线 |
| `getCrossLinks()` | 获取所有关联线 |
| `findNodeById(id)` | 全树节点查找 |

### 保持不变的 API（兼容层）

| API | 兼容说明 |
|-----|---------|
| `getRootNode()` | 返回 `_rootNodes.first` |
| `setRootNode(node)` | 替换第一个根节点 |
| `getData()` | 新格式，但旧调用不报错 |
| `loadData(json)` | 兼容旧单根格式 |
| `toJson()` / `fromJson()` | 兼容旧 `RootNode` 字段 |

### 禁用的功能组合

| 场景 | 处理 |
|------|------|
| `setMapType(MapType.fishbone)` 在多根模式 | 抛出提示，不执行 |
| `setMindMapType()` | 不应用到所有根节点（各根节点独立） |

---

## 五、实施顺序与风险点

```
Phase 1 → Phase 5 → Phase 3 → Phase 4 → Phase 2 → Phase 6

推荐顺序说明：
- Phase 1+5 先行：数据结构和序列化稳定后，其他阶段才不会反复改动数据格式
- Phase 3 次之：渲染能跑通才能验证后续交互
- Phase 4：交互建立在渲染可见的基础上
- Phase 2（CrossLink）最后：依赖节点查找（findNodeById）能正确工作
```

### 主要风险点

| 风险 | 说明 | 缓解措施 |
|------|------|---------|
| 拖拽坐标系混乱 | 每个根节点有独立 canvasOffset，拖拽时坐标换算需要叠加 | 统一在 `_renderObject`（RepaintBoundary）坐标系下计算 |
| CrossLink 节点被删除 | 一个节点删除后，指向它的跨树连线悬空 | `removeRootNode` / 节点删除时清理相关 CrossLink |
| 旧数据兼容 | 旧格式 `RootNode` 字段只有单节点 | `fromJson` 优先判断 `RootNodes`，回退到 `RootNode` |
| refresh() 性能 | 多个根节点全部 setOffset(null) 触发全量重建 | 可优化为只刷新改动的根节点（后期优化） |
| 根节点拖动与子节点拖动冲突 | 同一手势可能既触发根节点移动又触发子节点拖动 | 用长按区分根节点画布拖动，普通拖动仍为子节点树内拖动 |

---

## 六、验收标准

- [ ] 可以通过 `addRootNode()` 添加多个根节点，各自独立显示
- [ ] 长按根节点可拖动整棵树到画布任意位置
- [ ] 子节点可拖拽到其他根节点树下（跨树移动）
- [ ] 根节点可拖入回收站，触发确认对话框，确认后连子树删除
- [ ] 可通过 `addCrossLink()` 在两个不同树的节点间绘制关联线
- [ ] `toJson()` 输出含 `RootNodes` 数组和 `CrossLinks` 数组
- [ ] `fromJson()` 可正确还原多根节点布局和跨树连线
- [ ] 旧格式（含 `RootNode` 字段）仍可正常加载
- [ ] `setTheme()` 同时应用到所有根节点
- [ ] 鱼骨图模式下多根节点被禁止，给出提示
