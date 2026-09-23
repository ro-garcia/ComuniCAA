import 'package:flutter/material.dart';

class BarResizeHandle extends StatelessWidget {
  const BarResizeHandle({
    super.key,
    required this.expandTooltip,
    required this.resetTooltip,
    required this.dragTooltip,
    required this.expandIcon,
    required this.isExpanded,
    required this.isAtMaximum,
    required this.onExpand,
    required this.onReset,
    required this.onDragDelta,
  });

  final String expandTooltip;
  final String resetTooltip;
  final String dragTooltip;
  final IconData expandIcon;
  final bool isExpanded;
  final bool isAtMaximum;
  final VoidCallback onExpand;
  final VoidCallback onReset;
  final ValueChanged<double> onDragDelta;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: dragTooltip,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      final delta = details.primaryDelta ?? details.delta.dy;
                      onDragDelta(delta);
                    },
                    child: SizedBox.square(
                      dimension: 30,
                      child: Icon(
                        Icons.drag_handle,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              _SmallIconButton(
                tooltip: expandTooltip,
                icon: expandIcon,
                onPressed: isAtMaximum ? null : onExpand,
              ),
              _SmallIconButton(
                tooltip: resetTooltip,
                icon: Icons.restart_alt,
                onPressed: isExpanded ? onReset : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
      ),
      onPressed: onPressed,
    );
  }
}
