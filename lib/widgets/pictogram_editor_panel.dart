import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/mock_categories.dart';
import '../models/pictogram.dart';
import '../providers/category_provider.dart';
import '../providers/pictogram_provider.dart';
import '../screens/editor/image_source_sheet.dart';
import 'pictogram_image.dart';

class PictogramEditorPanel extends StatefulWidget {
  const PictogramEditorPanel({
    super.key,
    required this.pictogram,
    required this.onSaved,
    required this.onCancel,
  });

  final Pictogram pictogram;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  State<PictogramEditorPanel> createState() => _PictogramEditorPanelState();
}

class _PictogramEditorPanelState extends State<PictogramEditorPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _spokenTextController = TextEditingController();
  final _picker = ImagePicker();

  late String? _categoryId;
  late String? _parentFolderId;
  late String? _imagePath;
  late PictogramImageType? _imageType;
  late bool _favorite;
  bool _savingImage = false;

  @override
  void initState() {
    super.initState();
    final pictogram = widget.pictogram;
    _nameController.text = pictogram.label;
    _spokenTextController.text = pictogram.spokenText;
    _categoryId = pictogram.categoryId;
    _parentFolderId = pictogram.parentFolderId;
    _imagePath = pictogram.imagePath;
    _imageType = pictogram.imageType;
    _favorite = pictogram.favorite;
  }

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
    final folders = pictogramProvider.getFolderPictograms(
      excludingId: widget.pictogram.id,
    );
    final destinationId = _parentFolderId ?? _categoryId;

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
                      'Editar pictograma',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar edición',
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
    final preview = imagePath == null || imageType == null
        ? null
        : Pictogram(
            id: 'preview',
            label: _nameController.text.trim().isEmpty
                ? 'Previsualización'
                : _nameController.text.trim(),
            spokenText: _spokenTextController.text,
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
          label: 'Seleccionar imagen del pictograma',
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
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
                  : const Icon(Icons.swap_horiz_outlined),
              label: const Text('Cambiar imagen'),
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
    required List<dynamic> categories,
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
            decoration: const InputDecoration(
              labelText: 'Nombre del pictograma',
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Escribe un nombre';
              }
              return null;
            },
          ),
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
                label: const Text('Guardar cambios'),
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
    final spokenText = _spokenTextController.text.trim().isEmpty
        ? name.toLowerCase()
        : _spokenTextController.text.trim().toLowerCase();
    final parentFolderId = _parentFolderId;
    final updated = Pictogram(
      id: widget.pictogram.id,
      label: name,
      spokenText: spokenText,
      categoryId: _categoryId ?? categoryCore,
      imagePath: _imagePath!,
      imageType: _imageType!,
      audioPath: widget.pictogram.audioPath,
      favorite: _favorite,
      visible: widget.pictogram.visible,
      isCustom: widget.pictogram.isCustom,
      isFolder: widget.pictogram.isFolder,
      onBoard: parentFolderId == null ? widget.pictogram.onBoard : false,
      position: widget.pictogram.position == 0
          ? provider.nextPositionForCategory(_categoryId ?? categoryCore)
          : widget.pictogram.position,
      parentCategoryId: widget.pictogram.parentCategoryId,
      parentFolderId: parentFolderId,
    );

    provider.updatePictogram(updated);
    widget.onSaved();
  }
}
