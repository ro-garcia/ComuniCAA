import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pictogram.dart';
import '../providers/communication_provider.dart';
import '../providers/pictogram_provider.dart';
import '../screens/editor/pictogram_editor_screen.dart';

const Map<String, List<String>> grammarVariants = {
  'comer': ['Comer', 'Como', 'Come', 'Comí', 'Comeré'],
  'ir': ['Ir', 'Voy', 'Va', 'Fui', 'Iré'],
  'hacer': ['Hacer', 'Hago', 'Hace', 'Hice', 'Haré'],
};

bool hasGrammarVariants(Pictogram pictogram) {
  return grammarVariants.containsKey(pictogram.id);
}

Future<void> showGrammarVariantsSheet(
  BuildContext context,
  Pictogram pictogram,
) async {
  final variants = grammarVariants[pictogram.id];
  if (variants == null) return;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pictogram.label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              ...variants.map(
                (variant) => ListTile(
                  title: Text(variant),
                  leading: const Icon(Icons.text_fields_outlined),
                  onTap: () {
                    context
                        .read<CommunicationProvider>()
                        .addVariant(pictogram, variant);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showCaregiverPictogramMenu(
  BuildContext context,
  Pictogram pictogram,
  {
    VoidCallback? onEdit,
  }
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final provider = sheetContext.watch<PictogramProvider>();
      final onBoard = provider.isOnBoard(pictogram.id);
      final availableFolders = provider.getFolderPictograms(
        excludingId: pictogram.id,
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(pictogram.label),
                subtitle: Text(
                  pictogram.isCustom
                      ? 'Pictograma personalizado'
                      : 'Pictograma incluido',
                ),
              ),
              if (hasGrammarVariants(pictogram))
                ListTile(
                  leading: const Icon(Icons.short_text_outlined),
                  title: const Text('Variantes gramaticales'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showGrammarVariantsSheet(context, pictogram);
                  },
                ),
              ListTile(
                leading: Icon(
                  onBoard
                      ? Icons.remove_from_queue_outlined
                      : Icons.dashboard_customize_outlined,
                ),
                title: Text(
                  onBoard ? 'Quitar del tablero' : 'Agregar al tablero',
                ),
                onTap: () {
                  final provider = context.read<PictogramProvider>();
                  if (onBoard) {
                    provider.removeFromBoard(pictogram.id);
                  } else {
                    provider.addToBoard(pictogram.id);
                  }
                  Navigator.of(sheetContext).pop();
                  if (onBoard) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${pictogram.label} quitado del tablero'),
                      ),
                    );
                  }
                },
              ),
              if (onBoard && !pictogram.isFolder)
                ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: const Text('Convertir en carpeta'),
                  onTap: () {
                    context.read<PictogramProvider>().convertToFolder(
                          pictogram.id,
                        );
                    Navigator.of(sheetContext).pop();
                  },
                ),
              if (availableFolders.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.drive_file_move_outline),
                  title: const Text('Agregar a carpeta'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showFolderPicker(context, pictogram);
                  },
                ),
              if (pictogram.parentFolderId != null)
                ListTile(
                  leading: const Icon(Icons.folder_off_outlined),
                  title: const Text('Quitar de esta carpeta'),
                  onTap: () {
                    context.read<PictogramProvider>().removeFromFolder(
                          pictogram.id,
                        );
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar foto o nombre'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  if (onEdit != null) {
                    onEdit();
                    return;
                  }
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => PictogramEditorScreen(
                        existingPictogram: pictogram,
                      ),
                    ),
                  );
                  if (!context.mounted || updated != true) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pictogram.label} actualizado'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  pictogram.favorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                ),
                title: Text(
                  pictogram.favorite
                      ? 'Quitar de favoritos'
                      : 'Marcar favorito',
                ),
                onTap: () {
                  context
                      .read<PictogramProvider>()
                      .toggleFavorite(pictogram.id);
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        pictogram.favorite
                            ? '${pictogram.label} quitado de favoritos'
                            : '${pictogram.label} marcado como favorito',
                      ),
                    ),
                  );
                },
              ),
              if (pictogram.isCustom)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Eliminar'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelete(context, pictogram);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showFolderPicker(
  BuildContext context,
  Pictogram pictogram,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final folders = sheetContext.watch<PictogramProvider>().getFolderPictograms(
            excludingId: pictogram.id,
          );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Agregar a carpeta'),
                subtitle: Text(pictogram.label),
              ),
              ...folders.map(
                (folder) => ListTile(
                  leading: const Icon(Icons.folder_rounded),
                  title: Text(folder.label),
                  onTap: () {
                    context.read<PictogramProvider>().addToFolder(
                          pictogram.id,
                          folder.id,
                        );
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _confirmDelete(BuildContext context, Pictogram pictogram) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar este pictograma?'),
        content: const Text(
          'Esta acción eliminará el pictograma personalizado de la aplicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (!context.mounted || confirmed != true) return;
  context.read<PictogramProvider>().deletePictogram(pictogram.id);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Pictograma eliminado')),
  );
}
