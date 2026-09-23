import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../widgets/category_visual.dart';
import '../editor/image_source_sheet.dart';

class CategoryEditorScreen extends StatefulWidget {
  const CategoryEditorScreen({
    super.key,
    required this.category,
  });

  final CaaCategory category;

  @override
  State<CategoryEditorScreen> createState() => _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends State<CategoryEditorScreen> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Editar carpeta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Center(
                child: SizedBox(
                  width: 156,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _color, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CategoryVisual(
                          category: preview,
                          iconSize: 64,
                          borderRadius: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
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
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.hide_image_outlined),
                      label: const Text('Quitar foto'),
                      onPressed: () => setState(() => _imagePath = null),
                    ),
                ],
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
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
              const SizedBox(height: 18),
              Text(
                'Icono',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _iconOptions
                    .map(
                      (icon) => ChoiceChip(
                        showCheckmark: false,
                        label: Icon(icon, size: 22),
                        selected: icon == _icon,
                        onSelected: (_) => setState(() => _icon = icon),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar carpeta'),
                onPressed: _saveCategory,
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
    Navigator.of(context).pop(true);
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
          width: 38,
          height: 38,
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
              ? const Icon(Icons.check, color: Colors.white, size: 20)
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
