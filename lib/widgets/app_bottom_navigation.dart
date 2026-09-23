import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.editorMode,
    required this.onDestinationSelected,
    required this.onCustomizePressed,
    required this.onSettingsPressed,
  });

  final int selectedIndex;
  final bool editorMode;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCustomizePressed;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colors = Theme.of(context).colorScheme;
    final toolbarColor =
        settings.darkToolbar ? colors.inverseSurface : colors.surface;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: toolbarColor,
          border: Border(
            top: BorderSide(color: colors.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToolbarButton(
                label: 'Carpetas',
                icon: Icons.grid_view_outlined,
                selected: selectedIndex == 1,
                onPressed: () => onDestinationSelected(1),
              ),
            ),
            Expanded(
              child: _ToolbarButton(
                label: 'Buscar',
                icon: Icons.search_outlined,
                selected: selectedIndex == 2,
                onPressed: () => onDestinationSelected(2),
              ),
            ),
            Expanded(
              child: _ToolbarButton(
                label: 'Teclado',
                icon: Icons.keyboard_alt_outlined,
                selected: selectedIndex == 3,
                onPressed: () => onDestinationSelected(3),
              ),
            ),
            Expanded(
              child: _ToolbarButton(
                label: 'Inicio',
                icon: Icons.home_outlined,
                selected: selectedIndex == 0 && !editorMode,
                emphasized: true,
                onPressed: () => onDestinationSelected(0),
              ),
            ),
            Expanded(
              child: _ToolbarButton(
                label: 'Editar',
                icon: Icons.edit_outlined,
                selected: editorMode && selectedIndex != 4,
                onPressed: onCustomizePressed,
              ),
            ),
            Expanded(
              child: _ToolbarButton(
                label: 'Ajustes',
                icon: Icons.settings_outlined,
                selected: selectedIndex == 4,
                onPressed: onSettingsPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    final unselectedForeground =
        settings.darkToolbar ? colors.onInverseSurface : colors.onSurface;
    final foreground =
        selected ? colors.onPrimaryContainer : unselectedForeground;
    final background = selected ? colors.primaryContainer : Colors.transparent;

    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: Tooltip(
        message: label,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: foreground, size: emphasized ? 30 : 25),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
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
