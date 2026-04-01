import 'package:flutter/material.dart';
import 'package:flutter_mind_map/i_mind_map_node.dart';

class CrossLinkInfo {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  Color color;
  double width;
  String? label;

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
    label: json['label'] as String?,
  );
}
