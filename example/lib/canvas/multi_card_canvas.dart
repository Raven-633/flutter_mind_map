import 'dart:async';

import 'package:flutter/material.dart';

// ── 数据模型 ──────────────────────────────────────────────────────────────────

class CardModel {
  CardModel({
    required this.id,
    required this.title,
    required this.color,
    required this.offset,
    this.width = 160,
    this.height = 90,
  });

  final String id;
  final String title;
  final Color color;
  Offset offset;
  final double width;
  final double height;
}

// ── 页面入口 ──────────────────────────────────────────────────────────────────

class MultiCardCanvasPage extends StatelessWidget {
  const MultiCardCanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('多卡片画布：缩放 + 长按拖拽')),
      body: const MultiCardCanvas(),
    );
  }
}

// ── 画布主体 ──────────────────────────────────────────────────────────────────

class MultiCardCanvas extends StatefulWidget {
  const MultiCardCanvas({super.key});

  @override
  State<MultiCardCanvas> createState() => _MultiCardCanvasState();
}

class _MultiCardCanvasState extends State<MultiCardCanvas> {
  final TransformationController _transformController =
      TransformationController();

  // 用于获取 InteractiveViewer 在屏幕上的位置（坐标转换必需）
  final GlobalKey _viewerKey = GlobalKey();

  // ── 拖拽状态 ────────────────────────────────────────────────────────────────

  String? _draggingId;
  Offset _dragStartInCanvas = Offset.zero;
  Offset _cardStartOffset = Offset.zero;

  // ── 长按计时器（用于绕开手势竞技场冲突） ──────────────────────────────────────

  Timer? _longPressTimer;
  // 手指按下时的全局坐标（用于判断是否移动超过阈值）
  Offset _pointerDownGlobal = Offset.zero;
  // 是否已触发长按（进入拖拽模式）
  bool _longPressTriggered = false;
  // 当前按下的指针 ID（多点触控时只跟踪第一根手指）
  int? _activePointer;

  // 长按阈值：500ms，移动容差：10 逻辑像素
  static const Duration _longPressDuration = Duration(milliseconds: 500);
  static const double _moveSlop = 10.0;

  // ── 卡片数据 ────────────────────────────────────────────────────────────────

