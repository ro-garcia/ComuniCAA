import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/pictogram.dart';
import '../../providers/communication_provider.dart';
import '../../providers/pictogram_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pictogram_audio_service.dart';
import '../../widgets/message_bar.dart';
import '../../widgets/pictogram_action_sheet.dart';
import '../../widgets/pictogram_grid.dart';

class CategoryPictogramsScreen extends StatelessWidget {
  const CategoryPictogramsScreen({
    super.key,
    required this.category,
  });

  final CaaCategory category;

  @override
  Widget build(BuildContext context) {
    final pictograms = context.watch<PictogramProvider>().getByCategory(
          category.id,
        );

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: Column(
        children: [
          const MessageBar(),
          Expanded(
            child: PictogramGrid(
              pictograms: pictograms,
              emptyMessage: 'No hay pictogramas en esta carpeta',
              onPictogramTap: (pictogram) => _handleTap(context, pictogram),
              onPictogramLongPress: (pictogram) =>
                  _handleLongPress(context, pictogram),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, Pictogram pictogram) async {
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
