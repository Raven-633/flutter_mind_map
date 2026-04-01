import 'package:flutter/material.dart';

/// 独立路由页：带标题栏，可从「Canvas 学习」列表点击进入。
class CanvasDemo1Page extends StatelessWidget {
  const CanvasDemo1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基础绘制：圆'),
      ),
      body: const CanvasDemo1(),
    );
  }
}

/// 画布内容组件，也可嵌入其它页面。
class CanvasDemo1 extends StatelessWidget {
  const CanvasDemo1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(300, 300),
        painter: MyPainter(),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // 绘制一个圆，圆心在画布中心
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 80, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
