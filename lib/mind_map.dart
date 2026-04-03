import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mind_map/adapter/i_link_adapter.dart';
import 'package:flutter_mind_map/adapter/i_node_adapter.dart';
import 'package:flutter_mind_map/adapter/i_theme_adapter.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';
import 'package:flutter_mind_map/link/arc_line_linek.dart';
import 'package:flutter_mind_map/link/beerse_line_link.dart';
import 'package:flutter_mind_map/link/i_link.dart';
import 'package:flutter_mind_map/link/line_link.dart';
import 'package:flutter_mind_map/link/oblique_broken_line.dart';
import 'package:flutter_mind_map/link/poly_line_link.dart';
import 'package:flutter_mind_map/mind_map_node.dart';
import 'package:flutter_mind_map/theme/i_mind_map_theme.dart';
import 'package:flutter_mind_map/theme/json_theme.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_compact.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_large.dart';
import 'package:flutter_mind_map/theme/mind_map_theme_normal.dart';
import 'package:flutter_mind_map/cross_link/cross_link_info.dart';
import 'package:path_drawing/path_drawing.dart';

// ignore: must_be_immutable
class MindMap extends StatefulWidget {
  MindMap({super.key});
  final GlobalKey _key = GlobalKey();

  bool _enabledDoubleTapShowTextField = false;

  /// When double tap, show text field
  bool getEnabledDoubleTapShowTextField() {
    return _enabledDoubleTapShowTextField;
  }

  void setEnabledDoubleTapShowTextField(bool enabled) {
    _enabledDoubleTapShowTextField = enabled;
  }

  bool _enabledExtendedClick = false;

  /// When Extended is not empty, display underline and Hand mouse in Read Only mode
  bool getEnabledExtendedClick() => _enabledExtendedClick;
  void setEnabledExtendedClick(bool enabled) {
    _enabledExtendedClick = enabled;
  }

  int _expandedLevel = 99;

  /// Defalut expanded layers
  int getExpandedLevel() => _expandedLevel;
  void setExpandedLevel(int level) {
    _expandedLevel = level;
  }

  String deleteNodeString = "Delete this node?";

  ///Multilingual text of 'Delete this node?' string
  String getDeleteNodeString() {
    return deleteNodeString;
  }

  ///Set multilingual text of 'Delete this node?' string
  void setDeleteNodeString(String value) {
    deleteNodeString = value;
  }

  String cancelString = "Cancel";

  ///Multilingual text of  Cancel string
  String getCancelString() {
    return cancelString;
  }

  ///Multilingual text of  Cancel string
  void setCancelString(String value) {
    cancelString = value;
  }

  String okString = "OK";

  /// Multilingual text of OK string
  String getOkString() {
    return okString;
  }

  /// Multilingual text of OK string
  void setOkString(String value) {
    okString = value;
  }

  double _toolbarPadding = 20.0;

  /// Toolbar padding
  double getToolbarPadding() {
    return _toolbarPadding;
  }

  void setToolbarPadding(double value) {
    if (_toolbarPadding != value) {
      _toolbarPadding = value;
      refresh();
    }
  }

  MapType _mapType = MapType.mind;

  /// Map type
  MapType getMapType() {
    return _mapType;
  }

  //Change Map Type
  void setMapType(MapType value) {
    if (_mapType != value) {
      _mapType = value;
      refresh();
      onMapTypeChanged();
      onChanged();
    }
  }

  MindMapType _mindMapType = MindMapType.leftAndRight;

  /// Mind map type
  MindMapType getMindMapType() {
    return _mindMapType;
  }

  void setMindMapType(MindMapType value) {
    if (getMapType() == MapType.mind && _mindMapType != value) {
      _mindMapType = value;
      switch (value) {
        case MindMapType.leftAndRight:
          if (getRootNode().getLeftItems().isNotEmpty &&
              getRootNode().getRightItems().isEmpty) {
            while (getRootNode().getLeftItems().isNotEmpty) {
              IMindMapNode node = getRootNode().getLeftItems().first;
              getRootNode().removeLeftItem(node);
              getRootNode().addRightItem(node);
            }
          }
          if (getRootNode().getLeftItems().isEmpty &&
              getRootNode().getRightItems().isNotEmpty) {
            while (getRootNode().getRightItems().length >
                getRootNode().getLeftItems().length + 1) {
              IMindMapNode node = getRootNode().getRightItems().last;
              getRootNode().removeRightItem(node);
              getRootNode().addLeftItem(node);
            }
          }

          break;
        case MindMapType.left:
          if (getRootNode().getLeftItems().isNotEmpty &&
              getRootNode().getRightItems().isNotEmpty) {
            while (getRootNode().getLeftItems().isNotEmpty) {
              IMindMapNode node = getRootNode().getLeftItems().last;
              getRootNode().removeLeftItem(node);
              getRootNode().addRightItem(node);
            }
          }
          while (getRootNode().getRightItems().isNotEmpty) {
            IMindMapNode node = getRootNode().getRightItems().first;
            getRootNode().removeRightItem(node);
            getRootNode().addLeftItem(node);
          }
          break;
        case MindMapType.right:
          if (getRootNode().getLeftItems().isNotEmpty &&
              getRootNode().getRightItems().isNotEmpty) {
            while (getRootNode().getLeftItems().isNotEmpty) {
              IMindMapNode node = getRootNode().getLeftItems().last;
              getRootNode().removeLeftItem(node);
              getRootNode().addRightItem(node);
            }
          } else {
            while (getRootNode().getLeftItems().isNotEmpty) {
              IMindMapNode node = getRootNode().getLeftItems().first;
              getRootNode().removeLeftItem(node);
              getRootNode().addRightItem(node);
            }
          }
          break;
      }
      refresh();
      onChanged();
    }
  }

  FishboneMapType _fishboneMapType = FishboneMapType.leftToRight;

  /// Mind map type
  FishboneMapType getFishboneMapType() {
    return _fishboneMapType;
  }

  void setFishboneMapType(FishboneMapType value) {
    if (getMapType() == MapType.fishbone && _fishboneMapType != value) {
      _fishboneMapType = value;
      refresh();
      onChanged();
    }
  }

  Size _fishboneSize = Size.zero;
  Size getFishboneSize() {
    return _fishboneSize;
  }

  void setFishboneSize(Size value) {
    if (_fishboneSize.width != value.width ||
        _fishboneSize.height != value.height) {
      _fishboneSize = value;
    }
  }

  final List<Function()> _onMapTypeChangedListeners = [];

  /// Add listener for map type change
  void addOnMapTypeChangedListener(Function() listener) {
    _onMapTypeChangedListeners.add(listener);
  }

  /// Remove listener for map type change
  void removeOnMapTypeChangedListener(Function() listener) {
    _onMapTypeChangedListeners.remove(listener);
  }

  /// Called when the map type changes.
  void onMapTypeChanged() {
    for (Function() listener in _onMapTypeChangedListeners) {
      listener();
    }
  }

  String _watermark = "";

  ///WaterMark
  String getWatermark() {
    return _watermark;
  }

  ///Set Watermark
  void setWatermark(String value) {
    _watermark = value;
  }

  Color _watermarkColor = Colors.black;

  ///WaterMark Color
  Color getWatermarkColor() {
    return _watermarkColor;
  }

  ///Set Watermark Color
  void setWatermarkColor(Color value) {
    _watermarkColor = value;
  }

  double _watermarkOpacity = 0.1;

  ///WaterMark Opacity
  double getWatermarkOpacity() {
    return _watermarkOpacity;
  }

  ///Set Watermark Opacity
  void setWatermarkOpacity(double value) {
    _watermarkOpacity = value;
  }

  double _watermarkFontSize = 15;

  ///WaterMark Font Size
  double getWatermarkFontSize() {
    return _watermarkFontSize;
  }

  ///Set Watermark Font Size
  void setWatermarkFontSize(double value) {
    _watermarkFontSize = value;
  }

  double _watermarkRotationAngle = -0.5;

  ///WaterMark Rotation Angle
  double getWatermarkRotationAngle() {
    return _watermarkRotationAngle;
  }

  ///Set Watermark Rotation Angle
  void setWatermarkRotationAngle(double value) {
    _watermarkRotationAngle = value;
  }

  double _watermarkHorizontalInterval = 100;

  ///WaterMark Horizontal Interval
  double getWatermarkHorizontalInterval() {
    return _watermarkHorizontalInterval;
  }

  ///Set Watermark Horizontal Interval
  void setWatermarkHorizontalInterval(double value) {
    _watermarkHorizontalInterval = value;
  }

  double _watermarkVerticalInterval = 50;

  ///WaterMark Vertical Interval
  double getWatermarkVerticalInterval() {
    return _watermarkVerticalInterval;
  }

  ///Set Watermark Vertical Interval
  void setWatermarkVerticalInterval(double value) {
    _watermarkVerticalInterval = value;
  }

  ///End Watermark

