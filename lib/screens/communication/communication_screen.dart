import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_settings.dart';
import '../../models/category.dart';
import '../../models/pictogram.dart';
import '../../providers/communication_provider.dart';
import '../../providers/pictogram_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pictogram_audio_service.dart';
import '../../widgets/category_folder_strip.dart';
import '../../widgets/category_editor_panel.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/message_bar.dart';
import '../../widgets/pictogram_action_sheet.dart';
import '../../widgets/pictogram_editor_panel.dart';
import '../../widgets/pictogram_grid.dart';

class CommunicationScreen extends StatefulWidget {
  const CommunicationScreen({super.key});

  @override
  State<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  CaaCategory? _selectedCategory;
  CaaCategory? _editingCategory;
  Pictogram? _editingPictogram;
  final List<Pictogram> _folderPath = [];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final pictogramProvider = context.watch<PictogramProvider>();
    final boardPictograms = pictogramProvider.getBoardPictograms();
    final selectedCategory = _selectedCategory;
    final activeFolder = _folderPath.isEmpty ? null : _folderPath.last;

    return Column(
      children: [
        const MessageBar(),
        if (settings.folderStripPlacement == FolderStripPlacement.top)
          _buildCategoryStrip(context),
        if (settings.folderStripPlacement == FolderStripPlacement.top &&
            _editingCategory != null)
          CategoryEditorPanel(
            category: _editingCategory!,
            onSaved: () => setState(() => _editingCategory = null),
            onCancel: () => setState(() => _editingCategory = null),
          ),
        _BreadcrumbBar(
          selectedCategory: selectedCategory,
          folderPath: _folderPath,
          onHomePressed: _goHome,
          onFolderPressed: _goToFolder,
        ),
        Expanded(
          child: _editingPictogram != null
              ? PictogramEditorPanel(
                  pictogram: _editingPictogram!,
                  onSaved: () => setState(() => _editingPictogram = null),
                  onCancel: () => setState(() => _editingPictogram = null),
                )
              : activeFolder != null
                  ? _FolderPictogramPanel(
                      pictograms: pictogramProvider.getFolderChildren(
                        activeFolder.id,
                      ),
                      onPictogramTap: (pictogram) =>
                          _handlePictogramTap(context, pictogram),
                      onPictogramLongPress: (pictogram) =>
                          _handleLongPress(context, pictogram),
                    )
                  : selectedCategory == null
                      ? _buildBoard(context, boardPictograms)
                      : _CategoryPictogramPanel(
                          pictograms: pictogramProvider.getByCategory(
                            selectedCategory.id,
                          ),
                          onPictogramTap: (pictogram) =>
                              _handlePictogramTap(context, pictogram),
                          onPictogramLongPress: (pictogram) =>
                              _handleLongPress(context, pictogram),
                        ),
        ),
        if (settings.folderStripPlacement == FolderStripPlacement.bottom)
          _buildCategoryStrip(context),
        if (settings.folderStripPlacement == FolderStripPlacement.bottom &&
            _editingCategory != null)
          CategoryEditorPanel(
            category: _editingCategory!,
            onSaved: () => setState(() => _editingCategory = null),
            onCancel: () => setState(() => _editingCategory = null),
          ),
      ],
    );
  }

  Widget _buildCategoryStrip(BuildContext context) {
    return CategoryFolderStrip(
      onCategorySelected: (category) {
        setState(() {
          _selectedCategory = category;
          _folderPath.clear();
        });
      },
      onCategoryLongPress: _openCategoryEditor,
      onFolderSelected: _openFolder,
    );
  }

  Widget _buildBoard(BuildContext context, List<Pictogram> pictograms) {
    if (pictograms.isEmpty) {
      return const EmptyState(
        message: 'Tablero en blanco',
        icon: Icons.dashboard_customize_outlined,
      );
    }

    return PictogramGrid(
      pictograms: pictograms,
      onPictogramTap: (pictogram) => _handlePictogramTap(context, pictogram),
      onPictogramLongPress: (pictogram) => _handleLongPress(context, pictogram),
    );
  }

  void _openCategoryEditor(CaaCategory category) {
    setState(() => _editingCategory = category);
  }

  void _openPictogramEditor(Pictogram pictogram) {
    setState(() {
      _editingCategory = null;
      _editingPictogram = pictogram;
    });
  }

  void _goHome() {
    setState(() {
      _selectedCategory = null;
      _folderPath.clear();
    });
  }

  void _goToFolder(int index) {
    setState(() {
      _selectedCategory = null;
      _folderPath.removeRange(index + 1, _folderPath.length);
    });
  }

  void _openFolder(Pictogram folder) {
    setState(() {
      _selectedCategory = null;
      final existingIndex = _folderPath.indexWhere(
        (item) => item.id == folder.id,
      );
      if (existingIndex == -1) {
        _folderPath.add(folder);
      } else {
        _folderPath.removeRange(existingIndex + 1, _folderPath.length);
      }
    });
  }

  Future<void> _handlePictogramTap(
    BuildContext context,
    Pictogram pictogram,
  ) async {
    if (pictogram.isFolder) {
      _openFolder(pictogram);
      return;
    }

    final settings = context.read<SettingsProvider>();
    if (settings.isCaregiverMode) {
      context.read<PictogramProvider>().addToBoard(pictogram.id);
      return;
    }

    context.read<CommunicationProvider>().addPictogram(pictogram);
    if (!settings.speakOnTap) return;

    await PictogramAudioService.play(pictogram);
  }

  void _handleLongPress(BuildContext context, Pictogram pictogram) {
    final settings = context.read<SettingsProvider>();
    if (settings.isCaregiverMode) {
      showCaregiverPictogramMenu(
        context,
        pictogram,
        onEdit: () => _openPictogramEditor(pictogram),
      );
      return;
    }

    if (hasGrammarVariants(pictogram)) {
      showGrammarVariantsSheet(context, pictogram);
    }
  }
}

