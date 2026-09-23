import 'package:flutter/material.dart';

class CaaCategory {
  const CaaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.position,
    this.isFilter = false,
    this.imagePath,
  });

  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int position;
  final bool isFilter;
  final String? imagePath;

  CaaCategory copyWith({
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    int? position,
    bool? isFilter,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return CaaCategory(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      position: position ?? this.position,
      isFilter: isFilter ?? this.isFilter,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
    );
  }
}
