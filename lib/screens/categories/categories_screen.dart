import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/pictogram.dart';
import '../../providers/category_provider.dart';
import '../../providers/communication_provider.dart';
import '../../providers/pictogram_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pictogram_audio_service.dart';
import '../../widgets/category_card.dart';
import '../../widgets/category_editor_panel.dart';
import '../../widgets/message_bar.dart';
import '../../widgets/pictogram_action_sheet.dart';
import '../../widgets/pictogram_creator_panel.dart';
import '../../widgets/pictogram_folder_card.dart';
import '../../widgets/pictogram_grid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    this.isCreatingFolder = false,
    required this.viewResetToken,
    required this.onCreateSaved,
    required this.onCreateCancel,
  });

  final bool isCreatingFolder;
  final int viewResetToken;
  final VoidCallback onCreateSaved;
  final VoidCallback onCreateCancel;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CaaCategory? _selectedCategory;
  Pictogram? _selectedFolder;
  CaaCategory? _editingCategory;

  @override
  void didUpdateWidget(covariant CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewResetToken != oldWidget.viewResetToken) {
      _resetView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCreatingFolder) {
      return Column(
        children: [
          const MessageBar(forceVisible: true),
          Expanded(
            child: PictogramCreatorPanel(
              folderMode: true,
              onSaved: widget.onCreateSaved,
              onCancel: widget.onCreateCancel,
            ),
          ),
        ],
      );
    }

    final selectedFolder = _selectedFolder;
    if (selectedFolder != null) {
      final pictograms = context.watch<PictogramProvider>().getFolderChildren(
            selectedFolder.id,
          );

      return Column(
        children: [
          const MessageBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Volver a carpetas',
                  onPressed: () => setState(() => _selectedFolder = null),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedFolder.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PictogramGrid(
              pictograms: pictograms,
              emptyMessage: 'Carpeta vacía',
              onPictogramTap: (pictogram) => _handleTap(context, pictogram),
              onPictogramLongPress: (pictogram) =>
                  _handleLongPress(context, pictogram),
            ),
          ),
        ],
      );
    }

    if (_selectedCategory == null) {
      final overview = _CategoryOverview(
        onSelect: _selectCategory,
        onEdit: (category) => _openCategoryEditor(context, category),
        onFolderSelect: _selectFolder,
      );

      if (_editingCategory == null) return overview;

      return Column(
        children: [
          CategoryEditorPanel(
            category: _editingCategory!,
            onSaved: () => setState(() => _editingCategory = null),
            onCancel: () => setState(() => _editingCategory = null),
          ),
          Expanded(child: overview),
        ],
      );
    }

    final pictograms =
        context.watch<PictogramProvider>().getByCategory(_selectedCategory!.id);

    return Column(
      children: [
        const MessageBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: 'Volver a categorías',
                onPressed: () => setState(() => _selectedCategory = null),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedCategory!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PictogramGrid(
            pictograms: pictograms,
            emptyMessage: 'No hay pictogramas en esta categoría',
            onPictogramTap: (pictogram) => _handleTap(context, pictogram),
            onPictogramLongPress: (pictogram) =>
                _handleLongPress(context, pictogram),
          ),
        ),
      ],
    );
  }

  void _selectCategory(CaaCategory category) {
    setState(() {
      _editingCategory = null;
      _selectedFolder = null;
      _selectedCategory = category;
    });
  }

  void _selectFolder(Pictogram folder) {
    setState(() {
      _editingCategory = null;
      _selectedCategory = null;
      _selectedFolder = folder;
    });
  }

  void _openCategoryEditor(BuildContext context, CaaCategory category) {
    setState(() => _editingCategory = category);
  }

  void _resetView() {
    _selectedCategory = null;
    _selectedFolder = null;
    _editingCategory = null;
  }

  Future<void> _handleTap(BuildContext context, Pictogram pictogram) async {
    if (pictogram.isFolder) {
      _selectFolder(pictogram);
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
      showCaregiverPictogramMenu(context, pictogram);
    } else if (hasGrammarVariants(pictogram)) {
      showGrammarVariantsSheet(context, pictogram);
    }
  }
}

class _CategoryOverview extends StatelessWidget {
  const _CategoryOverview({
    required this.onSelect,
    required this.onEdit,
    required this.onFolderSelect,
  });

  final ValueChanged<CaaCategory> onSelect;
  final ValueChanged<CaaCategory> onEdit;
  final ValueChanged<Pictogram> onFolderSelect;

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final pictogramProvider = context.watch<PictogramProvider>();
    final folders = pictogramProvider.getRootFolderPictograms(
      onBoardOnly: false,
    );
    final settings = context.watch<SettingsProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200
            ? 4
            : width >= 760
                ? 3
                : 2;
        final aspectRatio = width >= 1200
            ? 1.22
            : width >= 760
                ? 1.04
                : 0.86;

        final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          );

        return CustomScrollView(
          slivers: [
            if (folders.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 14, 14, 2),
                  child: Text(
                    'Carpetas creadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(14),
                sliver: SliverGrid(
                  gridDelegate: gridDelegate,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final folder = folders[index];
                      return PictogramFolderCard(
                        folder: folder,
                        childCount: pictogramProvider
                            .getFolderChildren(folder.id)
                            .length,
                        onTap: () => onFolderSelect(folder),
                        onLongPress: settings.isCaregiverMode
                            ? () => showCaregiverPictogramMenu(context, folder)
                            : null,
                      );
                    },
                    childCount: folders.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 14, 14, 2),
                child: Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(14),
              sliver: SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      onTap: () => onSelect(category),
                      onEdit: settings.isCaregiverMode
                          ? () => onEdit(category)
                          : null,
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
