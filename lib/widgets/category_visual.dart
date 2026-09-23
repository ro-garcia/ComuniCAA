import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryVisual extends StatelessWidget {
  const CategoryVisual({
    super.key,
    required this.category,
    this.iconSize = 30,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final CaaCategory category;
  final double iconSize;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imagePath = category.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imagePath.startsWith('assets/')
            ? Image.asset(
                imagePath,
                fit: fit,
                errorBuilder: (_, __, ___) => _CategoryIcon(
                  category: category,
                  iconSize: iconSize,
                ),
              )
            : kIsWeb
                ? Image.network(
                    imagePath,
                    fit: fit,
                    errorBuilder: (_, __, ___) => _CategoryIcon(
                      category: category,
                      iconSize: iconSize,
                    ),
                  )
                : Image.file(
                    File(imagePath),
                    fit: fit,
                    errorBuilder: (_, __, ___) => _CategoryIcon(
                      category: category,
                      iconSize: iconSize,
                    ),
                  ),
      );
    }

    return _CategoryIcon(category: category, iconSize: iconSize);
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.category,
    required this.iconSize,
  });

  final CaaCategory category;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Icon(category.icon, color: category.color, size: iconSize);
  }
}
