import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mind_map_example/custom_page.dart';
import 'package:flutter_mind_map_example/fishbone_page.dart';
import 'package:flutter_mind_map_example/multi_root_page.dart';
import 'package:flutter_mind_map_example/theme_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 原底部导航四页：Custom / Theme / Fishbone / Multi Root。
class MindMapDemoPage extends StatefulWidget {
  const MindMapDemoPage({super.key});

  @override
  State<MindMapDemoPage> createState() => _MindMapDemoPageState();
}

class _MindMapDemoPageState extends State<MindMapDemoPage> {
  final CustomPage customPage = CustomPage();
  final ThemePage themePage = ThemePage();
  final FishbonePage fishbonePage = FishbonePage();
  final MultiRootPage multiRootPage = MultiRootPage();

  int index = 0;
  bool readOnly = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await Permission.storage.request().isDenied) {
        debugPrint("storage denied");
      } else {
        debugPrint("permission");
      }
      if (await Permission.manageExternalStorage.request().isDenied) {
        debugPrint("manageExternalStorage denied");
      } else {
        debugPrint("permission");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        title: Text(
          'Mind Map 示例',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Row(
            children: [
              IconButton(
                tooltip: '重置当前页数据',
                onPressed: () async {
                  var prefs = await SharedPreferences.getInstance();
                  switch (index) {
                    case 0:
                      prefs.remove("Custom");
                      customPage.prefs = null;
                      await customPage.init();
                      break;
                    case 1:
                      prefs.remove("Theme");
                      themePage.prefs = null;
                      await themePage.init();
                      break;
                    case 2:
                      prefs.remove("Fishbone");
                      fishbonePage.prefs = null;
                      await fishbonePage.init();
                      break;
                    case 3:
                      break;
                  }
                  setState(() {});
                },
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  Uint8List? image;
                  switch (index) {
                    case 0:
                      image = await customPage.mindMap.toPng();
                      break;
                    case 1:
                      image = await themePage.mindMap.toPng();
                      break;
                    case 2:
                      image = await fishbonePage.mindMap.toPng();
                      break;
                    case 3:
                      image = await multiRootPage.mindMap.toPng();
                      break;
                  }
                  if (image != null) {
                    String? filename;
                    if (Platform.isAndroid || Platform.isIOS) {
                      filename = await FilePicker.platform.saveFile(
                        type: FileType.custom,
                        allowedExtensions: ["png"],
                        fileName: "MindMap.png",
                        bytes: image,
                      );
                    } else {
                      filename = await FilePicker.platform.saveFile(
                        type: FileType.custom,
                        allowedExtensions: ["png"],
                      );
                    }
                    if (filename != null) {
                      File file = File(filename);
                      await file.writeAsBytes(image);
                    }
                  }
                },
                child: Text(
                  "Export Image",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "ReadOnly:",
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              Switch(
                value: readOnly,
                activeThumbColor: Theme.of(context).colorScheme.primary,
                activeTrackColor: Theme.of(context).colorScheme.onPrimary,
                onChanged: (value) {
                  setState(() {
                    readOnly = value;
                    customPage.mindMap.setReadOnly(value);
                    themePage.mindMap.setReadOnly(value);
                    fishbonePage.mindMap.setReadOnly(value);
                    multiRootPage.mindMap.setReadOnly(value);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: index == 0
          ? customPage
          : (index == 1
              ? themePage
              : (index == 2 ? fishbonePage : multiRootPage)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.blur_linear_rounded),
            label: "Custom",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            label: "Theme",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            label: "Fishbone",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            label: "Multi Root",
          ),
        ],
      ),
    );
  }
}