  ///Export to PNG
  Future<Uint8List?> toPng() async {
    _state?.refresh();
    RenderRepaintBoundary boundary =
        _key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      return byteData.buffer.asUint8List();
    }
    return null;
  }

  ///Load Data from Json
  void loadData(Map<String, dynamic> json) {
    _rootNodes.clear();
    _rootNodeCanvasOffsets.clear();
    _crossLinks.clear();
    if (json.containsKey("roots")) {
      for (Map<String, dynamic> r in (json["roots"] as List)) {
        MindMapNode node = MindMapNode();
        double cx = (r["canvasX"] as num?)?.toDouble() ?? 0;
        double cy = (r["canvasY"] as num?)?.toDouble() ?? 0;
        // Load data first so node.getID() returns the domain ID (not the
        // auto-generated UUID), ensuring _rootNodeCanvasOffsets is keyed
        // correctly and getRootNodeCanvasOffset() can find the offset later.
        node.loadData(r);
        addRootNode(node, canvasOffset: Offset(cx, cy));
      }
    } else if (json.containsKey("id") &&
        json.containsKey("content") &&
        json.containsKey("nodes")) {
      // Legacy single-root format
      MindMapNode rootNode = MindMapNode();
      addRootNode(rootNode, canvasOffset: Offset.zero);
      rootNode.loadData(json);
    }
    if (json.containsKey("crossLinks")) {
      for (Map<String, dynamic> linkJson in (json["crossLinks"] as List)) {
        _crossLinks.add(CrossLinkInfo.fromJson(linkJson));
      }
    }
  }

  ///Export Data to Json
  Map<String, dynamic> getData() {
    return {
      "roots": getRootNodes().map((n) {
        Offset off = getRootNodeCanvasOffset(n);
        return {"canvasX": off.dx, "canvasY": off.dy, ...n.getData()};
      }).toList(),
      "crossLinks": _crossLinks.map((l) => l.toJson()).toList(),
    };
  }

  ///Export Data&Style to Json
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "MapType": getMapType().name,
      "MindMapType": getMindMapType().name,
      "FishboneMapType": getFishboneMapType().name,
      "RootNodes": getRootNodes().map((node) {
        Offset off = getRootNodeCanvasOffset(node);
        return {
          "canvasX": off.dx.toString(),
          "canvasY": off.dy.toString(),
          node.runtimeType.toString(): node.toJson(),
        };
      }).toList(),
      "CrossLinks": _crossLinks.map((l) => l.toJson()).toList(),
      "Zoom": getZoom().toString(),
      "ExpandedLevel": getExpandedLevel(),
      "BackgroundColor": colorToString(getBackgroundColor()),
      "Theme": getTheme() is JsonTheme
          ? jsonEncode((getTheme() as JsonTheme).json)
          : "",
    };
    if (getMoveOffset() != Offset.zero) {
      json["x"] = getMoveOffset().dx.toString();
      json["y"] = getMoveOffset().dy.toString();
    }
    return json;
  }

  bool _isLoading = false;

  ///Load Data&Style from Json
  void fromJson(Map<String, dynamic> json) {
    _isLoading = true;
    if (json.containsKey("MapType")) {
      MapType mapType = MapType.mind;
      for (MapType type in MapType.values) {
        if (type.name == json["MapType"].toString()) {
          mapType = type;
          break;
        }
      }
      setMapType(mapType);
    }
    if (json.containsKey("MindMapType")) {
      MindMapType mindMapType = MindMapType.leftAndRight;
      for (MindMapType type in MindMapType.values) {
        if (type.name == json["MindMapType"].toString()) {
          mindMapType = type;
          break;
        }
      }
      setMindMapType(mindMapType);
    }
    if (json.containsKey("FishboneMapType")) {
      FishboneMapType fishboneMapType = FishboneMapType.leftToRight;
      for (FishboneMapType type in FishboneMapType.values) {
        if (type.name == json["FishboneMapType"].toString()) {
          fishboneMapType = type;
          break;
        }
      }
      setFishboneMapType(fishboneMapType);
    }
    if (json.containsKey("Zoom")) {
      setZoom(double.tryParse(json["Zoom"].toString()) ?? 1.0);
    }
    if (json.containsKey("ExpandedLevel")) {
      setExpandedLevel(int.tryParse(json["ExpandedLevel"].toString()) ?? 99);
    }
    if (json.containsKey("BackgroundColor")) {
      setBackgroundColor(stringToColor(json["BackgroundColor"].toString()));
    }
    if (json.containsKey("x") && json.containsKey("y")) {
      double x = double.tryParse(json["x"].toString()) ?? 0;
      double y = double.tryParse(json["y"].toString()) ?? 0;
      setMoveOffset(Offset(x, y));
    }
    if (json.containsKey("Theme")) {
      String themeName = json["Theme"];
      if (themeName.isNotEmpty) {
        Map<String, dynamic>? themeJson = jsonDecode(themeName);
        if (themeJson != null) {
          setTheme(JsonTheme("jsonTheme", themeJson));
        }
      }
    }
    _rootNodes.clear();
    _rootNodeCanvasOffsets.clear();
    _crossLinks.clear();
    if (json.containsKey("RootNodes")) {
      List<dynamic> rootsJson = json["RootNodes"] as List;
      for (Map<String, dynamic> rootJson in rootsJson) {
        double cx =
            double.tryParse(rootJson["canvasX"]?.toString() ?? "0") ?? 0;
        double cy =
            double.tryParse(rootJson["canvasY"]?.toString() ?? "0") ?? 0;
        String nodeKey = rootJson.keys.firstWhere(
          (k) => k != "canvasX" && k != "canvasY",
        );
        IMindMapNode? node = createNode(nodeKey);
        if (node != null) {
          node.fromJson(rootJson[nodeKey] as Map<String, dynamic>);
          addRootNode(node, canvasOffset: Offset(cx, cy));
        }
      }
    } else if (json.containsKey("RootNode")) {
      Map<String, dynamic> map = json["RootNode"];
      if (map.isNotEmpty) {
        IMindMapNode? node = createNode(map.keys.first);
        if (node != null) {
          addRootNode(node, canvasOffset: Offset.zero);
          node.fromJson(map);
        }
      }
    }
    if (json.containsKey("CrossLinks")) {
      for (Map<String, dynamic> linkJson in (json["CrossLinks"] as List)) {
        _crossLinks.add(CrossLinkInfo.fromJson(linkJson));
      }
    }
    _isLoading = false;
  }

  int _buttonWidth = 24;

  ///Button Width
  int getButtonWidth() {
    return _buttonWidth;
  }

  ///Set Button Width
  void setButtonWidth(int value) {
    if (_buttonWidth != value) {
      _buttonWidth = value;
      _state?.refresh();
    }
  }

  Color _buttonColor = Colors.black;

  ///Button Color
  Color getButtonColor() {
    return _buttonColor;
  }

  ///Set Button Color
  void setButtonColor(Color value) {
    if (_buttonColor != value) {
      _buttonColor = value;
      _state?.refresh();
    }
  }

  Color _buttonBackground = Colors.white;

  ///Button Background
  Color getButtonBackground() {
    return _buttonBackground;
  }

  ///Set Button Background
  void setButtonBackground(Color value) {
    if (_buttonBackground != value) {
      _buttonBackground = value;
      _state?.refresh();
    }
  }

  Color _dragInBorderColor = Colors.cyan;

  ///Drag In Border Color
  Color getDragInBorderColor() {
    return _dragInBorderColor;
  }

  ///Set Drag In Border Color
  void setDragInBorderColor(Color value) {
    if (_dragInBorderColor != value) {
      _dragInBorderColor = value;
      _state?.refresh();
    }
  }

  double _dragInBorderWidth = 3;

  ///Drag In Border Width
  double getDragInBorderWidth() {
    return _dragInBorderWidth;
  }

  ///Set Drag In Border Width
  void setDragInBorderWidth(double value) {
    if (_dragInBorderWidth != value) {
      _dragInBorderWidth = value;
      _state?.refresh();
    }
  }

  double _mindMapPadding = 80;

  ///MindMap Padding
  double getMindMapPadding() {
    return _mindMapPadding;
  }

  ///Set MindMap Padding
  void setMindMapPadding(double value) {
    if (_mindMapPadding != value) {
      _mindMapPadding = value;
      _state?.refresh();
    }
  }

  ///Adapter
  final List<INodeAdapter> _nodeAdapter = [MindMapNodeAdapter()];

  ///Register Node Adapter
  void registerNodeAdapter(INodeAdapter value) {
    if (!_nodeAdapter.contains(value)) {
      _nodeAdapter.add(value);
    }
  }

  ///Get Node Adapter
  List<INodeAdapter> getNodeAdapter() {
    return _nodeAdapter;
  }

  ///Create Node
  IMindMapNode? createNode(String name) {
    for (INodeAdapter na in _nodeAdapter) {
      if (na.getName() == name) {
        return na.createNode();
      }
    }
    return null;
  }

  final List<ILinkAdapter> _linkAdapter = [
    BeerseLinkLinkAdapter(),
    LineLinkAdapter(),
    PolyLineLinkAdapter(),
    ObliqueBrokenLineAdapter(),
    ArcLineLinkAdapter(),
  ];

  ///Register Link Adapter
  void registerLinkAdapter(ILinkAdapter value) {
    if (!_linkAdapter.contains(value)) {
      _linkAdapter.add(value);
    }
  }

  ///Get Link Adapter
  List<ILinkAdapter> getLinkAdapter() {
    return _linkAdapter;
  }

  ///Create Link
  ILink? createLink(String name) {
    for (ILinkAdapter na in _linkAdapter) {
      if (na.getName() == name) {
        return na.createLink();
      }
    }
    return null;
  }

  final List<IThemeAdapter> _themeAdapter = [
    MindMapThemeCompactAdapter(),
    MindMapThemeNormalAdapter(),
    MindMapThemeLargeAdapter(),
  ];

  ///Register Theme Adapter
  void registerThemeAdapter(IThemeAdapter value) {
    if (!_themeAdapter.contains(value)) {
      _themeAdapter.add(value);
    }
  }

  ///Get Theme Adapter
  List<IThemeAdapter> getThemeAdapter() {
    return _themeAdapter;
  }

  ///Create Theme
  IMindMapTheme? createTheme(String name) {
    for (IThemeAdapter na in _themeAdapter) {
      if (na.getName() == name) {
        return na.createTheme();
      }
    }
    return null;
  }

  ///End Adapter

  bool _showRecycle = true;

  ///Show Recycle
  bool getShowRecycle() {
    return _showRecycle;
  }

  ///Set Show Recycle
  void setShowRecycle(bool value) {
    if (_showRecycle != value) {
      _showRecycle = value;
      _state?.refresh();
    }
  }

  String _recycleTitle = "Drag here to delete";

  ///Recycle Title
  String getRecycleTitle() {
    return _recycleTitle;
  }

  ///Set Recycle Title
  void setRecycleTitle(String value) {
    if (_recycleTitle != value) {
      _recycleTitle = value;
      _state?.refresh();
    }
  }

  bool _canMove = true;

  ///Can Move
  bool getCanMove() {
    return _canMove;
  }

  ///  Set Can Move
  void setCanMove(bool value) {
    if (_canMove != value) {
      _canMove = value;
      _state?.refresh();
    }
  }

  bool _canMoveRootNodes = true;

  /// Whether individual root nodes can be dragged within the multi-root canvas.
  bool getCanMoveRootNodes() => _canMoveRootNodes;

  /// Set whether individual root nodes can be dragged.
  void setCanMoveRootNodes(bool value) {
    if (_canMoveRootNodes != value) {
      _canMoveRootNodes = value;
      _state?.refresh();
    }
  }

  bool _enableNodeReparentOnDrag = true;

  /// Whether dragging nodes can change parent/position by dropping on targets.
  ///
  /// When disabled, drag prompt line and drop-to-reparent behavior are turned off.
  bool getEnableNodeReparentOnDrag() => _enableNodeReparentOnDrag;

  /// Set whether dragging nodes can change parent/position by dropping on targets.
  void setEnableNodeReparentOnDrag(bool value) {
    if (_enableNodeReparentOnDrag != value) {
      _enableNodeReparentOnDrag = value;
      if (!value) {
        _dragInNode = null;
        _dragNode = null;
        _dragOffset = null;
      }
      _state?.refresh();
    }
  }

  bool _showZoom = true;

  ///Show Zoom
  bool getShowZoom() {
    return _showZoom;
  }

  ///Set Show Zoom
  void setShowZoom(bool value) {
    if (_showZoom != value) {
      _showZoom = value;
      _state?.refresh();
    }
  }

  ///refresh MindMap
  void refresh() {
    _state?.refresh();
  }

  /// 在导图区域本地坐标 [local] 处按滚轮纵向增量 [scrollDeltaDy] 缩放。
  /// 兼容外层调用；当前实现复用现有缩放体系。
  void applyWheelZoomAtLocal(Offset local, double scrollDeltaDy) {
    _state?.applyWheelZoomAtLocal(local, scrollDeltaDy);
  }

  /// 使用全局坐标 [globalPosition] 作为滚轮缩放锚点。
  void applyWheelZoomAtGlobal(Offset globalPosition, double scrollDeltaDy) {
    _state?.applyWheelZoomAtGlobal(globalPosition, scrollDeltaDy);
  }

  double _zoom = 1;

  ///Zoom
  double getZoom() {
    return _zoom;
  }

  ///Set Zoom
  void setZoom(double value) {
    if (value > 0 && _zoom != value) {
      _zoom = value;
      List<Function()> list = [];
      list.addAll(_onZoomChangedListeners);
      for (Function() call in list) {
        call();
      }
    }
  }

  bool _isScaling = false;
  bool getIsScaling() {
    return _isScaling;
  }

  void setIsScaling(bool value) {
    if (_isScaling != value) {
      _isScaling = value;
    }
  }

  final List<Function()> _onChangedListeners = [];

  ///Add On Changed Listeners
  void addOnChangedListeners(Function() value) {
    _onChangedListeners.add(value);
  }

  ///Remove On Changed Listeners
  void removeOnChangedListeners(Function() value) {
    _onChangedListeners.remove(value);
  }

  ///On Changed
  void onChanged() {
    if (!_isLoading) {
      List<Function()> list = [];
      list.addAll(_onChangedListeners);
      for (Function() call in list) {
        call();
      }
    }
  }

  IMindMapTheme? _theme;

  ///Theme
  IMindMapTheme? getTheme() {
    return _theme;
  }

  ///Set Theme
  void setTheme(IMindMapTheme? value) {
    for (IMindMapNode root in getRootNodes()) {
      root.clearStyle();
    }
    _theme = value;
    if (_theme != null) {
      if (_theme!.getThemeByLevel(0)!.containsKey("Image")) {
        if (getRootNode() is MindMapNode) {
          (getRootNode() as MindMapNode).setImage("");
          (getRootNode() as MindMapNode).setImageWidth(null);
          (getRootNode() as MindMapNode).setImageHeight(null);
        }
      }
      if (_theme!.getThemeByLevel(0)!.containsKey("Image2")) {
        if (getRootNode() is MindMapNode) {
          (getRootNode() as MindMapNode).setImage2("");
          (getRootNode() as MindMapNode).setImage2Width(null);
          (getRootNode() as MindMapNode).setImage2Height(null);
        }
      }
    }
    for (IMindMapNode root in getRootNodes()) {
      root.refresh();
    }
    refresh();
    onChanged();
  }

  final List<Function()> _onZoomChangedListeners = [];

  ///Add On Zoom Changed Listeners
  void addOnZoomChangedListeners(Function() value) {
    _onZoomChangedListeners.add(value);
  }

  ///Remove On Zoom Changed Listeners
  void removeOnZoomChangedListeners(Function() value) {
    _onZoomChangedListeners.remove(value);
  }

  IMindMapNode? _selectedNode;

  ///Selected Node
  IMindMapNode? getSelectedNode() {
    return _selectedNode;
  }

  ///Set Selected Node
  void setSelectedNode(IMindMapNode? node) {
    _selectedNode = node;
    notifySelectedNodeChanged();
  }

  final List<Function()> _onTapListeners = [];

  ///Add On Tap Listeners
  void addOnTapListeners(Function() callback) {
    _onTapListeners.add(callback);
  }

  ///Remove On Tap Listeners
  void removeOnTapListeners(Function() callback) {
    _onTapListeners.remove(callback);
  }

  ///On Tap
  void onTap() {
    List<Function()> list = [];
    list.addAll(_onTapListeners);
    for (Function() call in list) {
      call();
    }
  }

  final List<Function()> _onSelectedNodeChangedListeners = [];

  ///Add On Selected Node Changed Listeners
  void addOnSelectedNodeChangedListeners(Function() callback) {
    _onSelectedNodeChangedListeners.add(callback);
  }

  ///Remove On Selected Node Changed Listeners
  void removeOnSelectedNodeChangedListeners(Function() callback) {
    _onSelectedNodeChangedListeners.remove(callback);
  }

  ///Notify Selected Node Changed
  void notifySelectedNodeChanged() {
    for (var listener in _onSelectedNodeChangedListeners) {
      listener();
    }
  }

  final List<Function(IMindMapNode)> _onDoubleTapListeners = [];

  ///Add On Double Tap Listeners
  void addOnDoubleTapListeners(Function(IMindMapNode) value) {
    _onDoubleTapListeners.add(value);
  }

  ///Remove On Double Tap Listeners
  void removeOnDoubleTapListeners(Function(IMindMapNode) value) {
    _onDoubleTapListeners.remove(value);
  }

  ///On Double Tap
  void onDoubleTap(IMindMapNode node) {
    debugPrint(
      "[mind_map] dispatch onDoubleTap node=${node.getTitle()} id=${node.getID()} listeners=${_onDoubleTapListeners.length}",
    );
    List<Function(IMindMapNode)> list = [];
    list.addAll(_onDoubleTapListeners);
    for (Function(IMindMapNode) call in list) {
      call(node);
    }
  }

  final List<Function(IMindMapNode)> _onNodeAddedListeners = [];

  ///Add On Node Added Listeners
  void addOnNodeAddedListeners(Function(IMindMapNode) value) {
    _onNodeAddedListeners.add(value);
  }

  ///Remove On Node Added Listeners
  void removeOnNodeAddedListeners(Function(IMindMapNode) value) {
    _onNodeAddedListeners.remove(value);
  }

  ///On Node Added
  void onNodeAdded(IMindMapNode node) {
    List<Function(IMindMapNode)> list = [];
    list.addAll(_onNodeAddedListeners);
    for (Function(IMindMapNode) call in list) {
      call(node);
    }
  }

  final List<Function(IMindMapNode)> _onEditListeners = [];

  ///Add On Edit Listeners
  void addOnEditListeners(Function(IMindMapNode) value) {
    _onEditListeners.add(value);
  }

  ///Remove On Edit Listeners
  void removeOnEditListeners(Function(IMindMapNode) value) {
    _onEditListeners.remove(value);
  }

  ///On Edit
  void onEdit(IMindMapNode node) {
    List<Function(IMindMapNode)> list = [];
    list.addAll(_onEditListeners);
    for (Function(IMindMapNode) call in list) {
      call(node);
    }
  }

  bool _readOnly = false;

  ///Set Read Only
  void setReadOnly(bool value) {
    if (_readOnly != value) {
      _readOnly = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Read Only
  bool getReadOnly() => _readOnly;

  bool _hasTextField = true;

  ///Has TextField
  void setHasTextField(bool value) {
    if (_hasTextField != value) {
      _hasTextField = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Display text input box
  bool hasTextField() => _hasTextField;

  bool _hasEditButton = false;

  ///set Has Edit Button
  void setHasEditButton(bool value) {
    if (_hasEditButton != value) {
      _hasEditButton = value;
      setSelectedNode(null);
      _state?.refresh();
    }
  }

  ///Display edit button
  bool hasEditButton() => _hasEditButton;

  Color? _backgroundColor;

  ///Background Color
  Color getBackgroundColor() =>
      _backgroundColor ??
      (getTheme() != null
          ? getTheme()!.getBackgroundColor()
          : Colors.transparent);

  ///Set Background Color
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    _state?.refresh();
    onChanged();
  }

  final List<IMindMapNode> _rootNodes = [];
  final Map<String, Offset> _rootNodeCanvasOffsets = {};
  final List<CrossLinkInfo> _crossLinks = [];

  ///Root Node (compatibility: returns first root node, creating one if empty)
  IMindMapNode getRootNode() {
    if (_rootNodes.isEmpty) {
      // 同步完成数据结构，但 [addRootNode] 会触发 onRootNodeChanged → setState。
      // 若在 build（例如 DragTarget.builder）期间调用 getRootNode，会触发构建期 setState。
      // 将通知推迟到本帧布局完成之后。
      MindMapNode node = MindMapNode();
      _rootNodes.add(node);
      node.setNodeType(NodeType.root);
      node.setMindMap(this);
      _rootNodeCanvasOffsets[node.getID()] = Offset.zero;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onRootNodeChanged();
        onChanged();
      });
    }
    return _rootNodes.first;
  }

  ///Set Root Node (compatibility: replaces first root node)
  void setRootNode(IMindMapNode rootNode) {
    if (_rootNodes.isEmpty) {
      addRootNode(rootNode, canvasOffset: Offset.zero);
    } else {
      _rootNodes[0] = rootNode;
      rootNode.setNodeType(NodeType.root);
      rootNode.setMindMap(this);
      _rootNodeCanvasOffsets[rootNode.getID()] = Offset.zero;
    }
    onRootNodeChanged();
  }

  ///Get all root nodes
  List<IMindMapNode> getRootNodes() => List.unmodifiable(_rootNodes);

  ///Add a root node at the given canvas offset
  void addRootNode(IMindMapNode node, {Offset canvasOffset = Offset.zero}) {
    _rootNodes.add(node);
    node.setParentNode(null);
    node.setNodeType(NodeType.root);
    node.setMindMap(this);
    _rootNodeCanvasOffsets[node.getID()] = canvasOffset;
    onRootNodeChanged();
    onChanged();
  }

  ///Detach a node from its parent and promote it to an independent root node.
  ///
  /// Returns true when a promotion happens; false when node is null/already root.
  bool promoteNodeToRoot(
    IMindMapNode? node, {
    Offset canvasOffset = Offset.zero,
  }) {
    if (node == null) return false;
    if (node.getParentNode() == null || node.getNodeType() == NodeType.root) {
      return false;
    }

    final IMindMapNode? parent = node.getParentNode();
    if (parent == null) return false;

    parent.removeLeftItem(node);
    parent.removeRightItem(node);
    node.setParentNode(null);
    addRootNode(node, canvasOffset: canvasOffset);
    return true;
  }

  ///Remove a root node (and its subtree)
  void removeRootNode(IMindMapNode node) {
    _rootNodes.remove(node);
    _rootNodeCanvasOffsets.remove(node.getID());
    // Clean up cross links referencing nodes in the removed subtree
    Set<String> removedIds = {};
    _collectNodeIds(node, removedIds);
    _crossLinks.removeWhere(
      (l) =>
          removedIds.contains(l.fromNodeId) || removedIds.contains(l.toNodeId),
    );
    onRootNodeChanged();
    onChanged();
  }

  void _collectNodeIds(IMindMapNode node, Set<String> ids) {
    ids.add(node.getID());
    for (IMindMapNode child in [
      ...node.getLeftItems(),
      ...node.getRightItems(),
    ]) {
      _collectNodeIds(child, ids);
    }
  }

  ///Get canvas offset for a root node
  Offset getRootNodeCanvasOffset(IMindMapNode node) =>
      _rootNodeCanvasOffsets[node.getID()] ?? Offset.zero;

  ///Set canvas offset for a root node (called during drag)
  void setRootNodeCanvasOffset(IMindMapNode node, Offset offset) {
    _rootNodeCanvasOffsets[node.getID()] = offset;
    onChanged();
  }

  ///CrossLink management
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

  ///Find a node by ID across all root trees
  IMindMapNode? findNodeById(String id) {
    for (IMindMapNode root in _rootNodes) {
      IMindMapNode? result = _findInTree(root, id);
      if (result != null) return result;
    }
    return null;
  }

  IMindMapNode? _findInTree(IMindMapNode node, String id) {
    if (node.getID() == id) return node;
    for (IMindMapNode child in [
      ...node.getLeftItems(),
      ...node.getRightItems(),
    ]) {
      IMindMapNode? r = _findInTree(child, id);
      if (r != null) return r;
    }
    return null;
  }

  final List<Function()> _onRootNodeChangeListeners = [];

  ///Add On Root Node Change Listeners
  void addOnRootNodeChangeListener(Function() listener) {
    _onRootNodeChangeListeners.add(listener);
  }

  ///Remove On Root Node Change Listeners
  void removeOnRootNodeChangeListener(Function() listener) {
    _onRootNodeChangeListeners.remove(listener);
  }

  ///Notify Root Node Changed
  void onRootNodeChanged() {
    for (var listener in _onRootNodeChangeListeners) {
      listener();
    }
  }

  final List<Function()> _onMoveListeners = [];

  ///Add On Move Listeners
  void addOnMoveListeners(Function() callback) {
    _onMoveListeners.add(callback);
  }

  ///Remove On Move Listeners
  void removeOnMoveListeners(Function() callback) {
    _onMoveListeners.remove(callback);
  }

  ///On Move
  void onMove() {
    for (var listener in _onMoveListeners) {
      listener();
    }
  }

  @override
  State<StatefulWidget> createState() => MindMapState();

  MindMapState? _state;

  Offset? _offset;

  ///Set Offset
  void setOffset(Offset? value) {
    _offset = value;
    _state?.refresh();
  }

  ///Get Offset
  Offset? getOffset() => _offset;

  ///Move Offset
  Offset moveOffset = Offset.zero;

  ///Set Move Offset
  void setMoveOffset(Offset value) {
    if (moveOffset.dx != value.dx || moveOffset.dy != value.dy) {
      moveOffset = value;
      onMove();
      onChanged();
    }
  }

  ///Get Move Offset
  Offset getMoveOffset() => moveOffset;

  Size? _size;

  ///Set Size
  void setSize(Size? value) {
    if (_size == null ||
        (value != null &&
            (value.width != _size!.width || value.height != _size!.height))) {
      _size = value;
      _state?.refresh();
    }
  }

  ///Get Size
  Size? getSize() => _size;

  RenderObject? _renderObject;

  RenderObject? getRenderObject() {
    return _renderObject;
  }

  IMindMapNode? _dragInNode;
  IMindMapNode? _dragNode;
  Offset? _dragOffset;
  bool _leftDrag = true;
  bool _inRecycle = false;
}

