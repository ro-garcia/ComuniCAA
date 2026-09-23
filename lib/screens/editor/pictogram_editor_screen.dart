import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/mock_categories.dart';
import '../../models/pictogram.dart';
import '../../providers/category_provider.dart';
import '../../providers/pictogram_provider.dart';
import '../../widgets/pictogram_image.dart';
import 'image_source_sheet.dart';

class PictogramEditorScreen extends StatefulWidget {
  const PictogramEditorScreen({
    super.key,
    this.existingPictogram,
    this.folderMode = false,
  });

  final Pictogram? existingPictogram;
  final bool folderMode;

  @override
  State<PictogramEditorScreen> createState() => _PictogramEditorScreenState();
}

class _PictogramEditorScreenState extends State<PictogramEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _spokenTextController = TextEditingController();
  final _picker = ImagePicker();

  String? _categoryId;
  String? _parentFolderId;
  String? _imagePath;
  PictogramImageType? _imageType;
  bool _favorite = false;
  bool _savingImage = false;

  bool get _isEditing => widget.existingPictogram != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingPictogram;
    if (existing == null) {
      _categoryId = categoryCore;
      return;
    }

    _nameController.text = existing.label;
    _spokenTextController.text = existing.spokenText;
    _categoryId = existing.categoryId;
    _parentFolderId = existing.parentFolderId;
    _imagePath = existing.imagePath;
    _imageType = existing.imageType;
    _favorite = existing.favorite;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spokenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.folderMode
        ? 'Crear carpeta'
        : _isEditing
            ? 'Editar pictograma'
            : 'Crear pictograma';
    final categories = context.watch<CategoryProvider>().editableCategories;
    final pictogramProvider = context.watch<PictogramProvider>();
    final folders = pictogramProvider.getFolderPictograms(
      excludingId: widget.existingPictogram?.id,
    );
    final destinationId = _parentFolderId ?? _categoryId;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del pictograma',
                ),
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
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                    ...folders.map(
                      (folder) => DropdownMenuItem(
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
              ],
              const SizedBox(height: 18),
              _ImagePreview(
                imagePath: _imagePath,
                imageType: _imageType,
                label: _nameController.text,
                onTap: _pickImage,
                onRemove: _imagePath == null
                    ? null
                    : () => setState(() {
                          _imagePath = null;
                          _imageType = null;
                        }),
                savingImage: _savingImage,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Tomar fotografía'),
                    onPressed: _savingImage
                        ? null
                        : () => _pickFromSource(ImageSource.camera),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Elegir desde galería'),
                    onPressed: _savingImage
                        ? null
                        : () => _pickFromSource(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (!widget.folderMode)
                SwitchListTile(
                  value: _favorite,
                  title: const Text('Favorito'),
                  onChanged: (value) => setState(() => _favorite = value),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  widget.folderMode
                      ? 'Guardar carpeta'
                      : _isEditing
                          ? 'Guardar cambios'
                          : 'Guardar pictograma',
                ),
                onPressed: _savePictogram,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(context);
    if (source == null) return;
    await _pickFromSource(source);
  }

  Future<void> _pickFromSource(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (!mounted || picked == null) return;

      setState(() => _savingImage = true);
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
      Navigator.of(context).pop(true);
      return;
    }

    final spokenText = _spokenTextController.text.trim().isEmpty
        ? name.toLowerCase()
        : _spokenTextController.text.trim().toLowerCase();
    final existing = widget.existingPictogram;
    final categoryId = _categoryId ?? categoryCore;
    final parentFolderId = _parentFolderId;

    final pictogram = Pictogram(
      id: existing?.id ?? 'custom_${DateTime.now().microsecondsSinceEpoch}',
      label: name,
      spokenText: spokenText,
      categoryId: categoryId,
      imagePath: _imagePath!,
      imageType: _imageType!,
      favorite: _favorite,
      visible: true,
      isCustom: true,
      isFolder: existing?.isFolder ?? false,
      onBoard: parentFolderId == null ? (existing?.onBoard ?? true) : false,
      position:
          existing?.position ?? provider.nextPositionForCategory(categoryId),
      parentCategoryId: existing?.parentCategoryId,
      parentFolderId: parentFolderId,
    );

    if (existing == null) {
      provider.addPictogram(pictogram);
    } else {
      provider.updatePictogram(pictogram);
    }

    Navigator.of(context).pop(true);
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.imagePath,
    required this.imageType,
    required this.label,
    required this.onTap,
    required this.onRemove,
    required this.savingImage,
  });

  final String? imagePath;
  final PictogramImageType? imageType;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool savingImage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pictogram = imagePath == null || imageType == null
        ? null
        : Pictogram(
            id: 'preview',
            label: label.isEmpty ? 'Previsualización' : label,
            spokenText: label,
            categoryId: categoryCore,
            imagePath: imagePath!,
            imageType: imageType!,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Seleccionar imagen del pictograma',
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: savingImage
                    ? const Center(child: CircularProgressIndicator())
                    : pictogram == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Previsualización',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )
                        : PictogramImage(
                            pictogram: pictogram,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
          ),
        ),
        if (imagePath != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.swap_horiz_outlined),
                label: const Text('Cambiar imagen'),
                onPressed: onTap,
              ),
              TextButton.icon(
                icon: const Icon(Icons.close_outlined),
                label: const Text('Eliminar imagen'),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
