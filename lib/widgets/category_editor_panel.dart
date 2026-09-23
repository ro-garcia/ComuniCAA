import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import '../screens/editor/image_source_sheet.dart';
import 'category_visual.dart';

class CategoryEditorPanel extends StatefulWidget {
  const CategoryEditorPanel({
    super.key,
    required this.category,
    required this.onSaved,
    required this.onCancel,
  });

  final CaaCategory category;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  State<CategoryEditorPanel> createState() => _CategoryEditorPanelState();
}

class _CategoryEditorPanelState extends State<CategoryEditorPanel> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  late Color _color;
  late IconData _icon;
  String? _imagePath;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.category.name;
    _descriptionController.text = widget.category.description;
    _color = widget.category.color;
    _icon = widget.category.icon;
    _imagePath = widget.category.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.category.copyWith(
      name: _nameController.text.trim().isEmpty
          ? widget.category.name
          : _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _color,
      icon: _icon,
      imagePath: _imagePath,
      clearImagePath: _imagePath == null,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Editar carpeta',
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 440),
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontal = constraints.maxWidth >= 720;
                    final image = _buildImageColumn(context, preview);
                    final fields = _buildFields(context);

                    if (!horizontal) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [image, const SizedBox(height: 16), fields],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 220, child: image),
                        const SizedBox(width: 20),
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
    );
  }

  Widget _buildImageColumn(BuildContext context, CaaCategory preview) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _color, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: CategoryVisual(
                category: preview,
                iconSize: 58,
                borderRadius: 10,
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
              icon: _pickingImage
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Cambiar foto'),
              onPressed: _pickingImage ? null : _pickImage,
            ),
            if (_imagePath != null)
              IconButton(
                tooltip: 'Quitar foto',
                onPressed: () => setState(() => _imagePath = null),
                icon: const Icon(Icons.hide_image_outlined),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFields(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nombre'),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Escribe un nombre';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Descripción'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text(
            'Color',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colorOptions
                .map(
                  (color) => _ColorButton(
                    color: color,
                    selected: color == _color,
                    onTap: () => setState(() => _color = color),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Icono',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _iconOptions
                .map(
                  (icon) => ChoiceChip(
                    showCheckmark: false,
                    label: Icon(icon, size: 21),
                    selected: icon == _icon,
                    onSelected: (_) => setState(() => _icon = icon),
                  ),
                )
                .toList(),
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
                onPressed: _saveCategory,
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
      setState(() => _pickingImage = true);
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (!mounted) return;
      setState(() {
        _imagePath = picked?.path ?? _imagePath;
        _pickingImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pickingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible seleccionar la imagen.')),
      );
    }
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.category.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _color,
      icon: _icon,
      imagePath: _imagePath,
      clearImagePath: _imagePath == null,
    );

    context.read<CategoryProvider>().updateCategory(updated);
    widget.onSaved();
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Color de carpeta',
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}

const _colorOptions = <Color>[
  Color(0xFF2B7A78),
  Color(0xFF6C63FF),
  Color(0xFFE76F51),
  Color(0xFFE9C46A),
  Color(0xFF457B9D),
  Color(0xFF2A9D8F),
  Color(0xFF8D6E63),
  Color(0xFFFFB703),
  Color(0xFFD81B60),
  Color(0xFF7CB342),
];

const _iconOptions = <IconData>[
  Icons.grid_view_outlined,
  Icons.people_alt_outlined,
  Icons.restaurant_outlined,
  Icons.sentiment_satisfied_alt_outlined,
  Icons.place_outlined,
  Icons.sports_esports_outlined,
  Icons.inventory_2_outlined,
  Icons.star_border_rounded,
  Icons.school_outlined,
  Icons.home_outlined,
  Icons.medical_services_outlined,
  Icons.extension_outlined,
];
