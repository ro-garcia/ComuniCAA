import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/mock_categories.dart';
import '../models/category.dart';
import '../models/pictogram.dart';
import '../providers/category_provider.dart';
import '../providers/pictogram_provider.dart';
import '../screens/editor/image_source_sheet.dart';
import 'pictogram_image.dart';

class PictogramCreatorPanel extends StatefulWidget {
  const PictogramCreatorPanel({
    super.key,
    required this.onSaved,
    required this.onCancel,
    this.folderMode = false,
  });

  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final bool folderMode;

  @override
  State<PictogramCreatorPanel> createState() => _PictogramCreatorPanelState();
}

class _PictogramCreatorPanelState extends State<PictogramCreatorPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _spokenTextController = TextEditingController();
  final _picker = ImagePicker();

  String? _categoryId = categoryCore;
  String? _parentFolderId;
  String? _imagePath;
  PictogramImageType? _imageType;
  bool _favorite = false;
  bool _savingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _spokenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().editableCategories;
    final pictogramProvider = context.watch<PictogramProvider>();
    final folders = pictogramProvider.getFolderPictograms();
    final destinationId = _parentFolderId ?? _categoryId;
    final title = widget.folderMode ? 'Crear carpeta' : 'Crear pictograma';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar creación',
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontal = constraints.maxWidth >= 720;
                      final image = _buildImageColumn(context);
                      final fields = _buildFields(
                        context,
                        categories: categories,
                        folders: folders,
                        destinationId: destinationId,
                      );

                      if (!horizontal) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            image,
                            const SizedBox(height: 18),
                            fields,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 250, child: image),
                          const SizedBox(width: 24),
                          Expanded(child: fields),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageColumn(BuildContext context) {
    final imagePath = _imagePath;
    final imageType = _imageType;
    final imageSemanticLabel = widget.folderMode
        ? 'Seleccionar imagen de la carpeta'
        : 'Seleccionar imagen del pictograma';
    final preview = imagePath == null || imageType == null
        ? null
        : Pictogram(
            id: 'preview',
            label: _nameController.text.trim().isEmpty
                ? 'Previsualización'
                : _nameController.text.trim(),
            spokenText: widget.folderMode
                ? _nameController.text
                : _spokenTextController.text,
            categoryId: categoryCore,
            imagePath: imagePath,
            imageType: imageType,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Imagen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: imageSemanticLabel,
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: _savingImage
                      ? const Center(child: CircularProgressIndicator())
                      : preview == null
                          ? const Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 52,
                              ),
                            )
                          : PictogramImage(
                              pictogram: preview,
                              fit: BoxFit.contain,
                            ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              icon: _savingImage
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _imagePath == null
                          ? Icons.add_photo_alternate_outlined
                          : Icons.swap_horiz_outlined,
                    ),
              label: Text(
                _imagePath == null ? 'Agregar imagen' : 'Cambiar imagen',
              ),
              onPressed: _savingImage ? null : _pickImage,
            ),
            if (_imagePath != null)
              IconButton(
                tooltip: 'Quitar imagen',
                onPressed: _savingImage
                    ? null
                    : () => setState(() {
                          _imagePath = null;
                          _imageType = null;
                        }),
                icon: const Icon(Icons.hide_image_outlined),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFields(
    BuildContext context, {
    required List<CaaCategory> categories,
    required List<Pictogram> folders,
    required String? destinationId,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: widget.folderMode
                  ? 'Nombre de la carpeta'
                  : 'Nombre del pictograma',
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Escribe un nombre';
              }
              return null;
            },
          ),
          if (!widget.folderMode) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _spokenTextController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Texto que pronunciará',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: destinationId,
              decoration: const InputDecoration(
                labelText: 'Categoría o carpeta',
              ),
              items: [
                ...categories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  ),
                ),
                ...folders.map(
                  (folder) => DropdownMenuItem<String>(
                    value: folder.id,
                    child: Row(
                      children: [
                        const Icon(Icons.folder_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(folder.label),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                final selectedFolder = folders.any(
                  (folder) => folder.id == value,
                );
                setState(() {
                  _parentFolderId = selectedFolder ? value : null;
                  _categoryId = selectedFolder ? _categoryId : value;
                });
              },
              validator: (value) =>
                  value == null ? 'Selecciona una categoría' : null,
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _favorite,
              title: const Text('Favorito'),
              onChanged: (value) => setState(() => _favorite = value),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                onPressed: widget.onCancel,
              ),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.folderMode
                      ? 'Guardar carpeta'
                      : 'Guardar pictograma',
                ),
                onPressed: _savePictogram,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(context);
    if (source == null) return;

    try {
      setState(() => _savingImage = true);
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (!mounted || picked == null) {
        if (mounted) setState(() => _savingImage = false);
        return;
      }

      final storedPath = await _copyToAppStorage(picked);
      if (!mounted) return;
      setState(() {
        _imagePath = storedPath ?? picked.path;
        _imageType = PictogramImageType.localFile;
        _savingImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible seleccionar la imagen.')),
      );
    }
  }

  Future<String?> _copyToAppStorage(XFile picked) async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      final directory = Directory(
        '${documents.path}${Platform.pathSeparator}comunicaa_pictograms',
      );
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final extension = picked.path.split('.').last.toLowerCase();
      final safeExtension = extension.length <= 5 ? extension : 'jpg';
      final fileName =
          'pictogram_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
      final saved = await File(picked.path).copy(
        '${directory.path}${Platform.pathSeparator}$fileName',
      );
      return saved.path;
    } catch (_) {
      return null;
    }
  }

  void _savePictogram() {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePath == null || _imageType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen.')),
      );
      return;
    }

    final provider = context.read<PictogramProvider>();
    final name = _nameController.text.trim();
    if (widget.folderMode) {
      provider.addPictogram(
        Pictogram(
          id: 'folder_${DateTime.now().microsecondsSinceEpoch}',
          label: name,
          spokenText: name.toLowerCase(),
          categoryId: categoryCore,
          imagePath: _imagePath!,
          imageType: _imageType!,
          favorite: false,
          visible: true,
          isCustom: true,
          isFolder: true,
          onBoard: true,
          position: provider.nextPositionForCategory(categoryCore),
        ),
      );
      widget.onSaved();
      return;
    }

    final spokenText = _spokenTextController.text.trim().isEmpty
        ? name.toLowerCase()
        : _spokenTextController.text.trim().toLowerCase();
    final categoryId = _categoryId ?? categoryCore;
    final parentFolderId = _parentFolderId;

    provider.addPictogram(
      Pictogram(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        label: name,
        spokenText: spokenText,
        categoryId: categoryId,
        imagePath: _imagePath!,
        imageType: _imageType!,
        favorite: _favorite,
        visible: true,
        isCustom: true,
        onBoard: parentFolderId == null,
        position: provider.nextPositionForCategory(categoryId),
        parentFolderId: parentFolderId,
      ),
    );

    widget.onSaved();
  }
}