  final List<CardModel> _cards = [
    CardModel(
      id: 'a',
      title: '卡片 A',
      color: const Color(0xFF5C6BC0),
      offset: const Offset(60, 80),
    ),
    CardModel(
      id: 'b',
      title: '卡片 B',
      color: const Color(0xFF26A69A),
      offset: const Offset(280, 60),
    ),
    CardModel(
      id: 'c',
      title: '卡片 C',
      color: const Color(0xFFEF5350),
      offset: const Offset(160, 240),
    ),
    CardModel(
      id: 'd',
      title: '卡片 D',
      color: const Color(0xFFFF7043),
      offset: const Offset(400, 220),
    ),
    CardModel(
      id: 'e',
      title: '卡片 E',
      color: const Color(0xFF8D6E63),
      offset: const Offset(80, 380),
    ),
  ];

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _transformController.dispose();
    super.dispose();
  }

  // ── 坐标转换 ────────────────────────────────────────────────────────────────

  /// 屏幕（全局）坐标 → 画布坐标
  /// 步骤：全局坐标 → InteractiveViewer 本地坐标 → 逆矩阵变换到画布坐标
  Offset _toCanvas(Offset global) {
    final renderBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    final local =
        renderBox != null ? renderBox.globalToLocal(global) : global;
    final inverted = Matrix4.inverted(_transformController.value);
    return MatrixUtils.transformPoint(inverted, local);
  }

  // ── 命中测试 ────────────────────────────────────────────────────────────────

  CardModel? _hitTest(Offset canvasPos) {
    for (final card in _cards.reversed) {
      if (Rect.fromLTWH(card.offset.dx, card.offset.dy, card.width, card.height)
          .contains(canvasPos)) {
        return card;
      }
    }
    return null;
  }

  // ── 原始指针事件处理（绕开手势竞技场） ─────────────────────────────────────

  void _onPointerDown(PointerDownEvent event) {
    // 只处理第一根手指，多点触控交给 InteractiveViewer
    if (_activePointer != null) return;
    _activePointer = event.pointer;
    _pointerDownGlobal = event.position;
    _longPressTriggered = false;

    // 启动长按计时器
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, () {
      // 计时器到期时，检查当前是否仍命中某张卡片
      final canvasPos = _toCanvas(_pointerDownGlobal);
      final hit = _hitTest(canvasPos);
      if (hit == null) return;

      // 触发长按，进入拖拽模式
      _longPressTriggered = true;
      setState(() {
        _draggingId = hit.id;
        _dragStartInCanvas = canvasPos;
        _cardStartOffset = hit.offset;
        // 被拖拽的卡片置顶渲染
        _cards
          ..remove(hit)
          ..add(hit);
      });
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;

    // 若手指移动超过阈值，取消长按计时（视为滑动画布）
    final moved = (event.position - _pointerDownGlobal).distance;
    if (!_longPressTriggered && moved > _moveSlop) {
      _longPressTimer?.cancel();
      _activePointer = null;
      return;
    }

    // 已进入拖拽模式，更新卡片位置
    if (_longPressTriggered && _draggingId != null) {
      final canvasPos = _toCanvas(event.position);
      final delta = canvasPos - _dragStartInCanvas;
      setState(() {
        final card = _cards.firstWhere((c) => c.id == _draggingId);
        card.offset = _cardStartOffset + delta;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;
    _longPressTimer?.cancel();
    _activePointer = null;
    if (_longPressTriggered) {
      setState(() {
        _draggingId = null;
        _longPressTriggered = false;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) return;
    _longPressTimer?.cancel();
    _activePointer = null;
    if (_longPressTriggered) {
      setState(() {
        _draggingId = null;
        _longPressTriggered = false;
      });
    }
  }

  // ── 构建 ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 提示栏
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '滚轮 / 双指捏合 → 以鼠标为中心缩放    长按卡片（0.5s）→ 拖动',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // 画布区域
        Expanded(
          child: Listener(
            // Listener 直接捕获原始指针，不参与手势竞技场
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: InteractiveViewer(
              key: _viewerKey,
              transformationController: _transformController,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.2,
              maxScale: 4.0,
              // 拖拽卡片时禁用画布平移，避免画布跟着移动
              panEnabled: !_longPressTriggered,
              child: SizedBox(
                width: 800,
                height: 600,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const _GridBackground(width: 800, height: 600),
                    ..._cards.map(
                      (card) => Positioned(
                        left: card.offset.dx,
                        top: card.offset.dy,
                        child: _CardWidget(
                          card: card,
                          isDragging: card.id == _draggingId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 状态栏
        _StatusBar(
          draggingId: _draggingId,
          transformController: _transformController,
        ),
      ],
    );
  }
}

// ── 卡片 Widget ───────────────────────────────────────────────────────────────

class _CardWidget extends StatelessWidget {
  const _CardWidget({required this.card, required this.isDragging});

  final CardModel card;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: card.width,
      height: card.height,
      decoration: BoxDecoration(
        color: card.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.35 : 0.15),
            blurRadius: isDragging ? 16 : 6,
            offset: Offset(0, isDragging ? 6 : 2),
          ),
        ],
        border: isDragging ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Center(
        child: Text(
          card.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ── 背景网格 ──────────────────────────────────────────────────────────────────

class _GridBackground extends StatelessWidget {
  const _GridBackground({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    final linePaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = const Color(0xFFBBBBBB)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── 底部状态栏 ────────────────────────────────────────────────────────────────

class _StatusBar extends StatefulWidget {
  const _StatusBar({
    required this.draggingId,
    required this.transformController,
  });

  final String? draggingId;
  final TransformationController transformController;

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  @override
  void initState() {
    super.initState();
    widget.transformController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.transformController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final m = widget.transformController.value;
    final scale = m[0];
    final tx = m[12];
    final ty = m[13];

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            '缩放: ${scale.toStringAsFixed(2)}x  '
            '偏移: (${tx.toStringAsFixed(0)}, ${ty.toStringAsFixed(0)})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (widget.draggingId != null)
            Chip(
              label: Text('拖拽中: ${widget.draggingId}'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