class _CategoryPictogramPanel extends StatelessWidget {
  const _CategoryPictogramPanel({
    required this.pictograms,
    required this.onPictogramTap,
    required this.onPictogramLongPress,
  });

  final List<Pictogram> pictograms;
  final ValueChanged<Pictogram> onPictogramTap;
  final ValueChanged<Pictogram> onPictogramLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PictogramGrid(
            pictograms: pictograms,
            emptyMessage: 'No hay pictogramas en esta categoría',
            onPictogramTap: onPictogramTap,
            onPictogramLongPress: onPictogramLongPress,
          ),
        ),
      ],
    );
  }
}

class _FolderPictogramPanel extends StatelessWidget {
  const _FolderPictogramPanel({
    required this.pictograms,
    required this.onPictogramTap,
    required this.onPictogramLongPress,
  });

  final List<Pictogram> pictograms;
  final ValueChanged<Pictogram> onPictogramTap;
  final ValueChanged<Pictogram> onPictogramLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PictogramGrid(
            pictograms: pictograms,
            emptyMessage: 'Carpeta vacía',
            onPictogramTap: onPictogramTap,
            onPictogramLongPress: onPictogramLongPress,
          ),
        ),
      ],
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({
    required this.selectedCategory,
    required this.folderPath,
    required this.onHomePressed,
    required this.onFolderPressed,
  });

  final CaaCategory? selectedCategory;
  final List<Pictogram> folderPath;
  final VoidCallback onHomePressed;
  final ValueChanged<int> onFolderPressed;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colors = Theme.of(context).colorScheme;
    final dark = settings.darkToolbar;
    final background = dark ? colors.inverseSurface : colors.surface;
    final foreground = dark ? colors.onInverseSurface : colors.onSurface;
    final divider = dark
        ? colors.onInverseSurface.withValues(alpha: 0.18)
        : colors.outlineVariant;
    final category = selectedCategory;

    return Container(
      width: double.infinity,
      height: 38,
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(color: divider),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (constraints.maxWidth - 16).clamp(
                    0,
                    constraints.maxWidth,
                  ).toDouble(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildTrail(context, foreground, category),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTrail(
    BuildContext context,
    Color foreground,
    CaaCategory? category,
  ) {
    final items = <Widget>[
      Tooltip(
        message: 'Inicio',
        child: InkWell(
          onTap: onHomePressed,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 36,
            height: double.infinity,
            child: Icon(
              Icons.home_outlined,
              size: 22,
              color: foreground,
            ),
          ),
        ),
      ),
      _BreadcrumbText(
        label: 'Inicio',
        foreground: foreground,
        isCurrent: folderPath.isEmpty && category == null,
      ),
    ];

    for (var index = 0; index < folderPath.length; index++) {
      items
        ..add(_BreadcrumbChevron(foreground: foreground))
        ..add(
          InkWell(
            onTap: () => onFolderPressed(index),
            borderRadius: BorderRadius.circular(8),
            child: _BreadcrumbText(
              label: folderPath[index].label,
              foreground: foreground,
              isCurrent: index == folderPath.length - 1 && category == null,
            ),
          ),
        );
    }

    if (category != null) {
      items
        ..add(_BreadcrumbChevron(foreground: foreground))
        ..add(
          _BreadcrumbText(
            label: category.name,
            foreground: foreground,
            isCurrent: true,
          ),
        );
    }

    return items;
  }
}

class _BreadcrumbChevron extends StatelessWidget {
  const _BreadcrumbChevron({required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right,
        size: 20,
        color: foreground.withValues(alpha: 0.72),
      ),
    );
  }
}

class _BreadcrumbText extends StatelessWidget {
  const _BreadcrumbText({
    required this.label,
    required this.foreground,
    required this.isCurrent,
  });

  final String label;
  final Color foreground;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w800,
              letterSpacing: 0,
            ),
      ),
    );
  }
}
