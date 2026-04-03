import 'package:flutter/material.dart';
import 'package:flutter_mind_map_example/canvas/canvas_demo_list_page.dart';
import 'package:flutter_mind_map_example/draggable/draggable_example.dart';
import 'package:flutter_mind_map_example/mind_map_demo_page.dart';
import 'package:flutter_mind_map_example/multi_root_mind_map_only_page.dart';

/// 示例应用入口：选择 Mind Map 综合演示或进入 Canvas 学习列表。
class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Mind Map 示例')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '选择示例',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.account_tree_outlined,
            title: 'Mind Map 综合示例',
            subtitle: 'Custom、Theme、Fishbone、多根节点等，底部导航切换',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const MindMapDemoPage(),
                  settings: const RouteSettings(name: '/mind-map-demo'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.device_hub_outlined,
            title: '多根思维导图',
            subtitle: '仅思维导图（Mind），全屏画布、无鱼骨图',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const MultiRootMindMapOnlyPage(),
                  settings:
                      const RouteSettings(name: '/multi-root-mind-map-only'),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Flutter Canvas 学习',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '示例源码位于 example/lib/canvas/，在 canvas_examples_registry.dart 中登记后会在下列表中显示。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.brush_outlined,
            title: 'Canvas 学习',
            subtitle: '点击标题进入各小节（CustomPaint、绘制练习等）',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const CanvasDemoListPage(),
                  settings: const RouteSettings(name: '/canvas-list'),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            '手势与拖拽',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            '示例源码：example/lib/draggable/',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            icon: Icons.drag_indicator,
            title: 'Draggable 示例',
            subtitle: 'Draggable、DragTarget、拖动反馈与放置区域',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const DraggableExamplePage(),
                  settings: const RouteSettings(name: '/draggable-example'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
