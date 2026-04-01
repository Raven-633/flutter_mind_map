import 'package:flutter/material.dart';

/// Draggable / DragTarget 基础交互示例。
class DraggableExamplePage extends StatefulWidget {
  const DraggableExamplePage({super.key});

  @override
  State<DraggableExamplePage> createState() => _DraggableExamplePageState();
}

class _DraggableExamplePageState extends State<DraggableExamplePage> {
  static const String _payload = 'chip';

  String? _targetText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Draggable 示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('拖动下方色块到虚线框内释放', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Center(
              child: Draggable<String>(
                data: _payload,
                feedback: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: _dragChip(colorScheme.primary, dragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _dragChip(colorScheme.primary),
                ),
                child: _dragChip(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: DragTarget<String>(
                onAcceptWithDetails: (details) {
                  setState(() {
                    _targetText = '已接收：${details.data}';
                  });
                },
                builder: (context, candidate, rejected) {
                  final active = candidate.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: active
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: active ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      _targetText ?? (active ? '松开以放置' : '拖到这里'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragChip(Color color, {bool dragging = false}) {
    return Container(
      width: dragging ? 100 : 88,
      height: dragging ? 100 : 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.touch_app,
        color: Colors.white.withValues(alpha: 0.95),
        size: 36,
      ),
    );
  }
}
