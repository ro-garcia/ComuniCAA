import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../../providers/communication_provider.dart';
import '../../providers/pictogram_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/message_bar.dart';
import '../../widgets/pictogram_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final results = context.watch<PictogramProvider>().search(_controller.text);

    return Column(
      children: [
        const MessageBar(forceVisible: true),
        _SearchCommandPanel(
          controller: _controller,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Resultados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _controller.text.trim().isEmpty
              ? const EmptyState(
                  message: 'Escribe una palabra para buscar pictogramas',
                  icon: Icons.search_outlined,
                )
              : results.isEmpty
                  ? const EmptyState(
                      message: 'No se encontraron pictogramas',
                      icon: Icons.manage_search_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final pictogram = results[index];
                        final category = categoryProvider.byId(
                          pictogram.categoryId,
                        );
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: SizedBox(
                              width: 64,
                              height: 64,
                              child: PictogramImage(pictogram: pictogram),
                            ),
                            title: Text(
                              pictogram.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(category.name),
                            trailing: Icon(
                              settings.isCaregiverMode
                                  ? Icons.dashboard_customize_outlined
                                  : Icons.add_circle_outline,
                            ),
                            onTap: () {
                              if (settings.isCaregiverMode) {
                                context
                                    .read<PictogramProvider>()
                                    .addToBoard(pictogram.id);
                                return;
                              } else {
                                context
                                    .read<CommunicationProvider>()
                                    .addPictogram(pictogram);
                              }
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _SearchCommandPanel extends StatelessWidget {
  const _SearchCommandPanel({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: false,
                textInputAction: TextInputAction.search,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Buscar palabra...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black87,
                  ),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar busqueda',
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            controller.clear();
                            onChanged();
                          },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: colors.primaryContainer,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 8),
            _QuickSearchAction(
              tooltip: 'Buscar palabra frecuente',
              icon: Icons.bolt_outlined,
              onPressed: () {
                controller.text = 'comer';
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSearchAction extends StatelessWidget {
  const _QuickSearchAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        color: colors.onPrimaryContainer,
        style: IconButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          minimumSize: const Size(52, 52),
        ),
      ),
    );
  }
}
