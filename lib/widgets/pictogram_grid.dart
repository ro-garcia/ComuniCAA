import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pictogram.dart';
import '../providers/settings_provider.dart';
import 'empty_state.dart';
import 'pictogram_card.dart';

class PictogramGrid extends StatelessWidget {
  const PictogramGrid({
    super.key,
    required this.pictograms,
    required this.onPictogramTap,
    this.onPictogramLongPress,
    this.emptyMessage = 'No hay pictogramas disponibles',
  });

  final List<Pictogram> pictograms;
  final ValueChanged<Pictogram> onPictogramTap;
  final ValueChanged<Pictogram>? onPictogramLongPress;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (pictograms.isEmpty) {
      return EmptyState(message: emptyMessage);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = context.watch<SettingsProvider>();
        final columns = settings.gridColumnsForWidth(constraints.maxWidth);
        final spacing = settings.gridSpacing();

        return GridView.builder(
          padding: EdgeInsets.all(spacing),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: settings.pictogramCardAspectRatio(),
          ),
          itemCount: pictograms.length,
          itemBuilder: (context, index) {
            final pictogram = pictograms[index];
            return PictogramCard(
              pictogram: pictogram,
              onTap: () => onPictogramTap(pictogram),
              onLongPress: onPictogramLongPress == null
                  ? null
                  : () => onPictogramLongPress!(pictogram),
            );
          },
        );
      },
    );
  }
}