class MindMapState extends State<MindMap> {
  IMindMapNode? _hitTestNodeFromLocalPosition(Offset localPosition) {
    final RenderObject? mapRenderObject = widget._key.currentContext
        ?.findRenderObject();
    if (mapRenderObject is! RenderBox) return null;

    // localPosition is in _mapStackKey Container space.
    // ro.localToGlobal(ancestor: mapRenderBox) returns RepaintBoundary space.
    // Convert localPosition to the same space so comparisons are valid.
    final RenderBox? stackBox =
        _mapStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return null;
    final Offset globalPos = stackBox.localToGlobal(localPosition);
    final Offset posInMap = mapRenderObject.globalToLocal(globalPos);

    final List<IMindMapNode> roots = widget.getRootNodes();
    for (int i = roots.length - 1; i >= 0; i--) {
      final IMindMapNode? hit = _hitTestNodeRecursive(
        roots[i],
        mapRenderObject,
        posInMap,
      );
      if (hit != null) return hit;
    }
    return null;
  }

  IMindMapNode? _hitTestNodeRecursive(
    IMindMapNode node,
    RenderBox mapRenderBox,
    Offset localPosition,
  ) {
    final List<IMindMapNode> children = [
      ...node.getLeftItems(),
      ...node.getRightItems(),
    ];
    for (int i = children.length - 1; i >= 0; i--) {
      final IMindMapNode? childHit = _hitTestNodeRecursive(
        children[i],
        mapRenderBox,
        localPosition,
      );
      if (childHit != null) return childHit;
    }

    final RenderObject? ro = node.getRenderObject();
    if (ro is! RenderBox) return null;
    final Offset topLeft = ro.localToGlobal(
      Offset.zero,
      ancestor: mapRenderBox,
    );
    final Rect rect = topLeft & ro.size;
    if (rect.contains(localPosition)) {
      return node;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    widget.addOnRootNodeChangeListener(onRootNodeChanged);
    widget.addOnSelectedNodeChangedListeners(onSelectedNodeChanged);
    widget.addOnMapTypeChangedListener(onMapTypeChanged);
  }

  @override
  void dispose() {
    widget.removeOnRootNodeChangeListener(onRootNodeChanged);
    widget.removeOnSelectedNodeChangedListeners(onSelectedNodeChanged);
    widget.removeOnMapTypeChangedListener(onMapTypeChanged);
    super.dispose();
  }

  void onRootNodeChanged() {
    setState(() {});
  }

  void onSelectedNodeChanged() {
    setState(() {});
  }

  void onMapTypeChanged() {
    setState(() {});
  }

  Size s = Size.zero;

  Offset _focalPoint = Offset.zero;
  Offset _lastFocalPoint = Offset.zero;
  double _lastScale = 1.0;

  double _oldzoom = 1.0;

  final GlobalKey _pkey = GlobalKey();
  final GlobalKey _mapStackKey = GlobalKey();

  void applyWheelZoomAtGlobal(Offset globalPosition, double scrollDeltaDy) {
    final box = _mapStackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    applyWheelZoomAtLocal(box.globalToLocal(globalPosition), scrollDeltaDy);
  }

  void applyWheelZoomAtLocal(Offset local, double scrollDeltaDy) {
    // 与画布拖移手势解耦：选择模式下仍允许滚轮缩放（getCanMove 仅约束 onScale 平移/捏合）。
    if (scrollDeltaDy == 0) return;
    final oldZoom = widget.getZoom();
    final newZoom = (oldZoom - scrollDeltaDy * 0.002).clamp(0.1, 2.0);
    if ((newZoom - oldZoom).abs() < 1e-9) return;
    setState(() {
      widget.setZoom(newZoom);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    widget._state = this;
    WidgetsBinding.instance.addPostFrameCallback((c) {
      if (mounted) {
        RenderObject? ro = context.findRenderObject();
        if (ro != null && ro is RenderBox) {
          if (s.width != ro.size.width || s.height != ro.size.height) {
            setState(() {
              s = ro.size;
            });
          }
        }
      }
    });
    double x = widget.getOffset()?.dx ?? 0;
    double y = widget.getOffset()?.dy ?? 0;
    Size? size = widget.getSize();
    if (s.isEmpty) {
      s = MediaQuery.of(context).size;
    }
    // Multi-root mode: place canvas origin (0,0) at screen center so every
    // root tree is positioned relative to the center via its canvasOffset.
    if (widget.getOffset() == null && widget.getRootNodes().length > 1) {
      x = s.width / 2;
      y = s.height / 2;
    } else if (widget.getOffset() == null &&
        size != null &&
        size.width > 0 &&
        size.height > 0) {
      switch (widget.getMapType()) {
        case MapType.mind:
          x = (s.width - size.width * widget.getZoom()) / 2;
          y = (s.height - size.height * widget.getZoom()) / 2;
          break;
        case MapType.fishbone:
          x = widget.getMindMapPadding();
          y =
              widget.getMindMapPadding() +
              (s.height - widget.getFishboneSize().height * widget.getZoom()) /
                  2;
      }

      ///set RooetNode Center
      Size? rs = widget.getRootNode().getSize();
      Offset? ro = widget.getRootNode().getOffset();
      if (rs != null && ro != null) {
        switch (widget.getMapType()) {
          case MapType.mind:
            if (widget.getRootNode().getLeftItems().isNotEmpty &&
                widget.getRootNode().getRightItems().isNotEmpty) {
              x =
                  s.width / 2 -
                  ro.dx -
                  rs.width / 2 +
                  (ro.dx - size.width / 2 + rs.width / 2) -
                  (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();
              y =
                  s.height / 2 -
                  ro.dy -
                  rs.height / 2 +
                  (ro.dy - size.height / 2 + rs.height / 2) -
                  (ro.dy - size.height / 2 + rs.height / 2) * widget.getZoom();
            } else {
              if (widget.getRootNode().getLeftItems().isNotEmpty) {
                x =
                    s.width / 2 -
                    ro.dx -
                    rs.width / 2 +
                    (ro.dx - size.width / 2 + rs.width / 2) -
                    (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

                x = s.width < size.width * widget.getZoom()
                    ? x +
                          s.width / 2 -
                          rs.width * widget.getZoom() / 2 -
                          widget.getMindMapPadding() * widget.getZoom()
                    : x +
                          size.width * widget.getZoom() / 2 -
                          widget.getMindMapPadding() * widget.getZoom();

                y =
                    s.height / 2 -
                    ro.dy -
                    rs.height / 2 +
                    (ro.dy - size.height / 2 + rs.height / 2) -
                    (ro.dy - size.height / 2 + rs.height / 2) *
                        widget.getZoom();
              } else {
                x =
                    s.width / 2 -
                    ro.dx -
                    rs.width / 2 +
                    (ro.dx - size.width / 2 + rs.width / 2) -
                    (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

                x = s.width < size.width * widget.getZoom()
                    ? x -
                          (s.width / 2 -
                              rs.width * widget.getZoom() / 2 -
                              widget.getMindMapPadding() * widget.getZoom())
                    : x -
                          size.width * widget.getZoom() / 2 +
                          widget.getMindMapPadding() * widget.getZoom();
                y =
                    s.height / 2 -
                    ro.dy -
                    rs.height / 2 +
                    (ro.dy - size.height / 2 + rs.height / 2) -
                    (ro.dy - size.height / 2 + rs.height / 2) *
                        widget.getZoom();
              }
            }
            break;
          case MapType.fishbone:
            if (widget.getFishboneMapType() == FishboneMapType.rightToLeft) {
              x =
                  s.width / 2 -
                  ro.dx -
                  rs.width / 2 +
                  (ro.dx - size.width / 2 + rs.width / 2) -
                  (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

              x = s.width < size.width * widget.getZoom()
                  ? x +
                        (s.width / 2 -
                            rs.width * widget.getZoom() / 2 -
                            widget.getMindMapPadding() * widget.getZoom() / 2) +
                        widget.getMindMapPadding() * widget.getZoom()
                  : x + size.width * widget.getZoom() / 2;
            } else {
              x =
                  s.width / 2 -
                  ro.dx -
                  rs.width / 2 +
                  (ro.dx - size.width / 2 + rs.width / 2) -
                  (ro.dx - size.width / 2 + rs.width / 2) * widget.getZoom();

              x = s.width < size.width * widget.getZoom()
                  ? x -
                        (s.width / 2 -
                            rs.width * widget.getZoom() / 2 -
                            widget.getMindMapPadding() * widget.getZoom() / 2) +
                        widget.getMindMapPadding() * widget.getZoom()
                  : x -
                        size.width * widget.getZoom() / 2 +
                        widget.getMindMapPadding() * widget.getZoom() * 2;
            }

            y =
                widget.getMindMapPadding() * widget.getZoom() +
                s.height / 2 -
                ro.dy -
                rs.height / 2 +
                (ro.dy - size.height / 2 + rs.height / 2) -
                (ro.dy - size.height / 2 + rs.height / 2) * widget.getZoom();

            break;
        }
      }
    }
    return Container(
      color: widget.getBackgroundColor(),
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        // NOTE:
        // Keep map-level tap disabled to avoid competing with node-level
        // tap/double-tap recognizers in multi-root scenes.
        onTap: null,
        onDoubleTapDown: (details) {
          if (widget.getReadOnly()) return;
          final IMindMapNode? node = _hitTestNodeFromLocalPosition(
            details.localPosition,
          );
          if (node != null) {
            widget.setSelectedNode(node);
            widget.onDoubleTap(node);
          }
        },

        ///Scale
        onScaleStart: widget.getCanMove()
            ? (details) {
                widget.setIsScaling(true);
                setState(() {
                  _oldzoom = widget.getZoom();
                  widget._dragInNode = null;
                  widget._dragNode = null;
                  _focalPoint = widget.getMoveOffset();
                  _lastFocalPoint = details.focalPoint;
                  _lastScale = widget.getZoom();
                });
              }
            : null,
        onScaleUpdate: widget.getCanMove()
            ? (details) {
                setState(() {
                  double scale = _lastScale * details.scale;
                  widget.setZoom(scale < 0.1 ? 0.1 : scale);
                  widget.setMoveOffset(
                    Offset(
                      _focalPoint.dx +
                          details.focalPoint.dx -
                          _lastFocalPoint.dx,
                      _focalPoint.dy +
                          details.focalPoint.dy -
                          _lastFocalPoint.dy,
                    ),
                  );
                });
              }
            : null,
        onScaleEnd: widget.getCanMove()
            ? (details) {
                widget.setIsScaling(false);
                if (_oldzoom != widget.getZoom()) {
                  widget.onChanged();
                }
              }
            : null,
        child: DragTarget(
          key: _pkey,
          builder: (context, candidateData, rejectedData) {
            return Container(
              key: _mapStackKey,
              color: widget.getBackgroundColor(),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(
                        x +
                            widget.getMoveOffset().dx -
                            widget.getMindMapPadding() * widget.getZoom(),
                        y +
                            widget.getMoveOffset().dy -
                            widget.getMindMapPadding() * widget.getZoom(),
                      ),
                      child: Transform.scale(
                        scale: widget.getZoom(),
                        alignment: Alignment.topLeft,
                        child: RepaintBoundary(
                          key: widget._key,
                          child: Container(
                            color: widget.getBackgroundColor(),
                            // Separate the painter from the node hit-test layer.
                            // CustomPaint.hitTest rejects positions outside its
                            // bounds, which blocks root nodes at negative canvas
                            // offsets. By making CustomPaint a Positioned.fill
                            // sibling and wrapping both in a Clip.none Stack,
                            // the node Container is tested independently of the
                            // painter's bounds.
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: widget.getMapType() == MapType.mind
                                        ? MindMapPainter(mindMap: widget)
                                        : FishbonePainter(mindMap: widget),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(
                                    widget.getMapType() == MapType.mind
                                        ? widget.getMindMapPadding() *
                                              widget.getZoom()
                                        : 0,
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: widget.getRootNodes().map((
                                      rootNode,
                                    ) {
                                      return _DraggableRootNode(
                                        key: ValueKey(
                                          'drag_root_${rootNode.getID()}',
                                        ),
                                        rootNode: rootNode,
                                        mindMap: widget,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ), // closes Transform.scale
                    ), // closes Transform.translate
                  ), // closes Positioned.fill

                  widget.getWatermark().isEmpty
                      ? Container()
                      : Positioned.fill(
                          child: IgnorePointer(
                            child: ClipRect(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Row(
                                    children: List.generate(20, (index) {
                                      return Column(
                                        children: List.generate(20, (index) => "Item $index")
                                            .map(
                                              (item) => Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Transform.rotate(
                                                        angle: widget
                                                            .getWatermarkRotationAngle(),
                                                        child: Opacity(
                                                          opacity: widget
                                                              .getWatermarkOpacity(),
                                                          child: Text(
                                                            widget
                                                                .getWatermark(),
                                                            style: TextStyle(
                                                              color: widget
                                                                  .getWatermarkColor(),
                                                              fontSize: widget
                                                                  .getWatermarkFontSize(),
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors
                                                                      .white,
                                                                  offset: Offset
                                                                      .zero,
                                                                  blurRadius: 3,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: widget
                                                            .getWatermarkHorizontalInterval(),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: widget
                                                        .getWatermarkVerticalInterval(),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      widget.getToolbarPadding(),
                      20,
                      0,
                    ),
                    height: 32 + widget.getToolbarPadding(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MediaQuery.of(context).size.width > 600
                            ? Container()
                            : Spacer(),

                        ///Recycle
                        widget.getReadOnly() || !widget.getShowRecycle()
                            ? Container()
                            : DragTarget(
                                onWillAcceptWithDetails: (details) {
                                  if (!widget.getIsScaling() &&
                                      details.data is IMindMapNode) {
                                    setState(() {
                                      widget._inRecycle = true;
                                      widget._dragNode =
                                          details.data as IMindMapNode;
                                    });
                                    return true;
                                  }
                                  return false;
                                },
                                onAcceptWithDetails: (details) {
                                  if (!widget.getIsScaling() &&
                                      widget._dragNode != null) {
                                    if (widget._dragNode!.getNodeType() ==
                                        NodeType.root) {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: Text(
                                            widget.getDeleteNodeString(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                widget.getCancelString(),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                widget.removeRootNode(
                                                  widget._dragNode!,
                                                );
                                                setState(() {
                                                  widget._inRecycle = false;
                                                  widget._dragNode = null;
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: Text(widget.getOkString()),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        if (widget._dragNode!.getNodeType() ==
                                            NodeType.left) {
                                          widget._dragNode!
                                              .getParentNode()
                                              ?.removeLeftItem(
                                                widget._dragNode!,
                                              );
                                        } else {
                                          widget._dragNode!
                                              .getParentNode()
                                              ?.removeRightItem(
                                                widget._dragNode!,
                                              );
                                        }
                                        widget._inRecycle = false;
                                        widget._dragNode = null;
                                      });
                                    }
                                  }
                                },
                                onLeave: (data) {
                                  setState(() {
                                    widget._inRecycle = false;
                                  });
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: widget._inRecycle
                                                ? Colors.red
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          8,
                                          0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_outline_outlined,
                                              size: 20,
                                              color: widget._inRecycle
                                                  ? Colors.red
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.outline,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              widget.getRecycleTitle(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: widget._inRecycle
                                                    ? Colors.red
                                                    : Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              ),
                        MediaQuery.of(context).size.width > 600
                            ? Container()
                            : Spacer(),
                        (widget.getShowZoom()
                            ? SizedBox(width: 20)
                            : Container()),

                        ///Zoom
                        widget.getShowZoom()
                            ? Container(
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                  maxHeight: 32,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: ToggleButtons(
                                  constraints: const BoxConstraints.tightFor(
                                    height: 32,
                                    width: 32,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  borderColor: Theme.of(
                                    context,
                                  ).colorScheme.outline,
                                  isSelected: const [false, false, false],
                                  onPressed: (index) {
                                    switch (index) {
                                      case 0:
                                        if (widget.getZoom() > 0.2 && mounted) {
                                          setState(() {
                                            widget.setZoom(
                                              widget.getZoom() - 0.1,
                                            );
                                            widget.onChanged();
                                          });
                                        }
                                        break;
                                      case 1:
                                        setState(() {
                                          widget.setMoveOffset(Offset.zero);
                                          if (widget.getZoom() != 1) {
                                            widget.setZoom(1);
                                            widget.onChanged();
                                          }
                                        });
                                      case 2:
                                        if (widget.getZoom() < 2 && mounted) {
                                          setState(() {
                                            widget.setZoom(
                                              widget.getZoom() + 0.1,
                                            );
                                            widget.onChanged();
                                          });
                                        }
                                        break;
                                    }
                                  },
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      size: 16,
                                      shadows: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          blurRadius: 4.0,
                                          blurStyle: BlurStyle.outer,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${(widget.getZoom() * 100).round()}%",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            fontSize: 8,
                                            shadows: [
                                              BoxShadow(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                                blurRadius: 4.0,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                            ],
                                          ),
                                    ),
                                    Icon(
                                      Icons.add,
                                      size: 16,
                                      shadows: [
                                        BoxShadow(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          blurRadius: 4.0,
                                          blurStyle: BlurStyle.outer,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          onWillAcceptWithDetails: (details) {
            if (!widget.getIsScaling() &&
                widget.getEnableNodeReparentOnDrag()) {
              switch (widget.getMapType()) {
                case MapType.mind:
                  if (details.data is IMindMapNode) {
                    setState(() {
                      widget._dragNode = details.data as IMindMapNode;
                    });
                    return true;
                  }
                  break;
                case MapType.fishbone:
                  break;
              }

              setState(() {
                widget._dragNode = null;
              });
            }
            return false;
          },
          onAcceptWithDetails: (details) {
            if (!widget.getIsScaling() &&
                widget.getEnableNodeReparentOnDrag()) {
              switch (widget.getMapType()) {
                case MapType.mind:
                  if (details.data is IMindMapNode) {
                    setState(() {
                      if (widget._dragInNode != null) {
                        if ((details.data as IMindMapNode).getNodeType() ==
                            NodeType.left) {
                          (details.data as IMindMapNode)
                              .getParentNode()
                              ?.removeLeftItem((details.data as IMindMapNode));
                        } else {
                          (details.data as IMindMapNode)
                              .getParentNode()
                              ?.removeRightItem((details.data as IMindMapNode));
                        }
                        if (widget._leftDrag) {
                          widget._dragInNode!.insertLeftItem(
                            (details.data as IMindMapNode),
                            _dragIndex,
                          );
                        } else {
                          widget._dragInNode!.insertRightItem(
                            (details.data as IMindMapNode),
                            _dragIndex,
                          );
                        }
                        for (IMindMapNode root in widget.getRootNodes()) {
                          root.refresh();
                        }
                        widget.onChanged();
                      }
                      widget.refresh();
                      widget._dragInNode = null;
                    });
                  }
                  break;
                case MapType.fishbone:
                  break;
              }
              setState(() {
                widget._dragNode = null;
              });
            }
          },
          onLeave: (data) {
            setState(() {
              widget._dragInNode = null;
              widget._dragNode = null;
            });
          },
          onMove: (details) {
            if (!widget.getIsScaling() &&
                widget.getEnableNodeReparentOnDrag()) {
              if (details.data is IMindMapNode) {
                widget._dragInNode = details.data as IMindMapNode;
                Size dataSize =
                    (details.data as IMindMapNode).getSize() ?? Size.zero;
                RenderObject? ro = widget._key.currentContext
                    ?.findRenderObject();
                widget._renderObject = ro;
                if (ro != null && ro is RenderBox) {
                  Offset r = ro.localToGlobal(Offset.zero);
                  Offset offset = Offset(
                    details.offset.dx -
                        r.dx +
                        dataSize.width +
                        (dataSize.width * widget.getZoom() / 2) -
                        dataSize.width / 2,
                    details.offset.dy - r.dy + dataSize.height / 2,
                  );

                  IMindMapNode? leftDragNode = inLeftDrag(
                    details.data as IMindMapNode,
                    offset,
                  );
                  if (leftDragNode != null &&
                      !isParent(details.data as IMindMapNode, leftDragNode)) {
                    setState(() {
                      widget._leftDrag = true;
                      widget._dragInNode = leftDragNode;
                      widget._dragOffset = offset;
                    });
                    return;
                  }

                  offset = Offset(
                    details.offset.dx -
                        r.dx -
                        (dataSize.width * widget.getZoom() / 2) +
                        dataSize.width / 2,
                    details.offset.dy - r.dy + dataSize.height / 2,
                  );

                  IMindMapNode? rightDragNode = inRightDrag(
                    details.data as IMindMapNode,
                    offset,
                  );
                  if (rightDragNode != null &&
                      !isParent(details.data as IMindMapNode, rightDragNode)) {
                    setState(() {
                      widget._leftDrag = false;
                      widget._dragInNode = rightDragNode;
                      widget._dragOffset = offset;
                    });
                    return;
                  }

                  setState(() {
                    widget._dragInNode = null;
                  });
                }
              }
            }
          },
        ),
      ),
    );
  }

  IMindMapNode? inLeftDrag(IMindMapNode node, Offset offset) {
    for (IMindMapNode root in widget.getRootNodes()) {
      IMindMapNode? result = inLeftDragByParentNode(node, offset, root);
      if (result != null) return result;
    }
    return null;
  }

  int _dragIndex = 0;

  IMindMapNode? inLeftDragByParentNode(
    IMindMapNode node,
    Offset offset,
    IMindMapNode parentNode,
  ) {
    Rect? rect = parentNode.getLeftArea();

    if (rect != null) {
      if (parentNode.getNodeType() == NodeType.root) {
        rect = Rect.fromLTRB(
          rect.left,
          rect.top - 200,
          rect.right,
          rect.bottom + 200,
        );
      }
      if (rect.top * widget.getZoom() <= offset.dy &&
          rect.left * widget.getZoom() <= offset.dx &&
          rect.bottom * widget.getZoom() >= offset.dy &&
          rect.right * widget.getZoom() >= offset.dx) {
        _dragIndex = 0;
        if (parentNode.getLeftItems().isNotEmpty) {
          _dragIndex = parentNode.getLeftItems().length;
          int index = 0;

          for (IMindMapNode n in parentNode.getLeftItems()) {
            Size? size = n.getSize();
            Offset o = n.getOffset() ?? Offset.zero;
            if (n.getRenderObject() is RenderBox) {
              Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
                Offset.zero,
                ancestor: widget._renderObject,
              );
              o = Offset(o.dx + po.dx, o.dy + po.dy);
            }
            if (o.dy * widget.getZoom() +
                    (size?.height ?? 0) * widget.getZoom() / 2 >
                offset.dy) {
              _dragIndex = index;
              break;
            }
            index++;
          }
        }
        if (node.getParentNode() == parentNode &&
            node.getNodeType() == NodeType.left) {
          int i = parentNode.getLeftItems().indexOf(node);
          if (i < _dragIndex && _dragIndex > 0) {
            _dragIndex--;
          }
        }
        return parentNode;
      }
      for (IMindMapNode cn in parentNode.getLeftItems()) {
        IMindMapNode? n = inLeftDragByParentNode(node, offset, cn);
        if (n != null) {
          return n;
        }
      }
    }
    return null;
  }

  IMindMapNode? inRightDrag(IMindMapNode node, Offset offset) {
    for (IMindMapNode root in widget.getRootNodes()) {
      IMindMapNode? result = inRightDragByParentNode(node, offset, root);
      if (result != null) return result;
    }
    return null;
  }

  IMindMapNode? inRightDragByParentNode(
    IMindMapNode node,
    Offset offset,
    IMindMapNode parentNode,
  ) {
    Rect? rect = parentNode.getRightArea();

    if (rect != null) {
      if (parentNode.getNodeType() == NodeType.root) {
        rect = Rect.fromLTRB(
          rect.left,
          rect.top - 200,
          rect.right,
          rect.bottom + 200,
        );
      }
      if (rect.top * widget.getZoom() <= offset.dy &&
          rect.left * widget.getZoom() <= offset.dx &&
          rect.bottom * widget.getZoom() >= offset.dy &&
          rect.right * widget.getZoom() >= offset.dx) {
        _dragIndex = 0;
        if (parentNode.getRightItems().isNotEmpty) {
          _dragIndex = parentNode.getRightItems().length;
          int index = 0;

          for (IMindMapNode n in parentNode.getRightItems()) {
            Size? size = n.getSize();
            Offset o = n.getOffset() ?? Offset.zero;
            if (n.getRenderObject() is RenderBox) {
              Offset po = (n.getRenderObject() as RenderBox).localToGlobal(
                Offset.zero,
                ancestor: widget._renderObject,
              );
              o = Offset(o.dx + po.dx, o.dy + po.dy);
            }
            if (o.dy * widget.getZoom() +
                    (size?.height ?? 0) * widget.getZoom() / 2 >
                offset.dy) {
              _dragIndex = index;
              break;
            }
            index++;
          }
        }
        if (node.getParentNode() == parentNode &&
            node.getNodeType() == NodeType.right) {
          int i = parentNode.getRightItems().indexOf(node);
          if (i < _dragIndex && _dragIndex > 0) {
            _dragIndex--;
          }
        }
        return parentNode;
      }
      for (IMindMapNode cn in parentNode.getRightItems()) {
        IMindMapNode? n = inRightDragByParentNode(node, offset, cn);
        if (n != null) {
          return n;
        }
      }
    }
    return null;
  }

  bool isParent(IMindMapNode node, IMindMapNode dragNode) {
    IMindMapNode? parent = dragNode;
    while (parent != null) {
      if (parent == node) {
        return true;
      }
      parent = parent.getParentNode();
    }
    return false;
  }

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
}

class MindMapPainter extends CustomPainter {
  MindMapPainter({required this.mindMap});

  MindMap mindMap;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = mindMap.getDragInBorderWidth()
      ..color = mindMap.getDragInBorderColor();
    if (mindMap.getEnableNodeReparentOnDrag() &&
        mindMap._dragInNode != null &&
        !mindMap.getIsScaling()) {
      ///canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
      RenderObject? ro = mindMap._dragInNode!.getRenderObject();
      if (ro != null && mindMap._renderObject != null) {
        Offset o = (ro as RenderBox).localToGlobal(
          Offset.zero,
          ancestor: mindMap._renderObject,
        );
        Path path = Path();
        path.addRRect(
          RRect.fromLTRBR(
            o.dx +
                (mindMap._dragInNode!.getOffset()?.dx ?? 0) -
                3 -
                mindMap.getDragInBorderWidth(),
            o.dy +
                (mindMap._dragInNode!.getOffset()?.dy ?? 0) -
                3 -
                mindMap.getDragInBorderWidth(),
            o.dx +
                (mindMap._dragInNode!.getOffset()?.dx ?? 0) +
                (mindMap._dragInNode!.getSize()?.width ?? 0) +
                3 +
                mindMap.getDragInBorderWidth(),
            o.dy +
                (mindMap._dragInNode!.getOffset()?.dy ?? 0) +
                (mindMap._dragInNode!.getSize()?.height ?? 0) +
                3 +
                mindMap.getDragInBorderWidth(),
            Radius.circular(6),
          ),
        );
        canvas.drawPath(
          dashPath(
            path,
            dashArray: CircularIntervalList<double>(<double>[10, 10]),
          ),
          paint,
        );
        if (mindMap._dragOffset != null) {
          Path pathline = Path();
          double x1 = mindMap._dragOffset!.dx / mindMap.getZoom();
          double y1 = mindMap._dragOffset!.dy / mindMap.getZoom();
          double x2 =
              o.dx +
              (mindMap._dragInNode!.getOffset()?.dx ?? 0) +
              (mindMap._leftDrag
                  ? 0
                  : (mindMap._dragInNode!.getSize()?.width ?? 0));
          double y2 =
              o.dy +
              (mindMap._dragInNode!.getOffset()?.dy ?? 0) +
              (mindMap._dragInNode!.getSize()?.height ?? 0) / 2 +
              (mindMap._dragInNode!.getLinkOutOffset());
          pathline.moveTo(
            mindMap._dragOffset!.dx / mindMap.getZoom(),
            mindMap._dragOffset!.dy / mindMap.getZoom(),
          );
          pathline.cubicTo(
            x1 + (x2 - x1) / 2,
            y1,
            x2 - (x2 - x1) / 2,
            y2,
            x2,
            y2,
          );
          canvas.drawPath(
            dashPath(
              pathline,
              dashArray: CircularIntervalList<double>(<double>[10, 10]),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class FishbonePainter extends CustomPainter {
  FishbonePainter({required this.mindMap});

  MindMap mindMap;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (mindMap.getFishboneMapType() == FishboneMapType.leftToRight) {
      Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = mindMap.getRootNode().getLinkWidth() <= 0
            ? 2
            : mindMap.getRootNode().getLinkWidth()
        ..color = mindMap.getRootNode().getLinkColor() == Colors.transparent
            ? Colors.black
            : mindMap.getRootNode().getLinkColor();

      Offset offset = mindMap.getRootNode().getOffset() ?? Offset.zero;
      double dx = mindMap.getRootNode().getFishbonePosition().dx - offset.dx;
      double dy = mindMap.getRootNode().getFishbonePosition().dy - offset.dy;

      double left = offset.dx + (mindMap.getRootNode().getSize()?.width ?? 0);
      double top =
          offset.dy + (mindMap.getRootNode().getSize()?.height ?? 0) / 2;
      canvas.drawLine(
        Offset(
          left +
              dx +
              (mindMap.getRootNode() is MindMapNode
                  ? ((mindMap.getRootNode() as MindMapNode).getBorder()
                            as Border)
                        .left
                        .width
                  : 0),
          top + dy,
        ),
        Offset(
          mindMap.getFishboneSize().width -
              (mindMap.getRootNode() is MindMapNode
                  ? (mindMap.getRootNode() as MindMapNode).getImage2Width()
                  : 0) +
              dx,
          top + dy,
        ),
        paint,
      );
      List<IMindMapNode> items = [];
      items.addAll(mindMap.getRootNode().getRightItems());
      for (int i = 0; i < mindMap.getRootNode().getLeftItems().length; i++) {
        IMindMapNode node =
            mindMap.getRootNode().getLeftItems()[mindMap
                    .getRootNode()
                    .getLeftItems()
                    .length -
                i -
                1];
        items.add(node);
      }
      for (IMindMapNode node in items) {
        if (node.getFishboneNodeMode() == FishboneNodeMode.up) {
          Paint paint1 = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = node.getLinkWidth() <= 0 ? 2 : node.getLinkWidth()
            ..color = node.getLinkColor() == Colors.transparent
                ? Colors.black
                : node.getLinkColor();
          double l =
              node.getFishbonePosition().dx + (node.getSize()?.width ?? 0) / 2;
          double t =
              node.getFishbonePosition().dy + (node.getSize()?.height ?? 0);
          double h = top - t - dy;
          Offset p1 = Offset(
            l +
                dx -
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
            t +
                dy +
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
          );
          Offset p2 = Offset(l + dx - h, top);
          canvas.drawLine(p1, p2, paint1);
          //Child Line
          List<IMindMapNode> childs = [];
          childs.addAll(node.getRightItems());
          childs.addAll(node.getLeftItems());
          for (IMindMapNode child in childs) {
            Paint paint2 = Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = child.getLinkWidth() <= 0
                  ? 2
                  : child.getLinkWidth()
              ..color = child.getLinkColor() == Colors.transparent
                  ? Colors.black
                  : child.getLinkColor();
            double t2 =
                child.getLinkInOffset() +
                child.getFishbonePosition().dy +
                (child.getSize()?.height ?? 0) / 2;
            double h1 =
                node.getHSpace() +
                (child.getSize()?.height ?? 0) / 2 +
                child.getLinkInOffset();
            canvas.drawLine(
              Offset(
                child.getFishbonePosition().dx -
                    h1 +
                    dx -
                    mindMap.getRootNode().getLinkWidth(),
                t2 + dy,
              ),
              Offset(
                child.getFishbonePosition().dx +
                    dx -
                    (child is MindMapNode
                        ? ((child.getBorder() as Border).left.width)
                        : 0),
                t2 + dy,
              ),
              paint2,
            );
            drawChildLine(child, canvas);
          }
        } else {
          Paint paint1 = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = node.getLinkWidth() <= 0 ? 2 : node.getLinkWidth()
            ..color = node.getLinkColor() == Colors.transparent
                ? Colors.black
                : node.getLinkColor();
          double l =
              node.getFishbonePosition().dx + (node.getSize()?.width ?? 0) / 2;
          double t = node.getFishbonePosition().dy;
          double h = t + dy - top;
          Offset p1 = Offset(
            l +
                dx -
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
            t +
                dy -
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
          );
          Offset p2 = Offset(l + dx - h, top);
          canvas.drawLine(p1, p2, paint1);
          //Child Line
          List<IMindMapNode> childs = [];
          childs.addAll(node.getRightItems());
          childs.addAll(node.getLeftItems());
          for (IMindMapNode child in childs) {
            Paint paint2 = Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = child.getLinkWidth() <= 0
                  ? 2
                  : child.getLinkWidth()
              ..color = child.getLinkColor() == Colors.transparent
                  ? Colors.black
                  : child.getLinkColor();
            double t2 =
                child.getLinkInOffset() +
                child.getFishbonePosition().dy +
                (child.getSize()?.height ?? 0) / 2;
            double h1 =
                node.getHSpace() +
                (child.getSize()?.height ?? 0) / 2 -
                child.getLinkInOffset() +
                child.getFishboneHeight();
            canvas.drawLine(
              Offset(
                child.getFishbonePosition().dx -
                    h1 +
                    dx -
                    mindMap.getRootNode().getLinkWidth(),
                t2 + dy,
              ),
              Offset(
                child.getFishbonePosition().dx +
                    dx -
                    (child is MindMapNode
                        ? ((child.getBorder() as Border).left.width)
                        : 0),
                t2 + dy,
              ),
              paint2,
            );
            drawChildLine(child, canvas);
          }
        }
      }
    } else {
      Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = mindMap.getRootNode().getLinkWidth() <= 0
            ? 2
            : mindMap.getRootNode().getLinkWidth()
        ..color = mindMap.getRootNode().getLinkColor() == Colors.transparent
            ? Colors.black
            : mindMap.getRootNode().getLinkColor();

      Offset offset = mindMap.getRootNode().getOffset() ?? Offset.zero;
      double dx = mindMap.getRootNode().getFishbonePosition().dx - offset.dx;
      double dy = mindMap.getRootNode().getFishbonePosition().dy - offset.dy;

      double right = offset.dx;
      double top =
          offset.dy + (mindMap.getRootNode().getSize()?.height ?? 0) / 2;
      canvas.drawLine(
        Offset(
          right -
              (mindMap.getRootNode() is MindMapNode
                  ? ((mindMap.getRootNode() as MindMapNode).getBorder()
                            as Border)
                        .left
                        .width
                  : 0),
          top,
        ),
        Offset(
          (mindMap.getRootNode() is MindMapNode
              ? (mindMap.getRootNode() as MindMapNode).getImage2Width()
              : 0),
          top,
        ),
        paint,
      );
      List<IMindMapNode> items = [];
      items.addAll(mindMap.getRootNode().getLeftItems());
      for (int i = 0; i < mindMap.getRootNode().getRightItems().length; i++) {
        IMindMapNode node =
            mindMap.getRootNode().getRightItems()[mindMap
                    .getRootNode()
                    .getRightItems()
                    .length -
                i -
                1];
        items.add(node);
      }
      for (IMindMapNode node in items) {
        if (node.getFishboneNodeMode() == FishboneNodeMode.up) {
          Paint paint1 = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = node.getLinkWidth() <= 0 ? 2 : node.getLinkWidth()
            ..color = node.getLinkColor() == Colors.transparent
                ? Colors.black
                : node.getLinkColor();

          double l =
              node.getFishbonePosition().dx + (node.getSize()?.width ?? 0) / 2;
          double t =
              node.getFishbonePosition().dy + (node.getSize()?.height ?? 0);
          double h = top - t - dy;
          Offset p1 = Offset(
            l +
                dx +
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
            t +
                dy +
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
          );
          Offset p2 = Offset(l + dx + h, top);
          canvas.drawLine(p1, p2, paint1);
          //Child Line
          List<IMindMapNode> childs = [];
          childs.addAll(node.getRightItems());
          childs.addAll(node.getLeftItems());
          for (IMindMapNode child in childs) {
            Paint paint2 = Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = child.getLinkWidth() <= 0
                  ? 2
                  : child.getLinkWidth()
              ..color = child.getLinkColor() == Colors.transparent
                  ? Colors.black
                  : child.getLinkColor();
            double t2 =
                child.getLinkInOffset() +
                child.getFishbonePosition().dy +
                (child.getSize()?.height ?? 0) / 2;
            double h1 =
                node.getHSpace() +
                (child.getSize()?.height ?? 0) / 2 +
                child.getLinkInOffset();
            canvas.drawLine(
              Offset(
                child.getFishbonePosition().dx +
                    (child.getSize()?.width ?? 0) +
                    h1 +
                    mindMap.getRootNode().getLinkWidth(),
                t2,
              ),
              Offset(
                child.getFishbonePosition().dx +
                    (child.getSize()?.width ?? 0) +
                    (child is MindMapNode
                        ? ((child.getBorder() as Border).left.width)
                        : 0),
                t2,
              ),
              paint2,
            );
            drawChildLine(child, canvas);
          }
        } else {
          Paint paint1 = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = node.getLinkWidth() <= 0 ? 2 : node.getLinkWidth()
            ..color = node.getLinkColor() == Colors.transparent
                ? Colors.black
                : node.getLinkColor();
          double l =
              node.getFishbonePosition().dx + (node.getSize()?.width ?? 0) / 2;
          double t = node.getFishbonePosition().dy;
          double h = t + dy - top;
          Offset p1 = Offset(
            l +
                dx +
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
            t +
                dy -
                (node is MindMapNode ? (node.getBorder().bottom.width) : 0),
          );
          Offset p2 = Offset(l + dx + h, top);
          canvas.drawLine(p1, p2, paint1);
          //Child Line
          List<IMindMapNode> childs = [];
          childs.addAll(node.getRightItems());
          childs.addAll(node.getLeftItems());
          for (IMindMapNode child in childs) {
            Paint paint2 = Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = child.getLinkWidth() <= 0
                  ? 2
                  : child.getLinkWidth()
              ..color = child.getLinkColor() == Colors.transparent
                  ? Colors.black
                  : child.getLinkColor();
            double t2 =
                child.getLinkInOffset() +
                child.getFishbonePosition().dy +
                (child.getSize()?.height ?? 0) / 2;
            double h1 =
                (child.getSize()?.height ?? 0) / 2 -
                child.getLinkInOffset() +
                child.getFishboneHeight();
            canvas.drawLine(
              Offset(
                child.getFishbonePosition().dx +
                    (child.getSize()?.width ?? 0) +
                    h1 +
                    node.getHSpace() +
                    mindMap.getRootNode().getLinkWidth(),
                t2,
              ),
              Offset(
                child.getFishbonePosition().dx +
                    (child.getSize()?.width ?? 0) +
                    (child is MindMapNode
                        ? ((child.getBorder() as Border).left.width)
                        : 0),
                t2,
              ),
              paint2,
            );
            drawChildLine(child, canvas);
          }
        }
      }
    }
  }

  void drawChildLine(IMindMapNode node, ui.Canvas canvas) {
    List<IMindMapNode> childs = [];
    childs.addAll(node.getRightItems());
    childs.addAll(node.getLeftItems());
    double t = node.getFishbonePosition().dy + (node.getSize()?.height ?? 0);
    for (IMindMapNode child in childs) {
      Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = child.getLinkWidth() <= 0 ? 2 : child.getLinkWidth()
        ..color = child.getLinkColor() == Colors.transparent
            ? Colors.black
            : child.getLinkColor();
      if (mindMap.getFishboneMapType() == FishboneMapType.leftToRight) {
        double t2 =
            child.getLinkInOffset() +
            child.getFishbonePosition().dy +
            (child.getSize()?.height ?? 0) / 2;
        canvas.drawLine(
          Offset(child.getFishbonePosition().dx - node.getHSpace() / 2, t),
          Offset(child.getFishbonePosition().dx - node.getHSpace() / 2, t2),
          paint,
        );
        canvas.drawLine(
          Offset(child.getFishbonePosition().dx - node.getHSpace() / 2, t2),
          Offset(child.getFishbonePosition().dx, t2),
          paint,
        );
        drawChildLine(child, canvas);
      } else {
        double t2 =
            child.getLinkInOffset() +
            child.getFishbonePosition().dy +
            (child.getSize()?.height ?? 0) / 2;
        canvas.drawLine(
          Offset(
            child.getFishbonePosition().dx +
                (child.getSize()?.width ?? 0) +
                node.getHSpace() / 2,
            t,
          ),
          Offset(
            child.getFishbonePosition().dx +
                (child.getSize()?.width ?? 0) +
                node.getHSpace() / 2,
            t2,
          ),
          paint,
        );
        canvas.drawLine(
          Offset(
            child.getFishbonePosition().dx +
                (child.getSize()?.width ?? 0) +
                node.getHSpace() / 2,
            t2,
          ),
          Offset(
            child.getFishbonePosition().dx + (child.getSize()?.width ?? 0),
            t2,
          ),
          paint,
        );
        drawChildLine(child, canvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

enum MapType { mind, fishbone }

enum MindMapType { left, leftAndRight, right }

enum FishboneMapType { leftToRight, rightToLeft }

/// Wraps a root node in the multi-root [Stack] so it can be panned independently.
/// A single-finger drag on the node moves only that root node; the outer canvas
/// pan gesture is blocked by absorbing the pointer event.
class _DraggableRootNode extends StatefulWidget {
  const _DraggableRootNode({
    super.key,
    required this.rootNode,
    required this.mindMap,
  });

  final IMindMapNode rootNode;
  final MindMap mindMap;

  @override
  State<_DraggableRootNode> createState() => _DraggableRootNodeState();
}

class _DraggableRootNodeState extends State<_DraggableRootNode> {
  /// Visual offset during drag; synced from mindMap on non-drag rebuilds.
  late Offset _visualOffset;
  Offset _startCanvasOffset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  bool _dragging = false;

  // Current hovered drop target while panning this root node.
  IMindMapNode? _dropTarget;
  bool _dropIsLeft = true;
  Offset _lastPointerInMindMap = Offset.zero;

  bool _isAncestor(IMindMapNode ancestor, IMindMapNode node) {
    IMindMapNode? cur = node;
    while (cur != null) {
      if (cur == ancestor) return true;
      cur = cur.getParentNode();
    }
    return false;
  }

  void _clearDropHint() {
    _dropTarget = null;
    widget.mindMap._dragInNode = null;
    widget.mindMap._dragOffset = null;
    // Keep _leftDrag as-is.
  }

  void _updateDropHint(Offset globalPointer) {
    if (!widget.mindMap.getCanMoveRootNodes() ||
        !widget.mindMap.getEnableNodeReparentOnDrag() ||
        widget.mindMap.getIsScaling()) {
      _clearDropHint();
      return;
    }

    final RenderObject? mapRo = widget.mindMap._key.currentContext
        ?.findRenderObject();

    widget.mindMap._renderObject = mapRo;

    final RenderBox? mapBox = mapRo is RenderBox ? mapRo : null;
    final Offset pointerInMap =
        mapBox != null ? mapBox.globalToLocal(globalPointer) : globalPointer;
    _lastPointerInMindMap = pointerInMap;

    // Set drag line start point for the dashed "prompt" painter.
    final Size rootSize = widget.rootNode.getSize() ?? Size.zero;
    final double zoom = widget.mindMap.getZoom();
    if (mapRo is RenderBox) {
      final Offset r = mapRo.localToGlobal(Offset.zero);
      widget.mindMap._dragOffset = Offset(
        globalPointer.dx -
            r.dx +
            rootSize.width +
            (rootSize.width * zoom / 2) -
            rootSize.width / 2,
        globalPointer.dy - r.dy + rootSize.height / 2,
      );
    } else {
      widget.mindMap._dragOffset = Offset(
        globalPointer.dx,
        globalPointer.dy,
      );
    }

    IMindMapNode? bestTarget;
    bool bestIsLeft = true;
    double bestDist = double.infinity;

    // Collect all nodes in all root trees (including roots).
    void visit(IMindMapNode node) {
      // Skip: don't insert into itself or its descendants.
      if (node == widget.rootNode) return;
      if (_isAncestor(widget.rootNode, node)) return;

      final Rect? leftRect = node.getLeftArea();
      final Rect? rightRect = node.getRightArea();
      final bool inLeft = leftRect?.contains(pointerInMap) ?? false;
      final bool inRight = rightRect?.contains(pointerInMap) ?? false;
      if (!inLeft && !inRight) return;

      final Rect rect = inLeft ? leftRect! : rightRect!;
      final double dist =
          (rect.center - pointerInMap).distanceSquared;
      if (dist < bestDist) {
        bestDist = dist;
        bestTarget = node;
        bestIsLeft = inLeft;
      }
    }

    void collect(IMindMapNode root) {
      visit(root);
      for (final IMindMapNode child in [...root.getLeftItems(), ...root.getRightItems()]) {
        collect(child);
      }
    }

    for (final IMindMapNode root in widget.mindMap.getRootNodes()) {
      collect(root);
      // Early exit if you want (kept full scan for correctness).
    }

    if (bestTarget != null) {
      _dropTarget = bestTarget;
      _dropIsLeft = bestIsLeft;
      widget.mindMap._dragInNode = bestTarget;
      widget.mindMap._leftDrag = bestIsLeft;
    } else {
      _clearDropHint();
    }
  }

  @override
  void initState() {
    super.initState();
    _visualOffset = widget.mindMap.getRootNodeCanvasOffset(widget.rootNode);
  }

  @override
  void didUpdateWidget(covariant _DraggableRootNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When not dragging, keep visual offset in sync with external changes
    // (e.g. loadData resets positions).
    if (!_dragging) {
      _visualOffset = widget.mindMap.getRootNodeCanvasOffset(widget.rootNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canMove = widget.mindMap.getCanMoveRootNodes();
    return Positioned(
      left: _visualOffset.dx,
      top: _visualOffset.dy,
      // ClipRect is critical for correct multi-root hit testing.
      // The inner node widget uses HitTestBehavior.opaque, whose hitTestSelf
      // returns true for ANY position. Without ClipRect, the last root node
      // in the Stack (tested first due to reverse iteration) would capture
      // every touch globally. ClipRect.hitTest() explicitly checks
      // size.contains(position) and returns false when outside the node's
      // bounds, allowing touches on other root nodes to reach them correctly.
      child: ClipRect(
        child: GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onPanStart: canMove
              ? (details) {
                  _dragging = true;
                  _startFocalPoint = details.globalPosition;
                  _startCanvasOffset = widget.mindMap.getRootNodeCanvasOffset(
                    widget.rootNode,
                  );
                  _updateDropHint(details.globalPosition);
                }
              : null,
          onPanUpdate: canMove
              ? (details) {
                  if (!_dragging) return;
                  final zoom = widget.mindMap.getZoom();
                  final delta =
                      (details.globalPosition - _startFocalPoint) / zoom;
                  setState(() {
                    _visualOffset = _startCanvasOffset + delta;
                  });
                  _updateDropHint(details.globalPosition);
                }
              : null,
          onPanEnd: canMove
              ? (_) {
                  _dragging = false;

                  // If we're hovering a valid target, re-parent this root as its child.
                  if (_dropTarget != null) {
                    final IMindMapNode target = _dropTarget!;
                    final int index;
                    final List<IMindMapNode> siblings =
                        _dropIsLeft ? target.getLeftItems() : target.getRightItems();

                    // Best-effort insert order by pointer Y within the target's rendered list.
                    index = (() {
                      final RenderObject? mapRo = widget.mindMap._key.currentContext
                          ?.findRenderObject();
                      final RenderBox? mapBox = mapRo is RenderBox ? mapRo : null;
                      if (mapBox == null || siblings.isEmpty) return siblings.length;

                      for (int i = 0; i < siblings.length; i++) {
                        final RenderObject? childRo =
                            siblings[i].getRenderObject();
                        if (childRo is! RenderBox) continue;
                        final RenderBox childBox = childRo;
                        final Offset childInMap =
                            childBox.localToGlobal(
                          Offset.zero,
                          ancestor: mapRo,
                        );
                        final double childCenterY =
                            childInMap.dy + (siblings[i].getSize()?.height ?? 0) / 2;
                        if (_lastPointerInMindMap.dy < childCenterY) {
                          return i;
                        }
                      }
                      return siblings.length;
                    })();

                    widget.mindMap.removeRootNode(widget.rootNode);
                    if (_dropIsLeft) {
                      target.insertLeftItem(widget.rootNode, index);
                    } else {
                      target.insertRightItem(widget.rootNode, index);
                    }
                    _clearDropHint();
                    widget.mindMap.onMove();
                    return;
                  }

                  // Otherwise, persist final position (keeps root as root).
                  widget.mindMap.setRootNodeCanvasOffset(
                    widget.rootNode,
                    _visualOffset,
                  );
                }
              : null,
          onPanCancel: canMove
              ? () {
                  // Revert to last persisted position on cancel.
                  setState(() {
                    _dragging = false;
                    _visualOffset = widget.mindMap.getRootNodeCanvasOffset(
                      widget.rootNode,
                    );
                  });
                  _clearDropHint();
                }
              : null,
          child: widget.rootNode as Widget,
        ), // closes GestureDetector
      ), // closes ClipRect
    ); // closes Positioned
  }
}
