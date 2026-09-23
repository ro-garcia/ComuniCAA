import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Personalización',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Tablero',
            children: [
              _SegmentedRow<BoardDensity>(
                selected: settings.boardDensity,
                values: BoardDensity.values,
                labelFor: boardDensityLabel,
                onSelected: context.read<SettingsProvider>().setBoardDensity,
              ),
              const SizedBox(height: 14),
              _SegmentedRow<FolderStripPlacement>(
                selected: settings.folderStripPlacement,
                values: FolderStripPlacement.values,
                labelFor: folderStripPlacementLabel,
                onSelected:
                    context.read<SettingsProvider>().setFolderStripPlacement,
              ),
              const SizedBox(height: 14),
              _SegmentedRow<PictogramLabelPosition>(
                selected: settings.pictogramLabelPosition,
                values: PictogramLabelPosition.values,
                labelFor: pictogramLabelPositionLabel,
                onSelected:
                    context.read<SettingsProvider>().setPictogramLabelPosition,
              ),
              SwitchListTile(
                title: const Text('Colores por categoría'),
                value: settings.colorCodedCategories,
                onChanged:
                    context.read<SettingsProvider>().setColorCodedCategories,
              ),
              SwitchListTile(
                title: const Text('Barra inferior oscura'),
                value: settings.darkToolbar,
                onChanged: context.read<SettingsProvider>().setDarkToolbar,
              ),
              _SliderTile(
                title: 'Tamaño de pictogramas',
                value: settings.pictogramScale,
                min: 0.82,
                max: 1.16,
                divisions: 6,
                label: '${(settings.pictogramScale * 100).round()}%',
                onChanged: context.read<SettingsProvider>().setPictogramScale,
              ),
              _SliderTile(
                title: 'Alto de barra de carpetas',
                value: settings.folderStripScale,
                min: SettingsProvider.defaultFolderStripScale,
                max: SettingsProvider.maxFolderStripScale,
                divisions: 13,
                label: '${(settings.folderStripScale * 100).round()}%',
                onChanged: context.read<SettingsProvider>().setFolderStripScale,
              ),
              _SliderTile(
                title: 'Redondez de celdas',
                value: settings.cellCornerRadius,
                min: 4,
                max: 18,
                divisions: 7,
                label: '${settings.cellCornerRadius.round()}',
                onChanged: context.read<SettingsProvider>().setCellCornerRadius,
              ),
            ],
          ),
          _Section(
            title: 'Apariencia',
            children: [
              SwitchListTile(
                title: const Text('Tema oscuro'),
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (value) => context
                    .read<SettingsProvider>()
                    .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
              ),
              SwitchListTile(
                title: const Text('Mostrar texto en pictogramas'),
                value: settings.showTextOnPictograms,
                onChanged:
                    context.read<SettingsProvider>().setShowTextOnPictograms,
              ),
              SwitchListTile(
                title: const Text('Alto contraste'),
                value: settings.highContrast,
                onChanged: context.read<SettingsProvider>().setHighContrast,
              ),
              _SliderTile(
                title: 'Tamaño de texto',
                value: settings.textScale,
                min: 0.9,
                max: 1.4,
                divisions: 5,
                label: '${(settings.textScale * 100).round()}%',
                onChanged: context.read<SettingsProvider>().setTextScale,
              ),
            ],
          ),
          _Section(
            title: 'Cuadrícula',
            children: [
              _ChoiceWrap<int?>(
                selected: settings.manualGridColumns,
                values: const [null, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12],
                labelFor: (value) => value == null ? 'Auto' : '$value columnas',
                onSelected:
                    context.read<SettingsProvider>().setManualGridColumns,
              ),
            ],
          ),
          _Section(
            title: 'Comunicación',
            children: [
              SwitchListTile(
                title: const Text('Hablar al pulsar'),
                value: settings.speakOnTap,
                onChanged: context.read<SettingsProvider>().setSpeakOnTap,
              ),
              SwitchListTile(
                title: const Text('Mostrar barra de mensaje'),
                value: settings.showMessageBar,
                onChanged: context.read<SettingsProvider>().setShowMessageBar,
              ),
              SwitchListTile(
                title: const Text('Mostrar pictogramas en mensaje'),
                value: settings.showMessagePictograms,
                onChanged:
                    context.read<SettingsProvider>().setShowMessagePictograms,
              ),
              _SliderTile(
                title: 'Alto de barra de comunicacion',
                value: settings.messageBarScale,
                min: SettingsProvider.defaultMessageBarScale,
                max: SettingsProvider.maxMessageBarScale,
                divisions: 12,
                label: '${(settings.messageBarScale * 100).round()}%',
                onChanged: context.read<SettingsProvider>().setMessageBarScale,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.selected,
    required this.values,
    required this.labelFor,
    required this.onSelected,
  });

  final T selected;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<T>(
        segments: values
            .map(
              (value) => ButtonSegment<T>(
                value: value,
                label: Text(labelFor(value)),
              ),
            )
            .toList(),
        selected: {selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(title),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.selected,
    required this.values,
    required this.labelFor,
    required this.onSelected,
  });

  final T selected;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => ChoiceChip(
              label: Text(labelFor(value)),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
            ),
          )
          .toList(),
    );
  }
}
