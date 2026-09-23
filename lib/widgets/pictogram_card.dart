import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/pictogram.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import 'pictogram_image.dart';

class PictogramCard extends StatefulWidget {
  const PictogramCard({
    super.key,
    required this.pictogram,
    required this.onTap,
    this.onLongPress,
  });

  final Pictogram pictogram;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<PictogramCard> createState() => _PictogramCardState();
}

class _PictogramCardState extends State<PictogramCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colors = Theme.of(context).colorScheme;
    final category = context.watch<CategoryProvider>().byId(
          widget.pictogram.categoryId,
        );
    final categoryColor = category.color;
    final cellColor = settings.colorCodedCategories
        ? categoryColor.withValues(alpha: settings.highContrast ? 0.28 : 0.18)
        : colors.surface;
    final labelColor = settings.colorCodedCategories
        ? categoryColor.withValues(alpha: settings.highContrast ? 0.44 : 0.28)
        : colors.surfaceContainerHighest;
    final borderColor =
        settings.colorCodedCategories ? categoryColor : colors.outlineVariant;
    final radius = BorderRadius.circular(settings.cellCornerRadius);
    final animationDuration = settings.reduceAnimations
        ? Duration.zero
        : const Duration(milliseconds: 90);
    final label = _CardLabel(
      pictogram: widget.pictogram,
      backgroundColor: labelColor,
      borderColor: borderColor,
    );

    return Semantics(
      label: 'Pictograma ${widget.pictogram.label}',
      button: true,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: animationDuration,
        child: Material(
          color: cellColor,
          elevation: _pressed || settings.highContrast ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: settings.highContrast ? colors.outline : borderColor,
              width: settings.highContrast ? 2.5 : 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    children: [
                      if (settings.showTextOnPictograms &&
                          settings.pictogramLabelPosition ==
                              PictogramLabelPosition.top)
                        label,
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(
                            (settings.largeButtons ? 10 : 6) *
                                settings.pictogramScale,
                          ),
                          child: ColoredBox(
                            color: colors.surface.withValues(alpha: 0.72),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child:
                                  PictogramImage(pictogram: widget.pictogram),
                            ),
                          ),
                        ),
                      ),
                      if (settings.showTextOnPictograms &&
                          settings.pictogramLabelPosition ==
                              PictogramLabelPosition.bottom)
                        label,
                    ],
                  ),
                ),
                if (widget.pictogram.favorite)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC928),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.surface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFF5F4200),
                        ),
                      ),
                    ),
                  ),
                if (widget.pictogram.isFolder)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _CardBadge(
                      icon: Icons.folder_rounded,
                      backgroundColor: categoryColor,
                      foregroundColor: colors.onPrimary,
                    ),
                  ),
                if (settings.isCaregiverMode && widget.onLongPress != null)
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: _CardBadgeButton(
                      tooltip: 'Editar pictograma',
                      icon: Icons.edit_outlined,
                      onTap: widget.onLongPress!,
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

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 17, color: foregroundColor),
      ),
    );
  }
}

class _CardBadgeButton extends StatelessWidget {
  const _CardBadgeButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colors.primaryContainer,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: 28,
            child: Icon(
              icon,
              size: 16,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel({
    required this.pictogram,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Pictogram pictogram;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textStyle = settings.boardDensity == BoardDensity.dense
        ? Theme.of(context).textTheme.labelMedium
        : Theme.of(context).textTheme.titleSmall;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: settings.boardDensity == BoardDensity.dense ? 24 : 34,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: settings.boardDensity == BoardDensity.dense ? 3 : 7,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.5)),
      ),
      child: Text(
        pictogram.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
