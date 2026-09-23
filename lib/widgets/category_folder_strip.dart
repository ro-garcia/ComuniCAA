import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/category.dart';
import '../models/pictogram.dart';
import '../providers/category_provider.dart';
import '../providers/pictogram_provider.dart';
import '../providers/settings_provider.dart';
import 'bar_resize_handle.dart';
import 'category_visual.dart';
import 'pictogram_image.dart';

class CategoryFolderStrip extends StatelessWidget {
  const CategoryFolderStrip({
    super.key,
    required this.onCategorySelected,
    this.onCategoryLongPress,
    this.onFolderSelected,
  });

  final ValueChanged<CaaCategory> onCategorySelected;
  final ValueChanged<CaaCategory>? onCategoryLongPress;
  final ValueChanged<Pictogram>? onFolderSelected;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final pictogramProvider = context.watch<PictogramProvider>();
    final colors = Theme.of(context).colorScheme;
    final dense = settings.boardDensity == BoardDensity.dense;
    final stripScale = settings.folderStripScale;
    final baseHeight = dense ? 74.0 : 104.0;
    final stripHeight = baseHeight * stripScale;
    final isExpanded = stripScale > SettingsProvider.defaultFolderStripScale;
    final isAtMaximum =
        stripScale >= SettingsProvider.maxFolderStripScale - 0.01;
    final categories = categoryProvider.categories;
    final folders = pictogramProvider.getRootFolderPictograms();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(6, dense ? 4 : 8, 8, dense ? 4 : 8),
      decoration: BoxDecoration(
        color: settings.darkToolbar ? colors.inverseSurface : colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
          top: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: stripHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: settings.isCaregiverMode
                    ? ReorderableListView.builder(
                        scrollDirection: Axis.horizontal,
                        buildDefaultDragHandles: false,
                        itemCount: categories.length,
                        onReorderItem:
                            context.read<CategoryProvider>().reorderCategory,
                        proxyDecorator: (child, _, animation) {
                          return ScaleTransition(
                            scale: Tween<double>(begin: 1, end: 1.04).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final count = pictogramProvider
                              .getByCategory(category.id)
                              .length;

                          return Padding(
                            key: ValueKey(category.id),
                            padding: const EdgeInsets.only(right: 8),
                            child: _FolderButton(
                              category: category,
                              count: count,
                              dense: dense,
                              scale: stripScale,
                              onTap: () => onCategorySelected(category),
                              onLongPress: () =>
                                  onCategoryLongPress?.call(category),
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: const _DragHandle(),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final count = pictogramProvider
                              .getByCategory(category.id)
                              .length;

                          return _FolderButton(
                            category: category,
                            count: count,
                            dense: dense,
                            scale: stripScale,
                            onTap: () => onCategorySelected(category),
                          );
                        },
                      ),
              ),
              if (folders.isNotEmpty) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: (dense ? 108.0 : 136.0) * stripScale,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: folders.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return _PictogramFolderButton(
                        folder: folder,
                        childCount: pictogramProvider
                            .getFolderChildren(folder.id)
                            .length,
                        dense: dense,
                        scale: stripScale,
                        onTap: onFolderSelected == null
                            ? null
                            : () => onFolderSelected!(folder),
                      );
                    },
                  ),
                ),
              ],
              if (settings.isCaregiverMode) ...[
                const SizedBox(width: 8),
                BarResizeHandle(
                  expandTooltip: 'Agrandar barra de carpetas',
                  resetTooltip: 'Restaurar barra de carpetas',
                  dragTooltip: 'Arrastrar para ajustar barra de carpetas',
                  expandIcon: Icons.keyboard_arrow_up,
                  isExpanded: isExpanded,
                  isAtMaximum: isAtMaximum,
                  onExpand: () =>
                      context.read<SettingsProvider>().setFolderStripScale(
                            SettingsProvider.maxFolderStripScale,
                          ),
                  onReset: () =>
                      context.read<SettingsProvider>().setFolderStripScale(
                            SettingsProvider.defaultFolderStripScale,
                          ),
                  onDragDelta: (delta) {
                    final provider = context.read<SettingsProvider>();
                    provider.setFolderStripScale(
                      provider.folderStripScale - delta / 160,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderButton extends StatelessWidget {
  const _FolderButton({
    required this.category,
    required this.count,
    required this.dense,
    required this.scale,
    required this.onTap,
    this.onLongPress,
    this.dragHandle,
  });

  final CaaCategory category;
  final int count;
  final bool dense;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final paddingScale = scale.clamp(1.0, 1.22).toDouble();
    final iconScale = scale.clamp(1.0, 1.35).toDouble();

    return Semantics(
      label: 'Carpeta ${category.name}, $count pictogramas',
      button: true,
      child: SizedBox(
        width: (dense ? 92.0 : 116.0) * scale,
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dense ? 8 : 16),
            side: BorderSide(color: category.color, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Padding(
                    padding: EdgeInsets.all(
                      (dense ? 5.0 : 9.0) * paddingScale,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(dense ? 5 : 12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CategoryVisual(
                              category: category,
                              iconSize: 30.0 * iconScale,
                              borderRadius: dense ? 5 : 12,
                            ),
                          ),
                        ),
                        SizedBox(height: dense ? 3 : 6),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (dense
                                  ? Theme.of(context).textTheme.labelSmall
                                  : Theme.of(context).textTheme.labelLarge)
                              ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          ),
                        ),
                        if (!dense)
                          Text(
                            '$count palabras',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (dragHandle != null)
                Positioned(
                  top: 3,
                  right: 3,
                  child: dragHandle!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PictogramFolderButton extends StatelessWidget {
  const _PictogramFolderButton({
    required this.folder,
    required this.childCount,
    required this.dense,
    required this.scale,
    required this.onTap,
  });

  final Pictogram folder;
  final int childCount;
  final bool dense;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final width = (dense ? 92.0 : 116.0) * scale;

    return Semantics(
      label: 'Carpeta ${folder.label}, $childCount pictogramas',
      button: true,
      child: SizedBox(
        width: width,
        child: Material(
          color: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dense ? 8 : 16),
            side: BorderSide(color: colors.primary, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(dense ? 5 : 9),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(dense ? 5 : 12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.all(4),
                            child: PictogramImage(pictogram: folder),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Icon(
                            Icons.folder_rounded,
                            size: dense ? 18 : 22,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: dense ? 3 : 6),
                  Text(
                    folder.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (dense
                            ? Theme.of(context).textTheme.labelSmall
                            : Theme.of(context).textTheme.labelLarge)
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  if (!dense)
                    Text(
                      '$childCount pictogramas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Mover carpeta',
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: 26,
            child: Icon(
              Icons.drag_indicator,
              size: 16,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
