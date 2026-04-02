import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mind_map_example/example_home_page.dart';

void main() {
  // 勿默认开启：会为每个布局画上彩色/虚线「框」，容易误以为只有框、内容没了。
  // 需要时在本机临时改为 true，或 DevTools 里开「Debug paint」。
  debugPaintSizeEnabled = true;

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mind Map Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}
