import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/category.dart';
import 'category_visual.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.onEdit,
  });

  final CaaCategory category;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Categoria ${category.name}',
      button: true,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final dimension = math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );

                            return Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox.square(
                                dimension: dimension,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CategoryVisual(
                                      category: category,
                                      iconSize: dimension * 0.42,
                                      borderRadius: 16,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton.filledTonal(
                      tooltip: 'Editar carpeta',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(40, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
