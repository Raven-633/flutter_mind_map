import 'package:flutter/material.dart';
import 'package:flutter_mind_map_example/canvas/canvas_examples_registry.dart';

/// Canvas 学习示例列表：点击标题进入对应示例页。
class CanvasDemoListPage extends StatelessWidget {
  const CanvasDemoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = registeredCanvasExamples;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canvas 学习'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('暂无示例，请在 canvas_examples_registry.dart 中登记'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: item.subtitle != null
                      ? Text(
                          item.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: item.builder,
                        settings: RouteSettings(name: '/canvas/${item.id}'),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
